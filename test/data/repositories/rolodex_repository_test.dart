import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/data/repositories/rolodex_repository.dart';

import 'repository_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RolodexRepository', () {
    late ({Directory dir, File dbFile, AppDatabase db}) t;
    late RolodexRepository repo;

    setUp(() async {
      t = await openTempEncryptedDb('fi_rolodex_');
      final container = containerWithDatabase(t.db);
      addTearDown(container.dispose);
      repo = container.read(rolodexRepositoryProvider);
    });

    tearDown(() => disposeTempDb(db: t.db, dir: t.dir, dbFile: t.dbFile));

    // ── insert / getById ────────────────────────────────────────────────────

    test('insert returns a new row id and getById retrieves it', () async {
      final id = await repo.insert(RolodexContactsCompanion.insert(name: 'Alice'));
      expect(id, isPositive);

      final contact = await repo.getById(id);
      expect(contact, isNotNull);
      expect(contact!.name, 'Alice');
      expect(contact.isSponsor, isFalse);
    });

    // ── update ──────────────────────────────────────────────────────────────

    test('update persists field changes', () async {
      final id = await repo.insert(RolodexContactsCompanion.insert(name: 'Bob'));
      final original = (await repo.getById(id))!;

      final updated = original.copyWith(
        name: 'Robert',
        phone: const Value('555-1234'),
      );
      final success = await repo.update(updated);
      expect(success, isTrue);

      final retrieved = await repo.getById(id);
      expect(retrieved!.name, 'Robert');
      expect(retrieved.phone, '555-1234');
    });

    // ── delete ──────────────────────────────────────────────────────────────

    test('delete removes the row and getById returns null', () async {
      final id = await repo.insert(RolodexContactsCompanion.insert(name: 'Carol'));
      await repo.delete(id);
      expect(await repo.getById(id), isNull);
    });

    // ── watchAll ordering: sponsor first, then alphabetical ─────────────────

    test('watchAll emits sponsor before non-sponsors', () async {
      await repo.insert(RolodexContactsCompanion.insert(name: 'Zara'));
      final aliceId = await repo.insert(RolodexContactsCompanion.insert(name: 'Alice'));
      await repo.insert(RolodexContactsCompanion.insert(name: 'Bob'));

      // Make Alice the sponsor
      await repo.setSponsor(aliceId, value: true);

      final contacts = await repo.watchAll().first;
      expect(contacts.first.name, 'Alice');
      expect(contacts.first.isSponsor, isTrue);
      // Remaining are alphabetical: Bob, Zara
      expect(contacts[1].name, 'Bob');
      expect(contacts[2].name, 'Zara');
    });

    // ── setSponsor: single-sponsor invariant ─────────────────────────────────

    test('setSponsor(value:true) clears any existing sponsor first', () async {
      final idA = await repo.insert(RolodexContactsCompanion.insert(name: 'Sponsor A'));
      final idB = await repo.insert(RolodexContactsCompanion.insert(name: 'Sponsor B'));

      await repo.setSponsor(idA, value: true);
      await repo.setSponsor(idB, value: true);

      final all = await repo.watchAll().first;
      final sponsors = all.where((c) => c.isSponsor).toList();
      expect(sponsors, hasLength(1));
      expect(sponsors.single.name, 'Sponsor B');
    });

    test('setSponsor(value:false) just clears the flag', () async {
      final id = await repo.insert(RolodexContactsCompanion.insert(name: 'Dave'));
      await repo.setSponsor(id, value: true);
      await repo.setSponsor(id, value: false);

      final contact = await repo.getById(id);
      expect(contact!.isSponsor, isFalse);
    });

    test('setSponsor on non-existent id does not throw', () async {
      // Should complete without error even though no row exists.
      await expectLater(
        repo.setSponsor(9999, value: true),
        completes,
      );
    });

    // ── watchByMeeting ───────────────────────────────────────────────────────

    test('watchByMeeting returns only contacts linked to that meeting', () async {
      // Insert a meeting to satisfy the FK
      final meetingId = await t.db.into(t.db.meetings).insert(
            MeetingsCompanion.insert(
              sourceId:   'test',
              externalId: 'ext_meeting',
              name:       'Home Group',
              city:       'Springfield',
              state:      'IL',
              weekday:    1,
              startTime:  '19:00',
            ),
          );

      await repo.insert(RolodexContactsCompanion.insert(
        name: 'Eve',
        meetingId: Value(meetingId),
      ));
      await repo.insert(RolodexContactsCompanion.insert(name: 'Frank'));

      final byMeeting = await repo.watchByMeeting(meetingId).first;
      expect(byMeeting, hasLength(1));
      expect(byMeeting.single.name, 'Eve');
    });

    // ── setSponseeLink ────────────────────────────────────────────────────────

    test('setSponseeLink links a contact to a sponsee row', () async {
      final contactId = await repo.insert(RolodexContactsCompanion.insert(name: 'Gina'));
      final sponseeId = await t.db.into(t.db.sponsees).insert(
            SponseesCompanion.insert(name: 'Gina S.'),
          );

      await repo.setSponseeLink(contactId, sponseeId);
      final contact = await repo.getById(contactId);
      expect(contact!.sponseeId, sponseeId);
    });

    test('setSponseeLink with null unlinks the contact', () async {
      final contactId = await repo.insert(RolodexContactsCompanion.insert(name: 'Hank'));
      final sponseeId = await t.db.into(t.db.sponsees).insert(
            SponseesCompanion.insert(name: 'Hank S.'),
          );

      await repo.setSponseeLink(contactId, sponseeId);
      await repo.setSponseeLink(contactId, null);
      final contact = await repo.getById(contactId);
      expect(contact!.sponseeId, isNull);
    });

    // ── optional fields persisted correctly ────────────────────────────────

    test('nullable fields (phone, email, address, notes) round-trip', () async {
      final id = await repo.insert(RolodexContactsCompanion.insert(
        name:    'Iris',
        phone:   const Value('555-0001'),
        email:   const Value('iris@example.com'),
        address: const Value('123 Main St'),
        notes:   const Value('Met at home group'),
      ));
      final c = await repo.getById(id);
      expect(c!.phone,   '555-0001');
      expect(c.email,    'iris@example.com');
      expect(c.address,  '123 Main St');
      expect(c.notes,    'Met at home group');
    });
  });
}
