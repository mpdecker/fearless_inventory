import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../core/constants/character_defects.dart';
import '../../data/repositories/defect_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

/// A single Step 4 inventory entry presented in the Discovery Wizard.
class _Step4Item {
  final String sourceLabel; // 'Resentment', 'Fear', or 'Harm'
  final String displayText; // Human-readable description of the entry
  final String myPart;      // Pre-filled defect suggestion (may be empty)

  const _Step4Item({
    required this.sourceLabel,
    required this.displayText,
    required this.myPart,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider — aggregate all Step 4 entries from all three tables
// ─────────────────────────────────────────────────────────────────────────────

final discoveryItemsProvider = FutureProvider<List<_Step4Item>>((ref) async {
  final db = ref.read(databaseProvider);

  final resentments = await db.select(db.resentments).get();
  final fears       = await db.select(db.fears).get();
  final harms       = await db.select(db.harms).get();

  final items = <_Step4Item>[];

  for (final r in resentments) {
    items.add(_Step4Item(
      sourceLabel: 'Resentment',
      displayText: 'Resentful at ${r.person}: ${r.cause}',
      myPart: r.myPart.trim(),
    ));
  }
  for (final f in fears) {
    items.add(_Step4Item(
      sourceLabel: 'Fear',
      displayText: 'Fear: ${f.subject} — ${f.why}',
      myPart: f.myPart.trim(),
    ));
  }
  for (final h in harms) {
    items.add(_Step4Item(
      sourceLabel: 'Harm',
      displayText: 'Harm to ${h.person}: ${h.conduct}',
      myPart: h.myPart.trim(),
    ));
  }

  return items;
});

// ─────────────────────────────────────────────────────────────────────────────
// Wizard widget
// ─────────────────────────────────────────────────────────────────────────────

class DefectDiscoveryWizard extends ConsumerStatefulWidget {
  const DefectDiscoveryWizard({super.key});

  @override
  ConsumerState<DefectDiscoveryWizard> createState() =>
      _DefectDiscoveryWizardState();
}

class _DefectDiscoveryWizardState
    extends ConsumerState<DefectDiscoveryWizard> {
  int _currentIndex = 0;
  int _lastPrefillIndex = -1; // tracks which item last pre-filled the field
  late TextEditingController _defectController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _defectController = TextEditingController();
  }

  @override
  void dispose() {
    _defectController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _advanceTo(int nextIndex, List<_Step4Item> items) {
    setState(() {
      _currentIndex = nextIndex;
      _isSaving = false;
      // Pre-fill field with the next item's myPart (or clear it)
      if (nextIndex < items.length) {
        _defectController.text = items[nextIndex].myPart;
        _lastPrefillIndex = nextIndex;
      } else {
        _defectController.clear();
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(discoveryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery Wizard'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: itemsAsync.when(
        data: (items) {
          // Pre-fill field on first data load without triggering a rebuild loop
          if (_lastPrefillIndex == -1 && items.isNotEmpty) {
            Future.microtask(() {
              if (mounted && _lastPrefillIndex == -1) {
                setState(() {
                  _defectController.text = items[0].myPart;
                  _lastPrefillIndex = 0;
                });
              }
            });
          }

          if (items.isEmpty || _currentIndex >= items.length) {
            return _buildCompletionState(items.length);
          }
          return _buildWizardStep(items[_currentIndex], items);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading inventory: $e')),
      ),
    );
  }

  // ── Step screen ───────────────────────────────────────────────────────────

  Widget _buildWizardStep(_Step4Item item, List<_Step4Item> items) {
    final total = items.length;
    final progress = (_currentIndex + 1) / total;
    final selectedName = _defectController.text.trim().toLowerCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progress bar ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entry ${_currentIndex + 1} of $total',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade700),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                child: Text(
                  item.sourceLabel.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade500,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.indigo.shade50,
              valueColor:
                  AlwaysStoppedAnimation(Colors.indigo.shade500),
            ),
          ),
          const SizedBox(height: 24),

          // ── Inventory entry card ──────────────────────────────────
          _SectionLabel('FROM YOUR STEP 4 INVENTORY:'),
          const SizedBox(height: 8),
          Card(
            color: Colors.indigo.shade50,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.shade100)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                item.displayText,
                style: const TextStyle(
                    fontStyle: FontStyle.italic, fontSize: 15),
              ),
            ),
          ),
          if (item.myPart.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.arrow_forward,
                      size: 13, color: Colors.indigo.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'My part: ${item.myPart}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo.shade500,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),

          // ── Defect chips ──────────────────────────────────────────
          _SectionLabel('SELECT A DEFECT (OR TYPE YOUR OWN BELOW):'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: CharacterDefects.all.map((name) {
              final isSelected =
                  selectedName == name.toLowerCase();
              return ChoiceChip(
                label: Text(
                  name,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : null),
                ),
                selected: isSelected,
                selectedColor: Colors.indigo.shade600,
                backgroundColor: Colors.indigo.shade50,
                side: BorderSide(
                    color: isSelected
                        ? Colors.indigo.shade600
                        : Colors.indigo.shade200),
                onSelected: (_) =>
                    setState(() => _defectController.text = name),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Custom entry field ────────────────────────────────────
          _SectionLabel('OR ENTER A CUSTOM DEFECT:'),
          const SizedBox(height: 8),
          TextField(
            controller: _defectController,
            decoration: InputDecoration(
              hintText: 'e.g., Perfectionism, Controlling',
              border: const OutlineInputBorder(),
              suffixIcon: _defectController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                      onPressed: () => setState(() {
                        _defectController.clear();
                      }),
                    )
                  : null,
            ),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}), // refresh chip selection
          ),
          const SizedBox(height: 28),

          // ── Action buttons ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _advanceTo(_currentIndex + 1, items),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: Colors.blueGrey.shade300),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSaving ? null : () => _saveDefect(items),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_circle_outline),
                  label: const Text('Add to Step 6 List'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _saveDefect(List<_Step4Item> items) async {
    final name = _defectController.text.trim();
    if (name.isEmpty) {
      // Treat empty-field save as a skip
      _advanceTo(_currentIndex + 1, items);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(defectRepositoryProvider).insert(
            DefectsCompanion(
              name: Value(name),
              createdAt: Value(DateTime.now()),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added '$name' to your Step 6 list"),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _advanceTo(_currentIndex + 1, items);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save defect: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  // ── Completion ────────────────────────────────────────────────────────────

  Widget _buildCompletionState(int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Discovery Complete!',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              total > 0
                  ? 'You have reviewed all $total Step 4 inventory entries '
                      'and mapped them to character defects.'
                  : 'No Step 4 entries found yet.\n'
                      'Complete your inventory first, then return here.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Return to Defects List'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widget — small section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }
}
