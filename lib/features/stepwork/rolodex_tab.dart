import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/database/database.dart';
import '../../core/providers/sponsor_call_provider.dart';
import '../../data/repositories/meetings_repository.dart';
import '../../data/repositories/rolodex_repository.dart';
import '../../data/repositories/sponsee_repository.dart';
import 'sponsee_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final _allContactsProvider = StreamProvider.autoDispose<List<RolodexContact>>(
  (ref) => ref.watch(rolodexRepositoryProvider).watchAll(),
);

final _bookmarkedMeetingsProvider =
    StreamProvider.autoDispose<List<Meeting>>(
  (ref) => ref.watch(meetingsRepositoryProvider).watchBookmarked(),
);

// ─────────────────────────────────────────────────────────────────────────────
// RolodexTab — list
// ─────────────────────────────────────────────────────────────────────────────

class RolodexTab extends HookConsumerWidget {
  const RolodexTab({super.key});

  static void openAddContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const RolodexContactSheet(),
    );
  }

  static Future<void> openImportFromContacts(BuildContext context) async {
    final granted = await FlutterContacts.requestPermission(readonly: true);
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Contacts permission is required to import. '
                'Enable it in Settings.'),
          ),
        );
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _ContactPickerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(_allContactsProvider);
    final query = useState('');

    return contactsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (contacts) {
        final filtered = query.value.isEmpty
            ? contacts
            : contacts
                .where((c) =>
                    c.name.toLowerCase().contains(query.value.toLowerCase()) ||
                    (c.phone ?? '').contains(query.value))
                .toList();

        if (contacts.isEmpty) {
          return _RolodexEmptyState(
            onAdd: () => openAddContact(context),
            onImport: () => openImportFromContacts(context),
          );
        }

        return Column(
          children: [
            // ── Search bar + import button ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => query.value = v,
                      decoration: InputDecoration(
                        hintText: 'Search contacts…',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: query.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => query.value = '',
                              )
                            : null,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Import from Contacts',
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    color: Colors.tealAccent,
                    onPressed: () => openImportFromContacts(context),
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No contacts match "${query.value}"',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          _ContactCard(contact: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact card
// ─────────────────────────────────────────────────────────────────────────────

class _ContactCard extends ConsumerWidget {
  final RolodexContact contact;
  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openSheet(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              // ── Avatar ────────────────────────────────────────────
              CircleAvatar(
                radius: 22,
                backgroundColor: contact.isSponsor
                    ? Colors.tealAccent.withValues(alpha: 0.2)
                    : Colors.white10,
                child: Text(
                  contact.name.isNotEmpty
                      ? contact.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: contact.isSponsor
                        ? Colors.tealAccent
                        : Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Name + meta ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            contact.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.isSponsor) ...[
                          const SizedBox(width: 6),
                          _Badge(label: 'Sponsor', color: Colors.tealAccent),
                        ],
                        if (contact.sponseeId != null) ...[
                          const SizedBox(width: 6),
                          _Badge(label: 'Sponsee', color: Colors.purpleAccent),
                        ],
                      ],
                    ),
                    if (contact.phone != null && contact.phone!.isNotEmpty)
                      const SizedBox(height: 2),
                    if (contact.phone != null && contact.phone!.isNotEmpty)
                      Text(
                        contact.phone!,
                        style: TextStyle(
                            color: Colors.tealAccent.withValues(alpha: 0.8),
                            fontSize: 13),
                      ),
                    if (contact.address != null && contact.address!.isNotEmpty)
                      Text(
                        contact.address!,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // ── Quick-dial icon ───────────────────────────────────
              if (contact.phone != null && contact.phone!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.call_outlined,
                      color: Colors.tealAccent, size: 22),
                  tooltip: 'Call ${contact.name}',
                  onPressed: () => _dial(context, contact.phone!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => RolodexContactSheet(existing: contact),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add/edit sheet
// ─────────────────────────────────────────────────────────────────────────────

class RolodexContactSheet extends HookConsumerWidget {
  final RolodexContact? existing;
  const RolodexContactSheet({super.key, this.existing});

  bool get _isEditing => existing != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController(text: existing?.name ?? '');
    final phoneCtrl = useTextEditingController(text: existing?.phone ?? '');
    final emailCtrl = useTextEditingController(text: existing?.email ?? '');
    final addrCtrl = useTextEditingController(text: existing?.address ?? '');
    final notesCtrl = useTextEditingController(text: existing?.notes ?? '');

    final selectedMeetingId = useState<int?>(existing?.meetingId);
    final isSponsor = useState(existing?.isSponsor ?? false);
    final isSaving = useState(false);

    final meetingsAsync = ref.watch(_bookmarkedMeetingsProvider);

    // Map from id → meeting for display
    final meetings = meetingsAsync.maybeWhen(
      data: (list) => {for (final m in list) m.id: m},
      orElse: () => <int, Meeting>{},
    );

    final repo = ref.read(rolodexRepositoryProvider);
    final sponseeRepo = ref.read(sponseeRepositoryProvider);

    Future<void> save() async {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) return;
      isSaving.value = true;

      try {
        final phone =
            phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim();
        final email =
            emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim();
        final addr =
            addrCtrl.text.trim().isEmpty ? null : addrCtrl.text.trim();
        final notes =
            notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim();

        int contactId;

        if (_isEditing) {
          final updated = existing!.copyWith(
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(addr),
            notes: Value(notes),
            meetingId: Value(selectedMeetingId.value),
          );
          await repo.update(updated);
          contactId = existing!.id;
        } else {
          contactId = await repo.insert(RolodexContactsCompanion.insert(
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(addr),
            notes: Value(notes),
            meetingId: Value(selectedMeetingId.value),
          ));
        }

        // Handle sponsor toggle change
        final wasSponsored = existing?.isSponsor ?? false;
        if (isSponsor.value != wasSponsored) {
          await repo.setSponsor(contactId, value: isSponsor.value);

          // Sync phone to sponsor call prefs
          final config = ref
              .read(sponsorCallConfigProvider)
              .maybeWhen(data: (c) => c, orElse: () => null);
          if (config != null) {
            final newConfig = isSponsor.value
                ? config.copyWith(phone: phone)
                : config.copyWith(clearPhone: true);
            await ref
                .read(sponsorCallConfigProvider.notifier)
                .save(newConfig);
          }
        }

        if (context.mounted) Navigator.of(context).pop();
      } finally {
        isSaving.value = false;
      }
    }

    Future<void> makeSponsee() async {
      if (existing == null) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add as Sponsee?'),
          content: Text(
            'This will create a new sponsee entry for ${existing!.name} '
            'in the Sponsees tab.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Add Sponsee')),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final sponseeId = await sponseeRepo.insertSponsee(
        SponseesCompanion.insert(
          name: existing!.name,
          phone: Value(existing!.phone),
          email: Value(existing!.email),
        ),
      );
      await repo.setSponseeLink(existing!.id, sponseeId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${existing!.name} added as a sponsee.'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SponseeDetailScreen(sponseeId: sponseeId),
                ),
              ),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            // ── Handle ───────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            Text(
              _isEditing ? 'Edit Contact' : 'New Contact',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Name ─────────────────────────────────────────────────
            TextField(
              controller: nameCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),

            // ── Phone ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ),
                if (_isEditing &&
                    (existing!.phone ?? '').isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.call),
                    tooltip: 'Call now',
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black),
                    onPressed: () =>
                        _dial(context, existing!.phone!),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // ── Email ────────────────────────────────────────────────
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),

            // ── Address ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addrCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                ),
                if (_isEditing &&
                    (existing!.address ?? '').isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.map_outlined),
                    tooltip: 'Open in Maps',
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black),
                    onPressed: () =>
                        _openMaps(context, existing!.address!),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // ── Notes ────────────────────────────────────────────────
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Meeting association ──────────────────────────────────
            const Text('Met at meeting',
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _MeetingPicker(
              meetings: meetings,
              selectedId: selectedMeetingId.value,
              onChanged: (id) => selectedMeetingId.value = id,
            ),
            const SizedBox(height: 20),

            // ── Sponsor toggle ───────────────────────────────────────
            _SponsorToggleTile(
              value: isSponsor.value,
              onChanged: (v) => isSponsor.value = v,
            ),

            const SizedBox(height: 20),

            // ── Make sponsee ─────────────────────────────────────────
            if (_isEditing) ...[
              if (existing!.sponseeId == null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Add as Sponsee'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.purpleAccent),
                    foregroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: makeSponsee,
                )
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View Sponsee Record'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.purple.shade300),
                    foregroundColor: Colors.purple.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SponseeDetailScreen(
                          sponseeId: existing!.sponseeId!),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
            ],

            // ── Save ─────────────────────────────────────────────────
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: isSaving.value ? null : save,
              child: isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // ── Delete ───────────────────────────────────────────────
            if (_isEditing) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete Contact',
                    style: TextStyle(color: Colors.red)),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text(
            'Remove ${existing!.name} from your rolodex. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(rolodexRepositoryProvider).delete(existing!.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting picker
// ─────────────────────────────────────────────────────────────────────────────

class _MeetingPicker extends StatelessWidget {
  final Map<int, Meeting> meetings;
  final int? selectedId;
  final void Function(int?) onChanged;

  const _MeetingPicker({
    required this.meetings,
    required this.selectedId,
    required this.onChanged,
  });

  static const _weekdays = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  @override
  Widget build(BuildContext context) {
    if (meetings.isEmpty) {
      return Text(
        'No bookmarked meetings. Bookmark a meeting in the Meetings tab '
        'to associate a contact with it.',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      );
    }

    return DropdownButtonFormField<int?>(
      value: selectedId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.groups_outlined),
        hintText: 'None',
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('None'),
        ),
        ...meetings.values.map((m) {
          final day = m.weekday < 7 ? _weekdays[m.weekday] : '';
          return DropdownMenuItem<int?>(
            value: m.id,
            child: Text(
              '${m.name}${day.isNotEmpty ? ' ($day)' : ''}',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsor toggle tile
// ─────────────────────────────────────────────────────────────────────────────

class _SponsorToggleTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SponsorToggleTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? Colors.tealAccent.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.tealAccent.withValues(alpha: 0.4) : Colors.white12,
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.tealAccent,
        secondary: Icon(
          Icons.star_outline,
          color: value ? Colors.tealAccent : Colors.blueGrey,
        ),
        title: const Text('My Sponsor',
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          value
              ? "This person's phone number will be used for your sponsor "
                  'call reminder.'
              : 'Mark this contact as your sponsor to enable the call reminder.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _RolodexEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onImport;
  const _RolodexEmptyState({required this.onAdd, required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contacts_outlined,
                size: 72, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            const Text(
              'Your Rolodex is Empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add people you meet in the rooms — phone contacts, '
              'your sponsor, or potential sponsees.',
              style: TextStyle(color: Colors.grey.shade500, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Manually'),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal.shade700),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.contacts_outlined),
              label: const Text('Import from Contacts'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.tealAccent,
                side: const BorderSide(color: Colors.tealAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge chip
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact picker screen — browse & search device contacts, pick one to import
// ─────────────────────────────────────────────────────────────────────────────

class _ContactPickerScreen extends HookWidget {
  const _ContactPickerScreen();

  @override
  Widget build(BuildContext context) {
    final contacts = useState<List<Contact>>([]);
    final isLoading = useState(true);
    final query = useState('');

    useEffect(() {
      // Fetch names only — withProperties: true crashes on iOS when any
      // contact has a nil label (force-unwrap in SwiftFlutterContactsPlugin).
      // Properties are loaded lazily on tap via FlutterContacts.getContact.
      FlutterContacts.getContacts(
        withProperties: false,
        withPhoto: false,
        sorted: true,
      ).then((list) {
        contacts.value = list;
        isLoading.value = false;
      });
      return null;
    }, const []);

    final filtered = query.value.isEmpty
        ? contacts.value
        : contacts.value.where((c) {
            final name = c.displayName.toLowerCase();
            final q = query.value.toLowerCase();
            return name.contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Contacts'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (v) => query.value = v,
              decoration: InputDecoration(
                hintText: 'Search by name or number…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => query.value = '',
                      )
                    : null,
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? Center(
                  child: Text(
                    query.value.isEmpty
                        ? 'No contacts found on this device.'
                        : 'No contacts match "${query.value}"',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade800,
                        child: Text(
                          c.displayName.isNotEmpty
                              ? c.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(c.displayName),
                      onTap: () => _openPrefilled(context, c.id, c.displayName),
                    );
                  },
                ),
    );
  }

  Future<void> _openPrefilled(
    BuildContext context,
    String contactId,
    String displayName,
  ) async {
    // Fetch properties individually — avoids the SwiftFlutterContactsPlugin
    // nil-unwrap crash that occurs when fetching all contacts with properties.
    final full = await FlutterContacts.getContact(
      contactId,
      withProperties: true,
      withPhoto: false,
    );

    if (!context.mounted) return;

    final phone =
        full != null && full.phones.isNotEmpty ? full.phones.first.number : null;
    final email =
        full != null && full.emails.isNotEmpty ? full.emails.first.address : null;

    String? address;
    if (full != null && full.addresses.isNotEmpty) {
      final a = full.addresses.first;
      final parts = [a.street, a.city, a.state, a.postalCode]
          .where((s) => s.isNotEmpty)
          .join(', ');
      if (parts.isNotEmpty) address = parts;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PrefilledContactSheet(
          name: displayName,
          phone: phone,
          email: email,
          address: address,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pre-filled contact sheet — wraps RolodexContactSheet with device contact data
// ─────────────────────────────────────────────────────────────────────────────

class _PrefilledContactSheet extends StatelessWidget {
  final String name;
  final String? phone;
  final String? email;
  final String? address;

  const _PrefilledContactSheet({
    required this.name,
    this.phone,
    this.email,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _PrefilledSheetBody(
            name: name,
            phone: phone,
            email: email,
            address: address,
          ),
        ),
      ),
    );
  }
}

class _PrefilledSheetBody extends HookConsumerWidget {
  final String name;
  final String? phone;
  final String? email;
  final String? address;

  const _PrefilledSheetBody({
    required this.name,
    this.phone,
    this.email,
    this.address,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController(text: name);
    final phoneCtrl = useTextEditingController(text: phone ?? '');
    final emailCtrl = useTextEditingController(text: email ?? '');
    final addrCtrl = useTextEditingController(text: address ?? '');
    final notesCtrl = useTextEditingController();

    final selectedMeetingId = useState<int?>(null);
    final isSponsor = useState(false);
    final isSaving = useState(false);

    final meetingsAsync = ref.watch(_bookmarkedMeetingsProvider);
    final meetings = meetingsAsync.maybeWhen(
      data: (list) => {for (final m in list) m.id: m},
      orElse: () => <int, Meeting>{},
    );

    final repo = ref.read(rolodexRepositoryProvider);

    Future<void> save() async {
      final n = nameCtrl.text.trim();
      if (n.isEmpty) return;
      isSaving.value = true;

      try {
        final ph = phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim();
        final em = emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim();
        final ad = addrCtrl.text.trim().isEmpty ? null : addrCtrl.text.trim();
        final nt = notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim();

        final contactId = await repo.insert(RolodexContactsCompanion.insert(
          name: n,
          phone: Value(ph),
          email: Value(em),
          address: Value(ad),
          notes: Value(nt),
          meetingId: Value(selectedMeetingId.value),
        ));

        if (isSponsor.value) {
          await repo.setSponsor(contactId, value: true);
          final config = ref
              .read(sponsorCallConfigProvider)
              .maybeWhen(data: (c) => c, orElse: () => null);
          if (config != null) {
            await ref
                .read(sponsorCallConfigProvider.notifier)
                .save(config.copyWith(phone: ph));
          }
        }

        if (context.mounted) {
          // Pop back to the contact picker, then the rolodex tab
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$n added to your Rolodex.')),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: addrCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: notesCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Met at meeting',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _MeetingPicker(
            meetings: meetings,
            selectedId: selectedMeetingId.value,
            onChanged: (id) => selectedMeetingId.value = id,
          ),
          const SizedBox(height: 20),
          _SponsorToggleTile(
            value: isSponsor.value,
            onChanged: (v) => isSponsor.value = v,
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: isSaving.value ? null : save,
            child: isSaving.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save to Rolodex',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared URL helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _dial(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the phone dialler.')),
    );
  }
}

Future<void> _openMaps(BuildContext context, String address) async {
  final encoded = Uri.encodeComponent(address);
  final uri = Platform.isIOS
      ? Uri.parse('https://maps.apple.com/?q=$encoded')
      : Uri.parse('geo:0,0?q=$encoded');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Maps.')),
    );
  }
}
