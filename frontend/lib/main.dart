import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/database/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/translation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: SwasthyaApp()));
}

class SwasthyaApp extends ConsumerWidget {
  const SwasthyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = AppTheme.getTheme(settings.fontSize);

    // Override font family with Inter from Google Fonts
    final textTheme = GoogleFonts.interTextTheme(theme.textTheme);

    return MaterialApp(
      title: 'SwasthyaAI – Rural Health Assistant',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(textTheme: textTheme),
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}
