import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';
import '../family/profile_provider.dart';
import 'medicine_provider.dart';

class MedicineReminderScreen extends ConsumerStatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  ConsumerState<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends ConsumerState<MedicineReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _stockController = TextEditingController();

  String selectedFrequency = 'Once a day';
  String selectedTiming = 'After Food';
  String selectedTimeOfDay = '09:00 AM';

  final List<String> frequencies = [
    'Once a day',
    'Twice a day',
    'Three times a day',
    'Once a week',
  ];

  final List<String> timings = [
    'Before Food',
    'After Food',
    'Empty Stomach',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _showAddMedicineDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header line
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Add Medicine Schedule',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Input Name
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Medicine Name',
                          hintText: 'e.g., Paracetamol 650mg',
                          prefixIcon: const Icon(Icons.medication_rounded, color: AppTheme.accentBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Please enter medicine name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Dosage & Stock Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dosageController,
                              decoration: InputDecoration(
                                labelText: 'Dosage / मात्रा',
                                hintText: 'e.g., 1 tablet',
                                prefixIcon: const Icon(Icons.adjust_rounded, color: Colors.purple),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Total Stock',
                                hintText: 'e.g., 30',
                                prefixIcon: const Icon(Icons.inventory_2_rounded, color: Colors.orange),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Frequency Select
                      DropdownButtonFormField<String>(
                        value: selectedFrequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency / आवृत्ति',
                          prefixIcon: const Icon(Icons.repeat_rounded, color: Colors.teal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedFrequency = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Timing Select
                      DropdownButtonFormField<String>(
                        value: selectedTiming,
                        decoration: InputDecoration(
                          labelText: 'Timing / भोजन समय',
                          prefixIcon: const Icon(Icons.restaurant_rounded, color: Colors.deepOrange),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: timings.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedTiming = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 28),

                      GradientButton(
                        text: 'Save Medicine Reminder',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final activeProfile = ref.read(activeProfileProvider);
                            final notifier = ref.read(medicineRemindersProvider.notifier);

                            final reminder = MedicineReminder(
                              id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                              profileId: activeProfile?.id ?? 'self',
                              name: _nameController.text,
                              dosage: _dosageController.text,
                              frequency: selectedFrequency,
                              timing: selectedTiming,
                              timeOfDay: selectedTimeOfDay,
                              stock: int.tryParse(_stockController.text) ?? 10,
                            );

                            notifier.addReminder(reminder);

                            _nameController.clear();
                            _dosageController.clear();
                            _stockController.clear();
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    ref.watch(medicineRemindersProvider);
    final notifier = ref.read(medicineRemindersProvider.notifier);

    final activeReminders = notifier.getActiveReminders();

    int totalTaken = 0;
    int totalMissed = 0;
    for (final rem in activeReminders) {
      totalTaken += rem.takenCount;
      totalMissed += rem.missedCount;
    }
    double adherenceRate = 100.0;
    if (totalTaken + totalMissed > 0) {
      adherenceRate = (totalTaken / (totalTaken + totalMissed)) * 100;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Beautiful Parallax Header with Score ────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryBlue,
            elevation: 0,
            foregroundColor: Colors.white,
            title: Text(
              Translations.get(settings.language, 'medicine_reminders'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_rounded, size: 28),
                onPressed: _showAddMedicineDialog,
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          // Radial-like Indicator
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 76,
                                height: 76,
                                child: CircularProgressIndicator(
                                  value: adherenceRate / 100.0,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    adherenceRate >= 80
                                        ? AppTheme.successGreen
                                        : adherenceRate >= 50
                                            ? AppTheme.warningYellow
                                            : AppTheme.dangerRed,
                                  ),
                                ),
                              ),
                              Text(
                                '${adherenceRate.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'ADHERENCE SCORE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white54,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  adherenceRate >= 85 ? 'Excellent Compliance!' : 'Medicines Pending',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Taken: $totalTaken logs  •  Missed: $totalMissed logs',
                                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Medicine reminders list ─────────────────────────────────
          activeReminders.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
                            ],
                          ),
                          child: const Text('💊', style: TextStyle(fontSize: 44)),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'No Medicines Scheduled',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "+" at the top right to schedule medication',
                          style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final rem = activeReminders[index];
                        final isLowStock = rem.stock <= 5;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: isLowStock
                                    ? AppTheme.warningYellow.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.02),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isLowStock
                                  ? AppTheme.warningYellow.withOpacity(0.4)
                                  : const Color(0xFFF1F5F9),
                              width: isLowStock ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rem.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => notifier.deleteReminder(rem.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.dangerRed.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.delete_rounded, color: AppTheme.dangerRed, size: 16),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildLabelTag(rem.frequency, AppTheme.accentBlue),
                                    const SizedBox(width: 8),
                                    _buildLabelTag(rem.timing, Colors.purple),
                                    const SizedBox(width: 8),
                                    _buildLabelTag('${rem.dosage}', Colors.grey.shade600),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Stock Info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2_rounded,
                                          size: 14,
                                          color: isLowStock ? AppTheme.warningYellow : AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Stock: ${rem.stock} pills remaining',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isLowStock ? FontWeight.w800 : FontWeight.w600,
                                            color: isLowStock ? AppTheme.warningYellow : AppTheme.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isLowStock)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.warningYellow.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Low Stock!',
                                          style: TextStyle(
                                            color: AppTheme.warningYellow,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                const SizedBox(height: 12),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _actionBtn(
                                        label: 'Missed / भूल गए',
                                        color: AppTheme.dangerRed,
                                        onTap: () {
                                          notifier.updateStockAndAdherence(rem.id, taken: false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Marked as Missed'),
                                              duration: Duration(milliseconds: 600),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _actionBtn(
                                        label: 'Take / खा ली',
                                        color: AppTheme.successGreen,
                                        isSolid: true,
                                        onTap: () {
                                          notifier.updateStockAndAdherence(rem.id, taken: true);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Marked as Taken! 💊'),
                                              duration: Duration(milliseconds: 600),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: activeReminders.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _actionBtn({required String label, required Color color, bool isSolid = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSolid ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(isSolid ? 0 : 0.2)),
          boxShadow: isSolid
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSolid ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildLabelTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
