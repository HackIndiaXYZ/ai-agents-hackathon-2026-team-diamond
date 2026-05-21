import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class OutbreaksScreen extends ConsumerWidget {
  const OutbreaksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final alerts = [
      {
        'disease': 'Malaria Alert (मलेरिया चेतावनी)',
        'location': 'Rampur Block & surrounding villages',
        'severity': 'yellow',
        'cases': '14 cases reported this week',
        'action': 'Use mosquito nets while sleeping. Clear stagnant water around home pits. Spray oil or larvicide in open drains.',
      },
      {
        'disease': 'Dengue Outbreak (डेंगू प्रकोप)',
        'location': 'Ward 5 General Town',
        'severity': 'red',
        'cases': '32 active cases reported',
        'action': 'High risk during daytime mosquito bites. Wear full-sleeved clothes. Report fever with joint pains immediately to PHC.',
      },
      {
        'disease': 'Heatwave Warning (लू की चेतावनी)',
        'location': 'District-wide advisory',
        'severity': 'yellow',
        'cases': 'Temperature exceeding 44°C',
        'action': 'Avoid outdoor work between 12 PM - 3 PM. Drink ORS/Jaljeera water frequently. Keep cattle under cool sheds.',
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm soft off-white
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF4444), // Crimson/Red
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'outbreak_alerts'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Alert Bulletin Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Public Health Advisories',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Local advisories verified by block medical officers. Stay alert and follow precautions.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Outbreaks list
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final al = alerts[index];
                  final isRed = al['severity'] == 'red';
                  final severityColor = isRed ? const Color(0xFFEF4444) : const Color(0xFFD97706);
                  final cardBgColor = isRed ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: severityColor.withOpacity(0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: severityColor.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  al['disease']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: severityColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  isRed ? 'HIGH RISK' : 'MONITOR',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: severityColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Location & Stats
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.textLight),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        al['location']!,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.primaryBlue),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.bar_chart_rounded, size: 16, color: AppTheme.textLight),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        al['cases']!,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Precautionary action steps
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.gpp_good_rounded, color: severityColor, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SAFETY PRECAUTIONS / बचाव के उपाय',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                        color: severityColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  al['action']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: severityColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          )
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
}
