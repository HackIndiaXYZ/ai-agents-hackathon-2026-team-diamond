import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Profile Model
class FamilyProfile {
  final String id;
  final String name;
  final String age;
  final String gender;
  final String relation;
  final int score;

  FamilyProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.relation,
    required this.score,
  });

  factory FamilyProfile.fromMap(Map<dynamic, dynamic> map) {
    return FamilyProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as String,
      gender: map['gender'] as String,
      relation: map['relation'] as String,
      score: map['score'] as int? ?? 80,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'relation': relation,
      'score': score,
    };
  }
}

// Active Profile ID Provider
class ActiveProfileIdNotifier extends StateNotifier<String> {
  ActiveProfileIdNotifier() : super('self');

  void selectProfile(String id) {
    state = id;
  }
}

final activeProfileIdProvider = StateNotifierProvider<ActiveProfileIdNotifier, String>((ref) {
  return ActiveProfileIdNotifier();
});

// Profiles Box Provider
final profilesBoxProvider = Provider<Box>((ref) => Hive.box('profiles'));

// Family Profiles List Provider
class FamilyProfilesNotifier extends StateNotifier<List<FamilyProfile>> {
  final Box _box;

  FamilyProfilesNotifier(this._box) : super([]) {
    _loadProfiles();
  }

  void _loadProfiles() {
    final list = _box.values.map((v) => FamilyProfile.fromMap(v as Map)).toList();
    state = list;
  }

  void addProfile(FamilyProfile profile) {
    _box.put(profile.id, profile.toMap());
    _loadProfiles();
  }

  void deleteProfile(String id) {
    _box.delete(id);
    _loadProfiles();
  }
}

final familyProfilesProvider = StateNotifierProvider<FamilyProfilesNotifier, List<FamilyProfile>>((ref) {
  final box = ref.read(profilesBoxProvider);
  return FamilyProfilesNotifier(box);
});

// Currently Active Profile Provider
final activeProfileProvider = Provider<FamilyProfile?>((ref) {
  final activeId = ref.watch(activeProfileIdProvider);
  final profiles = ref.watch(familyProfilesProvider);
  if (profiles.isEmpty) return null;
  return profiles.firstWhere((p) => p.id == activeId, orElse: () => profiles.first);
});
