import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/translation_provider.dart';
import 'symptom_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Color _getTriageColor(String triage) {
    switch (triage) {
      case 'red':
        return AppTheme.dangerRed;
      case 'yellow':
        return AppTheme.warningYellow;
      case 'green':
      default:
        return AppTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final logs = ref.watch(diagnosisLogsProvider);
    final textTheme = AppTheme.getTextTheme(settings.fontSize);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get(settings.language, 'symptom_history')),
      ),
      body: SafeArea(
        child: logs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 16),
                    Text('No Diagnosis History Found', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Saved scans will appear here offline.'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final triageColor = _getTriageColor(log.triage);
                  final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(log.date.toLocal());

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: triageColor.withOpacity(0.3), width: 1.5),
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(color: triageColor, shape: BoxShape.circle),
                      ),
                      title: Text(
                        log.diagnosis,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      subtitle: Text('Scanned: $formattedDate', style: const TextStyle(fontSize: 11)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Text('Symptoms / लक्षण:', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('"${log.symptoms}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                              const SizedBox(height: 12),
                              Text('Doctor Type:', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text(log.doctorType, style: const TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text('Recommendations:', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(log.advice, style: const TextStyle(fontSize: 13, height: 1.4)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
