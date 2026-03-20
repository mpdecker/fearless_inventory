import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/amends_repository.dart';
import '../../core/models/amends_type.dart';

class AmendsEntryScreen extends HookConsumerWidget {
  final Harm? fromHarm;
  final Amend? editAmends;

  const AmendsEntryScreen({super.key, this.fromHarm, this.editAmends});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personController = useTextEditingController(text: editAmends?.person ?? fromHarm?.person ?? '');
    final planController = useTextEditingController(text: editAmends?.plan ?? '');
    final selectedType = useState<AmendsType>(editAmends?.amendsType ?? AmendsType.personal);
    final isStep9 = useState(editAmends?.status != 'step8' && planController.text.isNotEmpty);

    final isValid = useState(false);

    useEffect(() {
      void listener() {
        // Validation: If planning Step 9, plan is required. For Step 8, only person is required.
        if (isStep9.value) {
          isValid.value = personController.text.trim().isNotEmpty && planController.text.trim().isNotEmpty;
        } else {
          isValid.value = personController.text.trim().isNotEmpty;
        }
      }
      personController.addListener(listener);
      planController.addListener(listener);
      listener();
      return () {
        personController.removeListener(listener);
        planController.removeListener(listener);
      };
    }, [personController, planController, isStep9.value]);

    return Scaffold(
      appBar: AppBar(title: Text(editAmends != null ? 'Edit Amends' : 'Add to List')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: personController,
              decoration: const InputDecoration(labelText: "Who am I making amends to?", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Ready to plan (Step 9)?"),
              value: isStep9.value,
              onChanged: (val) => isStep9.value = val,
            ),
            if (isStep9.value) ...[
              const SizedBox(height: 20),
              DropdownButton<AmendsType>(
                value: selectedType.value,
                isExpanded: true,
                items: AmendsType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
                onChanged: (v) => selectedType.value = v!,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: planController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "The Plan", border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isValid.value ? () async {
                final repo = ref.read(amendsRepositoryProvider);
                final status = isStep9.value ? 'pending' : 'step8';

                if (editAmends != null) {
                  // Update logic...
                } else {
                  await repo.insert(AmendsCompanion(
                    person: Value(personController.text.trim()),
                    amendsType: Value(selectedType.value),
                    plan: Value(planController.text.isNotEmpty ? planController.text.trim() : null),
                    status: Value(status),
                    datePlanned: Value(isStep9.value ? DateTime.now() : null),
                    harmId: fromHarm != null ? Value(fromHarm!.id) : const Value.absent(),
                  ));
                }
                Navigator.pop(context);
              } : null,
              child: const Text("Save Amends"),
            ),
          ],
        ),
      ),
    );
  }
}