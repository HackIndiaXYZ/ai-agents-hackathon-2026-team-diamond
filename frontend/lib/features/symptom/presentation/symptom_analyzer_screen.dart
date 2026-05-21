import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/translation_provider.dart';
import '../../../core/router/app_router.dart';
import 'symptom_provider.dart';

class SymptomAnalyzerScreen extends ConsumerStatefulWidget {
  const SymptomAnalyzerScreen({super.key});

  @override
  ConsumerState<SymptomAnalyzerScreen> createState() => _SymptomAnalyzerScreenState();
}

class _SymptomAnalyzerScreenState extends ConsumerState<SymptomAnalyzerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> presets = [
    {
      'label': '🚨 Chest Pain & Shortness of Breath (Red)',
      'query': 'Mujhe dil me dard ho raha hai aur saans lene me taklif hai.',
    },
    {
      'label': '🤒 Fever & Body Pain (Yellow)',
      'query': 'Do din se tej bukhar hai, sar dard aur badan me dard hai.',
    },
    {
      'label': '🤧 Mild Cough & Cold (Green)',
      'query': 'Halki khansi aur gale me kharash hai.',
    }
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _speakDiagnosis(DiagnosisLog log, AppLanguage lang) {
    String speakText = 'Diagnosis: ${log.diagnosis}. Urgency: ';
    if (log.triage == 'red') {
      speakText += 'Emergency! Go to hospital now. ';
    } else if (log.triage == 'yellow') {
      speakText += 'Caution. Visit clinic soon. ';
    } else {
      speakText += 'Safe. Follow home care. ';
    }
    speakText += 'Advice: ${log.advice}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF8FAFC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_rounded, color: AppTheme.accentBlue, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Audio Assist Playing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              Text(
                speakText,
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  minimumSize: const Size(120, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final analyzerState = ref.watch(symptomNotifierProvider);
    final notifier = ref.read(symptomNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              notifier.clear();
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          Translations.get(settings.language, 'ai_symptom_analysis'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Glowing header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentBlue.withOpacity(0.15),
                        AppTheme.primaryBlue.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology_rounded, color: AppTheme.accentBlue, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Translations.get(settings.language, 'speak_now'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Describe details like pain, duration, or fever',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pulsing Scan Container
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (analyzerState.isRecording) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(8, (index) {
                            return AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                final value = (_waveController.value + (index * 0.15)) % 1.0;
                                final height = 20.0 + (60.0 * (value > 0.5 ? 1.0 - value : value));
                                return Container(
                                  width: 8,
                                  height: height,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppTheme.accentBlue, AppTheme.accentBlue.withOpacity(0.4)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentBlue.withOpacity(0.3),
                                        blurRadius: 8,
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          Translations.get(settings.language, 'tap_stop'),
                          style: const TextStyle(
                            color: AppTheme.dangerRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ] else if (analyzerState.isAnalyzing) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          Translations.get(settings.language, 'analyzing_voice'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: () {
                            notifier.startRecording();
                            Future.delayed(const Duration(seconds: 2), () {
                              notifier.stopRecordingAndAnalyze(presets[1]['query']!);
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing Rings
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentBlue.withOpacity(0.08),
                                ),
                              ),
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentBlue.withOpacity(0.15),
                                ),
                              ),
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent,
                                      blurRadius: 16,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Icon(Icons.mic, color: Colors.white, size: 34),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Tap to Scan Symptoms',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Speak clearly in Hindi or English',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Presets & Fallback Text Input
                if (analyzerState.result == null && !analyzerState.isRecording && !analyzerState.isAnalyzing) ...[
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white10)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Quick Presets / तुरंत चयन',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white10)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...presets.map((preset) {
                    final isRed = preset['label']!.contains('Red');
                    final isYellow = preset['label']!.contains('Yellow');
                    final accentColor = isRed
                        ? AppTheme.dangerRed
                        : isYellow
                            ? AppTheme.warningYellow
                            : AppTheme.successGreen;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.play_arrow_rounded, color: accentColor, size: 18),
                        ),
                        title: Text(
                          preset['label']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            preset['query']!,
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ),
                        onTap: () {
                          notifier.stopRecordingAndAnalyze(preset['query']!);
                        },
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // Text fallback input
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Or type symptoms here...',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (_textController.text.isNotEmpty) {
                            notifier.stopRecordingAndAnalyze(_textController.text);
                            _textController.clear();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  )
                ],

                // Premium Triage Results Box
                if (analyzerState.result != null) ...[
                  _buildTriageResultBox(analyzerState.result!, settings.language),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Scan New Symptoms',
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      notifier.clear();
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      notifier.clear();
                      AppRouter.replaceWith(context, AppRouter.home);
                    },
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Text(
                        'Back to Main Menu',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTriageResultBox(DiagnosisLog log, AppLanguage lang) {
    Color themeColor;
    String triageTitle;
    IconData triageIcon;

    switch (log.triage) {
      case 'red':
        themeColor = AppTheme.dangerRed;
        triageTitle = Translations.get(lang, 'triage_red');
        triageIcon = Icons.report_problem_rounded;
        break;
      case 'yellow':
        themeColor = AppTheme.warningYellow;
        triageTitle = Translations.get(lang, 'triage_yellow');
        triageIcon = Icons.warning_rounded;
        break;
      case 'green':
      default:
        themeColor = AppTheme.successGreen;
        triageTitle = Translations.get(lang, 'triage_green');
        triageIcon = Icons.check_circle_rounded;
    }

    return Column(
      children: [
        // Urgency Card Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: themeColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(triageIcon, color: Colors.white, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATUS ASSESSMENT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      triageTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 24),
                onPressed: () => _speakDiagnosis(log, lang),
              )
            ],
          ),
        ),

        // Diagnosis Content Body
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR INPUT / आपके लक्षण',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppTheme.textMuted, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                '"${log.symptoms}"',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14, color: AppTheme.textLight, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              const Text(
                'AI ASSESSMENT / एआई निदान',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppTheme.textMuted, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                log.diagnosis,
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              // Specialist recommendation
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: AppTheme.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RECOMMENDED SPECIALIST',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log.doctorType,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryBlue, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              Text(
                Translations.get(lang, 'ai_recommendations').toUpperCase() + ' / उपचार एवं सलाह',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppTheme.textMuted, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Text(
                  log.advice,
                  style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                ),
              ),

              // Call to Action
              if (log.triage == 'red' || log.triage == 'yellow') ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    AppRouter.replaceWith(context, AppRouter.hospitals);
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: log.triage == 'red' ? AppTheme.dangerRed : AppTheme.accentBlue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (log.triage == 'red' ? AppTheme.dangerRed : AppTheme.accentBlue).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Find Nearest Hospital',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ],
    );
  }
}
