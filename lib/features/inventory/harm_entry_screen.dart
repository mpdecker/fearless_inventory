import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/harm_repository.dart';

class HarmEntryScreen extends HookConsumerWidget {
  final Harm? existing;
  const HarmEntryScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controllers initialized with existing data if editing, or empty strings if new
    final personController = useTextEditingController(text: existing?.person ?? '');
    final conductController = useTextEditingController(text: existing?.conduct ?? '');
    final myPartController = useTextEditingController(text: existing?.myPart ?? '');
    final amendsPlanController = useTextEditingController(text: existing?.amendsPlan ?? '');

    // Form validation state
    final isValid = useState(personController.text.isNotEmpty);

    // Listener to update validation when the name field changes
    useEffect(() {
      void listener() => isValid.value = personController.text.trim().isNotEmpty;
      personController.addListener(listener);
      return () => personController.removeListener(listener);
    }, [personController]);

    Future<void> save() async {
      if (!isValid.value) return;

      final repo = ref.read(harmRepositoryProvider);

      if (existing == null) {
        // Create new entry using the Companion
        final companion = HarmsCompanion(
          person: Value(personController.text.trim()),
          conduct: Value(conductController.text.trim()),
          myPart: Value(myPartController.text.trim()),
          amendsPlan: Value(amendsPlanController.text.trim()),
          createdAt: Value(DateTime.now()),
        );
        await repo.insertHarm(companion);
      } else {
        // Update existing entry using copyWith
        // Note: amendsPlan requires Value() because it is nullable in the schema
        await repo.updateHarm(existing!.copyWith(
          person: personController.text.trim(),
          conduct: conductController.text.trim(),
          myPart: myPartController.text.trim(),
          amendsPlan: Value(amendsPlanController.text.trim()),
        ));
      }

      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'New Harm Entry' : 'Edit Harm Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who did I harm?', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            TextField(
              controller: personController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Name of person or institution',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'What was the conduct/harm?', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            TextField(
              controller: conductController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Briefly describe what happened...',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'My part (Selfish, Dishonest, Afraid?)', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            TextField(
              controller: myPartController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Where was I at fault?',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Amends Plan', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amendsPlanController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'How can I make this right?',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: isValid.value ? save : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Colors.deepOrange.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}