import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class AyushmanScreen extends ConsumerStatefulWidget {
  const AyushmanScreen({super.key});

  @override
  ConsumerState<AyushmanScreen> createState() => _AyushmanScreenState();
}

class _AyushmanScreenState extends ConsumerState<AyushmanScreen> {
  final _incomeController = TextEditingController(text: '80000');
  final _ageController = TextEditingController(text: '45');
  String selectedCategory = 'BPL Ration Card';
  bool? isEligible;

  final List<String> categories = [
    'BPL Ration Card',
    'Antyodaya Anna Yojana (AAY)',
    'General Category',
  ];

  @override
  void dispose() {
    _incomeController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _checkEligibility() {
    final income = double.tryParse(_incomeController.text) ?? 100000;

    setState(() {
      if (selectedCategory == 'BPL Ration Card' || selectedCategory == 'Antyodaya Anna Yojana (AAY)' || income <= 250000) {
        isEligible = true;
      } else {
        isEligible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5), // Soft warm cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFEA580C), // Orange-600 (PM-JAY Gold/Orange)
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'ayushman_bharat'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scheme Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA580C)], // Rich Orange/Gold
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEA580C).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.security_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'PM-JAY Scheme Info',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Get free medical coverage up to ₹5,00,000 per family annually across all government & empanelled private hospitals.',
                      style: TextStyle(color: Color(0xFFEFEFEF), fontSize: 13, height: 1.45, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Eligibility Form
              Text(
                Translations.get(settings.language, 'eligibility_check').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Age
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: Translations.get(settings.language, 'age'),
                        prefixIcon: const Icon(Icons.face_rounded, color: Color(0xFFEA580C)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Income
                    TextFormField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: Translations.get(settings.language, 'income') + ' (₹)',
                        prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFFEA580C)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Ration Card
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Ration / Social Category',
                        prefixIcon: const Icon(Icons.assignment_rounded, color: Color(0xFFEA580C)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: _checkEligibility,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEA580C).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              Translations.get(settings.language, 'check_now'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Eligibility Result
              if (isEligible != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isEligible! ? AppTheme.successGreen : AppTheme.dangerRed,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isEligible! ? AppTheme.successGreen : AppTheme.dangerRed).withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: Icon(
                          isEligible! ? Icons.check_rounded : Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          isEligible!
                              ? Translations.get(settings.language, 'eligible')
                              : Translations.get(settings.language, 'not_eligible'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Info Section
              const Text(
                'HOW TO CLAIM BENEFITS / दावा प्रक्रिया',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildStepRow('1', 'Go to PHC/CHC or Empanelled Hospital', 'Meet at the PM-JAY registration desk.'),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildStepRow('2', 'Meet "Ayushman Mitra" at desk', 'Identify yourself using Aadhaar/Ration card verification.'),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildStepRow('3', 'Verifies biometric ID & starts care', 'Cashless medical billing is handled automatically.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF7ED),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFFEA580C),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


