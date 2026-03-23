import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/repositories/step5_repository.dart';
import '../../data/services/export_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider: loads Step 4 data once for the ceremony
// ─────────────────────────────────────────────────────────────────────────────

final _step5DataProvider =
    FutureProvider.autoDispose<_Step5Data>((ref) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final resentments = await repo.watchResentments().first;
  final fears = await repo.watchFears().first;
  final harms = await repo.watchHarms().first;
  return _Step5Data(resentments: resentments, fears: fears, harms: harms);
});

class _Step5Data {
  final List<Resentment> resentments;
  final List<Fear> fears;
  final List<Harm> harms;
  const _Step5Data(
      {required this.resentments, required this.fears, required this.harms});
}

// ─────────────────────────────────────────────────────────────────────────────
// Main ceremony widget
// ─────────────────────────────────────────────────────────────────────────────

class Step5CeremonyScreen extends HookConsumerWidget {
  const Step5CeremonyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_step5DataProvider);
    final page = useState(0); // 0=prep 1=resentments 2=fears 3=harms 4=admissions 5=done

    return dataAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: Center(child: Text('Error loading inventory: $e'))),
      data: (data) => _CeremonyBody(
        data: data,
        currentPage: page.value,
        onNext: () => page.value++,
        onBack: () => page.value--,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ceremony body — switches between pages via IndexedStack-style logic
// ─────────────────────────────────────────────────────────────────────────────

class _CeremonyBody extends HookConsumerWidget {
  final _Step5Data data;
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _CeremonyBody({
    required this.data,
    required this.currentPage,
    required this.onNext,
    required this.onBack,
  });

  static const int _totalPages = 6;
  static const List<String> _pageTitles = [
    'Preparation',
    'Resentments',
    'Fears',
    'Harms',
    'Three Admissions',
    'Complete',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1429),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: currentPage > 0 && currentPage < 5
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                onPressed: onBack,
              )
            : null,
        title: Text(
          _pageTitles[currentPage],
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        bottom: currentPage > 0 && currentPage < 5
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: currentPage / (_totalPages - 2),
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF00BFA5)),
                ),
              )
            : null,
      ),
      body: _buildCurrentPage(context, ref),
    );
  }

  Widget _buildCurrentPage(BuildContext context, WidgetRef ref) {
    switch (currentPage) {
      case 0:
        return _PreparationPage(
            data: data, onBegin: onNext);
      case 1:
        return _InventoryReviewPage(
          title: 'Resentments',
          subtitle:
              'Read each resentment — the person, the cause, how it affected you, and your part.',
          itemCount: data.resentments.length,
          emptyMessage: 'No resentments recorded.',
          items: data.resentments
              .map((r) => _ReviewItem(
                    heading: r.person,
                    body: r.cause,
                    detail: r.myPart.isNotEmpty ? 'My part: ${r.myPart}' : null,
                    flagged: r.flagForReview,
                  ))
              .toList(),
          onContinue: onNext,
          onBack: onBack,
        );
      case 2:
        return _InventoryReviewPage(
          title: 'Fears',
          subtitle:
              'Read each fear — what you were afraid of, why, and your part in it.',
          itemCount: data.fears.length,
          emptyMessage: 'No fears recorded.',
          items: data.fears
              .map((f) => _ReviewItem(
                    heading: f.subject,
                    body: f.why,
                    detail: f.myPart.isNotEmpty ? 'My part: ${f.myPart}' : null,
                    flagged: f.flagForReview,
                  ))
              .toList(),
          onContinue: onNext,
          onBack: onBack,
        );
      case 3:
        return _InventoryReviewPage(
          title: 'Harms',
          subtitle:
              'Read each harm — who you hurt, what you did, and your part.',
          itemCount: data.harms.length,
          emptyMessage: 'No harms recorded.',
          items: data.harms
              .map((h) => _ReviewItem(
                    heading: h.person,
                    body: h.conduct,
                    detail: h.myPart.isNotEmpty ? 'My part: ${h.myPart}' : null,
                    flagged: h.flagForReview,
                  ))
              .toList(),
          onContinue: onNext,
          onBack: onBack,
        );
      case 4:
        return _AdmissionsPage(
          data: data,
          onComplete: onNext,
          onBack: onBack,
          ref: ref,
        );
      case 5:
        return _CompletionPage(data: data);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 0: Preparation
// ─────────────────────────────────────────────────────────────────────────────

class _PreparationPage extends StatelessWidget {
  final _Step5Data data;
  final VoidCallback onBegin;

  const _PreparationPage({required this.data, required this.onBegin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Text(
            'Step Five',
            style: TextStyle(
              color: Color(0xFF00BFA5),
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Admitted to God, to ourselves, and to another human being the exact nature of our wrongs.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.4,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'You are about to review your entire Step Four inventory. '
            'Take your time with each entry. '
            'When you are ready, you will make three admissions '
            'that complete this step.',
            style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 24),
          _InventorySummaryChips(data: data),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onBegin,
              child: const Text('Begin Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InventorySummaryChips extends StatelessWidget {
  final _Step5Data data;
  const _InventorySummaryChips({required this.data});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        _Chip(
            label: '${data.resentments.length} Resentments',
            icon: Icons.format_list_bulleted,
            color: Colors.redAccent),
        _Chip(
            label: '${data.fears.length} Fears',
            icon: Icons.warning_amber_rounded,
            color: Colors.amber),
        _Chip(
            label: '${data.harms.length} Harms',
            icon: Icons.people_outline,
            color: Colors.teal),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label,
          style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pages 1–3: Read-only inventory review
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewItem {
  final String heading;
  final String body;
  final String? detail;
  final bool flagged;
  const _ReviewItem(
      {required this.heading,
      required this.body,
      this.detail,
      required this.flagged});
}

class _InventoryReviewPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final int itemCount;
  final String emptyMessage;
  final List<_ReviewItem> items;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const _InventoryReviewPage({
    required this.title,
    required this.subtitle,
    required this.itemCount,
    required this.emptyMessage,
    required this.items,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Text(
            subtitle,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(emptyMessage,
                      style: const TextStyle(color: Colors.white54)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: item.flagged
                            ? const Color(0xFF00BFA5).withOpacity(0.08)
                            : const Color(0xFF1E2A44),
                        borderRadius: BorderRadius.circular(12),
                        border: item.flagged
                            ? Border.all(
                                color: const Color(0xFF00BFA5).withOpacity(0.4),
                                width: 1)
                            : null,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.heading,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (item.flagged)
                                const Icon(
                                    Icons.supervised_user_circle_outlined,
                                    size: 16,
                                    color: Color(0xFF00BFA5)),
                            ],
                          ),
                          if (item.body.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(item.body,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13,
                                    height: 1.4)),
                          ],
                          if (item.detail != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.detail!,
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onContinue,
              child: const Text('I have read these — Continue',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 4: Three Admissions
// ─────────────────────────────────────────────────────────────────────────────

class _AdmissionsPage extends HookWidget {
  final _Step5Data data;
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final WidgetRef ref;

  const _AdmissionsPage({
    required this.data,
    required this.onComplete,
    required this.onBack,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final admittedToSelf = useState(false);
    final admittedToHigherPower = useState(false);
    final admittedToSponsor = useState(false);
    final reflectionController = useTextEditingController();
    final isSaving = useState(false);

    final allChecked = admittedToSelf.value &&
        admittedToHigherPower.value &&
        admittedToSponsor.value;

    Future<void> complete() async {
      if (!allChecked || isSaving.value) return;
      isSaving.value = true;
      try {
        await ref.read(step5RepositoryProvider).recordCompletion(
              admittedToSelf: admittedToSelf.value,
              admittedToHigherPower: admittedToHigherPower.value,
              admittedToSponsor: admittedToSponsor.value,
              reflection: reflectionController.text.trim().isNotEmpty
                  ? reflectionController.text.trim()
                  : null,
              resentmentCount: data.resentments.length,
              fearCount: data.fears.length,
              harmCount: data.harms.length,
            );
        onComplete();
      } finally {
        isSaving.value = false;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Having reviewed my inventory, I now make three admissions.',
            style: TextStyle(
                color: Colors.white60, fontSize: 14, height: 1.6,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 32),

          // ── Admission 1 ───────────────────────────────────────────────
          _AdmissionTile(
            number: '1',
            title: 'Admitted to myself',
            body:
                'I have honestly examined the nature of my wrongs, without minimising or exaggerating.',
            checked: admittedToSelf.value,
            onChanged: (v) => admittedToSelf.value = v ?? false,
          ),
          const SizedBox(height: 16),

          // ── Admission 2 ───────────────────────────────────────────────
          _AdmissionTile(
            number: '2',
            title: 'Admitted to my Higher Power',
            body:
                'I have brought this inventory honestly before the God of my understanding.',
            checked: admittedToHigherPower.value,
            onChanged: (v) => admittedToHigherPower.value = v ?? false,
          ),
          const SizedBox(height: 16),

          // ── Admission 3 ───────────────────────────────────────────────
          _AdmissionTile(
            number: '3',
            title: 'Admitted to another person',
            body:
                'I have shared the exact nature of my wrongs with my sponsor or a trusted person in recovery.',
            checked: admittedToSponsor.value,
            onChanged: (v) => admittedToSponsor.value = v ?? false,
          ),

          const SizedBox(height: 32),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),

          // ── Optional reflection ───────────────────────────────────────
          const Text('Reflection (optional)',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: reflectionController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  'What came up for you? What are you feeling now?',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF00BFA5))),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: allChecked
                    ? const Color(0xFF00BFA5)
                    : Colors.white12,
                foregroundColor:
                    allChecked ? Colors.black : Colors.white30,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: allChecked && !isSaving.value ? complete : null,
              child: isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Complete Step Five',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          if (!allChecked)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Check all three admissions to continue.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _AdmissionTile extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  const _AdmissionTile({
    required this.number,
    required this.title,
    required this.body,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: checked
            ? const Color(0xFF00BFA5).withOpacity(0.10)
            : const Color(0xFF1E2A44),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: checked
              ? const Color(0xFF00BFA5).withOpacity(0.5)
              : Colors.white12,
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: const Color(0xFF00BFA5),
        checkColor: Colors.black,
        value: checked,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextStyle(
            color: checked ? const Color(0xFF00BFA5) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            body,
            style: const TextStyle(
                color: Colors.white54, fontSize: 13, height: 1.4),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page 5: Completion
// ─────────────────────────────────────────────────────────────────────────────

class _CompletionPage extends ConsumerWidget {
  final _Step5Data data;
  const _CompletionPage({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateTime.now().toIso8601String().split('T').first;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA5).withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF00BFA5).withOpacity(0.5), width: 2),
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF00BFA5), size: 40),
          ),
          const SizedBox(height: 28),
          const Text(
            'Step Five Complete',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 28),
          const Text(
            '"We are now at Step Six. Many of us thought this was a beginning, not an ending."',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '— Twelve Steps and Twelve Traditions',
            style: TextStyle(color: Colors.white30, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // ── Export ─────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00BFA5),
                side:
                    const BorderSide(color: Color(0xFF00BFA5), width: 1),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Export Step 5 Worksheet'),
              onPressed: () => _exportWorksheet(context, ref),
            ),
          ),
          const SizedBox(height: 14),
          // ── Return ─────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                // Pop all the way back to the root navigator
                Navigator.of(context)
                    .popUntil((route) => route.isFirst);
              },
              child: const Text('Return to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _exportWorksheet(BuildContext context, WidgetRef ref) async {
    final latestCompletion =
        await ref.read(step5RepositoryProvider).latestCompletion();
    await ExportService.generateStep5CompletionPdf(
      resentments: data.resentments,
      fears: data.fears,
      harms: data.harms,
      completedAt: latestCompletion?.completedAt ?? DateTime.now(),
      reflection: latestCompletion?.reflection,
    );
  }
}
