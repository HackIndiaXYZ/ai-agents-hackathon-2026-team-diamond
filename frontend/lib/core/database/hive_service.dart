import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static Future<void> init() async {
    // On web, Hive uses IndexedDB — no path needed.
    // On mobile/desktop, we provide the app documents directory.
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }

    // Open boxes
    await Hive.openBox('settings');
    final profilesBox = await Hive.openBox('profiles');
    final medicinesBox = await Hive.openBox('medicines');
    final symptomsBox = await Hive.openBox('symptoms');

    // Populate Mock Data on first load if empty
    if (profilesBox.isEmpty) {
      _seedMockData(profilesBox, medicinesBox, symptomsBox);
    }
  }

  static void _seedMockData(Box profiles, Box medicines, Box symptoms) {
    // 1. Seed Family Profiles
    profiles.putAll({
      'self': {
        'id': 'self',
        'name': 'Ramesh Kumar',
        'age': '42',
        'gender': 'Male',
        'relation': 'Self',
        'score': 85,
      },
      'spouse': {
        'id': 'spouse',
        'name': 'Sita Devi',
        'age': '38',
        'gender': 'Female',
        'relation': 'Spouse',
        'score': 92,
      },
      'elderly': {
        'id': 'elderly',
        'name': 'Harishankar Prasad',
        'age': '71',
        'gender': 'Male',
        'relation': 'Father',
        'score': 68,
      },
      'child': {
        'id': 'child',
        'name': 'Aarav Kumar',
        'age': '8',
        'gender': 'Male',
        'relation': 'Son',
        'score': 95,
      }
    });

    // 2. Seed Medicine Reminders
    medicines.putAll({
      'med_1': {
        'id': 'med_1',
        'profileId': 'elderly',
        'name': 'Metformin 500mg',
        'dosage': '1 Tablet',
        'frequency': 'Twice a day',
        'timing': 'After Food',
        'timeOfDay': '08:00 AM, 08:00 PM',
        'stock': 12,
        'takenCount': 18,
        'missedCount': 2,
      },
      'med_2': {
        'id': 'med_2',
        'profileId': 'self',
        'name': 'Amlodipine 5mg',
        'dosage': '1 Tablet',
        'frequency': 'Once a day',
        'timing': 'Before Food',
        'timeOfDay': '09:00 AM',
        'stock': 4,
        'takenCount': 25,
        'missedCount': 1,
      },
      'med_3': {
        'id': 'med_3',
        'profileId': 'spouse',
        'name': 'Iron & Folic Acid',
        'dosage': '1 Capsule',
        'frequency': 'Once a day',
        'timing': 'After Food',
        'timeOfDay': '02:00 PM',
        'stock': 20,
        'takenCount': 30,
        'missedCount': 0,
      }
    });

    // 3. Seed Symptom History Logs
    symptoms.putAll({
      'sym_1': {
        'id': 'sym_1',
        'profileId': 'elderly',
        'date': '2026-05-18T10:30:00Z',
        'symptoms': 'Chest heaviness and mild breathlessness',
        'diagnosis': 'Possible cardiovascular strain. Urgent examination advised.',
        'triage': 'red', // emergency
        'doctorType': 'Cardiologist',
        'advice': 'Rest completely. Do not engage in physical effort. Contact nearby PHC/Government hospital or dial 108 immediately.',
      },
      'sym_2': {
        'id': 'sym_2',
        'profileId': 'self',
        'date': '2026-05-15T14:20:00Z',
        'symptoms': 'High fever, body pain, headache',
        'diagnosis': 'Viral Fever (Possible Dengue/Malaria)',
        'triage': 'yellow', // monitor
        'doctorType': 'General Physician',
        'advice': 'Take paracetamol if fever exceeds 100°F. Keep hydrated with ORS or coconut water. Monitor platelet counts if fever persists.',
      },
      'sym_3': {
        'id': 'sym_3',
        'profileId': 'child',
        'date': '2026-05-10T09:15:00Z',
        'symptoms': 'Running nose and mild dry cough',
        'diagnosis': 'Common Cold / Rhinovirus',
        'triage': 'green', // safe
        'doctorType': 'Paediatrician / Home care',
        'advice': 'Steam inhalation, warm fluids, saline nose drops. Monitor for high fever. Ensure rest.',
      }
    });
  }
}
