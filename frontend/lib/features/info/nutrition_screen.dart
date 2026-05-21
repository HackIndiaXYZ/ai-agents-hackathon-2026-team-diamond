import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final recommendations = [
      {
        'item': 'Guava (अमरूद) 🍉',
        'benefit': 'Immunity & Vitamin C',
        'desc': 'Locally grown, extremely rich in Vitamin C (more than oranges) and fiber. Helps fight colds and builds immunity.',
        'color': const Color(0xFF10B981), // Emerald
      },
      {
        'item': 'Millets / Ragi (बाजरा) 🌾',
        'benefit': 'Calcium & Energy',
        'desc': 'Low-cost grains containing massive iron and calcium. Excellent for growing kids, elderly and pregnant women.',
        'color': const Color(0xFFF59E0B), // Amber
      },
      {
        'item': 'Moringa Leaves / Sahjan (सहजन) 🍃',
        'benefit': 'Iron & Blood Levels',
        'desc': 'Superfood growing in backyard trees. Renders huge amounts of Vitamin A, C, iron, and proteins. Cook in standard dal/vegetable.',
        'color': const Color(0xFF059669), // Green-600
      },
      {
        'item': 'Jaggery / Gur (गुड़) 🥮',
        'benefit': 'Fights Anaemia',
        'desc': 'Healthy alternative to white sugar. High iron content helps pregnant women and children build rich red blood counts.',
        'color': const Color(0xFFD97706), // Brown/Amber-700
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Minty white/green
      appBar: AppBar(
        backgroundColor: const Color(0xFF15803D), // Green-700
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'nutrition_guide'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner/Header explanation
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🥗', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local & Low-Cost Superfoods',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Boost nutrition with affordable ingredients available in your local village market.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recommendations List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  final color = rec['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: color, width: 6),
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    rec['item'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: color.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    rec['benefit'] as String,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              rec['desc'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
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

