import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/services/seed_data_service.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/services/sobriety_service.dart';
import '../../data/repositories/sponsee_repository.dart';
import '../../data/repositories/step12_repository.dart';
import '../../data/services/export_service.dart';
import 'step12_screen.dart' show AddSponseeSheet, AddStepCallSheet;
import 'providers/sponsee_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class SponseeDetailScreen extends ConsumerWidget {
  final int sponseeId;
  const SponseeDetailScreen({super.key, required this.sponseeId});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponseeAsync = ref.watch(sponseeProvider(sponseeId));

    return sponseeAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (sponsee) {
        if (sponsee == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sponsee')),
            body: const Center(child: Text('Sponsee not found.')),
          );
        }
        return _SponseeDetailBody(sponsee: sponsee);
      },
    );
  }
}

class _SponseeDetailBody extends ConsumerWidget {
  final Sponsee sponsee;
  const _SponseeDetailBody({required this.sponsee});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = sponsee.sobrietyDate != null
        ? DateTime.now().difference(sponsee.sobrietyDate!).inDays
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(sponsee.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'edit') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (_) => AddSponseeSheet(existing: sponsee),
                );
              } else if (val == 'deactivate') {
                await ref
                    .read(sponseeRepositoryProvider)
                    .setActive(sponsee.id, value: false);
                if (context.mounted) Navigator.pop(context);
              } else if (val == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Sponsee?'),
                    content: Text(
                        'This will remove ${sponsee.name} and all their progress. This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref
                      .read(sponseeRepositoryProvider)
                      .deleteSponsee(sponsee.id);
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ])),
              PopupMenuItem(
                  value: 'deactivate',
                  child: Row(children: [
                    Icon(Icons.person_off_outlined,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 10),
                    Text('Mark Inactive',
                        style:
                            TextStyle(color: Colors.orange.shade700)),
                  ])),
              const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ])),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Sobriety card ──────────────────────────────────────────
          if (sponsee.sobrietyDate != null || days != null)
            _SobrietyCard(sponsee: sponsee, days: days),

          // ── Contact info ───────────────────────────────────────────
          _ContactCard(sponsee: sponsee),

          // ── Step progress ──────────────────────────────────────────
          _StepProgressSection(sponseeId: sponsee.id),

          // ── Check-ins ──────────────────────────────────────────────
          _CheckInsSection(sponsee: sponsee),

          // ── Linked 12th step calls ─────────────────────────────────
          _SponseCallsSection(sponsee: sponsee),

          // ── Sponsor review import ──────────────────────────────────
          _ReviewSection(sponsee: sponsee),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sobriety card
// ─────────────────────────────────────────────────────────────────────────────

class _SobrietyCard extends StatelessWidget {
  final Sponsee sponsee;
  final int? days;
  const _SobrietyCard({required this.sponsee, required this.days});

  @override
  Widget build(BuildContext context) {
    final milestone = days != null
        ? SobrietyService.currentMilestone(days!)
        : null;
    final next = days != null ? SobrietyService.nextMilestone(days!) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.favorite, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(DateFormat('MMM d, yyyy').format(sponsee.sobrietyDate!),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13)),
          ]),
          const SizedBox(height: 6),
          if (days != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$days',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        letterSpacing: -1)),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text('days sober',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
            if (milestone != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('🎉 ${milestone.label} milestone',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ),
            if (next != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                    '${next.days - days!} days to ${next.label}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact card
// ─────────────────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final Sponsee sponsee;
  const _ContactCard({required this.sponsee});

  static final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    final hasContact =
        sponsee.phone != null || sponsee.email != null;
    if (!hasContact && sponsee.startedSponsoringDate == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contact',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            if (sponsee.phone != null)
              _InfoRow(
                  icon: Icons.phone_outlined, label: sponsee.phone!),
            if (sponsee.email != null)
              _InfoRow(
                  icon: Icons.email_outlined, label: sponsee.email!),
            if (sponsee.startedSponsoringDate != null)
              _InfoRow(
                icon: Icons.handshake_outlined,
                label: 'Sponsoring since ${_dateFmt.format(sponsee.startedSponsoringDate!)}',
              ),
            if (sponsee.notes != null && sponsee.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(sponsee.notes!,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4)),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step progress section
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressSection extends ConsumerWidget {
  final int sponseeId;
  const _StepProgressSection({required this.sponseeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(sponseeStepProgressProvider(sponseeId));

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Step Progress',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 10),
            progressAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (entries) {
                // Build a map for quick lookup
                final statusMap = {
                  for (final e in entries) e.stepNumber: e.status
                };

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (i) {
                    final step = i + 1;
                    final status = statusMap[step] ?? 'not_started';
                    return _StepChip(
                      step: step,
                      status: status,
                      onTap: () => _cycleStatus(
                          context, ref, step, status),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a step to cycle: not started → in progress → completed',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  void _cycleStatus(BuildContext context, WidgetRef ref, int step,
      String current) async {
    const cycle = ['not_started', 'in_progress', 'completed'];
    final nextIdx = (cycle.indexOf(current) + 1) % cycle.length;
    final next = cycle[nextIdx];
    await ref.read(sponseeRepositoryProvider).updateStepStatus(
          sponseeId,
          step,
          next,
          completedAt: next == 'completed' ? DateTime.now() : null,
        );
    // Update currentStep on the sponsee if completing a step.
    if (next == 'completed') {
      final sponsees =
          await ref.read(sponseeRepositoryProvider).watchAll().first;
      final sponsee = sponsees.firstWhere((s) => s.id == sponseeId,
          orElse: () => throw StateError('not found'));
      if ((sponsee.currentStep ?? 0) < step) {
        await ref
            .read(sponseeRepositoryProvider)
            .setCurrentStep(sponseeId, step);
      }
    }
  }
}

class _StepChip extends StatelessWidget {
  final int step;
  final String status;
  final VoidCallback onTap;
  const _StepChip(
      {required this.step, required this.status, required this.onTap});

  Color get _bg {
    switch (status) {
      case 'completed':
        return Colors.green.shade100;
      case 'in_progress':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color get _fg {
    switch (status) {
      case 'completed':
        return Colors.green.shade800;
      case 'in_progress':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade500;
    }
  }

  IconData? get _icon {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.timelapse;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _fg.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(_icon, size: 12, color: _fg),
              ),
            Text(
              'Step $step',
              style: TextStyle(
                  color: _fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Check-ins section
// ─────────────────────────────────────────────────────────────────────────────

class _CheckInsSection extends ConsumerWidget {
  final Sponsee sponsee;
  const _CheckInsSection({required this.sponsee});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInsAsync = ref.watch(sponseeCheckInsProvider(sponsee.id));
    final now = DateTime.now();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Check-ins',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _openAddCheckIn(context, ref, sponsee.id),
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Schedule', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.purple.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4)),
                ),
              ],
            ),
            checkInsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Error: $e'),
              data: (checkIns) {
                if (checkIns.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('No check-ins yet.',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13)),
                  );
                }

                final upcoming = checkIns
                    .where((c) =>
                        c.completedAt == null &&
                        c.scheduledAt.isAfter(now))
                    .toList()
                  ..sort((a, b) =>
                      a.scheduledAt.compareTo(b.scheduledAt));
                final done =
                    checkIns.where((c) => c.completedAt != null).toList()
                      ..sort((a, b) =>
                          b.scheduledAt.compareTo(a.scheduledAt));
                final overdue = checkIns
                    .where((c) =>
                        c.completedAt == null &&
                        !c.scheduledAt.isAfter(now))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (overdue.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Overdue',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                              letterSpacing: 0.5)),
                      for (final c in overdue)
                        _CheckInRow(
                          checkIn: c,
                          sponseeId: sponsee.id,
                          isOverdue: true,
                        ),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Upcoming',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade700,
                              letterSpacing: 0.5)),
                      for (final c in upcoming)
                        _CheckInRow(
                          checkIn: c,
                          sponseeId: sponsee.id,
                        ),
                    ],
                    if (done.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Completed',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5)),
                      for (final c in done.take(3))
                        _CheckInRow(checkIn: c, sponseeId: sponsee.id),
                      if (done.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('+${done.length - 3} more',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400)),
                        ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _openAddCheckIn(
      BuildContext context, WidgetRef ref, int sponseeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddCheckInSheet(sponseeId: sponseeId),
    );
  }
}

class _CheckInRow extends ConsumerWidget {
  final SponseeCheckIn checkIn;
  final int sponseeId;
  final bool isOverdue;
  const _CheckInRow(
      {required this.checkIn,
      required this.sponseeId,
      this.isOverdue = false});

  static final _dtFmt = DateFormat('MMM d, h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = checkIn.completedAt != null;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 0, right: 0),
      leading: Icon(
        isCompleted
            ? Icons.check_circle
            : isOverdue
                ? Icons.warning_amber_rounded
                : Icons.schedule_outlined,
        color: isCompleted
            ? Colors.green.shade600
            : isOverdue
                ? Colors.red.shade400
                : Colors.purple.shade500,
        size: 18,
      ),
      title: Text(
        _dtFmt.format(checkIn.scheduledAt),
        style: TextStyle(
            fontSize: 13,
            decoration:
                isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey.shade400 : null),
      ),
      subtitle: checkIn.notes != null && checkIn.notes!.isNotEmpty
          ? Text(checkIn.notes!,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)
          : null,
      trailing: isCompleted
          ? null
          : TextButton(
              onPressed: () async {
                await ref
                    .read(sponseeRepositoryProvider)
                    .completeCheckIn(checkIn.id);
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2)),
              child: const Text('Done', style: TextStyle(fontSize: 12)),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsee's 12th step calls
// ─────────────────────────────────────────────────────────────────────────────

class _SponseCallsSection extends ConsumerWidget {
  final Sponsee sponsee;
  const _SponseCallsSection({required this.sponsee});

  static final _dtFmt = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsAsync = ref.watch(sponseeCallsProvider(sponsee.id));

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('12th Step Calls',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24))),
                    builder: (_) => AddStepCallSheet(
                      sponseeId: sponsee.id,
                      sponseeName: sponsee.name,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Log', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4)),
                ),
              ],
            ),
            callsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Error: $e'),
              data: (calls) {
                if (calls.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('No calls logged for ${sponsee.name} yet.',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  );
                }
                return Column(
                  children: calls.take(5).map((c) {
                    final isScheduled = c.scheduledAt != null &&
                        c.scheduledAt!.isAfter(DateTime.now());
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                          isScheduled
                              ? Icons.event_outlined
                              : Icons.phone_in_talk_outlined,
                          size: 16,
                          color: isScheduled
                              ? Colors.purple.shade500
                              : Colors.blue.shade500),
                      title: Text(
                        c.description,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                          _dtFmt.format(c.scheduledAt ?? c.occurredAt),
                          style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsor review import section
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  final Sponsee sponsee;
  const _ReviewSection({required this.sponsee});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.purple.shade100)),
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined,
                    color: Colors.purple.shade700, size: 18),
                const SizedBox(width: 8),
                const Text('Sponsor Review',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'If ${sponsee.name} uses this app, they can export their '
              'Step 4 inventory for review. Paste the exported text below '
              'to view their resentments, fears, and harms.',
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.4),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openReviewImport(context),
                icon: const Icon(Icons.paste_outlined, size: 16),
                label: const Text('Import & Review Inventory'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple.shade700,
                  side: BorderSide(color: Colors.purple.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReviewImport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ReviewImportSheet(sponsee: sponsee),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review import sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewImportSheet extends StatefulWidget {
  final Sponsee sponsee;
  const _ReviewImportSheet({required this.sponsee});

  @override
  State<_ReviewImportSheet> createState() => _ReviewImportSheetState();
}

class _ReviewImportSheetState extends State<_ReviewImportSheet> {
  final _ctrl = TextEditingController();
  Map<String, dynamic>? _parsed;
  String? _error;
  String? _exportedAt;

  void _parse() {
    final result = ExportService.parseSponsorReviewJson(_ctrl.text.trim());
    setState(() {
      _error = result.error;
      _exportedAt = result.exportedAt;
      if (result.error == null) {
        _parsed = {
          'resentments': result.resentments,
          'fears': result.fears,
          'harms': result.harms,
        };
      } else {
        _parsed = null;
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text('Review ${widget.sponsee.name}\'s Inventory',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Ask your sponsee to share their Step 4 export (Settings → '
            'Export for Sponsor Review). Paste the full text below.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          if (_parsed == null) ...[
            TextField(
              controller: _ctrl,
              minLines: 6,
              maxLines: 12,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Paste JSON export here…',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _ctrl.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 12)),
              ),
            const SizedBox(height: 8),
            // Demo helper — pre-fill with Jordan's sample inventory JSON
            TextButton.icon(
              onPressed: () => setState(() {
                _ctrl.text = SeedDataService.sampleSponsorReviewJson;
                _error = null;
              }),
              icon: const Icon(Icons.science_outlined, size: 15),
              label: const Text('Paste sample data (demo)'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _ctrl.text.trim().isNotEmpty ? _parse : null,
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('Parse & Review'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ] else ...[
            // ── Parsed review ──────────────────────────────────────
            if (_exportedAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Exported on $_exportedAt',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ),

            _ReviewSection2(
              title: 'Resentments',
              icon: Icons.bolt_outlined,
              color: Colors.orange.shade700,
              items: (_parsed!['resentments']
                      as List<Map<String, dynamic>>)
                  .map((r) => _ReviewItem(
                        headline: r['person'] as String? ?? '',
                        lines: [
                          if (r['cause'] != null)
                            'Cause: ${r['cause']}',
                          if (r['affects'] != null)
                            'Affects: ${r['affects']}',
                          if (r['myPart'] != null)
                            'My part: ${r['myPart']}',
                        ],
                        flagged: r['flagForReview'] == true,
                      ))
                  .toList(),
            ),

            _ReviewSection2(
              title: 'Fears',
              icon: Icons.warning_amber_outlined,
              color: Colors.red.shade700,
              items: (_parsed!['fears']
                      as List<Map<String, dynamic>>)
                  .map((f) => _ReviewItem(
                        headline: f['subject'] as String? ?? '',
                        lines: [
                          if (f['why'] != null) 'Why: ${f['why']}',
                          if (f['myPart'] != null)
                            'My part: ${f['myPart']}',
                        ],
                        flagged: f['flagForReview'] == true,
                      ))
                  .toList(),
            ),

            _ReviewSection2(
              title: 'Harms',
              icon: Icons.people_outline,
              color: Colors.purple.shade700,
              items: (_parsed!['harms']
                      as List<Map<String, dynamic>>)
                  .map((h) => _ReviewItem(
                        headline: h['person'] as String? ?? '',
                        lines: [
                          if (h['conduct'] != null)
                            'Conduct: ${h['conduct']}',
                          if (h['myPart'] != null)
                            'My part: ${h['myPart']}',
                        ],
                        flagged: h['flagForReview'] == true,
                      ))
                  .toList(),
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _parsed = null;
                _error = null;
                _ctrl.clear();
              }),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Clear & Re-import'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewSection2 extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_ReviewItem> items;
  const _ReviewSection2(
      {required this.title,
      required this.icon,
      required this.color,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text('$title (${items.length})',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.3)),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('None.',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13)),
          )
        else
          for (final item in items) _ReviewItemCard(item: item, color: color),
        const Divider(height: 16),
      ],
    );
  }
}

class _ReviewItem {
  final String headline;
  final List<String> lines;
  final bool flagged;
  const _ReviewItem(
      {required this.headline,
      required this.lines,
      required this.flagged});
}

class _ReviewItemCard extends StatelessWidget {
  final _ReviewItem item;
  final Color color;
  const _ReviewItemCard(
      {required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.flagged ? color.withOpacity(0.07) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: item.flagged
                ? color.withOpacity(0.3)
                : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(item.headline,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14))),
              if (item.flagged)
                Icon(Icons.flag_rounded, size: 14, color: color),
            ],
          ),
          for (final line in item.lines)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(line,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add check-in sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddCheckInSheet extends ConsumerStatefulWidget {
  final int sponseeId;
  const _AddCheckInSheet({required this.sponseeId});

  @override
  ConsumerState<_AddCheckInSheet> createState() => _AddCheckInSheetState();
}

class _AddCheckInSheetState extends ConsumerState<_AddCheckInSheet> {
  DateTime _scheduledAt = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _notesCtrl = TextEditingController();

  static final _dateFmt = DateFormat('EEE, MMM d, yyyy');

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dt = DateTime(
      _scheduledAt.year,
      _scheduledAt.month,
      _scheduledAt.day,
      _time.hour,
      _time.minute,
    );
    final repo = ref.read(sponseeRepositoryProvider);
    await repo.insertCheckIn(SponseeCheckInsCompanion(
      sponseeId: Value(widget.sponseeId),
      scheduledAt: Value(dt),
      notes: Value(
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
    ));

    // Create a calendar event.
    final step12Repo = ref.read(step12RepositoryProvider);
    await step12Repo.insert(StepTwelveEventsCompanion(
      title: const Value('Sponsee Check-in'),
      startTime: Value(dt),
      endTime: Value(dt.add(const Duration(minutes: 60))),
      eventType: const Value('sponsee'),
    ));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Schedule Check-in',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final d = await showAdaptiveAppDatePicker(
                          context: context,
                          initialDate: _scheduledAt,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) setState(() => _scheduledAt = d);
                      },
                      icon: const Icon(Icons.calendar_today_outlined,
                          size: 16),
                      label: Text(_dateFmt.format(_scheduledAt)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final t = await showAdaptiveAppTimePicker(
                          context: context,
                          initialTime: _time,
                        );
                        if (t != null) setState(() => _time = t);
                      },
                      icon: const Icon(Icons.schedule_outlined, size: 16),
                      label: Text(_time.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Schedule',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
