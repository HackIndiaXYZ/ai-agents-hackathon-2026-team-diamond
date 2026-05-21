import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../family/profile_provider.dart';

// Medicine Reminder Model
class MedicineReminder {
  final String id;
  final String profileId;
  final String name;
  final String dosage;
  final String frequency;
  final String timing; // Before Food / After Food
  final String timeOfDay; // 08:00 AM, etc.
  final int stock;
  final int takenCount;
  final int missedCount;

  MedicineReminder({
    required this.id,
    required this.profileId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timing,
    required this.timeOfDay,
    required this.stock,
    this.takenCount = 0,
    this.missedCount = 0,
  });

  factory MedicineReminder.fromMap(Map<dynamic, dynamic> map) {
    return MedicineReminder(
      id: map['id'] as String,
      profileId: map['profileId'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as String,
      timing: map['timing'] as String,
      timeOfDay: map['timeOfDay'] as String? ?? '09:00 AM',
      stock: map['stock'] as int? ?? 10,
      takenCount: map['takenCount'] as int? ?? 0,
      missedCount: map['missedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'timing': timing,
      'timeOfDay': timeOfDay,
      'stock': stock,
      'takenCount': takenCount,
      'missedCount': missedCount,
    };
  }

  MedicineReminder copyWith({
    int? stock,
    int? takenCount,
    int? missedCount,
  }) {
    return MedicineReminder(
      id: id,
      profileId: profileId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      timing: timing,
      timeOfDay: timeOfDay,
      stock: stock ?? this.stock,
      takenCount: takenCount ?? this.takenCount,
      missedCount: missedCount ?? this.missedCount,
    );
  }
}

// Box Provider
final medicinesBoxProvider = Provider<Box>((ref) => Hive.box('medicines'));

// Reminders Notifier
class MedicineReminderNotifier extends StateNotifier<List<MedicineReminder>> {
  final Box _box;
  final Ref _ref;

  MedicineReminderNotifier(this._box, this._ref) : super([]) {
    _loadReminders();
  }

  void _loadReminders() {
    final list = _box.values.map((v) => MedicineReminder.fromMap(v as Map)).toList();
    state = list;
  }

  // Get reminders for currently active profile
  List<MedicineReminder> getActiveReminders() {
    final activeProfile = _ref.read(activeProfileProvider);
    if (activeProfile == null) return [];
    return state.where((m) => m.profileId == activeProfile.id).toList();
  }

  void addReminder(MedicineReminder reminder) {
    _box.put(reminder.id, reminder.toMap());
    _loadReminders();
  }

  void updateStockAndAdherence(String id, {bool taken = true}) {
    final remIndex = state.indexWhere((r) => r.id == id);
    if (remIndex != -1) {
      final old = state[remIndex];
      final updated = old.copyWith(
        stock: (old.stock - 1).clamp(0, 999),
        takenCount: taken ? old.takenCount + 1 : old.takenCount,
        missedCount: !taken ? old.missedCount + 1 : old.missedCount,
      );
      _box.put(id, updated.toMap());
      _loadReminders();
    }
  }

  void deleteReminder(String id) {
    _box.delete(id);
    _loadReminders();
  }
}

final medicineRemindersProvider = StateNotifierProvider<MedicineReminderNotifier, List<MedicineReminder>>((ref) {
  final box = ref.read(medicinesBoxProvider);
  return MedicineReminderNotifier(box, ref);
});
