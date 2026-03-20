import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/defect_repository.dart';

class StepSixWizard extends StatefulWidget {
  const StepSixWizard({super.key});

  @override
  State<StepSixWizard> createState() => _StepSixWizardState();
}

class _StepSixWizardState extends State<StepSixWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Literature-based prompts (12 & 12 inspired)
  final List<Map<String, String>> _prompts = [
    {
      "category": "Pride",
      "question": "Do I often find myself looking down on others to feel better about myself, or do I obsess over how others perceive my status?",
      "defect": "Pride / Vanity"
    },
    {
      "category": "Greed",
      "question": "Is there a persistent fear that I will never have 'enough'—whether it's money, attention, or possessions?",
      "defect": "Greed / Materialism"
    },
    {
      "category": "Lust",
      "question": "Have I used other people as objects for my own gratification or to escape my feelings?",
      "defect": "Lust"
    },
    {
      "category": "Envy",
      "question": "Do I feel a 'quiet sting' when others succeed, or do I constantly compare my life to those I perceive as more fortunate?",
      "defect": "Envy / Jealousy"
    },
    {
      "category": "Gluttony",
      "question": "Do I seek excessive comfort in food, shopping, or other distractions to avoid facing my internal reality?",
      "defect": "Gluttony / Excess"
    },
    {
      "category": "Anger",
      "question": "Do I harbor a 'righteous indignation' or a quiet resentment that I refuse to let go of?",
      "defect": "Resentment / Anger"
    },
    {
      "category": "Sloth",
      "question": "Am I paralyzed by apathy? Do I avoid spiritual work or responsibilities because they feel too difficult?",
      "defect": "Sloth / Procrastination"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discovery Wizard"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentPage + 1) / _prompts.length),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: _prompts.length,
              itemBuilder: (context, index) {
                final prompt = _prompts[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prompt['category']!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.indigo.shade400,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        prompt['question']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, height: 1.5),
                      ),
                      const SizedBox(height: 48),
                      Consumer(builder: (context, ref, _) {
                        return ElevatedButton(
                          onPressed: () => _addDefect(ref, prompt['defect']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: Text("Yes, I recognize '${prompt['defect']}'"),
                        );
                      }),
                      TextButton(
                        onPressed: _nextPage,
                        child: const Text("No, this doesn't fit me"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _prompts.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _addDefect(WidgetRef ref, String name) async {
    await ref.read(defectRepositoryProvider).insert(
      DefectsCompanion(
        name: Value(name),
        createdAt: Value(DateTime.now()),
      ),
    );
    _nextPage();
  }
}