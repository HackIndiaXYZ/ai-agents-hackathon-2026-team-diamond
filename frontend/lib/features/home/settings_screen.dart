import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _triggerSync(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Simulate 2 seconds of sync progress
            Future.delayed(const Duration(milliseconds: 2000), () {
              Navigator.pop(context); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offline data synced successfully to government servers!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            });

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Syncing offline health history & logs...', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Uploading encrypt reports safely.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final textTheme = AppTheme.getTextTheme(settings.fontSize);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get(settings.language, 'settings')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Language Selection
            Text(
              Translations.get(settings.language, 'language_select'),
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppLanguage>(
                    value: settings.language,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: AppLanguage.en, child: Text('English (English)')),
                      DropdownMenuItem(value: AppLanguage.hi, child: Text('हिन्दी (Hindi)')),
                      DropdownMenuItem(value: AppLanguage.ta, child: Text('தமிழ் (Tamil)')),
                      DropdownMenuItem(value: AppLanguage.te, child: Text('తెలుగు (Telugu)')),
                      DropdownMenuItem(value: AppLanguage.bn, child: Text('বাংলা (Bengali)')),
                      DropdownMenuItem(value: AppLanguage.mr, child: Text('मराठी (Marathi)')),
                    ],
                    onChanged: (lang) {
                      if (lang != null) {
                        settingsNotifier.setLanguage(lang);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Font Size Selection (Elder Accessibility)
            Text(
              Translations.get(settings.language, 'font_size'),
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              child: Column(
                children: [
                  RadioListTile<AppFontSize>(
                    title: Text(Translations.get(settings.language, 'font_normal')),
                    value: AppFontSize.normal,
                    groupValue: settings.fontSize,
                    activeColor: AppTheme.accentBlue,
                    onChanged: (size) {
                      if (size != null) settingsNotifier.setFontSize(size);
                    },
                  ),
                  RadioListTile<AppFontSize>(
                    title: Text(Translations.get(settings.language, 'font_large')),
                    value: AppFontSize.large,
                    groupValue: settings.fontSize,
                    activeColor: AppTheme.accentBlue,
                    onChanged: (size) {
                      if (size != null) settingsNotifier.setFontSize(size);
                    },
                  ),
                  RadioListTile<AppFontSize>(
                    title: Text(Translations.get(settings.language, 'font_xlarge')),
                    value: AppFontSize.extraLarge,
                    groupValue: settings.fontSize,
                    activeColor: AppTheme.accentBlue,
                    onChanged: (size) {
                      if (size != null) settingsNotifier.setFontSize(size);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Audio assist toggle
            Text(
              'Speech Assistance / आवाज सहायता',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              child: SwitchListTile(
                title: Text(Translations.get(settings.language, 'audio_assist')),
                subtitle: const Text('Read screens aloud for low-literacy users'),
                value: settings.audioGuidance,
                activeColor: AppTheme.successGreen,
                onChanged: (val) {
                  settingsNotifier.setAudioGuidance(val);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Sync Data
            Text(
              'Offline Data Sync / सिंक',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_done_rounded, color: AppTheme.successGreen),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            Translations.get(settings.language, 'sync_status'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'All local health profiles, diagnostics, and prescriptions are stored locally on this phone. Tap below to back them up when you have internet.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.sync_rounded),
                      label: Text(Translations.get(settings.language, 'sync_now')),
                      onPressed: () => _triggerSync(context),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
