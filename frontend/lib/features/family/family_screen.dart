import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';
import 'profile_provider.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String selectedGender = 'Male';
  String selectedRelation = 'Spouse';

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> relations = ['Spouse', 'Father', 'Mother', 'Son', 'Daughter', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog() {
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
                        'Add Family Profile / सदस्य जोड़ें',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'e.g., Sita Devi',
                          prefixIcon: const Icon(Icons.person_rounded, color: AppTheme.accentBlue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Age / उम्र',
                          hintText: 'e.g., 38',
                          prefixIcon: const Icon(Icons.cake_rounded, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Please enter age' : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender / लिंग',
                          prefixIcon: const Icon(Icons.transgender_rounded, color: Colors.teal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedGender = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedRelation,
                        decoration: InputDecoration(
                          labelText: 'Relation / रिश्ता',
                          prefixIcon: const Icon(Icons.family_restroom_rounded, color: Colors.deepOrange),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        items: relations.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedRelation = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 28),

                      GradientButton(
                        text: 'Create Family Profile',
                        icon: Icons.person_add_rounded,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final notifier = ref.read(familyProfilesProvider.notifier);
                            final score = 75 + (DateTime.now().millisecond % 21);

                            final newProfile = FamilyProfile(
                              id: 'prof_${DateTime.now().millisecondsSinceEpoch}',
                              name: _nameController.text,
                              age: _ageController.text,
                              gender: selectedGender,
                              relation: selectedRelation,
                              score: score,
                            );

                            notifier.addProfile(newProfile);

                            _nameController.clear();
                            _ageController.clear();
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

  Color _getRelationColor(String relation) {
    switch (relation.toLowerCase()) {
      case 'self':
        return Colors.blue;
      case 'spouse':
        return Colors.pink;
      case 'father':
      case 'mother':
        return Colors.orange;
      case 'son':
      case 'daughter':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final profiles = ref.watch(familyProfilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final activeNotifier = ref.read(activeProfileIdProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'family_dashboard'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 28),
            onPressed: _showAddMemberDialog,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky top help card
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.people_alt_rounded, color: AppTheme.accentBlue, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shared Health Profiles',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryBlue),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Select a family member below to switch profiles.',
                            style: TextStyle(color: AppTheme.textLight, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Profile list
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isSelected = profile.id == activeId;
                  final relColor = _getRelationColor(profile.relation);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppTheme.accentBlue.withOpacity(0.08)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected ? AppTheme.accentBlue : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: relColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          profile.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: relColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryBlue),
                          ),
                          const SizedBox(width: 8),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                              ),
                            )
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${profile.relation}  •  ${profile.age} Yrs  •  ${profile.gender}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('HEALTH SCORE', style: TextStyle(fontSize: 8, color: AppTheme.textMuted, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(
                                '${profile.score}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: profile.score >= 80
                                      ? AppTheme.successGreen
                                      : profile.score >= 70
                                          ? AppTheme.warningYellow
                                          : AppTheme.dangerRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          if (!isSelected)
                            IconButton(
                              icon: const Icon(Icons.swap_horiz_rounded, color: AppTheme.accentBlue),
                              onPressed: () {
                                activeNotifier.selectProfile(profile.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Switched profile to ${profile.name}'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
