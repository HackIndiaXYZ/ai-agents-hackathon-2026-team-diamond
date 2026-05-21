import 'package:flutter/material.dart';
import 'dart:ui';

enum AppFontSize { normal, large, extraLarge }

class AppTheme {
  // ─── Core Brand Palette ───────────────────────────────────────────────────
  static const Color primaryBlue    = Color(0xFF0A0F1E); // Deep Navy
  static const Color accentBlue     = Color(0xFF3B82F6); // Vivid Blue
  static const Color accentIndigo   = Color(0xFF6366F1); // Indigo
  static const Color successGreen   = Color(0xFF10B981); // Emerald
  static const Color warningYellow  = Color(0xFFF59E0B); // Amber
  static const Color dangerRed      = Color(0xFFEF4444); // Red
  static const Color neonGreen      = Color(0xFF00FFB2); // Neon accent

  static const Color bgLight        = Color(0xFFF0F4FF); // Soft blue-tinted bg
  static const Color bgDark         = Color(0xFF060B18); // Deep dark bg
  static const Color cardBg         = Color(0xFFFFFFFF);
  static const Color textDark       = Color(0xFF0F172A);
  static const Color textLight      = Color(0xFF64748B);
  static const Color textMuted      = Color(0xFF94A3B8);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A0F1E), Color(0xFF0D1B4B), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF3B82F6).withOpacity(0.08),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: const Color(0xFF3B82F6).withOpacity(0.35),
      blurRadius: 32,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get dangerGlow => [
    BoxShadow(
      color: const Color(0xFFEF4444).withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Font Size ────────────────────────────────────────────────────────────
  static double getFontSizeMultiplier(AppFontSize size) {
    switch (size) {
      case AppFontSize.normal:     return 1.0;
      case AppFontSize.large:      return 1.2;
      case AppFontSize.extraLarge: return 1.45;
    }
  }

  static TextTheme getTextTheme(AppFontSize fontSizeSetting) {
    final s = getFontSizeMultiplier(fontSizeSetting);
    return TextTheme(
      displayLarge:  TextStyle(fontSize: 36 * s, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1.5),
      displayMedium: TextStyle(fontSize: 28 * s, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -1),
      displaySmall:  TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w700, color: textDark, letterSpacing: -0.5),
      headlineMedium:TextStyle(fontSize: 18 * s, fontWeight: FontWeight.w700, color: textDark),
      titleLarge:    TextStyle(fontSize: 17 * s, fontWeight: FontWeight.w600, color: textDark),
      titleMedium:   TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w600, color: textDark),
      bodyLarge:     TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w400, color: textDark),
      bodyMedium:    TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w400, color: textLight),
      labelLarge:    TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
      labelSmall:    TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w600, color: textMuted),
    );
  }

  static ThemeData getTheme(AppFontSize fontSizeSetting) {
    final t = getTextTheme(fontSizeSetting);
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentBlue,
        primary: accentBlue,
        secondary: accentIndigo,
        error: dangerRed,
        surface: cardBg,
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: t,
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: t.labelLarge,
          elevation: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: t.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─── Responsive Layout Wrapper ────────────────────────────────────────────────
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// ─── Glassmorphism Card ───────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? tint;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.tint,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (tint ?? Colors.white).withOpacity(0.12),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> colors;
  final IconData? icon;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.colors = const [Color(0xFF3B82F6), Color(0xFF6366F1)],
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Color Utilities ──────────────────────────────────────────────────────────
extension ColorDarken on Color {
  Color darken([double amount = 0.3]) {
    final hsv = HSVColor.fromColor(this);
    return hsv.withValue((hsv.value - amount).clamp(0.0, 1.0)).toColor();
  }

  Color lighten([double amount = 0.3]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
