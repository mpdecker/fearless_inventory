import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/fear_repository.dart';

class FearEntryScreen extends HookConsumerWidget {
  final Fear? existing;
  const FearEntryScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectController =
        useTextEditingController(text: existing?.subject ?? '');
    final whyController =
        useTextEditingController(text: existing?.why ?? '');
    final myPartController =
        useTextEditingController(text: existing?.myPart ?? '');
    final sponsorNoteController =
        useTextEditingController(text: existing?.sponsorNote ?? '');

    final flagForReview =
        useState<bool>(existing?.flagForReview ?? false);

    final isValid =
        useState(subjectController.text.trim().isNotEmpty);

    useEffect(() {
      void listener() =>
          isValid.value = subjectController.text.trim().isNotEmpty;
      subjectController.addListener(listener);
      return () => subjectController.removeListener(listener);
    }, [subjectController]);

    Future<void> save() async {
      if (!isValid.value) return;
      final repo = ref.read(fearRepositoryProvider);

      if (existing == null) {
        await repo.insertFear(FearsCompanion(
          subject: Value(subjectController.text.trim()),
          why: Value(whyController.text.trim()),
          myPart: Value(myPartController.text.trim()),
          sponsorNote: Value(sponsorNoteController.text.trim().isNotEmpty
              ? sponsorNoteController.text.trim()
              : null),
          flagForReview: Value(flagForReview.value),
          createdAt: Value(DateTime.now()),
        ));
      } else {
        await repo.updateFear(existing!.copyWith(
          subject: subjectController.text.trim(),
          why: whyController.text.trim(),
          myPart: myPartController.text.trim(),
          sponsorNote: Value(sponsorNoteController.text.trim().isNotEmpty
              ? sponsorNoteController.text.trim()
              : null),
          flagForReview: flagForReview.value,
        ));
      }

      if (context.mounted) Navigator.pop(context, true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'New Fear Entry' : 'Edit Fear Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isValid.value ? save : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What am I afraid of?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Person, situation, future event...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            Text('Why do I have this fear?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: whyController,
              maxLines: 3,
              decoration:
                  const InputDecoration(border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            Text('My part', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: myPartController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'How does self-reliance, control, or dishonesty show up?',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),

            // ── Sponsor Work ────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.supervised_user_circle_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Sponsor Work',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(letterSpacing: 0.8)),
              ],
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Flag for sponsor review'),
              subtitle:
                  const Text('Mark this item to discuss in your Step 5'),
              value: flagForReview.value,
              onChanged: (val) => flagForReview.value = val,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: sponsorNoteController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Sponsor's notes",
                hintText: 'Record what your sponsor said about this fear...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: isValid.value ? save : null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
              child: const Text('Save & Return'),
            ),
          ],
        ),
      ),
    );
  }
}
