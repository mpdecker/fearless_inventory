import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'; // Correct library for HookConsumerWidget
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

    final personController = useTextEditingController(text: existing?.person ?? '');
    final causeController = useTextEditingController(text: existing?.cause ?? '');
    final myPartController = useTextEditingController(text: existing?.myPart ?? '');

    // Splits comma-separated String from DB into UI List
    final selectedAffects = useState<List<String>>(
      existing?.affects.split(',').where((s) => s.isNotEmpty).toList() ?? []
    );

    final isValid = useState(personController.text.trim().isNotEmpty);

    useEffect(() {
      void listener() => isValid.value = personController.text.trim().isNotEmpty;
      personController.addListener(listener);
      return () => personController.removeListener(listener);
    }, [personController]);

    Future<void> save() async {
      if (!isValid.value) return;

      final affectsStr = selectedAffects.value.join(',');
      final companion = ResentmentsCompanion(
        person: Value(personController.text.trim()),
        cause: Value(causeController.text.trim()),
        affects: Value(affectsStr),
        myPart: Value(myPartController.text.trim()),
        createdAt: Value(DateTime.now()),
      );

      if (existing == null) {
        await repo.insertResentment(companion);
      } else {
        await repo.updateResentment(existing!.copyWith(
          person: personController.text.trim(),
          cause: causeController.text.trim(),
          affects: affectsStr,
          myPart: myPartController.text.trim(),
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
            Text('I\'m resentful at', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: personController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Name/Institution'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Text('The cause...', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: causeController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Text('Affects my...', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: affectsOptions.map((opt) {
                final isSelected = selectedAffects.value.contains(opt['value']);
                return FilterChip(
                  label: Text(opt['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newList = List<String>.from(selectedAffects.value);
                    if (selected) {
                      newList.add(opt['value']!);
                    } else {
                      newList.remove(opt['value']);
                    }
                    selectedAffects.value = newList;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('My part', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: myPartController,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isValid.value ? save : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              child: const Text('Save & Return'),
            ),
          ],
        ),
      ),
    );
  }
}