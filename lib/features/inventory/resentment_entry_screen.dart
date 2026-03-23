import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/resentment_repository.dart';
import 'models/affects.dart';

class ResentmentEntryScreen extends HookConsumerWidget {
  final Resentment? existing;

  const ResentmentEntryScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(resentmentRepositoryProvider);

    final personController =
        useTextEditingController(text: existing?.person ?? '');
    final causeController =
        useTextEditingController(text: existing?.cause ?? '');
    final myPartController =
        useTextEditingController(text: existing?.myPart ?? '');
    final sponsorNoteController =
        useTextEditingController(text: existing?.sponsorNote ?? '');

    final selectedAffects = useState<List<String>>(
        existing?.affects.split(',').where((s) => s.isNotEmpty).toList() ?? []);

    // Sponsor workflow state
    final flagForReview =
        useState<bool>(existing?.flagForReview ?? false);

    final isValid =
        useState(personController.text.trim().isNotEmpty);

    useEffect(() {
      void listener() =>
          isValid.value = personController.text.trim().isNotEmpty;
      personController.addListener(listener);
      return () => personController.removeListener(listener);
    }, [personController]);

    Future<void> save() async {
      if (!isValid.value) return;

      final affectsStr = selectedAffects.value.join(',');

      if (existing == null) {
        await repo.insertResentment(ResentmentsCompanion(
          person: Value(personController.text.trim()),
          cause: Value(causeController.text.trim()),
          affects: Value(affectsStr),
          myPart: Value(myPartController.text.trim()),
          sponsorNote: Value(sponsorNoteController.text.trim().isNotEmpty
              ? sponsorNoteController.text.trim()
              : null),
          flagForReview: Value(flagForReview.value),
          createdAt: Value(DateTime.now()),
        ));
      } else {
        await repo.updateResentment(existing!.copyWith(
          person: personController.text.trim(),
          cause: causeController.text.trim(),
          affects: affectsStr,
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
        title: const Text('Resentments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isValid.value ? save : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Column 1: Who ───────────────────────────────────────────────
            Text("I'm resentful at",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: personController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name / Institution / Principle'),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // ── Column 2: Cause ─────────────────────────────────────────────
            Text('The cause...',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: causeController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // ── Column 3: Affects ───────────────────────────────────────────
            Text('Affects my...',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: affectsOptions.map((opt) {
                final isSelected =
                    selectedAffects.value.contains(opt['value']);
                return FilterChip(
                  label: Text(opt['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newList = List<String>.from(selectedAffects.value);
                    selected
                        ? newList.add(opt['value']!)
                        : newList.remove(opt['value']);
                    selectedAffects.value = newList;
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Column 4: My Part ───────────────────────────────────────────
            Text('My part', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: myPartController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Where was I selfish, dishonest, self-seeking, or afraid?',
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
                hintText:
                    'Record what your sponsor said about this resentment...',
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
