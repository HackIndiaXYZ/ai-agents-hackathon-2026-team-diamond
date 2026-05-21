import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

// ─── Data Model ──────────────────────────────────────────────────────────────
class NearbyHospital {
  final String id;
  final String name;
  final String type;
  final double lat;
  final double lon;
  final double distance; // km
  final String? phone;
  final String? address;

  const NearbyHospital({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    required this.distance,
    this.phone,
    this.address,
  });

  int get estimatedMinutes => max(1, (distance * 12).round());

  factory NearbyHospital.fromOverpassElement(Map<String, dynamic> el, double userLat, double userLon) {
    final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? {};
    final lat = (el['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (el['lon'] as num?)?.toDouble() ?? 0.0;
    final dist = _haversine(userLat, userLon, lat, lon);

    final amenity = tags['amenity'] as String? ?? '';
    String type = 'Hospital';
    if (amenity == 'clinic')         type = 'Clinic';
    if (amenity == 'doctors')        type = 'Doctor';
    if (amenity == 'pharmacy')       type = 'Pharmacy';
    if (amenity == 'health_centre' || amenity == 'health_center') type = 'Health Centre';

    return NearbyHospital(
      id: '${el['id']}',
      name: (tags['name'] as String?)?.trim().isNotEmpty == true
          ? tags['name'] as String
          : 'Unnamed ${type}',
      type: type,
      lat: lat,
      lon: lon,
      distance: dist,
      phone: tags['phone'] as String? ?? tags['contact:phone'] as String?,
      address: _buildAddress(tags),
    );
  }

  static String? _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:street'] != null) parts.add(tags['addr:street'] as String);
    if (tags['addr:city'] != null) parts.add(tags['addr:city'] as String);
    if (tags['addr:state'] != null) parts.add(tags['addr:state'] as String);
    return parts.isEmpty ? null : parts.join(', ');
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _deg2rad(double d) => d * pi / 180;
}

// ─── Provider State ───────────────────────────────────────────────────────────
enum HospitalLoadState { idle, locating, loading, done, error }

class HospitalState {
  final HospitalLoadState status;
  final List<NearbyHospital> hospitals;
  final double? userLat;
  final double? userLon;
  final String? errorMessage;

  const HospitalState({
    this.status = HospitalLoadState.idle,
    this.hospitals = const [],
    this.userLat,
    this.userLon,
    this.errorMessage,
  });

  HospitalState copyWith({
    HospitalLoadState? status,
    List<NearbyHospital>? hospitals,
    double? userLat,
    double? userLon,
    String? errorMessage,
  }) => HospitalState(
    status: status ?? this.status,
    hospitals: hospitals ?? this.hospitals,
    userLat: userLat ?? this.userLat,
    userLon: userLon ?? this.userLon,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class HospitalNotifier extends StateNotifier<HospitalState> {
  HospitalNotifier() : super(const HospitalState());

  Future<void> fetchNearby() async {
    state = state.copyWith(status: HospitalLoadState.locating, errorMessage: null);

    double lat = 28.8045; // Default fallback (Rampur block)
    double lon = 79.0286;

    try {
      // ── Get GPS location ──────────────────────────────────────────
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }

        if (perm != LocationPermission.denied && perm != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
          lat = pos.latitude;
          lon = pos.longitude;
        }
      }
    } catch (e) {
      // Graceful fallback for MissingPluginException on Web or lack of permission
      debugPrint('Geolocator failed: $e. Using default coordinates.');
    }

    state = state.copyWith(status: HospitalLoadState.loading, userLat: lat, userLon: lon);

    try {
      // ── Query OpenStreetMap Overpass API ──────────────────────────
      const radius = 20000; // 20 km for broader coverage
      final query = '''
[out:json][timeout:25];
(
  node["amenity"~"hospital|clinic|doctors|health_centre|health_center|pharmacy"](around:$radius,$lat,$lon);
  way["amenity"~"hospital|clinic|doctors|health_centre|health_center|pharmacy"](around:$radius,$lat,$lon);
);
out center tags;
''';

      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Overpass API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List?) ?? [];

      final results = elements
          .map((el) {
            try {
              // For ways, use the center point
              Map<String, dynamic> elem = el as Map<String, dynamic>;
              if (elem['type'] == 'way' && elem['center'] != null) {
                final center = elem['center'] as Map;
                elem = {...elem, 'lat': center['lat'], 'lon': center['lon']};
              }
              return NearbyHospital.fromOverpassElement(elem, lat, lon);
            } catch (_) {
              return null;
            }
          })
          .whereType<NearbyHospital>()
          .where((h) => h.name != 'Unnamed Hospital' || h.distance < 2)
          .toList()
        ..sort((a, b) => a.distance.compareTo(b.distance));

      state = state.copyWith(
        status: HospitalLoadState.done,
        hospitals: results.toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: HospitalLoadState.error,
        errorMessage: 'Could not fetch hospitals: ${e.toString().split(':').first}',
      );
    }
  }
}

final hospitalProvider = StateNotifierProvider<HospitalNotifier, HospitalState>(
  (_) => HospitalNotifier(),
);

// ─── Screen ───────────────────────────────────────────────────────────────────
class HospitalLocatorScreen extends ConsumerStatefulWidget {
  const HospitalLocatorScreen({super.key});

  @override
  ConsumerState<HospitalLocatorScreen> createState() => _HospitalLocatorScreenState();
}

class _HospitalLocatorScreenState extends ConsumerState<HospitalLocatorScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hospitalProvider.notifier).fetchNearby();
    });
  }

  Future<void> _openGoogleMaps(NearbyHospital h) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${h.lat},${h.lon}&query_place_id=${Uri.encodeComponent(h.name)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDirections(NearbyHospital h, double? uLat, double? uLon) async {
    String url;
    if (uLat != null && uLon != null) {
      url = 'https://www.google.com/maps/dir/$uLat,$uLon/${h.lat},${h.lon}';
    } else {
      url = 'https://www.google.com/maps/dir/?api=1&destination=${h.lat},${h.lon}';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final hospitalState = ref.watch(hospitalProvider);

    final filtered = hospitalState.hospitals.where((h) {
      final matchesType = selectedFilter == 'All' || h.type == selectedFilter;
      final matchesSearch = searchQuery.isEmpty || h.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(Translations.get(settings.language, 'hospital_locator'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white)),
          if (hospitalState.userLat != null)
            Text(
              'Near ${hospitalState.userLat!.toStringAsFixed(4)}°, ${hospitalState.userLon!.toStringAsFixed(4)}°',
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.read(hospitalProvider.notifier).fetchNearby(),
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: Column(children: [
        // ── Status bar ──────────────────────────────────────────────────
        _buildStatusBar(hospitalState),

        // ── Search bar ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search hospitals...',
              prefixIcon: Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) => setState(() => searchQuery = val),
          ),
        ),

        // ── Filter chips ────────────────────────────────────────────────
        if (hospitalState.status == HospitalLoadState.done && hospitalState.hospitals.isNotEmpty)
          _buildFilterBar(),

        // ── Content ─────────────────────────────────────────────────────
        Expanded(child: _buildContent(hospitalState, filtered, settings)),
      ]),
    );
  }

  Widget _buildStatusBar(HospitalState s) {
    if (s.status == HospitalLoadState.locating) {
      return _infoBar(Icons.gps_fixed_rounded, 'Getting your location...', AppTheme.accentBlue);
    }
    if (s.status == HospitalLoadState.loading) {
      return _infoBar(Icons.search_rounded, 'Searching nearby hospitals...', AppTheme.warningYellow);
    }
    if (s.status == HospitalLoadState.done) {
      return _infoBar(
        Icons.check_circle_rounded,
        '${s.hospitals.length} facilities found within 5 km',
        AppTheme.successGreen,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _infoBar(IconData icon, String text, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))),
        SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: color,
            value: [HospitalLoadState.done, HospitalLoadState.error].contains(
              ref.read(hospitalProvider).status) ? 1 : null,
          ),
        ),
      ]),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Hospital', 'Clinic', 'Health Centre', 'Pharmacy', 'Doctor'];
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        children: filters.map((f) {
          final isSelected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f, style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
              )),
              selected: isSelected,
              selectedColor: AppTheme.accentBlue,
              backgroundColor: const Color(0xFFF0F4FF),
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              onSelected: (_) => setState(() => selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(HospitalState s, List<NearbyHospital> filtered, AppSettings settings) {
    // Loading
    if (s.status == HospitalLoadState.locating || s.status == HospitalLoadState.loading) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
          ),
          child: const CircularProgressIndicator(strokeWidth: 3, color: AppTheme.accentBlue),
        ),
        const SizedBox(height: 20),
        Text(
          s.status == HospitalLoadState.locating ? 'Detecting your location...' : 'Finding hospitals nearby...',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textLight),
        ),
      ]));
    }

    // Error
    if (s.status == HospitalLoadState.error) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.dangerRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_off_rounded, color: AppTheme.dangerRed, size: 40),
          ),
          const SizedBox(height: 20),
          Text('Location Error', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            s.errorMessage ?? 'Unknown error',
            style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Try Again',
            icon: Icons.refresh_rounded,
            onPressed: () => ref.read(hospitalProvider.notifier).fetchNearby(),
          ),
        ]),
      ));
    }

    // Empty
    if (filtered.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.local_hospital_outlined, size: 60, color: AppTheme.textMuted),
        const SizedBox(height: 16),
        const Text('No facilities found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 6),
        Text('Try selecting a different category', style: const TextStyle(color: AppTheme.textLight)),
      ]));
    }

    // Results
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildHospitalCard(filtered[index], s),
    );
  }

  Widget _buildHospitalCard(NearbyHospital h, HospitalState s) {
    final typeColor = _typeColor(h.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: typeColor.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header row ──────────────────────────────────────────────
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon(h.type), color: typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryBlue)),
              const SizedBox(height: 4),
              Row(children: [
                _typeTag(h.type, typeColor),
                const SizedBox(width: 8),
                Icon(Icons.near_me_rounded, size: 12, color: AppTheme.textLight),
                const SizedBox(width: 3),
                Text('${h.distance.toStringAsFixed(1)} km  •  ~${h.estimatedMinutes} min',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
              ]),
            ])),
          ]),

          // ── Address ─────────────────────────────────────────────────
          if (h.address != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.place_rounded, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(child: Text(h.address!, style: const TextStyle(fontSize: 12, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // ── Action buttons ──────────────────────────────────────────
          Row(children: [
            // Call
            if (h.phone != null)
              Expanded(child: _actionBtn(
                icon: Icons.call_rounded,
                label: 'Call',
                color: AppTheme.successGreen,
                onTap: () => _callPhone(h.phone!),
              )),
            if (h.phone != null) const SizedBox(width: 8),

            // Directions on Google Maps
            Expanded(child: _actionBtn(
              icon: Icons.directions_rounded,
              label: 'Directions',
              color: AppTheme.accentBlue,
              onTap: () => _openDirections(h, s.userLat, s.userLon),
            )),
            const SizedBox(width: 8),

            // View on Google Maps
            Expanded(child: _actionBtn(
              icon: Icons.map_rounded,
              label: 'Google Map',
              color: const Color(0xFFEA4335), // Google red
              onTap: () => _openGoogleMaps(h),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _typeTag(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Hospital':      return const Color(0xFF3B82F6);
      case 'Clinic':        return const Color(0xFF10B981);
      case 'Health Centre': return const Color(0xFF8B5CF6);
      case 'Pharmacy':      return const Color(0xFFF59E0B);
      case 'Doctor':        return const Color(0xFF06B6D4);
      default:              return AppTheme.accentBlue;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Hospital':      return Icons.local_hospital_rounded;
      case 'Clinic':        return Icons.medical_services_rounded;
      case 'Health Centre': return Icons.health_and_safety_rounded;
      case 'Pharmacy':      return Icons.medication_rounded;
      case 'Doctor':        return Icons.person_rounded;
      default:              return Icons.local_hospital_rounded;
    }
  }
}
