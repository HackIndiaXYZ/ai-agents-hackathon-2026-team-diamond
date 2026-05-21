import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class VaccineScreen extends ConsumerStatefulWidget {
  const VaccineScreen({super.key});

  @override
  ConsumerState<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends ConsumerState<VaccineScreen> {
  final List<Map<String, dynamic>> vaccines = [
    {
      'name': 'BCG (Tuberculosis)',
      'due': 'At Birth / जन्म के समय',
      'desc': 'Protects against severe tuberculosis in children.',
      'status': true,
    },
    {
      'name': 'OPV 1, 2, 3 (Oral Polio Vaccine)',
      'due': '6, 10, 14 Weeks',
      'desc': 'Essential drops for lifetime polio immunity.',
      'status': true,
    },
    {
      'name': 'Pentavalent 1, 2, 3 (DPT + HepB + Hib)',
      'due': '6, 10, 14 Weeks',
      'desc': 'Combats Diphtheria, Pertussis, Tetanus, Hepatitis B, and Influenza.',
      'status': false,
    },
    {
      'name': 'MR 1st Dose (Measles & Rubella)',
      'due': '9 - 12 Months',
      'desc': 'Guards against viral rashes and high-fever measles.',
      'status': false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final completedCount = vaccines.where((v) => v['status'] == true).length;
    final totalCount = vaccines.length;
    final progressPercent = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'vaccination_tracker'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header stats banner
            Container(
              color: AppTheme.primaryBlue,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    // Percentage Gauge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: progressPercent,
                            strokeWidth: 6,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
                          ),
                        ),
                        Text(
                          '${(progressPercent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NATIONAL IMMUNIZATION PROGRAM',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white54,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Universal Immunization Schedule',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completed: $completedCount of $totalCount vaccines tracking',
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Help info card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: const [
                    Text('👶', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keep track of child immunization schedules. Present this status to your local ASHA health worker during routine monthly visits.',
                        style: TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // List of Vaccines
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: vaccines.length,
                itemBuilder: (context, index) {
                  final v = vaccines[index];
                  final isDone = v['status'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                      border: Border.all(
                        color: isDone ? AppTheme.successGreen.withOpacity(0.2) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: CheckboxListTile(
                      activeColor: AppTheme.successGreen,
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      value: isDone,
                      onChanged: (val) {
                        setState(() {
                          vaccines[index]['status'] = val;
                        });
                      },
                      title: Text(
                        v['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Due: ${v['due']}',
                                style: const TextStyle(
                                  color: AppTheme.accentBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              v['desc'] as String,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.3),
                            ),
                          ],
                        ),
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
