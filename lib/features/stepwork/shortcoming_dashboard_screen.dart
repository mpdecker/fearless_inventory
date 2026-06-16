import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants/character_defects.dart';
import '../../core/database/database.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/widgets/quote_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../data/repositories/shortcomings_repository.dart';
import '../../data/repositories/defect_repository.dart';
import 'providers/defect_providers.dart';
import 'providers/shortcoming_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ShortcomingDashboardScreen extends ConsumerWidget {
  const ShortcomingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defectsAsync = ref.watch(defectsListProvider);
    final logsAsync = ref.watch(allShortcomingLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 7: Shortcomings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(defectsListProvider);
          ref.invalidate(allShortcomingLogsProvider);
          ref.invalidate(step4PatternsProvider);
        },
        child: defectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (defects) => logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (logs) => _ShortcomingBody(
              defects: defects,
              logs: logs,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Log Shortcoming'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ── Info dialog ────────────────────────────────────────────────────────────
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Defects vs. Shortcomings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Character defects are the persistent underlying flaws we '
              'carry — pride, fear, selfishness, and the like.\n\n'
              'Shortcomings are the specific instances where we failed to '
              'act better than those defects would lead us to act. Each '
              'log here names one such moment.',
            ),
            SizedBox(height: 12),
            QuoteCard(quote: RecoveryQuotes.step7Humility, compact: true),
            QuoteCard(quote: RecoveryQuotes.step7Prayer, compact: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ── Log dialog (reusable for FAB, defect-header taps, and edits) ──────────
  static void _showLogDialog(
      BuildContext context, WidgetRef ref, Defect? preselectedDefect,
      {ShortcomingLog? existingLog}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => _LogShortcomingSheet(
        preselectedDefect: preselectedDefect,
        existingLog: existingLog,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — grouped list
// ─────────────────────────────────────────────────────────────────────────────

class _ShortcomingBody extends StatelessWidget {
  final List<Defect> defects;
  final List<ShortcomingLog> logs;

  const _ShortcomingBody({required this.defects, required this.logs});

  @override
  Widget build(BuildContext context) {
    final unlinked = logs.where((l) => l.defectId == null).toList();

    if (defects.isEmpty && logs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(

      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Step 7 quote ───────────────────────────────────────────────────
        const QuoteCard(quote: RecoveryQuotes.step7Humility, compact: true),
        const SizedBox(height: 4),
        // ── Step 4 patterns panel ──────────────────────────────────────────
        const _Step4PatternsPanel(),
        const SizedBox(height: 20),

        // ── Defect-grouped sections ────────────────────────────────────────
        if (defects.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'No character defects identified yet. Complete the Step 6 '
              'Discovery Wizard first to map your shortcomings.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ...defects.map((defect) {
            final defectLogs =
                logs.where((l) => l.defectId == defect.id).toList();
            return _DefectSection(
              defect: defect,
              logs: defectLogs,
            );
          }),

        // ── Unlinked catch-all ─────────────────────────────────────────────
        if (unlinked.isNotEmpty) ...[
          const SizedBox(height: 8),
          _DefectSection(
            defect: null,
            logs: unlinked,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 64, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'No Shortcomings Logged',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Use the Step 6 wizard to identify character defects, then '
              'log specific instances of failing to act better than those '
              'defects here for Step 7 prayer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Defect section
// ─────────────────────────────────────────────────────────────────────────────

class _DefectSection extends ConsumerWidget {
  final Defect? defect; // null = catch-all / unlinked
  final List<ShortcomingLog> logs;

  const _DefectSection({required this.defect, required this.logs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlinked = defect == null;
    final name = isUnlinked ? 'Other (No Defect Linked)' : defect!.name;
    final color = isUnlinked ? Colors.grey.shade600 : Colors.teal.shade700;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isUnlinked ? Colors.grey.shade200 : Colors.teal.shade100,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: logs.isNotEmpty,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(
            isUnlinked
                ? Icons.help_outline
                : Icons.account_tree_outlined,
            color: color,
            size: 18,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15),
        ),
        subtitle: Text(
          '${logs.length} instance${logs.length == 1 ? '' : 's'} logged',
          style: TextStyle(
              fontSize: 12,
              color: isUnlinked
                  ? Colors.grey.shade500
                  : Colors.teal.shade400),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick-log button for this defect
            if (!isUnlinked)
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: color),
                tooltip: 'Log instance of ${defect!.name}',
                onPressed: () => ShortcomingDashboardScreen._showLogDialog(
                    context, ref, defect),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          if (logs.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'No instances logged yet for this defect.',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13),
              ),
            )
          else
            ...logs.map((log) => _LogTile(log: log)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Log tile
// ─────────────────────────────────────────────────────────────────────────────

class _LogTile extends ConsumerWidget {
  final ShortcomingLog log;
  const _LogTile({required this.log});

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: const Icon(Icons.radio_button_unchecked,
          size: 18, color: Colors.teal),
      title: Text(log.description, style: const TextStyle(fontSize: 14)),
      subtitle: Text(_formatDate(log.dateObserved),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Edit ──────────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Colors.blueGrey, size: 20),
            tooltip: 'Edit this shortcoming',
            onPressed: () => ShortcomingDashboardScreen._showLogDialog(
              context,
              ref,
              null,
              existingLog: log,
            ),
          ),
          // ── Delete ────────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            tooltip: 'Delete this shortcoming',
            onPressed: () =>
                ref.read(shortcomingRepositoryProvider).delete(log.id),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 patterns panel
// ─────────────────────────────────────────────────────────────────────────────

class _Step4PatternsPanel extends ConsumerWidget {
  const _Step4PatternsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternsAsync = ref.watch(step4PatternsProvider);

    return Card(
      elevation: 0,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))),
        leading: Icon(Icons.lightbulb_outline,
            color: Colors.amber.shade700),
        title: Text(
          'Step 4 Patterns (My Part)',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.amber.shade800),
        ),
        subtitle: Text(
          'Recurring behaviors from your inventory — use these as '
          'inspiration when naming a shortcoming.',
          style:
              TextStyle(fontSize: 12, color: Colors.amber.shade700),
        ),
        children: [
          patternsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Could not load patterns: $e'),
            ),
            data: (patterns) => patterns.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Complete your Step 4 inventory entries with '
                      '"My Part" text to see patterns here.',
                      style: TextStyle(
                          color: Colors.amber.shade700, fontSize: 13),
                    ),
                  )
                : Padding(
                    padding:
                        const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: patterns
                          .map((p) => _PatternChip(text: p))
                          .toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _PatternChip extends ConsumerWidget {
  final String text;
  const _PatternChip({required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      label: Text(text,
          style: TextStyle(
              fontSize: 12, color: Colors.amber.shade900)),
      backgroundColor: Colors.amber.shade100,
      side: BorderSide(color: Colors.amber.shade300),
      tooltip: 'Tap to pre-fill a new shortcoming log',
      onPressed: () {
        // Open the log dialog pre-filled with this phrase
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => _LogShortcomingSheet(
            prefillDescription: text,
            preselectedDefect: null,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Log shortcoming bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _LogShortcomingSheet extends ConsumerStatefulWidget {
  final Defect? preselectedDefect;
  final String? prefillDescription;
  /// When set, the sheet operates in edit mode for the existing log.
  final ShortcomingLog? existingLog;

  const _LogShortcomingSheet({
    this.preselectedDefect,
    this.prefillDescription,
    this.existingLog,
  });

  @override
  ConsumerState<_LogShortcomingSheet> createState() =>
      _LogShortcomingSheetState();
}

class _LogShortcomingSheetState
    extends ConsumerState<_LogShortcomingSheet> {
  late final TextEditingController _descController;

  /// The currently selected defect *name* (may be from catalog or canonical list).
  /// Null means "no defect linked".
  String? _selectedDefectName;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.existingLog != null;

  @override
  void initState() {
    super.initState();
    final log = widget.existingLog;
    _descController = TextEditingController(
      text: log?.description ?? widget.prefillDescription ?? '',
    );
    _selectedDefectName = widget.preselectedDefect?.name;
    if (log != null) _date = log.dateObserved;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  /// Resolve the name for the existing log's defectId once the catalog is loaded.
  /// Only runs once when editing and the defect hasn't been resolved yet.
  void _resolveDefectFromLog(List<Defect> catalog) {
    if (_isEditing &&
        widget.existingLog!.defectId != null &&
        _selectedDefectName == null) {
      final matches =
          catalog.where((d) => d.id == widget.existingLog!.defectId);
      if (matches.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedDefectName = matches.first.name);
        });
      }
    }
  }

  /// Build a deduplicated, ordered list of defect name options.
  ///
  /// The user's personal catalog comes first (preserving their ordering),
  /// followed by any canonical defects not already represented by name.
  List<String> _buildDefectOptions(List<Defect> catalog) {
    final options = <String>[];
    final seen = <String>{};

    for (final d in catalog) {
      final key = d.name.trim().toLowerCase();
      if (seen.add(key)) options.add(d.name.trim());
    }
    for (final name in CharacterDefects.all) {
      final key = name.toLowerCase();
      if (seen.add(key)) options.add(name);
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final defectsAsync = ref.watch(defectsListProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ────────────────────────────────────────────────────
          Text(
            _isEditing ? 'Edit Shortcoming' : 'Log a Shortcoming',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Describe a specific moment when you failed to act better '
            'than your character defect would lead you to act.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // ── Description ──────────────────────────────────────────────
          TextField(
            controller: _descController,
            autofocus: !_isEditing,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'What specifically did I do or fail to do?',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // ── Defect selector ───────────────────────────────────────────
          // Always shown — falls back to canonical list when catalog is empty.
          defectsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (catalog) {
              _resolveDefectFromLog(catalog);
              final options = _buildDefectOptions(catalog);
              return DropdownButtonFormField<String?>(
                value: _selectedDefectName,
                decoration: const InputDecoration(
                  labelText: 'Which character defect drove this?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_tree_outlined),
                ),
                hint: const Text('Select a defect (optional)'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('— None / Unlinked —',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ...options.map(
                    (name) => DropdownMenuItem<String?>(
                      value: name,
                      child: Text(name),
                    ),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _selectedDefectName = v),
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Date ─────────────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final picked = await showAdaptiveAppDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Text('Date: ${_formatDate(_date)}',
                      style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Save ─────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final text = _descController.text.trim();
                if (text.isEmpty) return;

                // Resolve defect id — find existing defect by name or
                // create a new catalog entry if it doesn't exist yet.
                int? defectId;
                if (_selectedDefectName != null) {
                  defectId = await ref
                      .read(defectRepositoryProvider)
                      .findOrCreateByName(_selectedDefectName!);
                }

                final repo = ref.read(shortcomingRepositoryProvider);

                if (_isEditing) {
                  await repo.update(widget.existingLog!.copyWith(
                    description: text,
                    dateObserved: _date,
                    defectId: Value(defectId),
                  ));
                } else {
                  await repo.insert(ShortcomingLogsCompanion(
                    description: Value(text),
                    dateObserved: Value(_date),
                    defectId: Value(defectId),
                  ));
                }

                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text(
                  _isEditing ? 'Update Shortcoming' : 'Save Shortcoming'),
            ),
          ),
        ],
      ),
    );
  }
}
