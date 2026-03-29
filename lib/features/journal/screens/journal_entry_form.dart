import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/journal_repository.dart';
import '../data/step_tradition_content.dart';
import '../services/prompt_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// JournalEntryForm
// ─────────────────────────────────────────────────────────────────────────────

/// Create or edit a journal entry.
///
/// Pass [subject] to pre-associate the entry with a step or tradition.
/// Pass [entry] to edit an existing entry (creates a new one if null).
/// Pass [initialPrompt] when the user tapped a specific contemplative prompt.
class JournalEntryForm extends HookConsumerWidget {
  final JournalSubjectContent? subject;
  final JournalEntry? entry;
  final ContemplativePrompt? initialPrompt;

  const JournalEntryForm({
    super.key,
    this.subject,
    this.entry,
    this.initialPrompt,
  });

  bool get _isEditing => entry != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleCtrl = useTextEditingController(
      text: entry?.title ?? '',
    );
    final contentCtrl = useTextEditingController(
      text: entry?.content ?? '',
    );
    final isSaving = useState(false);

    // Track which prompt (if any) inspired this entry.
    final activePromptId = useState<String?>(
      entry?.promptId ?? initialPrompt?.id,
    );

    // Subject association — pre-filled but editable.
    final selectedStep = useState<int?>(
      entry?.stepNumber ?? (subject?.type == JournalSubjectType.step ? subject!.number : null),
    );
    final selectedTradition = useState<int?>(
      entry?.traditionNumber ?? (subject?.type == JournalSubjectType.tradition ? subject!.number : null),
    );

    final contentFocus = useFocusNode();

    // Auto-focus the content field when opened with a prompt.
    useEffect(() {
      if (initialPrompt != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          contentFocus.requestFocus();
        });
      }
      return null;
    }, const []);

    Future<void> save() async {
      final content = contentCtrl.text.trim();
      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write something before saving.')),
        );
        return;
      }

      isSaving.value = true;
      final repo = ref.read(journalRepositoryProvider);
      try {
        if (_isEditing) {
          await repo.update(
            id: entry!.id,
            content: content,
            title: titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
            stepNumber: selectedStep.value,
            traditionNumber: selectedTradition.value,
            promptId: activePromptId.value,
          );
        } else {
          await repo.insert(
            content: content,
            title: titleCtrl.text.trim().isEmpty ? null : titleCtrl.text.trim(),
            stepNumber: selectedStep.value,
            traditionNumber: selectedTradition.value,
            promptId: activePromptId.value,
          );
        }
        if (context.mounted) Navigator.pop(context);
      } finally {
        isSaving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Journal Entry'),
        actions: [
          if (isSaving.value)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: save,
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Prompt banner ──────────────────────────────────────────────
            if (initialPrompt != null)
              _PromptBanner(prompt: initialPrompt!),

            // ── Context selector ──────────────────────────────────────────
            _ContextSelector(
              selectedStep: selectedStep.value,
              selectedTradition: selectedTradition.value,
              onStepChanged: (s) {
                selectedStep.value = s;
                selectedTradition.value = null;
              },
              onTraditionChanged: (t) {
                selectedTradition.value = t;
                selectedStep.value = null;
              },
            ),

            const SizedBox(height: 16),

            // ── Title ────────────────────────────────────────────────────
            TextField(
              controller: titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                hintText: 'Give this entry a name…',
              ),
              maxLines: 1,
            ),

            const SizedBox(height: 16),

            // ── Content ──────────────────────────────────────────────────
            TextField(
              controller: contentCtrl,
              focusNode: contentFocus,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Your reflection',
                hintText: 'Write freely…',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              minLines: 10,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 8),
            Text(
              'Your journal is stored only on this device and is encrypted.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Displays the prompt text that inspired this entry.
class _PromptBanner extends StatelessWidget {
  final ContemplativePrompt prompt;

  const _PromptBanner({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prompt',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prompt.text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.85),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Drop-down selectors for step / tradition association.
class _ContextSelector extends StatelessWidget {
  final int? selectedStep;
  final int? selectedTradition;
  final ValueChanged<int?> onStepChanged;
  final ValueChanged<int?> onTraditionChanged;

  // ignore: prefer_const_constructors_in_immutables
  _ContextSelector({
    required this.selectedStep,
    required this.selectedTradition,
    required this.onStepChanged,
    required this.onTraditionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int?>(
            value: selectedStep,
            decoration: const InputDecoration(
              labelText: 'Step',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('— None —')),
              ...List.generate(
                12,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('Step ${i + 1}'),
                ),
              ),
            ],
            onChanged: onStepChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int?>(
            value: selectedTradition,
            decoration: const InputDecoration(
              labelText: 'Tradition',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('— None —')),
              ...List.generate(
                12,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('Tradition ${i + 1}'),
                ),
              ),
            ],
            onChanged: onTraditionChanged,
          ),
        ),
      ],
    );
  }
}
