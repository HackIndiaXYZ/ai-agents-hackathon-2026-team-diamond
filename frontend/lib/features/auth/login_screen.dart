import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';
import '../../core/router/app_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  String phoneNumber = '';
  String otpCode = '';
  bool isOtpSent = false;
  bool isVerifying = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -8, end: 8),  weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 8, end: -6),  weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -6, end: 0),  weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String val) => setState(() {
    if (!isOtpSent) { if (phoneNumber.length < 10) phoneNumber += val; }
    else { if (otpCode.length < 6) otpCode += val; }
  });

  void _onBackspace() => setState(() {
    if (!isOtpSent) { if (phoneNumber.isNotEmpty) phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1); }
    else { if (otpCode.isNotEmpty) otpCode = otpCode.substring(0, otpCode.length - 1); }
  });

  void _sendOtp() {
    if (phoneNumber.length == 10) {
      setState(() { isVerifying = true; });
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() { isOtpSent = true; isVerifying = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
            Icon(Icons.sms_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('OTP Sent! Use 123456 to login.', style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(12),
        ));
      });
    }
  }

  void _verifyOtp() {
    if (otpCode == '123456') {
      setState(() { isVerifying = true; });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) AppRouter.replaceWith(context, AppRouter.home);
      });
    } else {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Invalid OTP. Enter 123456', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ));
    }
  }

  String _formatPhone(String num) {
    if (num.isEmpty) return '• • • • •  • • • • •';
    final padded = num.padRight(10, '•');
    return '${padded.substring(0, 5)}  ${padded.substring(5)}';
  }

  String _formatOtp(String code) {
    final padded = code.padRight(6, '•');
    return padded.split('').join('  ');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final size = MediaQuery.of(context).size;
    final isComplete = isOtpSent ? otpCode.length == 6 : phoneNumber.length == 10;

    return Scaffold(
      body: Stack(children: [
        // Background
        Container(decoration: const BoxDecoration(gradient: AppTheme.heroGradient)),

        // Top glow
        Positioned(
          top: -80, right: -60,
          child: Container(width: 250, height: 250, decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [AppTheme.accentBlue.withOpacity(0.3), Colors.transparent]),
          )),
        ),

        SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(children: [

            // Back button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
                  onPressed: () {
                    if (isOtpSent) {
                      setState(() { isOtpSent = false; otpCode = ''; });
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),

            Expanded(child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width < 400 ? 16 : 28),
              child: Column(children: [
                const SizedBox(height: 10),

                // Icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(isOtpSent),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOtpSent
                            ? [const Color(0xFF059669), const Color(0xFF10B981)]
                            : [const Color(0xFF3B82F6), const Color(0xFF6366F1)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: isOtpSent ? AppTheme.glowShadow : AppTheme.glowShadow,
                    ),
                    child: Icon(
                      isOtpSent ? Icons.lock_open_rounded : Icons.phone_android_rounded,
                      color: Colors.white, size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    key: ValueKey(isOtpSent),
                    isOtpSent
                        ? Translations.get(settings.language, 'verify_otp')
                        : Translations.get(settings.language, 'phone_number'),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isOtpSent
                      ? Translations.get(settings.language, 'enter_otp')
                      : Translations.get(settings.language, 'enter_phone'),
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Display Box
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    borderRadius: 22,
                    child: Column(children: [
                      Text(
                        isOtpSent ? _formatOtp(otpCode) : _formatPhone(phoneNumber),
                        style: TextStyle(
                          fontSize: isOtpSent ? 28 : 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isOtpSent ? 8 : 2,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Progress dots
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        ...List.generate(
                          isOtpSent ? 6 : 10,
                          (i) {
                            final filled = isOtpSent ? i < otpCode.length : i < phoneNumber.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: filled ? 18 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: filled ? AppTheme.neonGreen : Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                      ]),
                    ]),
                  ),
                ),

                if (isOtpSent) ...[
                  const SizedBox(height: 10),
                  Text('Hint: Use 1 2 3 4 5 6',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],

                const SizedBox(height: 20),

                // Action button
                if (isVerifying)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  AnimatedOpacity(
                    opacity: isComplete ? 1 : 0.45,
                    duration: const Duration(milliseconds: 200),
                    child: GradientButton(
                      text: isOtpSent
                          ? Translations.get(settings.language, 'verify_otp')
                          : Translations.get(settings.language, 'get_otp'),
                      icon: isOtpSent ? Icons.verified_rounded : Icons.send_rounded,
                      onPressed: () {
                        if (!isOtpSent && phoneNumber.length == 10) _sendOtp();
                        if (isOtpSent && otpCode.length == 6) _verifyOtp();
                      },
                      colors: isOtpSent
                          ? const [Color(0xFF059669), Color(0xFF10B981)]
                          : const [Color(0xFF3B82F6), Color(0xFF6366F1)],
                    ),
                  ),
                const SizedBox(height: 20),
              ]),
            )),

            // ── Numpad ───────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Column(children: [
                _numRow(['1', '2', '3']),
                const SizedBox(height: 8),
                _numRow(['4', '5', '6']),
                const SizedBox(height: 8),
                _numRow(['7', '8', '9']),
                const SizedBox(height: 8),
                Row(children: [
                  _specialKey(
                    child: const Icon(Icons.backspace_rounded, color: AppTheme.dangerRed, size: 22),
                    onTap: _onBackspace,
                    isDelete: true,
                  ),
                  const SizedBox(width: 8),
                  _numKey('0'),
                  const SizedBox(width: 8),
                  _specialKey(
                    child: Icon(
                      isOtpSent ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      color: isComplete ? Colors.white : Colors.white38,
                      size: 24,
                    ),
                    onTap: () {
                      if (!isOtpSent && phoneNumber.length == 10) _sendOtp();
                      else if (isOtpSent && otpCode.length == 6) _verifyOtp();
                    },
                    isAccept: isComplete,
                  ),
                ]),
              ]),
            ),
          ]),
        ))),
      ]),
    );
  }

  Row _numRow(List<String> keys) {
    return Row(children: [
      _numKey(keys[0]), const SizedBox(width: 8),
      _numKey(keys[1]), const SizedBox(width: 8),
      _numKey(keys[2]),
    ]);
  }

  Widget _numKey(String val) {
    return Expanded(child: GestureDetector(
      onTap: () => _onKeyPress(val),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Center(
          child: Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    ));
  }

  Widget _specialKey({required Widget child, required VoidCallback onTap, bool isDelete = false, bool isAccept = false}) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: isAccept
              ? const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)])
              : null,
          color: isAccept ? null : (isDelete ? AppTheme.dangerRed.withOpacity(0.1) : Colors.white.withOpacity(0.07)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isAccept ? AppTheme.successGreen : Colors.white.withOpacity(0.1)),
          boxShadow: isAccept ? AppTheme.glowShadow : [],
        ),
        child: Center(child: child),
      ),
    ));
  }
}
