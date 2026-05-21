import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../family/profile_provider.dart';

// Diagnosis Log Model
class DiagnosisLog {
  final String id;
  final String profileId;
  final DateTime date;
  final String symptoms;
  final String diagnosis;
  final String triage; // 'red', 'yellow', 'green'
  final String doctorType;
  final String advice;

  DiagnosisLog({
    required this.id,
    required this.profileId,
    required this.date,
    required this.symptoms,
    required this.diagnosis,
    required this.triage,
    required this.doctorType,
    required this.advice,
  });

  factory DiagnosisLog.fromMap(Map<dynamic, dynamic> map) {
    return DiagnosisLog(
      id: map['id'] as String,
      profileId: map['profileId'] as String,
      date: DateTime.parse(map['date'] as String),
      symptoms: map['symptoms'] as String,
      diagnosis: map['diagnosis'] as String,
      triage: map['triage'] as String,
      doctorType: map['doctorType'] as String,
      advice: map['advice'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'triage': triage,
      'doctorType': doctorType,
      'advice': advice,
    };
  }
}

// State class for analyzer
class SymptomState {
  final bool isRecording;
  final bool isAnalyzing;
  final String transcribedText;
  final DiagnosisLog? result;

  SymptomState({
    this.isRecording = false,
    this.isAnalyzing = false,
    this.transcribedText = '',
    this.result,
  });

  SymptomState copyWith({
    bool? isRecording,
    bool? isAnalyzing,
    String? transcribedText,
    DiagnosisLog? result,
  }) {
    return SymptomState(
      isRecording: isRecording ?? this.isRecording,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      transcribedText: transcribedText ?? this.transcribedText,
      result: result ?? this.result,
    );
  }
}

// Symptom Notifier
class SymptomNotifier extends StateNotifier<SymptomState> {
  final Box _symptomsBox;
  final Ref _ref;

  SymptomNotifier(this._symptomsBox, this._ref) : super(SymptomState());

  void startRecording() {
    state = SymptomState(isRecording: true);
  }

  void stopRecordingAndAnalyze(String simulatedVoiceInput) {
    state = state.copyWith(isRecording: false, isAnalyzing: true, transcribedText: simulatedVoiceInput);

    // Simulate Gemini AI classification logic
    Future.delayed(const Duration(milliseconds: 1500), () {
      final activeProfile = _ref.read(activeProfileProvider);
      final profileId = activeProfile?.id ?? 'self';
      
      final log = _analyzeSymptoms(simulatedVoiceInput, profileId);
      
      // Save offline in Hive Box
      _symptomsBox.put(log.id, log.toMap());

      state = state.copyWith(isAnalyzing: false, result: log);
    });
  }

  void clear() {
    state = SymptomState();
  }

  DiagnosisLog _analyzeSymptoms(String text, String profileId) {
    final lowerText = text.toLowerCase();
    
    // Triage Logic
    if (lowerText.contains('chest pain') || 
        lowerText.contains('heart') || 
        lowerText.contains('dil me dard') || 
        lowerText.contains('stroke') ||
        lowerText.contains('breathless') ||
        lowerText.contains('saans lene me taklif')) {
      return DiagnosisLog(
        id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
        profileId: profileId,
        date: DateTime.now(),
        symptoms: text,
        diagnosis: 'Possible Cardiac Strain or Severe Respiratory Distress',
        triage: 'red',
        doctorType: 'Cardiologist / Emergency ICU',
        advice: 'DO NOT exercise. Rest immediately. Take Sorbitrate 5mg if prescribed. Call emergency ambulance (108) or proceed to the nearest multi-specialty government hospital immediately.',
      );
    } else if (lowerText.contains('fever') || 
               lowerText.contains('bukhar') || 
               lowerText.contains('jwar') ||
               lowerText.contains('headache') ||
               lowerText.contains('body pain') ||
               lowerText.contains('sar dard')) {
      return DiagnosisLog(
        id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
        profileId: profileId,
        date: DateTime.now(),
        symptoms: text,
        diagnosis: 'Acute Viral Fever (Evaluate for Malaria, Dengue or Typhoid)',
        triage: 'yellow',
        doctorType: 'General Physician / PHC Doctor',
        advice: 'Take Paracetamol 650mg every 6 hours (max 4 per day) to control temperature. Sponging with normal tap water. Drink plenty of fluids (ORS, coconut water, or clean water). Get CBC and platelet count if fever lasts more than 3 days.',
      );
    } else {
      // Default / Safe Green
      return DiagnosisLog(
        id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
        profileId: profileId,
        date: DateTime.now(),
        symptoms: text,
        diagnosis: 'Common Cold, Mild Rhinovirus Infection, or Throat Irritation',
        triage: 'green',
        doctorType: 'Home Care / Local ASHA Worker',
        advice: 'Perform warm water gargles with a pinch of salt 3 times a day. Steam inhalation twice daily. Stay warm and rested. Take honey and ginger tea for throat relief. Visit clinic only if symptoms persist beyond 5 days.',
      );
    }
  }
}

// Providers
final symptomsBoxProvider = Provider<Box>((ref) => Hive.box('symptoms'));

final symptomNotifierProvider = StateNotifierProvider<SymptomNotifier, SymptomState>((ref) {
  final box = ref.read(symptomsBoxProvider);
  return SymptomNotifier(box, ref);
});

// Full Diagnosis Logs List Provider
final diagnosisLogsProvider = Provider<List<DiagnosisLog>>((ref) {
  final box = ref.watch(symptomsBoxProvider);
  final activeProfile = ref.watch(activeProfileProvider);
  
  if (activeProfile == null) return [];
  
  return box.values
      .map((v) => DiagnosisLog.fromMap(v as Map))
      .where((log) => log.profileId == activeProfile.id)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});
