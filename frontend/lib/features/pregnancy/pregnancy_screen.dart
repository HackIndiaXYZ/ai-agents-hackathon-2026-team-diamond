import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class PregnancyScreen extends ConsumerStatefulWidget {
  const PregnancyScreen({super.key});

  @override
  ConsumerState<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends ConsumerState<PregnancyScreen> {
  int currentWeek = 24;

  final List<Map<String, dynamic>> weeksData = [
    {
      'week': 12,
      'title': 'First Trimester - Scan Time',
      'babySize': 'Size of a Lemon 🍋',
      'tips': 'Ensure taking Folic Acid daily. Schedule first ultrasound scan with local ANM/ASHA worker.',
      'done': true,
    },
    {
      'week': 24,
      'title': 'Second Trimester - Growth Phase',
      'babySize': 'Size of a Corn 🌽',
      'tips': 'Check blood pressure & haemoglobin level. Test for gestational diabetes. Eat iron-rich spinach/dates.',
      'done': false,
    },
    {
      'week': 36,
      'title': 'Third Trimester - Delivery Prep',
      'babySize': 'Size of a Papaya 🍉',
      'tips': 'Prepare emergency transport details. Keep 108 ambulance contact active. Keep baby bag ready.',
      'done': false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F9), // Soft pink-tinted grey
      appBar: AppBar(
        backgroundColor: const Color(0xFFDB2777), // Pink-600
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'pregnancy_care'),
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
              // Maternal Card info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🤰', style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week $currentWeek of Pregnancy',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Baby status: Active and growing beautifully!',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Timeline Header
              const Text(
                'MATERNAL CARE TIMELINE / साप्ताहिक प्रगति',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Timeline List
              ...weeksData.map((data) {
                final isCurrent = data['week'] == currentWeek;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrent
                            ? const Color(0xFFEC4899).withOpacity(0.06)
                            : Colors.black.withOpacity(0.02),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFEC4899).withOpacity(0.4)
                          : const Color(0xFFE2E8F0),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFFFCE7F3) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'W${data['week']}',
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFFBE185D) : AppTheme.textLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: Text(
                      data['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: isCurrent ? const Color(0xFFBE185D) : AppTheme.primaryBlue,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Baby: ${data['babySize']}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFFE11D48)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['tips'] as String,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.4),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      data['done'] as bool ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: data['done'] as bool ? AppTheme.successGreen : Colors.grey.shade300,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),

              // Immunization Check card
              const Text(
                'REQUIRED TETANUS TOXOID VACCINES',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      activeColor: const Color(0xFFEC4899),
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      title: const Text(
                        'Td-1 (Tetanus Toxoid 1st Dose)',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryBlue),
                      ),
                      subtitle: const Text(
                        'Given in early pregnancy weeks / गर्भावस्था के शुरुआती हफ्तों में दी जाती है',
                        style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                      ),
                      value: true,
                      onChanged: (val) {},
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    CheckboxListTile(
                      activeColor: const Color(0xFFEC4899),
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      title: const Text(
                        'Td-2 (Tetanus Toxoid 2nd Dose)',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryBlue),
                      ),
                      subtitle: const Text(
                        'Given 4 weeks after 1st dose / पहली खुराक के 4 हफ्ते बाद दी जाती है',
                        style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                      ),
                      value: false,
                      onChanged: (val) {},
                    ),
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
}
