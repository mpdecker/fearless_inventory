import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/amends_repository.dart';
import '../../core/models/amends_type.dart';

// ── Timeframe helpers ────────────────────────────────────────────────────────

const _kTimeframes = [
  ('asap', 'ASAP'),
  ('days', 'Days'),
  ('weeks', 'Weeks'),
  ('months', 'Months'),
  ('years', 'Years'),
];

String timeframeLabel(String? raw) {
  if (raw == null) return '';
  return _kTimeframes.firstWhere(
    (t) => t.$1 == raw,
    orElse: () => (raw, raw),
  ).$2;
}

// ─────────────────────────────────────────────────────────────────────────────

class AmendsEntryScreen extends HookConsumerWidget {
  final Harm? fromHarm;
  final Amend? editAmends;

  const AmendsEntryScreen({super.key, this.fromHarm, this.editAmends});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personController = useTextEditingController(
        text: editAmends?.person ?? fromHarm?.person ?? '');
    final planController =
        useTextEditingController(text: editAmends?.plan ?? '');
    final selectedType = useState<AmendsType>(
        editAmends?.amendsType ?? AmendsType.personal);
    final isStep9 = useState(
        editAmends?.status != 'step8' &&
            (editAmends?.plan?.isNotEmpty ?? false));

    // ── Timeframe state ────────────────────────────────────────────────────
    // useSpecificDate: true = calendar picker, false = general dropdown
    final useSpecificDate =
        useState(editAmends?.datePlanned != null && editAmends?.timeframe == null);
    final selectedTimeframe =
        useState<String>(editAmends?.timeframe ?? 'asap');
    final selectedDate = useState<DateTime?>(editAmends?.datePlanned);

    final isValid = useState(false);

    useEffect(() {
      void listener() {
        if (isStep9.value) {
          isValid.value = personController.text.trim().isNotEmpty &&
              planController.text.trim().isNotEmpty;
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

    Future<void> save() async {
      if (!isValid.value) return;
      final repo = ref.read(amendsRepositoryProvider);
      final newStatus = isStep9.value ? 'pending' : 'step8';
      final planText = planController.text.trim().isNotEmpty
          ? planController.text.trim()
          : null;

      // Timeframe is only written when in Step 9 mode
      final String? tfValue =
          isStep9.value && !useSpecificDate.value ? selectedTimeframe.value : null;
      final DateTime? dateValue =
          isStep9.value && useSpecificDate.value ? selectedDate.value : null;

      if (editAmends != null) {
        await repo.update(editAmends!.copyWith(
          person: personController.text.trim(),
          amendsType: Value(selectedType.value),
          plan: Value(planText),
          status: newStatus,
          timeframe: Value(tfValue),
          datePlanned: Value(dateValue),
        ));
      } else {
        await repo.insert(AmendsCompanion(
          person: Value(personController.text.trim()),
          amendsType: Value(selectedType.value),
          plan: Value(planText),
          status: Value(newStatus),
          timeframe: Value(tfValue),
          datePlanned: Value(dateValue),
          harmId:
              fromHarm != null ? Value(fromHarm!.id) : const Value.absent(),
        ));
      }

      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(editAmends != null ? 'Edit Amends' : 'Add to List')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Person ────────────────────────────────────────────────────
            TextField(
              controller: personController,
              decoration: const InputDecoration(
                labelText: 'Who am I making amends to?',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // ── Step 9 toggle ─────────────────────────────────────────────
            SwitchListTile(
              title: const Text('Ready to plan (Step 9)?'),
              subtitle: const Text('Turn on to add a specific amends plan'),
              value: isStep9.value,
              onChanged: (val) => isStep9.value = val,
            ),

            if (isStep9.value) ...[
              const SizedBox(height: 20),

              // ── Type ──────────────────────────────────────────────────
              DropdownButtonFormField<AmendsType>(
                value: selectedType.value,
                decoration: const InputDecoration(
                  labelText: 'Type of amends',
                  border: OutlineInputBorder(),
                ),
                items: AmendsType.values
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text(t.displayName)))
                    .toList(),
                onChanged: (v) => selectedType.value = v!,
              ),
              const SizedBox(height: 20),

              // ── Plan ──────────────────────────────────────────────────
              TextField(
                controller: planController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'The Plan',
                  hintText: 'Specific action I will take...',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // ── Timeframe section ─────────────────────────────────────
              Text('When do you plan to make this amend?',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 12),

              // General / Specific Date toggle
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('General Timeframe'),
                    icon: Icon(Icons.timelapse_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Specific Date'),
                    icon: Icon(Icons.calendar_today_outlined),
                  ),
                ],
                selected: {useSpecificDate.value},
                onSelectionChanged: (val) =>
                    useSpecificDate.value = val.first,
              ),
              const SizedBox(height: 16),

              if (!useSpecificDate.value) ...[
                // ── General dropdown ────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: selectedTimeframe.value,
                  decoration: const InputDecoration(
                    labelText: 'General timeframe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.schedule_outlined),
                  ),
                  items: _kTimeframes
                      .map((t) => DropdownMenuItem(
                            value: t.$1,
                            child: Text(t.$2),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) selectedTimeframe.value = v;
                  },
                ),
              ] else ...[
                // ── Date picker ─────────────────────────────────────────
                _DatePickerTile(
                  selectedDate: selectedDate.value,
                  onDateSelected: (d) => selectedDate.value = d,
                ),
              ],
            ],

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isValid.value ? save : null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56)),
              child:
                  Text(editAmends != null ? 'Update Amends' : 'Save Amends'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date picker tile ─────────────────────────────────────────────────────────

class _DatePickerTile extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerTile(
      {required this.selectedDate, required this.onDateSelected});

  String get _label {
    if (selectedDate == null) return 'Tap to select a date';
    final d = selectedDate!;
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? now,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365 * 10)),
          helpText: 'When will I make this amend?',
        );
        if (picked != null) onDateSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
              color: selectedDate != null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: selectedDate != null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _label,
              style: TextStyle(
                fontSize: 16,
                color: selectedDate != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey.shade500,
              ),
            ),
            const Spacer(),
            if (selectedDate != null)
              Icon(Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
