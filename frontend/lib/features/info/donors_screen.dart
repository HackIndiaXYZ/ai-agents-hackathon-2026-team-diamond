import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class DonorsScreen extends ConsumerStatefulWidget {
  const DonorsScreen({super.key});

  @override
  ConsumerState<DonorsScreen> createState() => _DonorsScreenState();
}

class _DonorsScreenState extends ConsumerState<DonorsScreen> {
  String selectedBloodGroup = 'All';

  final List<Map<String, dynamic>> donors = [
    {
      'name': 'Amit Verma',
      'group': 'A+',
      'distance': 1.8,
      'contact': '9876543212',
      'available': true,
    },
    {
      'name': 'Rajesh Sharma',
      'group': 'B+',
      'distance': 3.2,
      'contact': '9876543213',
      'available': true,
    },
    {
      'name': 'Sunita Yadav',
      'group': 'O+',
      'distance': 0.9,
      'contact': '9876543214',
      'available': true,
    },
    {
      'name': 'Vikram Singh',
      'group': 'AB+',
      'distance': 4.1,
      'contact': '9876543215',
      'available': false,
    },
    {
      'name': 'Priya Das',
      'group': 'O-',
      'distance': 5.0,
      'contact': '9876543216',
      'available': true,
    }
  ];

  Future<void> _makeCall(String num) async {
    final Uri url = Uri(scheme: 'tel', path: num);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendSms(String num, String group) async {
    final Uri url = Uri(
      scheme: 'sms',
      path: num,
      queryParameters: {'body': 'Urgent: Blood request for group $group. Please contact immediately.'},
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    final filteredDonors = donors.where((d) {
      if (selectedBloodGroup == 'All') return true;
      return d['group'] == selectedBloodGroup;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8), // Subtle red-white tint
      appBar: AppBar(
        backgroundColor: AppTheme.dangerRed,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'blood_donor'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter blood chips
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: ['All', 'A+', 'B+', 'O+', 'O-', 'AB+'].map((group) {
                  final isSelected = selectedBloodGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        group,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppTheme.dangerRed,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.dangerRed,
                      backgroundColor: const Color(0xFFFFF1F2),
                      checkmarkColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      onSelected: (val) {
                        setState(() {
                          selectedBloodGroup = group;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Help instruction card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Row(
                  children: const [
                    Text('🩸', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Direct blood donor directory. In case of medical emergencies, contact available voluntary donors nearest to your location.',
                        style: TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Donor List
            Expanded(
              child: filteredDonors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🩸', style: TextStyle(fontSize: 44)),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'No Donors Found',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.dangerRed),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: filteredDonors.length,
                      itemBuilder: (context, index) {
                        final d = filteredDonors[index];
                        final isAvailable = d['available'] as bool;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              )
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Blood Drop Circle
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      d['group'] as String,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d['name'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryBlue),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${d['distance']} km away  •  Rural Area',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: isAvailable ? AppTheme.successGreen : Colors.grey.shade400,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isAvailable ? 'Available Now' : 'Recently Donated',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: isAvailable ? AppTheme.successGreen : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),

                                // Actions
                                if (isAvailable) ...[
                                  _pillActionBtn(
                                    icon: Icons.message_rounded,
                                    color: AppTheme.accentBlue,
                                    onTap: () => _sendSms(d['contact'] as String, d['group'] as String),
                                  ),
                                  const SizedBox(width: 8),
                                  _pillActionBtn(
                                    icon: Icons.phone_rounded,
                                    color: AppTheme.successGreen,
                                    onTap: () => _makeCall(d['contact'] as String),
                                  )
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillActionBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
