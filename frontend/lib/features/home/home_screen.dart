import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';
import '../../core/router/app_router.dart';
import '../family/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _makeCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _showVoiceAssist(BuildContext context, AppLanguage lang) {
    final texts = {
      AppLanguage.hi: 'नमस्ते! स्वास्थ्यAI में आपका स्वागत है। बीमारी जांचने के लिए आवाज बटन दबाएं।',
      AppLanguage.ta: 'வணக்கம்! SwasthyaAI-க்கு வரவேற்கிறோம். நோய் பரிசோதனைக்கு குரல் பொத்தானை அழுத்துங்கள்.',
      AppLanguage.te: 'నమస్తే! SwasthyaAI కి స్వాగతం. రోగ నిర్ధారణ కోసం మైక్ నొక్కండి.',
      AppLanguage.bn: 'নমস্কার! SwasthyaAI-তে স্বাগতম। রোগ পরীক্ষার জন্য মাইক্রোফোন বোতামটি টিপুন।',
      AppLanguage.mr: 'नमस्ते! SwasthyaAI मध्ये स्वागत आहे. आजार तपासणीसाठी मायक्रोफोन दाबा.',
      AppLanguage.en: 'Hello! Welcome to SwasthyaAI. Tap Voice Analysis to check your illness, or use the red SOS button for emergencies.',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.elevatedShadow,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF6366F1)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hearing_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Voice Guide', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ]),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.accentBlue.withOpacity(0.05),
                AppTheme.accentIndigo.withOpacity(0.05),
              ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentBlue.withOpacity(0.12)),
            ),
            child: Row(children: [
              const Icon(Icons.volume_up_rounded, color: AppTheme.accentBlue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texts[lang] ?? texts[AppLanguage.en]!,
                  style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          GradientButton(text: 'OK / ठीक है', onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  void _showProfileSelector(BuildContext context, WidgetRef ref) {
    final profiles = ref.read(familyProfilesProvider);
    final activeNotifier = ref.read(activeProfileIdProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(builder: (context, ref2, _) {
        final activeId = ref2.watch(activeProfileIdProvider);
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Family Members', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ]),
            const SizedBox(height: 4),
            Text('Switch active health profile', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
            const SizedBox(height: 16),
            ...profiles.map((profile) {
              final isActive = profile.id == activeId;
              final color = _relationColor(profile.relation);
              return GestureDetector(
                onTap: () { activeNotifier.selectProfile(profile.id); Navigator.pop(context); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? color.withOpacity(0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isActive ? color : Colors.grey.shade200, width: isActive ? 2 : 1),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: color,
                      child: Text(profile.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('${profile.relation} • ${profile.age} yrs', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                    ])),
                    if (isActive) Icon(Icons.check_circle_rounded, color: color, size: 22),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 8),
            GradientButton(
              text: 'Add Family Member',
              icon: Icons.person_add_rounded,
              onPressed: () { Navigator.pop(context); AppRouter.navigateTo(context, AppRouter.family); },
            ),
          ]),
        );
      }),
    );
  }

  void _showEmergencySOS(BuildContext context, AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.elevatedShadow,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)]),
              shape: BoxShape.circle,
              boxShadow: AppTheme.dangerGlow,
            ),
            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          const Text('Emergency SOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.dangerRed)),
          const SizedBox(height: 4),
          Text('Choose emergency contact', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
          const SizedBox(height: 20),
          _sosBtn('🚑  Ambulance (108)', () => _makeCall('108'), AppTheme.dangerRed),
          const SizedBox(height: 10),
          _sosBtn('📞  Health Helpline (102)', () => _makeCall('102'), AppTheme.warningYellow),
          const SizedBox(height: 10),
          _sosBtn('🏠  Call Family', () => _makeCall('9876543210'), AppTheme.accentBlue),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  static Widget _sosBtn(String label, VoidCallback onTap, Color color) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
            const Spacer(),
            Icon(Icons.call_rounded, color: color, size: 20),
          ]),
        ),
      ),
    );
  }

  Color _relationColor(String relation) {
    switch (relation.toLowerCase()) {
      case 'self':     return AppTheme.accentBlue;
      case 'spouse':   return const Color(0xFFEC4899);
      case 'father':
      case 'mother':   return AppTheme.warningYellow;
      case 'son':
      case 'daughter': return AppTheme.successGreen;
      default:         return AppTheme.textLight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final size = MediaQuery.of(context).size;

    if (activeProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final services = [
      {'title': Translations.get(settings.language, 'ai_symptom_analysis'),  'desc': Translations.get(settings.language, 'symptom_desc'),       'emoji': '🗣️', 'gradient': const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF6366F1)]), 'route': AppRouter.symptoms},
      {'title': Translations.get(settings.language, 'hospital_locator'),      'desc': Translations.get(settings.language, 'hospital_desc'),        'emoji': '🏥', 'gradient': const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]), 'route': AppRouter.hospitals},
      {'title': Translations.get(settings.language, 'medicine_reminders'),    'desc': Translations.get(settings.language, 'medicine_desc'),        'emoji': '💊', 'gradient': const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)]), 'route': AppRouter.reminders},
      {'title': Translations.get(settings.language, 'ocr_scanner'),           'desc': Translations.get(settings.language, 'ocr_desc'),             'emoji': '📷', 'gradient': const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]), 'route': AppRouter.ocr},
      {'title': Translations.get(settings.language, 'symptom_history'),       'desc': Translations.get(settings.language, 'symptom_history_desc'), 'emoji': '📋', 'gradient': const LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF0284C7)]), 'route': AppRouter.history},
      {'title': Translations.get(settings.language, 'family_dashboard'),      'desc': Translations.get(settings.language, 'family_desc'),          'emoji': '👥', 'gradient': const LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFEC4899)]), 'route': AppRouter.family},
      {'title': Translations.get(settings.language, 'ayushman_bharat'),       'desc': Translations.get(settings.language, 'ayushman_desc'),        'emoji': '📜', 'gradient': const LinearGradient(colors: [Color(0xFFB45309), Color(0xFFD97706)]), 'route': AppRouter.ayushman},
      {'title': Translations.get(settings.language, 'pregnancy_care'),        'desc': Translations.get(settings.language, 'pregnancy_desc'),       'emoji': '🤰', 'gradient': const LinearGradient(colors: [Color(0xFFBE185D), Color(0xFFDB2777)]), 'route': AppRouter.pregnancy},
      {'title': Translations.get(settings.language, 'vaccination_tracker'),   'desc': Translations.get(settings.language, 'vaccine_desc'),         'emoji': '💉', 'gradient': const LinearGradient(colors: [Color(0xFF4338CA), Color(0xFF6366F1)]), 'route': AppRouter.vaccine},
      {'title': Translations.get(settings.language, 'nutrition_guide'),       'desc': Translations.get(settings.language, 'nutrition_desc'),       'emoji': '🍉', 'gradient': const LinearGradient(colors: [Color(0xFF047857), Color(0xFF059669)]), 'route': AppRouter.nutrition},
      {'title': Translations.get(settings.language, 'outbreak_alerts'),       'desc': Translations.get(settings.language, 'outbreaks_desc'),       'emoji': '🚨', 'gradient': const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFF87171)]), 'route': AppRouter.alerts},
      {'title': Translations.get(settings.language, 'blood_donor'),           'desc': Translations.get(settings.language, 'donor_desc'),           'emoji': '🩸', 'gradient': const LinearGradient(colors: [Color(0xFF9F1239), Color(0xFFDC2626)]), 'route': AppRouter.donors},
    ];

    final scoreColor = activeProfile.score >= 80
        ? AppTheme.successGreen
        : activeProfile.score >= 60
            ? AppTheme.warningYellow
            : AppTheme.dangerRed;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: CustomScrollView(
            slivers: [
              // ── Hero App Bar ─────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppTheme.primaryBlue,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                    child: Stack(children: [
                      // Glow orb
                      Positioned(
                        top: -40, right: -40,
                        child: Container(
                          width: 200, height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              AppTheme.accentBlue.withOpacity(0.2), Colors.transparent,
                            ]),
                          ),
                        ),
                      ),
                      SafeArea(child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile row
                            GestureDetector(
                              onTap: () => _showProfileSelector(context, ref),
                              child: Row(children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: _relationColor(activeProfile.relation),
                                  child: Text(activeProfile.name[0],
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text(
                                        Translations.get(settings.language, 'welcome_back'),
                                        style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
                                      ),
                                      Text(activeProfile.name.split(' ')[0],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                                    ]),
                                    Text('${activeProfile.relation} • ${activeProfile.age} yrs  ▾',
                                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
                                  ],
                                )),
                                // Health Score badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: scoreColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: scoreColor.withOpacity(0.4)),
                                  ),
                                  child: Row(children: [
                                    Icon(Icons.favorite_rounded, color: scoreColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text('${activeProfile.score}%',
                                      style: TextStyle(color: scoreColor, fontWeight: FontWeight.w800, fontSize: 14)),
                                  ]),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 14),
                            // App title
                            ShaderMask(
                              shaderCallback: (b) => const LinearGradient(
                                colors: [Colors.white, Color(0xFFBAE6FD)],
                              ).createShader(b),
                              child: const Text('SwasthyaAI',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                                    color: Colors.white, letterSpacing: -1)),
                            ),
                            Text('Rural Health Assistant',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                          ],
                        ),
                      )),
                    ]),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.hearing_rounded,
                        color: settings.audioGuidance ? AppTheme.neonGreen : Colors.white54, size: 24),
                    onPressed: () => _showVoiceAssist(context, settings.language),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Colors.white70, size: 24),
                    onPressed: () => AppRouter.navigateTo(context, AppRouter.settings),
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              // ── Sticky content ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(children: [

                    // ── Emergency SOS ─────────────────────────────
                    GestureDetector(
                      onTap: () => _showEmergencySOS(context, settings.language),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.dangerGlow,
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(Translations.get(settings.language, 'emergency_sos'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                            const SizedBox(height: 2),
                            Text(Translations.get(settings.language, 'emergency_desc'),
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                          ])),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Offline Status pill ───────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.successGreen.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: AppTheme.neonGreen, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(Translations.get(settings.language, 'offline_status'),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.successGreen))),
                        const Text('100% Offline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.successGreen)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              // ── Services grid ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size.width < 400 ? 1 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: size.width < 400 ? 2.8 : 1.35,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = services[index];
                      final gradient = item['gradient'] as LinearGradient;
                      final baseColor = gradient.colors.first;

                      return GestureDetector(
                        onTap: () => AppRouter.navigateTo(context, item['route'] as String),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: baseColor.withOpacity(0.08),
                                blurRadius: 16, spreadRadius: 0, offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon bubble
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: baseColor.withOpacity(0.35),
                                        blurRadius: 10, offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(child: Text(item['emoji'] as String,
                                      style: const TextStyle(fontSize: 20))),
                                ),
                                // Title & desc
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(item['title'] as String,
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(item['desc'] as String,
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: services.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
