import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';
import '../../core/router/app_router.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  final languages = [
    {'code': AppLanguage.hi, 'native': 'हिन्दी',  'english': 'Hindi',   'flag': '🇮🇳', 'color': const Color(0xFFFF6B35)},
    {'code': AppLanguage.en, 'native': 'English',  'english': 'English',  'flag': '🌐', 'color': const Color(0xFF3B82F6)},
    {'code': AppLanguage.ta, 'native': 'தமிழ்',   'english': 'Tamil',   'flag': '🇮🇳', 'color': const Color(0xFF10B981)},
    {'code': AppLanguage.te, 'native': 'తెలుగు',  'english': 'Telugu',  'flag': '🇮🇳', 'color': const Color(0xFF8B5CF6)},
    {'code': AppLanguage.bn, 'native': 'বাংলা',   'english': 'Bengali', 'flag': '🇮🇳', 'color': const Color(0xFFF59E0B)},
    {'code': AppLanguage.mr, 'native': 'मराठी',   'english': 'Marathi', 'flag': '🇮🇳', 'color': const Color(0xFFEC4899)},
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated background ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          ),

          // Floating orbs
          Positioned(
            top: -100, right: -80,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 320, height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFF3B82F6).withOpacity(0.25),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60, left: -60,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) => Transform.scale(
                scale: 2.0 - _pulseAnimation.value,
                child: Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFF6366F1).withOpacity(0.2),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width < 400 ? 16 : 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // ── Logo ──────────────────────────────────
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, _) => Transform.scale(
                            scale: _pulseAnimation.value * 0.97,
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: AppTheme.glowShadow,
                              ),
                              child: const Icon(Icons.health_and_safety_rounded,
                                  color: Colors.white, size: 42),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── App name ──────────────────────────────
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFBAE6FD)],
                          ).createShader(b),
                          child: const Text(
                            'SwasthyaAI',
                            style: TextStyle(
                              fontSize: 34, fontWeight: FontWeight.w900,
                              color: Colors.white, letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rural Health Assistant • ग्रामीण स्वास्थ्य',
                          style: TextStyle(
                            fontSize: 13, color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500, letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // ── Language prompt card ──────────────────
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.record_voice_over_rounded,
                                    color: AppTheme.neonGreen, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Translations.get(settings.language, 'language_select'),
                                      style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Select your preferred language below',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.55),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Language grid ─────────────────────────
                        Expanded(
                          child: GridView.builder(
                            itemCount: languages.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: size.width < 350 ? 1 : 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.6,
                            ),
                            itemBuilder: (context, index) {
                              final lang = languages[index];
                              final isSelected = settings.language == lang['code'];
                              final color = lang['color'] as Color;

                              return GestureDetector(
                                onTap: () {
                                  notifier.setLanguage(lang['code'] as AppLanguage);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Row(children: [
                                      const Icon(Icons.volume_up, color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Text('${lang['native']} selected'),
                                    ]),
                                    duration: const Duration(milliseconds: 600),
                                    backgroundColor: color,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ));
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected ? color : Colors.white.withOpacity(0.12),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))]
                                        : [],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Text(lang['flag'] as String,
                                            style: const TextStyle(fontSize: 24)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                lang['native'] as String,
                                                style: TextStyle(
                                                  fontSize: 18, fontWeight: FontWeight.w800,
                                                  color: isSelected ? color : Colors.white,
                                                ),
                                              ),
                                              Text(
                                                lang['english'] as String,
                                                style: TextStyle(
                                                  fontSize: 12, fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? color.withOpacity(0.8)
                                                      : Colors.white.withOpacity(0.45),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            width: 22, height: 22,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check, color: Colors.white, size: 14),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Audio toggle row ──────────────────────
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                settings.audioGuidance ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                color: settings.audioGuidance ? AppTheme.neonGreen : Colors.white38,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  Translations.get(settings.language, 'audio_assist'),
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Switch(
                                value: settings.audioGuidance,
                                onChanged: (val) => ref.read(settingsProvider.notifier).setAudioGuidance(val),
                                activeColor: AppTheme.neonGreen,
                                trackColor: WidgetStateProperty.resolveWith(
                                  (s) => s.contains(WidgetState.selected)
                                      ? AppTheme.neonGreen.withOpacity(0.3)
                                      : Colors.white12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── CTA Button ────────────────────────────
                        GradientButton(
                          text: Translations.get(settings.language, 'login'),
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => AppRouter.replaceWith(context, AppRouter.login),
                          colors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
