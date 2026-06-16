import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';

final rolodexRepositoryProvider =
    Provider((ref) => RolodexRepository(ref.watch(databaseProvider)));

class RolodexRepository {
  final AppDatabase _db;
  RolodexRepository(this._db);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// All contacts, sponsor first then alphabetical.
  Stream<List<RolodexContact>> watchAll() =>
      (_db.select(_db.rolodexContacts)
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.isSponsor, mode: OrderingMode.desc),
              (t) =>
                  OrderingTerm(expression: t.name, mode: OrderingMode.asc),
            ]))
          .watch();

  /// Contacts associated with a specific meeting.
  Stream<List<RolodexContact>> watchByMeeting(int meetingId) =>
      (_db.select(_db.rolodexContacts)
            ..where((t) => t.meetingId.equals(meetingId))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.name, mode: OrderingMode.asc),
            ]))
          .watch();

  Future<RolodexContact?> getById(int id) =>
      (_db.select(_db.rolodexContacts)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<int> insert(RolodexContactsCompanion entry) =>
      _db.into(_db.rolodexContacts).insert(entry);

  Future<bool> update(RolodexContact entry) =>
      _db.update(_db.rolodexContacts).replace(entry);

  Future<void> delete(int id) =>
      (_db.delete(_db.rolodexContacts)..where((t) => t.id.equals(id))).go();

  /// Set this contact as sponsor (clears the flag on all other contacts first).
  ///
  /// Pass [value: false] to just clear the sponsor flag without promoting
  /// another contact.
  Future<void> setSponsor(int id, {required bool value}) async {
    await _db.transaction(() async {
      if (value) {
        // Clear existing sponsor(s)
        await (_db.update(_db.rolodexContacts)
              ..where((t) => t.isSponsor.equals(true)))
            .write(const RolodexContactsCompanion(
              isSponsor: Value(false),
            ));
      }
      await (_db.update(_db.rolodexContacts)..where((t) => t.id.equals(id)))
          .write(RolodexContactsCompanion(isSponsor: Value(value)));
    });
  }

  /// Link (or unlink) this contact to a Sponsee row.
  Future<void> setSponseeLink(int contactId, int? sponseeId) =>
      (_db.update(_db.rolodexContacts)
            ..where((t) => t.id.equals(contactId)))
          .write(RolodexContactsCompanion(sponseeId: Value(sponseeId)));
}
