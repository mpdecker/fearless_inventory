// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ResentmentsTable extends Resentments
    with TableInfo<$ResentmentsTable, Resentment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResentmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _causeMeta = const VerificationMeta('cause');
  @override
  late final GeneratedColumn<String> cause = GeneratedColumn<String>(
    'cause',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _affectsMeta = const VerificationMeta(
    'affects',
  );
  @override
  late final GeneratedColumn<String> affects = GeneratedColumn<String>(
    'affects',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _myPartMeta = const VerificationMeta('myPart');
  @override
  late final GeneratedColumn<String> myPart = GeneratedColumn<String>(
    'my_part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sponsorNoteMeta = const VerificationMeta(
    'sponsorNote',
  );
  @override
  late final GeneratedColumn<String> sponsorNote = GeneratedColumn<String>(
    'sponsor_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagForReviewMeta = const VerificationMeta(
    'flagForReview',
  );
  @override
  late final GeneratedColumn<bool> flagForReview = GeneratedColumn<bool>(
    'flag_for_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flag_for_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    person,
    cause,
    affects,
    myPart,
    sponsorNote,
    flagForReview,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resentments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Resentment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('cause')) {
      context.handle(
        _causeMeta,
        cause.isAcceptableOrUnknown(data['cause']!, _causeMeta),
      );
    } else if (isInserting) {
      context.missing(_causeMeta);
    }
    if (data.containsKey('affects')) {
      context.handle(
        _affectsMeta,
        affects.isAcceptableOrUnknown(data['affects']!, _affectsMeta),
      );
    } else if (isInserting) {
      context.missing(_affectsMeta);
    }
    if (data.containsKey('my_part')) {
      context.handle(
        _myPartMeta,
        myPart.isAcceptableOrUnknown(data['my_part']!, _myPartMeta),
      );
    } else if (isInserting) {
      context.missing(_myPartMeta);
    }
    if (data.containsKey('sponsor_note')) {
      context.handle(
        _sponsorNoteMeta,
        sponsorNote.isAcceptableOrUnknown(
          data['sponsor_note']!,
          _sponsorNoteMeta,
        ),
      );
    }
    if (data.containsKey('flag_for_review')) {
      context.handle(
        _flagForReviewMeta,
        flagForReview.isAcceptableOrUnknown(
          data['flag_for_review']!,
          _flagForReviewMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Resentment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Resentment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      )!,
      cause: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cause'],
      )!,
      affects: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}affects'],
      )!,
      myPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_part'],
      )!,
      sponsorNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sponsor_note'],
      ),
      flagForReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flag_for_review'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ResentmentsTable createAlias(String alias) {
    return $ResentmentsTable(attachedDatabase, alias);
  }
}

class Resentment extends DataClass implements Insertable<Resentment> {
  final int id;
  final String person;
  final String cause;
  final String affects;
  final String myPart;
  final String? sponsorNote;
  final bool flagForReview;
  final DateTime createdAt;
  const Resentment({
    required this.id,
    required this.person,
    required this.cause,
    required this.affects,
    required this.myPart,
    this.sponsorNote,
    required this.flagForReview,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person'] = Variable<String>(person);
    map['cause'] = Variable<String>(cause);
    map['affects'] = Variable<String>(affects);
    map['my_part'] = Variable<String>(myPart);
    if (!nullToAbsent || sponsorNote != null) {
      map['sponsor_note'] = Variable<String>(sponsorNote);
    }
    map['flag_for_review'] = Variable<bool>(flagForReview);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ResentmentsCompanion toCompanion(bool nullToAbsent) {
    return ResentmentsCompanion(
      id: Value(id),
      person: Value(person),
      cause: Value(cause),
      affects: Value(affects),
      myPart: Value(myPart),
      sponsorNote: sponsorNote == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorNote),
      flagForReview: Value(flagForReview),
      createdAt: Value(createdAt),
    );
  }

  factory Resentment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Resentment(
      id: serializer.fromJson<int>(json['id']),
      person: serializer.fromJson<String>(json['person']),
      cause: serializer.fromJson<String>(json['cause']),
      affects: serializer.fromJson<String>(json['affects']),
      myPart: serializer.fromJson<String>(json['myPart']),
      sponsorNote: serializer.fromJson<String?>(json['sponsorNote']),
      flagForReview: serializer.fromJson<bool>(json['flagForReview']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'person': serializer.toJson<String>(person),
      'cause': serializer.toJson<String>(cause),
      'affects': serializer.toJson<String>(affects),
      'myPart': serializer.toJson<String>(myPart),
      'sponsorNote': serializer.toJson<String?>(sponsorNote),
      'flagForReview': serializer.toJson<bool>(flagForReview),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Resentment copyWith({
    int? id,
    String? person,
    String? cause,
    String? affects,
    String? myPart,
    Value<String?> sponsorNote = const Value.absent(),
    bool? flagForReview,
    DateTime? createdAt,
  }) => Resentment(
    id: id ?? this.id,
    person: person ?? this.person,
    cause: cause ?? this.cause,
    affects: affects ?? this.affects,
    myPart: myPart ?? this.myPart,
    sponsorNote: sponsorNote.present ? sponsorNote.value : this.sponsorNote,
    flagForReview: flagForReview ?? this.flagForReview,
    createdAt: createdAt ?? this.createdAt,
  );
  Resentment copyWithCompanion(ResentmentsCompanion data) {
    return Resentment(
      id: data.id.present ? data.id.value : this.id,
      person: data.person.present ? data.person.value : this.person,
      cause: data.cause.present ? data.cause.value : this.cause,
      affects: data.affects.present ? data.affects.value : this.affects,
      myPart: data.myPart.present ? data.myPart.value : this.myPart,
      sponsorNote: data.sponsorNote.present
          ? data.sponsorNote.value
          : this.sponsorNote,
      flagForReview: data.flagForReview.present
          ? data.flagForReview.value
          : this.flagForReview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Resentment(')
          ..write('id: $id, ')
          ..write('person: $person, ')
          ..write('cause: $cause, ')
          ..write('affects: $affects, ')
          ..write('myPart: $myPart, ')
          ..write('sponsorNote: $sponsorNote, ')
          ..write('flagForReview: $flagForReview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    person,
    cause,
    affects,
    myPart,
    sponsorNote,
    flagForReview,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Resentment &&
          other.id == this.id &&
          other.person == this.person &&
          other.cause == this.cause &&
          other.affects == this.affects &&
          other.myPart == this.myPart &&
          other.sponsorNote == this.sponsorNote &&
          other.flagForReview == this.flagForReview &&
          other.createdAt == this.createdAt);
}

class ResentmentsCompanion extends UpdateCompanion<Resentment> {
  final Value<int> id;
  final Value<String> person;
  final Value<String> cause;
  final Value<String> affects;
  final Value<String> myPart;
  final Value<String?> sponsorNote;
  final Value<bool> flagForReview;
  final Value<DateTime> createdAt;
  const ResentmentsCompanion({
    this.id = const Value.absent(),
    this.person = const Value.absent(),
    this.cause = const Value.absent(),
    this.affects = const Value.absent(),
    this.myPart = const Value.absent(),
    this.sponsorNote = const Value.absent(),
    this.flagForReview = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ResentmentsCompanion.insert({
    this.id = const Value.absent(),
    required String person,
    required String cause,
    required String affects,
    required String myPart,
    this.sponsorNote = const Value.absent(),
    this.flagForReview = const Value.absent(),
    required DateTime createdAt,
  }) : person = Value(person),
       cause = Value(cause),
       affects = Value(affects),
       myPart = Value(myPart),
       createdAt = Value(createdAt);
  static Insertable<Resentment> custom({
    Expression<int>? id,
    Expression<String>? person,
    Expression<String>? cause,
    Expression<String>? affects,
    Expression<String>? myPart,
    Expression<String>? sponsorNote,
    Expression<bool>? flagForReview,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (person != null) 'person': person,
      if (cause != null) 'cause': cause,
      if (affects != null) 'affects': affects,
      if (myPart != null) 'my_part': myPart,
      if (sponsorNote != null) 'sponsor_note': sponsorNote,
      if (flagForReview != null) 'flag_for_review': flagForReview,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ResentmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? person,
    Value<String>? cause,
    Value<String>? affects,
    Value<String>? myPart,
    Value<String?>? sponsorNote,
    Value<bool>? flagForReview,
    Value<DateTime>? createdAt,
  }) {
    return ResentmentsCompanion(
      id: id ?? this.id,
      person: person ?? this.person,
      cause: cause ?? this.cause,
      affects: affects ?? this.affects,
      myPart: myPart ?? this.myPart,
      sponsorNote: sponsorNote ?? this.sponsorNote,
      flagForReview: flagForReview ?? this.flagForReview,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (cause.present) {
      map['cause'] = Variable<String>(cause.value);
    }
    if (affects.present) {
      map['affects'] = Variable<String>(affects.value);
    }
    if (myPart.present) {
      map['my_part'] = Variable<String>(myPart.value);
    }
    if (sponsorNote.present) {
      map['sponsor_note'] = Variable<String>(sponsorNote.value);
    }
    if (flagForReview.present) {
      map['flag_for_review'] = Variable<bool>(flagForReview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResentmentsCompanion(')
          ..write('id: $id, ')
          ..write('person: $person, ')
          ..write('cause: $cause, ')
          ..write('affects: $affects, ')
          ..write('myPart: $myPart, ')
          ..write('sponsorNote: $sponsorNote, ')
          ..write('flagForReview: $flagForReview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FearsTable extends Fears with TableInfo<$FearsTable, Fear> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FearsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whyMeta = const VerificationMeta('why');
  @override
  late final GeneratedColumn<String> why = GeneratedColumn<String>(
    'why',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _myPartMeta = const VerificationMeta('myPart');
  @override
  late final GeneratedColumn<String> myPart = GeneratedColumn<String>(
    'my_part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sponsorNoteMeta = const VerificationMeta(
    'sponsorNote',
  );
  @override
  late final GeneratedColumn<String> sponsorNote = GeneratedColumn<String>(
    'sponsor_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagForReviewMeta = const VerificationMeta(
    'flagForReview',
  );
  @override
  late final GeneratedColumn<bool> flagForReview = GeneratedColumn<bool>(
    'flag_for_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flag_for_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subject,
    why,
    myPart,
    sponsorNote,
    flagForReview,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fears';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fear> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('why')) {
      context.handle(
        _whyMeta,
        why.isAcceptableOrUnknown(data['why']!, _whyMeta),
      );
    } else if (isInserting) {
      context.missing(_whyMeta);
    }
    if (data.containsKey('my_part')) {
      context.handle(
        _myPartMeta,
        myPart.isAcceptableOrUnknown(data['my_part']!, _myPartMeta),
      );
    } else if (isInserting) {
      context.missing(_myPartMeta);
    }
    if (data.containsKey('sponsor_note')) {
      context.handle(
        _sponsorNoteMeta,
        sponsorNote.isAcceptableOrUnknown(
          data['sponsor_note']!,
          _sponsorNoteMeta,
        ),
      );
    }
    if (data.containsKey('flag_for_review')) {
      context.handle(
        _flagForReviewMeta,
        flagForReview.isAcceptableOrUnknown(
          data['flag_for_review']!,
          _flagForReviewMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fear map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fear(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      why: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}why'],
      )!,
      myPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_part'],
      )!,
      sponsorNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sponsor_note'],
      ),
      flagForReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flag_for_review'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FearsTable createAlias(String alias) {
    return $FearsTable(attachedDatabase, alias);
  }
}

class Fear extends DataClass implements Insertable<Fear> {
  final int id;
  final String subject;
  final String why;
  final String myPart;
  final String? sponsorNote;
  final bool flagForReview;
  final DateTime createdAt;
  const Fear({
    required this.id,
    required this.subject,
    required this.why,
    required this.myPart,
    this.sponsorNote,
    required this.flagForReview,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject'] = Variable<String>(subject);
    map['why'] = Variable<String>(why);
    map['my_part'] = Variable<String>(myPart);
    if (!nullToAbsent || sponsorNote != null) {
      map['sponsor_note'] = Variable<String>(sponsorNote);
    }
    map['flag_for_review'] = Variable<bool>(flagForReview);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FearsCompanion toCompanion(bool nullToAbsent) {
    return FearsCompanion(
      id: Value(id),
      subject: Value(subject),
      why: Value(why),
      myPart: Value(myPart),
      sponsorNote: sponsorNote == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorNote),
      flagForReview: Value(flagForReview),
      createdAt: Value(createdAt),
    );
  }

  factory Fear.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fear(
      id: serializer.fromJson<int>(json['id']),
      subject: serializer.fromJson<String>(json['subject']),
      why: serializer.fromJson<String>(json['why']),
      myPart: serializer.fromJson<String>(json['myPart']),
      sponsorNote: serializer.fromJson<String?>(json['sponsorNote']),
      flagForReview: serializer.fromJson<bool>(json['flagForReview']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subject': serializer.toJson<String>(subject),
      'why': serializer.toJson<String>(why),
      'myPart': serializer.toJson<String>(myPart),
      'sponsorNote': serializer.toJson<String?>(sponsorNote),
      'flagForReview': serializer.toJson<bool>(flagForReview),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Fear copyWith({
    int? id,
    String? subject,
    String? why,
    String? myPart,
    Value<String?> sponsorNote = const Value.absent(),
    bool? flagForReview,
    DateTime? createdAt,
  }) => Fear(
    id: id ?? this.id,
    subject: subject ?? this.subject,
    why: why ?? this.why,
    myPart: myPart ?? this.myPart,
    sponsorNote: sponsorNote.present ? sponsorNote.value : this.sponsorNote,
    flagForReview: flagForReview ?? this.flagForReview,
    createdAt: createdAt ?? this.createdAt,
  );
  Fear copyWithCompanion(FearsCompanion data) {
    return Fear(
      id: data.id.present ? data.id.value : this.id,
      subject: data.subject.present ? data.subject.value : this.subject,
      why: data.why.present ? data.why.value : this.why,
      myPart: data.myPart.present ? data.myPart.value : this.myPart,
      sponsorNote: data.sponsorNote.present
          ? data.sponsorNote.value
          : this.sponsorNote,
      flagForReview: data.flagForReview.present
          ? data.flagForReview.value
          : this.flagForReview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fear(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('why: $why, ')
          ..write('myPart: $myPart, ')
          ..write('sponsorNote: $sponsorNote, ')
          ..write('flagForReview: $flagForReview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subject,
    why,
    myPart,
    sponsorNote,
    flagForReview,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fear &&
          other.id == this.id &&
          other.subject == this.subject &&
          other.why == this.why &&
          other.myPart == this.myPart &&
          other.sponsorNote == this.sponsorNote &&
          other.flagForReview == this.flagForReview &&
          other.createdAt == this.createdAt);
}

class FearsCompanion extends UpdateCompanion<Fear> {
  final Value<int> id;
  final Value<String> subject;
  final Value<String> why;
  final Value<String> myPart;
  final Value<String?> sponsorNote;
  final Value<bool> flagForReview;
  final Value<DateTime> createdAt;
  const FearsCompanion({
    this.id = const Value.absent(),
    this.subject = const Value.absent(),
    this.why = const Value.absent(),
    this.myPart = const Value.absent(),
    this.sponsorNote = const Value.absent(),
    this.flagForReview = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FearsCompanion.insert({
    this.id = const Value.absent(),
    required String subject,
    required String why,
    required String myPart,
    this.sponsorNote = const Value.absent(),
    this.flagForReview = const Value.absent(),
    required DateTime createdAt,
  }) : subject = Value(subject),
       why = Value(why),
       myPart = Value(myPart),
       createdAt = Value(createdAt);
  static Insertable<Fear> custom({
    Expression<int>? id,
    Expression<String>? subject,
    Expression<String>? why,
    Expression<String>? myPart,
    Expression<String>? sponsorNote,
    Expression<bool>? flagForReview,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subject != null) 'subject': subject,
      if (why != null) 'why': why,
      if (myPart != null) 'my_part': myPart,
      if (sponsorNote != null) 'sponsor_note': sponsorNote,
      if (flagForReview != null) 'flag_for_review': flagForReview,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FearsCompanion copyWith({
    Value<int>? id,
    Value<String>? subject,
    Value<String>? why,
    Value<String>? myPart,
    Value<String?>? sponsorNote,
    Value<bool>? flagForReview,
    Value<DateTime>? createdAt,
  }) {
    return FearsCompanion(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      why: why ?? this.why,
      myPart: myPart ?? this.myPart,
      sponsorNote: sponsorNote ?? this.sponsorNote,
      flagForReview: flagForReview ?? this.flagForReview,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (why.present) {
      map['why'] = Variable<String>(why.value);
    }
    if (myPart.present) {
      map['my_part'] = Variable<String>(myPart.value);
    }
    if (sponsorNote.present) {
      map['sponsor_note'] = Variable<String>(sponsorNote.value);
    }
    if (flagForReview.present) {
      map['flag_for_review'] = Variable<bool>(flagForReview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FearsCompanion(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('why: $why, ')
          ..write('myPart: $myPart, ')
          ..write('sponsorNote: $sponsorNote, ')
          ..write('flagForReview: $flagForReview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HarmsTable extends Harms with TableInfo<$HarmsTable, Harm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conductMeta = const VerificationMeta(
    'conduct',
  );
  @override
  late final GeneratedColumn<String> conduct = GeneratedColumn<String>(
    'conduct',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _myPartMeta = const VerificationMeta('myPart');
  @override
  late final GeneratedColumn<String> myPart = GeneratedColumn<String>(
    'my_part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amendsPlanMeta = const VerificationMeta(
    'amendsPlan',
  );
  @override
  late final GeneratedColumn<String> amendsPlan = GeneratedColumn<String>(
    'amends_plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAmendsDoneMeta = const VerificationMeta(
    'isAmendsDone',
  );
  @override
  late final GeneratedColumn<bool> isAmendsDone = GeneratedColumn<bool>(
    'is_amends_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_amends_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateAmendsDoneMeta = const VerificationMeta(
    'dateAmendsDone',
  );
  @override
  late final GeneratedColumn<DateTime> dateAmendsDone =
      GeneratedColumn<DateTime>(
        'date_amends_done',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sponsorNoteMeta = const VerificationMeta(
    'sponsorNote',
  );
  @override
  late final GeneratedColumn<String> sponsorNote = GeneratedColumn<String>(
    'sponsor_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagForReviewMeta = const VerificationMeta(
    'flagForReview',
  );
  @override
  late final GeneratedColumn<bool> flagForReview = GeneratedColumn<bool>(
    'flag_for_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flag_for_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    person,
    conduct,
    myPart,
    amendsPlan,
    isAmendsDone,
    dateAmendsDone,
    sponsorNote,
    flagForReview,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'harms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Harm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('conduct')) {
      context.handle(
        _conductMeta,
        conduct.isAcceptableOrUnknown(data['conduct']!, _conductMeta),
      );
    } else if (isInserting) {
      context.missing(_conductMeta);
    }
    if (data.containsKey('my_part')) {
      context.handle(
        _myPartMeta,
        myPart.isAcceptableOrUnknown(data['my_part']!, _myPartMeta),
      );
    } else if (isInserting) {
      context.missing(_myPartMeta);
    }
    if (data.containsKey('amends_plan')) {
      context.handle(
        _amendsPlanMeta,
        amendsPlan.isAcceptableOrUnknown(data['amends_plan']!, _amendsPlanMeta),
      );
    }
    if (data.containsKey('is_amends_done')) {
      context.handle(
        _isAmendsDoneMeta,
        isAmendsDone.isAcceptableOrUnknown(
          data['is_amends_done']!,
          _isAmendsDoneMeta,
        ),
      );
    }
    if (data.containsKey('date_amends_done')) {
      context.handle(
        _dateAmendsDoneMeta,
        dateAmendsDone.isAcceptableOrUnknown(
          data['date_amends_done']!,
          _dateAmendsDoneMeta,
        ),
      );
    }
    if (data.containsKey('sponsor_note')) {
      context.handle(
        _sponsorNoteMeta,
        sponsorNote.isAcceptableOrUnknown(
          data['sponsor_note']!,
          _sponsorNoteMeta,
        ),
      );
    }
    if (data.containsKey('flag_for_review')) {
      context.handle(
        _flagForReviewMeta,
        flagForReview.isAcceptableOrUnknown(
          data['flag_for_review']!,
          _flagForReviewMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Harm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Harm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      )!,
      conduct: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conduct'],
      )!,
      myPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}my_part'],
      )!,
      amendsPlan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amends_plan'],
      ),
      isAmendsDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_amends_done'],
      )!,
      dateAmendsDone: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_amends_done'],
      ),
      sponsorNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sponsor_note'],
      ),
      flagForReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flag_for_review'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HarmsTable createAlias(String alias) {
    return $HarmsTable(attachedDatabase, alias);
  }
}

class Harm extends DataClass implements Insertable<Harm> {
  final int id;
  final String person;
  final String conduct;
  final String myPart;
  final String? amendsPlan;
  final bool isAmendsDone;
  final DateTime? dateAmendsDone;
  final String? sponsorNote;
  final bool flagForReview;
  final DateTime createdAt;
  const Harm({
    required this.id,
    required this.person,
    required this.conduct,
    required this.myPart,
    this.amendsPlan,
    required this.isAmendsDone,
    this.dateAmendsDone,
    this.sponsorNote,
    required this.flagForReview,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person'] = Variable<String>(person);
    map['conduct'] = Variable<String>(conduct);
    map['my_part'] = Variable<String>(myPart);
    if (!nullToAbsent || amendsPlan != null) {
      map['amends_plan'] = Variable<String>(amendsPlan);
    }
    map['is_amends_done'] = Variable<bool>(isAmendsDone);
    if (!nullToAbsent || dateAmendsDone != null) {
      map['date_amends_done'] = Variable<DateTime>(dateAmendsDone);
    }
    if (!nullToAbsent || sponsorNote != null) {
      map['sponsor_note'] = Variable<String>(sponsorNote);
    }
    map['flag_for_review'] = Variable<bool>(flagForReview);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HarmsCompanion toCompanion(bool nullToAbsent) {
    return HarmsCompanion(
      id: Value(id),
      person: Value(person),
      conduct: Value(conduct),
      myPart: Value(myPart),
      amendsPlan: amendsPlan == null && nullToAbsent
          ? const Value.absent()
          : Value(amendsPlan),
      isAmendsDone: Value(isAmendsDone),
      dateAmendsDone: dateAmendsDone == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAmendsDone),
      sponsorNote: sponsorNote == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorNote),
      flagForReview: Value(flagForReview),
      createdAt: Value(createdAt),
    );
  }

  factory Harm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Harm(
      id: serializer.fromJson<int>(json['id']),
      person: serializer.fromJson<String>(json['person']),
      conduct: serializer.fromJson<String>(json['conduct']),
      myPart: serializer.fromJson<String>(json['myPart']),
      amendsPlan: serializer.fromJson<String?>(json['amendsPlan']),
      isAmendsDone: serializer.fromJson<bool>(json['isAmendsDone']),
      dateAmendsDone: serializer.fromJson<DateTime?>(json['dateAmendsDone']),
      sponsorNote: serializer.fromJson<String?>(json['sponsorNote']),
      flagForReview: serializer.fromJson<bool>(json['flagForReview']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'person': serializer.toJson<String>(person),
      'conduct': serializer.toJson<String>(conduct),
      'myPart': serializer.toJson<String>(myPart),
      'amendsPlan': serializer.toJson<String?>(amendsPlan),
      'isAmendsDone': serializer.toJson<bool>(isAmendsDone),
      'dateAmendsDone': serializer.toJson<DateTime?>(dateAmendsDone),
      'sponsorNote': serializer.toJson<String?>(sponsorNote),
      'flagForReview': serializer.toJson<bool>(flagForReview),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Harm copyWith({
    int? id,
    String? person,
    String? conduct,
    String? myPart,
    Value<String?> amendsPlan = const Value.absent(),
    bool? isAmendsDone,
    Value<DateTime?> dateAmendsDone = const Value.absent(),
    Value<String?> sponsorNote = const Value.absent(),
    bool? flagForReview,
    DateTime? createdAt,
  }) => Harm(
    id: id ?? this.id,
    person: person ?? this.person,
    conduct: conduct ?? this.conduct,
    myPart: myPart ?? this.myPart,
    amendsPlan: amendsPlan.present ? amendsPlan.value : this.amendsPlan,
    isAmendsDone: isAmendsDone ?? this.isAmendsDone,
    dateAmendsDone: dateAmendsDone.present
        ? dateAmendsDone.value
        : this.dateAmendsDone,
    sponsorNote: sponsorNote.present ? sponsorNote.value : this.sponsorNote,
    flagForReview: flagForReview ?? this.flagForReview,
    createdAt: createdAt ?? this.createdAt,
  );
  Harm copyWithCompanion(HarmsCompanion data) {
    return Harm(
      id: data.id.present ? data.id.value : this.id,
      person: data.person.present ? data.person.value : this.person,
      conduct: data.conduct.present ? data.conduct.value : this.conduct,
      myPart: data.myPart.present ? data.myPart.value : this.myPart,
      amendsPlan: data.amendsPlan.present
          ? data.amendsPlan.value
          : this.amendsPlan,
      isAmendsDone: data.isAmendsDone.present
          ? data.isAmendsDone.value
          : this.isAmendsDone,
      dateAmendsDone: data.dateAmendsDone.present
          ? data.dateAmendsDone.value
          : this.dateAmendsDone,
      sponsorNote: data.sponsorNote.present
          ? data.sponsorNote.value
          : this.sponsorNote,
      flagForReview: data.flagForReview.present
          ? data.flagForReview.value
          : this.flagForReview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Harm(')
          ..write('id: $id, ')
          ..write('person: $person, ')
          ..write('conduct: $conduct, ')
          ..write('myPart: $myPart, ')
          ..write('amendsPlan: $amendsPlan, ')
          ..write('isAmendsDone: $isAmendsDone, ')
          ..write('dateAmendsDone: $dateAmendsDone, ')
          ..write('sponsorNote: $sponsorNote, ')
          ..write('flagForReview: $flagForReview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    person,
    conduct,
    myPart,
    amendsPlan,
    isAmendsDone,
    dateAmendsDone,
    sponsorNote,
    flagForReview,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Harm &&
          other.id == this.id &&
          other.person == this.person &&
          other.conduct == this.conduct &&
          other.myPart == this.myPart &&
          other.amendsPlan == this.amendsPlan &&
          other.isAmendsDone == this.isAmendsDone &&
          other.dateAmendsDone == this.dateAmendsDone &&
          other.sponsorNote == this.sponsorNote &&
          other.flagForReview == this.flagForReview &&
          other.createdAt == this.createdAt);
}

class HarmsCompanion extends UpdateCompanion<Harm> {
  final Value<int> id;
  final Value<String> person;
  final Value<String> conduct;
  final Value<String> myPart;
  final Value<String?> amendsPlan;
  final Value<bool> isAmendsDone;
  final Value<DateTime?> dateAmendsDone;
  final Value<String?> sponsorNote;
  final Value<bool> flagForReview;
  final Value<DateTime> createdAt;
  const HarmsCompanion({
    this.id = const Value.absent(),
    this.person = const Value.absent(),
    this.conduct = const Value.absent(),
    this.myPart = const Value.absent(),
    this.amendsPlan = const Value.absent(),
    this.isAmendsDone = const Value.absent(),
    this.dateAmendsDone = const Value.absent(),
    this.sponsorNote = const Value.absent(),
    this.flagForReview = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HarmsCompanion.insert({
    this.id = const Value.absent(),
    required String person,
    required String conduct,
    required String myPart,
    this.amendsPlan = const Value.absent(),
    this.isAmendsDone = const Value.absent(),
    this.dateAmendsDone = const Value.absent(),
    this.sponsorNote = const Value.absent(),
    this.flagForReview = const Value.absent(),
    required DateTime createdAt,
  }) : person = Value(person),
       conduct = Value(conduct),
       myPart = Value(myPart),
       createdAt = Value(createdAt);
  static Insertable<Harm> custom({
    Expression<int>? id,
    Expression<String>? person,
    Expression<String>? conduct,
    Expression<String>? myPart,
    Expression<String>? amendsPlan,
    Expression<bool>? isAmendsDone,
    Expression<DateTime>? dateAmendsDone,
    Expression<String>? sponsorNote,
    Expression<bool>? flagForReview,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (person != null) 'person': person,
      if (conduct != null) 'conduct': conduct,
      if (myPart != null) 'my_part': myPart,
      if (amendsPlan != null) 'amends_plan': amendsPlan,
      if (isAmendsDone != null) 'is_amends_done': isAmendsDone,
      if (dateAmendsDone != null) 'date_amends_done': dateAmendsDone,
      if (sponsorNote != null) 'sponsor_note': sponsorNote,
      if (flagForReview != null) 'flag_for_review': flagForReview,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HarmsCompanion copyWith({
    Value<int>? id,
    Value<String>? person,
    Value<String>? conduct,
    Value<String>? myPart,
    Value<String?>? amendsPlan,
    Value<bool>? isAmendsDone,
    Value<DateTime?>? dateAmendsDone,
    Value<String?>? sponsorNote,
    Value<bool>? flagForReview,
    Value<DateTime>? createdAt,
  }) {
    return HarmsCompanion(
      id: id ?? this.id,
      person: person ?? this.person,
      conduct: conduct ?? this.conduct,
      myPart: myPart ?? this.myPart,
      amendsPlan: amendsPlan ?? this.amendsPlan,
      isAmendsDone: isAmendsDone ?? this.isAmendsDone,
      dateAmendsDone: dateAmendsDone ?? this.dateAmendsDone,
      sponsorNote: sponsorNote ?? this.sponsorNote,
      flagForReview: flagForReview ?? this.flagForReview,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (conduct.present) {
      map['conduct'] = Variable<String>(conduct.value);
    }
    if (myPart.present) {
      map['my_part'] = Variable<String>(myPart.value);
    }
    if (amendsPlan.present) {
      map['amends_plan'] = Variable<String>(amendsPlan.value);
    }
    if (isAmendsDone.present) {
      map['is_amends_done'] = Variable<bool>(isAmendsDone.value);
    }
    if (dateAmendsDone.present) {
      map['date_amends_done'] = Variable<DateTime>(dateAmendsDone.value);
    }
    if (sponsorNote.present) {
      map['sponsor_note'] = Variable<String>(sponsorNote.value);
    }
    if (flagForReview.present) {
      map['flag_for_review'] = Variable<bool>(flagForReview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HarmsCompanion(')
          ..write('id: $id, ')
          ..write('person: $person, ')
          ..write('conduct: $conduct, ')
          ..write('myPart: $myPart, ')
          ..write('amendsPlan: $amendsPlan, ')
          ..write('isAmendsDone: $isAmendsDone, ')
          ..write('dateAmendsDone: $dateAmendsDone, ')
          ..write('sponsorNote: $sponsorNote, ')
          ..write('flagForReview: $flagForReview, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyReviewsTable extends DailyReviews
    with TableInfo<$DailyReviewsTable, DailyReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasResentfulMeta = const VerificationMeta(
    'wasResentful',
  );
  @override
  late final GeneratedColumn<bool> wasResentful = GeneratedColumn<bool>(
    'was_resentful',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_resentful" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wasSelfishMeta = const VerificationMeta(
    'wasSelfish',
  );
  @override
  late final GeneratedColumn<bool> wasSelfish = GeneratedColumn<bool>(
    'was_selfish',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_selfish" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wasDishonestMeta = const VerificationMeta(
    'wasDishonest',
  );
  @override
  late final GeneratedColumn<bool> wasDishonest = GeneratedColumn<bool>(
    'was_dishonest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_dishonest" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wasAfraidMeta = const VerificationMeta(
    'wasAfraid',
  );
  @override
  late final GeneratedColumn<bool> wasAfraid = GeneratedColumn<bool>(
    'was_afraid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_afraid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gratitudeMeta = const VerificationMeta(
    'gratitude',
  );
  @override
  late final GeneratedColumn<String> gratitude = GeneratedColumn<String>(
    'gratitude',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewTypeMeta = const VerificationMeta(
    'reviewType',
  );
  @override
  late final GeneratedColumn<String> reviewType = GeneratedColumn<String>(
    'review_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nightly'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    wasResentful,
    wasSelfish,
    wasDishonest,
    wasAfraid,
    notes,
    gratitude,
    reviewType,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('was_resentful')) {
      context.handle(
        _wasResentfulMeta,
        wasResentful.isAcceptableOrUnknown(
          data['was_resentful']!,
          _wasResentfulMeta,
        ),
      );
    }
    if (data.containsKey('was_selfish')) {
      context.handle(
        _wasSelfishMeta,
        wasSelfish.isAcceptableOrUnknown(data['was_selfish']!, _wasSelfishMeta),
      );
    }
    if (data.containsKey('was_dishonest')) {
      context.handle(
        _wasDishonestMeta,
        wasDishonest.isAcceptableOrUnknown(
          data['was_dishonest']!,
          _wasDishonestMeta,
        ),
      );
    }
    if (data.containsKey('was_afraid')) {
      context.handle(
        _wasAfraidMeta,
        wasAfraid.isAcceptableOrUnknown(data['was_afraid']!, _wasAfraidMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('gratitude')) {
      context.handle(
        _gratitudeMeta,
        gratitude.isAcceptableOrUnknown(data['gratitude']!, _gratitudeMeta),
      );
    }
    if (data.containsKey('review_type')) {
      context.handle(
        _reviewTypeMeta,
        reviewType.isAcceptableOrUnknown(data['review_type']!, _reviewTypeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyReview(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      wasResentful: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_resentful'],
      )!,
      wasSelfish: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_selfish'],
      )!,
      wasDishonest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_dishonest'],
      )!,
      wasAfraid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_afraid'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      gratitude: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gratitude'],
      ),
      reviewType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyReviewsTable createAlias(String alias) {
    return $DailyReviewsTable(attachedDatabase, alias);
  }
}

class DailyReview extends DataClass implements Insertable<DailyReview> {
  final int id;
  final DateTime date;
  final bool wasResentful;
  final bool wasSelfish;
  final bool wasDishonest;
  final bool wasAfraid;
  final String? notes;
  final String? gratitude;
  final String reviewType;
  final DateTime createdAt;
  const DailyReview({
    required this.id,
    required this.date,
    required this.wasResentful,
    required this.wasSelfish,
    required this.wasDishonest,
    required this.wasAfraid,
    this.notes,
    this.gratitude,
    required this.reviewType,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['was_resentful'] = Variable<bool>(wasResentful);
    map['was_selfish'] = Variable<bool>(wasSelfish);
    map['was_dishonest'] = Variable<bool>(wasDishonest);
    map['was_afraid'] = Variable<bool>(wasAfraid);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || gratitude != null) {
      map['gratitude'] = Variable<String>(gratitude);
    }
    map['review_type'] = Variable<String>(reviewType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyReviewsCompanion toCompanion(bool nullToAbsent) {
    return DailyReviewsCompanion(
      id: Value(id),
      date: Value(date),
      wasResentful: Value(wasResentful),
      wasSelfish: Value(wasSelfish),
      wasDishonest: Value(wasDishonest),
      wasAfraid: Value(wasAfraid),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      gratitude: gratitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gratitude),
      reviewType: Value(reviewType),
      createdAt: Value(createdAt),
    );
  }

  factory DailyReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyReview(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      wasResentful: serializer.fromJson<bool>(json['wasResentful']),
      wasSelfish: serializer.fromJson<bool>(json['wasSelfish']),
      wasDishonest: serializer.fromJson<bool>(json['wasDishonest']),
      wasAfraid: serializer.fromJson<bool>(json['wasAfraid']),
      notes: serializer.fromJson<String?>(json['notes']),
      gratitude: serializer.fromJson<String?>(json['gratitude']),
      reviewType: serializer.fromJson<String>(json['reviewType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'wasResentful': serializer.toJson<bool>(wasResentful),
      'wasSelfish': serializer.toJson<bool>(wasSelfish),
      'wasDishonest': serializer.toJson<bool>(wasDishonest),
      'wasAfraid': serializer.toJson<bool>(wasAfraid),
      'notes': serializer.toJson<String?>(notes),
      'gratitude': serializer.toJson<String?>(gratitude),
      'reviewType': serializer.toJson<String>(reviewType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyReview copyWith({
    int? id,
    DateTime? date,
    bool? wasResentful,
    bool? wasSelfish,
    bool? wasDishonest,
    bool? wasAfraid,
    Value<String?> notes = const Value.absent(),
    Value<String?> gratitude = const Value.absent(),
    String? reviewType,
    DateTime? createdAt,
  }) => DailyReview(
    id: id ?? this.id,
    date: date ?? this.date,
    wasResentful: wasResentful ?? this.wasResentful,
    wasSelfish: wasSelfish ?? this.wasSelfish,
    wasDishonest: wasDishonest ?? this.wasDishonest,
    wasAfraid: wasAfraid ?? this.wasAfraid,
    notes: notes.present ? notes.value : this.notes,
    gratitude: gratitude.present ? gratitude.value : this.gratitude,
    reviewType: reviewType ?? this.reviewType,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyReview copyWithCompanion(DailyReviewsCompanion data) {
    return DailyReview(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      wasResentful: data.wasResentful.present
          ? data.wasResentful.value
          : this.wasResentful,
      wasSelfish: data.wasSelfish.present
          ? data.wasSelfish.value
          : this.wasSelfish,
      wasDishonest: data.wasDishonest.present
          ? data.wasDishonest.value
          : this.wasDishonest,
      wasAfraid: data.wasAfraid.present ? data.wasAfraid.value : this.wasAfraid,
      notes: data.notes.present ? data.notes.value : this.notes,
      gratitude: data.gratitude.present ? data.gratitude.value : this.gratitude,
      reviewType: data.reviewType.present
          ? data.reviewType.value
          : this.reviewType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyReview(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('wasResentful: $wasResentful, ')
          ..write('wasSelfish: $wasSelfish, ')
          ..write('wasDishonest: $wasDishonest, ')
          ..write('wasAfraid: $wasAfraid, ')
          ..write('notes: $notes, ')
          ..write('gratitude: $gratitude, ')
          ..write('reviewType: $reviewType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    wasResentful,
    wasSelfish,
    wasDishonest,
    wasAfraid,
    notes,
    gratitude,
    reviewType,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyReview &&
          other.id == this.id &&
          other.date == this.date &&
          other.wasResentful == this.wasResentful &&
          other.wasSelfish == this.wasSelfish &&
          other.wasDishonest == this.wasDishonest &&
          other.wasAfraid == this.wasAfraid &&
          other.notes == this.notes &&
          other.gratitude == this.gratitude &&
          other.reviewType == this.reviewType &&
          other.createdAt == this.createdAt);
}

class DailyReviewsCompanion extends UpdateCompanion<DailyReview> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<bool> wasResentful;
  final Value<bool> wasSelfish;
  final Value<bool> wasDishonest;
  final Value<bool> wasAfraid;
  final Value<String?> notes;
  final Value<String?> gratitude;
  final Value<String> reviewType;
  final Value<DateTime> createdAt;
  const DailyReviewsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.wasResentful = const Value.absent(),
    this.wasSelfish = const Value.absent(),
    this.wasDishonest = const Value.absent(),
    this.wasAfraid = const Value.absent(),
    this.notes = const Value.absent(),
    this.gratitude = const Value.absent(),
    this.reviewType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DailyReviewsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.wasResentful = const Value.absent(),
    this.wasSelfish = const Value.absent(),
    this.wasDishonest = const Value.absent(),
    this.wasAfraid = const Value.absent(),
    this.notes = const Value.absent(),
    this.gratitude = const Value.absent(),
    this.reviewType = const Value.absent(),
    required DateTime createdAt,
  }) : date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<DailyReview> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<bool>? wasResentful,
    Expression<bool>? wasSelfish,
    Expression<bool>? wasDishonest,
    Expression<bool>? wasAfraid,
    Expression<String>? notes,
    Expression<String>? gratitude,
    Expression<String>? reviewType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (wasResentful != null) 'was_resentful': wasResentful,
      if (wasSelfish != null) 'was_selfish': wasSelfish,
      if (wasDishonest != null) 'was_dishonest': wasDishonest,
      if (wasAfraid != null) 'was_afraid': wasAfraid,
      if (notes != null) 'notes': notes,
      if (gratitude != null) 'gratitude': gratitude,
      if (reviewType != null) 'review_type': reviewType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailyReviewsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<bool>? wasResentful,
    Value<bool>? wasSelfish,
    Value<bool>? wasDishonest,
    Value<bool>? wasAfraid,
    Value<String?>? notes,
    Value<String?>? gratitude,
    Value<String>? reviewType,
    Value<DateTime>? createdAt,
  }) {
    return DailyReviewsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      wasResentful: wasResentful ?? this.wasResentful,
      wasSelfish: wasSelfish ?? this.wasSelfish,
      wasDishonest: wasDishonest ?? this.wasDishonest,
      wasAfraid: wasAfraid ?? this.wasAfraid,
      notes: notes ?? this.notes,
      gratitude: gratitude ?? this.gratitude,
      reviewType: reviewType ?? this.reviewType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (wasResentful.present) {
      map['was_resentful'] = Variable<bool>(wasResentful.value);
    }
    if (wasSelfish.present) {
      map['was_selfish'] = Variable<bool>(wasSelfish.value);
    }
    if (wasDishonest.present) {
      map['was_dishonest'] = Variable<bool>(wasDishonest.value);
    }
    if (wasAfraid.present) {
      map['was_afraid'] = Variable<bool>(wasAfraid.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (gratitude.present) {
      map['gratitude'] = Variable<String>(gratitude.value);
    }
    if (reviewType.present) {
      map['review_type'] = Variable<String>(reviewType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyReviewsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('wasResentful: $wasResentful, ')
          ..write('wasSelfish: $wasSelfish, ')
          ..write('wasDishonest: $wasDishonest, ')
          ..write('wasAfraid: $wasAfraid, ')
          ..write('notes: $notes, ')
          ..write('gratitude: $gratitude, ')
          ..write('reviewType: $reviewType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AmendsTable extends Amends with TableInfo<$AmendsTable, Amend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AmendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _harmIdMeta = const VerificationMeta('harmId');
  @override
  late final GeneratedColumn<int> harmId = GeneratedColumn<int>(
    'harm_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES harms (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AmendsType?, int> amendsType =
      GeneratedColumn<int>(
        'amends_type',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<AmendsType?>($AmendsTable.$converteramendsTypen);
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('step8'),
  );
  static const VerificationMeta _timeframeMeta = const VerificationMeta(
    'timeframe',
  );
  @override
  late final GeneratedColumn<String> timeframe = GeneratedColumn<String>(
    'timeframe',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _datePlannedMeta = const VerificationMeta(
    'datePlanned',
  );
  @override
  late final GeneratedColumn<DateTime> datePlanned = GeneratedColumn<DateTime>(
    'date_planned',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateCompletedMeta = const VerificationMeta(
    'dateCompleted',
  );
  @override
  late final GeneratedColumn<DateTime> dateCompleted =
      GeneratedColumn<DateTime>(
        'date_completed',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    harmId,
    person,
    amendsType,
    plan,
    priority,
    status,
    timeframe,
    datePlanned,
    dateCompleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'amends';
  @override
  VerificationContext validateIntegrity(
    Insertable<Amend> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('harm_id')) {
      context.handle(
        _harmIdMeta,
        harmId.isAcceptableOrUnknown(data['harm_id']!, _harmIdMeta),
      );
    }
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('timeframe')) {
      context.handle(
        _timeframeMeta,
        timeframe.isAcceptableOrUnknown(data['timeframe']!, _timeframeMeta),
      );
    }
    if (data.containsKey('date_planned')) {
      context.handle(
        _datePlannedMeta,
        datePlanned.isAcceptableOrUnknown(
          data['date_planned']!,
          _datePlannedMeta,
        ),
      );
    }
    if (data.containsKey('date_completed')) {
      context.handle(
        _dateCompletedMeta,
        dateCompleted.isAcceptableOrUnknown(
          data['date_completed']!,
          _dateCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Amend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Amend(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      harmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harm_id'],
      ),
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      )!,
      amendsType: $AmendsTable.$converteramendsTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amends_type'],
        ),
      ),
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      timeframe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timeframe'],
      ),
      datePlanned: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_planned'],
      ),
      dateCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_completed'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AmendsTable createAlias(String alias) {
    return $AmendsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AmendsType, int, int> $converteramendsType =
      const EnumIndexConverter<AmendsType>(AmendsType.values);
  static JsonTypeConverter2<AmendsType?, int?, int?> $converteramendsTypen =
      JsonTypeConverter2.asNullable($converteramendsType);
}

class Amend extends DataClass implements Insertable<Amend> {
  final int id;
  final int? harmId;
  final String person;
  final AmendsType? amendsType;
  final String? plan;
  final int priority;
  final String status;
  final String? timeframe;
  final DateTime? datePlanned;
  final DateTime? dateCompleted;
  final DateTime createdAt;
  const Amend({
    required this.id,
    this.harmId,
    required this.person,
    this.amendsType,
    this.plan,
    required this.priority,
    required this.status,
    this.timeframe,
    this.datePlanned,
    this.dateCompleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || harmId != null) {
      map['harm_id'] = Variable<int>(harmId);
    }
    map['person'] = Variable<String>(person);
    if (!nullToAbsent || amendsType != null) {
      map['amends_type'] = Variable<int>(
        $AmendsTable.$converteramendsTypen.toSql(amendsType),
      );
    }
    if (!nullToAbsent || plan != null) {
      map['plan'] = Variable<String>(plan);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || timeframe != null) {
      map['timeframe'] = Variable<String>(timeframe);
    }
    if (!nullToAbsent || datePlanned != null) {
      map['date_planned'] = Variable<DateTime>(datePlanned);
    }
    if (!nullToAbsent || dateCompleted != null) {
      map['date_completed'] = Variable<DateTime>(dateCompleted);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AmendsCompanion toCompanion(bool nullToAbsent) {
    return AmendsCompanion(
      id: Value(id),
      harmId: harmId == null && nullToAbsent
          ? const Value.absent()
          : Value(harmId),
      person: Value(person),
      amendsType: amendsType == null && nullToAbsent
          ? const Value.absent()
          : Value(amendsType),
      plan: plan == null && nullToAbsent ? const Value.absent() : Value(plan),
      priority: Value(priority),
      status: Value(status),
      timeframe: timeframe == null && nullToAbsent
          ? const Value.absent()
          : Value(timeframe),
      datePlanned: datePlanned == null && nullToAbsent
          ? const Value.absent()
          : Value(datePlanned),
      dateCompleted: dateCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory Amend.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Amend(
      id: serializer.fromJson<int>(json['id']),
      harmId: serializer.fromJson<int?>(json['harmId']),
      person: serializer.fromJson<String>(json['person']),
      amendsType: $AmendsTable.$converteramendsTypen.fromJson(
        serializer.fromJson<int?>(json['amendsType']),
      ),
      plan: serializer.fromJson<String?>(json['plan']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      timeframe: serializer.fromJson<String?>(json['timeframe']),
      datePlanned: serializer.fromJson<DateTime?>(json['datePlanned']),
      dateCompleted: serializer.fromJson<DateTime?>(json['dateCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'harmId': serializer.toJson<int?>(harmId),
      'person': serializer.toJson<String>(person),
      'amendsType': serializer.toJson<int?>(
        $AmendsTable.$converteramendsTypen.toJson(amendsType),
      ),
      'plan': serializer.toJson<String?>(plan),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'timeframe': serializer.toJson<String?>(timeframe),
      'datePlanned': serializer.toJson<DateTime?>(datePlanned),
      'dateCompleted': serializer.toJson<DateTime?>(dateCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Amend copyWith({
    int? id,
    Value<int?> harmId = const Value.absent(),
    String? person,
    Value<AmendsType?> amendsType = const Value.absent(),
    Value<String?> plan = const Value.absent(),
    int? priority,
    String? status,
    Value<String?> timeframe = const Value.absent(),
    Value<DateTime?> datePlanned = const Value.absent(),
    Value<DateTime?> dateCompleted = const Value.absent(),
    DateTime? createdAt,
  }) => Amend(
    id: id ?? this.id,
    harmId: harmId.present ? harmId.value : this.harmId,
    person: person ?? this.person,
    amendsType: amendsType.present ? amendsType.value : this.amendsType,
    plan: plan.present ? plan.value : this.plan,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    timeframe: timeframe.present ? timeframe.value : this.timeframe,
    datePlanned: datePlanned.present ? datePlanned.value : this.datePlanned,
    dateCompleted: dateCompleted.present
        ? dateCompleted.value
        : this.dateCompleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Amend copyWithCompanion(AmendsCompanion data) {
    return Amend(
      id: data.id.present ? data.id.value : this.id,
      harmId: data.harmId.present ? data.harmId.value : this.harmId,
      person: data.person.present ? data.person.value : this.person,
      amendsType: data.amendsType.present
          ? data.amendsType.value
          : this.amendsType,
      plan: data.plan.present ? data.plan.value : this.plan,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      timeframe: data.timeframe.present ? data.timeframe.value : this.timeframe,
      datePlanned: data.datePlanned.present
          ? data.datePlanned.value
          : this.datePlanned,
      dateCompleted: data.dateCompleted.present
          ? data.dateCompleted.value
          : this.dateCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Amend(')
          ..write('id: $id, ')
          ..write('harmId: $harmId, ')
          ..write('person: $person, ')
          ..write('amendsType: $amendsType, ')
          ..write('plan: $plan, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('timeframe: $timeframe, ')
          ..write('datePlanned: $datePlanned, ')
          ..write('dateCompleted: $dateCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    harmId,
    person,
    amendsType,
    plan,
    priority,
    status,
    timeframe,
    datePlanned,
    dateCompleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Amend &&
          other.id == this.id &&
          other.harmId == this.harmId &&
          other.person == this.person &&
          other.amendsType == this.amendsType &&
          other.plan == this.plan &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.timeframe == this.timeframe &&
          other.datePlanned == this.datePlanned &&
          other.dateCompleted == this.dateCompleted &&
          other.createdAt == this.createdAt);
}

class AmendsCompanion extends UpdateCompanion<Amend> {
  final Value<int> id;
  final Value<int?> harmId;
  final Value<String> person;
  final Value<AmendsType?> amendsType;
  final Value<String?> plan;
  final Value<int> priority;
  final Value<String> status;
  final Value<String?> timeframe;
  final Value<DateTime?> datePlanned;
  final Value<DateTime?> dateCompleted;
  final Value<DateTime> createdAt;
  const AmendsCompanion({
    this.id = const Value.absent(),
    this.harmId = const Value.absent(),
    this.person = const Value.absent(),
    this.amendsType = const Value.absent(),
    this.plan = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.timeframe = const Value.absent(),
    this.datePlanned = const Value.absent(),
    this.dateCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AmendsCompanion.insert({
    this.id = const Value.absent(),
    this.harmId = const Value.absent(),
    required String person,
    this.amendsType = const Value.absent(),
    this.plan = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.timeframe = const Value.absent(),
    this.datePlanned = const Value.absent(),
    this.dateCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : person = Value(person);
  static Insertable<Amend> custom({
    Expression<int>? id,
    Expression<int>? harmId,
    Expression<String>? person,
    Expression<int>? amendsType,
    Expression<String>? plan,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<String>? timeframe,
    Expression<DateTime>? datePlanned,
    Expression<DateTime>? dateCompleted,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (harmId != null) 'harm_id': harmId,
      if (person != null) 'person': person,
      if (amendsType != null) 'amends_type': amendsType,
      if (plan != null) 'plan': plan,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (timeframe != null) 'timeframe': timeframe,
      if (datePlanned != null) 'date_planned': datePlanned,
      if (dateCompleted != null) 'date_completed': dateCompleted,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AmendsCompanion copyWith({
    Value<int>? id,
    Value<int?>? harmId,
    Value<String>? person,
    Value<AmendsType?>? amendsType,
    Value<String?>? plan,
    Value<int>? priority,
    Value<String>? status,
    Value<String?>? timeframe,
    Value<DateTime?>? datePlanned,
    Value<DateTime?>? dateCompleted,
    Value<DateTime>? createdAt,
  }) {
    return AmendsCompanion(
      id: id ?? this.id,
      harmId: harmId ?? this.harmId,
      person: person ?? this.person,
      amendsType: amendsType ?? this.amendsType,
      plan: plan ?? this.plan,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      timeframe: timeframe ?? this.timeframe,
      datePlanned: datePlanned ?? this.datePlanned,
      dateCompleted: dateCompleted ?? this.dateCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (harmId.present) {
      map['harm_id'] = Variable<int>(harmId.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (amendsType.present) {
      map['amends_type'] = Variable<int>(
        $AmendsTable.$converteramendsTypen.toSql(amendsType.value),
      );
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (timeframe.present) {
      map['timeframe'] = Variable<String>(timeframe.value);
    }
    if (datePlanned.present) {
      map['date_planned'] = Variable<DateTime>(datePlanned.value);
    }
    if (dateCompleted.present) {
      map['date_completed'] = Variable<DateTime>(dateCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AmendsCompanion(')
          ..write('id: $id, ')
          ..write('harmId: $harmId, ')
          ..write('person: $person, ')
          ..write('amendsType: $amendsType, ')
          ..write('plan: $plan, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('timeframe: $timeframe, ')
          ..write('datePlanned: $datePlanned, ')
          ..write('dateCompleted: $dateCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DefectsTable extends Defects with TableInfo<$DefectsTable, Defect> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReadyMeta = const VerificationMeta(
    'isReady',
  );
  @override
  late final GeneratedColumn<bool> isReady = GeneratedColumn<bool>(
    'is_ready',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ready" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    isReady,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'defects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Defect> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_ready')) {
      context.handle(
        _isReadyMeta,
        isReady.isAcceptableOrUnknown(data['is_ready']!, _isReadyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Defect map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Defect(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      isReady: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ready'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DefectsTable createAlias(String alias) {
    return $DefectsTable(attachedDatabase, alias);
  }
}

class Defect extends DataClass implements Insertable<Defect> {
  final int id;
  final String name;
  final String? category;
  final bool isReady;
  final DateTime createdAt;
  const Defect({
    required this.id,
    required this.name,
    this.category,
    required this.isReady,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_ready'] = Variable<bool>(isReady);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DefectsCompanion toCompanion(bool nullToAbsent) {
    return DefectsCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isReady: Value(isReady),
      createdAt: Value(createdAt),
    );
  }

  factory Defect.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Defect(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      isReady: serializer.fromJson<bool>(json['isReady']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'isReady': serializer.toJson<bool>(isReady),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Defect copyWith({
    int? id,
    String? name,
    Value<String?> category = const Value.absent(),
    bool? isReady,
    DateTime? createdAt,
  }) => Defect(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    isReady: isReady ?? this.isReady,
    createdAt: createdAt ?? this.createdAt,
  );
  Defect copyWithCompanion(DefectsCompanion data) {
    return Defect(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      isReady: data.isReady.present ? data.isReady.value : this.isReady,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Defect(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('isReady: $isReady, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, isReady, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Defect &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.isReady == this.isReady &&
          other.createdAt == this.createdAt);
}

class DefectsCompanion extends UpdateCompanion<Defect> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<bool> isReady;
  final Value<DateTime> createdAt;
  const DefectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.isReady = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DefectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.isReady = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Defect> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<bool>? isReady,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (isReady != null) 'is_ready': isReady,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DefectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? category,
    Value<bool>? isReady,
    Value<DateTime>? createdAt,
  }) {
    return DefectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isReady: isReady ?? this.isReady,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isReady.present) {
      map['is_ready'] = Variable<bool>(isReady.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('isReady: $isReady, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShortcomingLogsTable extends ShortcomingLogs
    with TableInfo<$ShortcomingLogsTable, ShortcomingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShortcomingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateObservedMeta = const VerificationMeta(
    'dateObserved',
  );
  @override
  late final GeneratedColumn<DateTime> dateObserved = GeneratedColumn<DateTime>(
    'date_observed',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedReviewIdMeta = const VerificationMeta(
    'relatedReviewId',
  );
  @override
  late final GeneratedColumn<int> relatedReviewId = GeneratedColumn<int>(
    'related_review_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES daily_reviews (id)',
    ),
  );
  static const VerificationMeta _defectIdMeta = const VerificationMeta(
    'defectId',
  );
  @override
  late final GeneratedColumn<int> defectId = GeneratedColumn<int>(
    'defect_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES defects (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    description,
    dateObserved,
    relatedReviewId,
    defectId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shortcoming_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShortcomingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date_observed')) {
      context.handle(
        _dateObservedMeta,
        dateObserved.isAcceptableOrUnknown(
          data['date_observed']!,
          _dateObservedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateObservedMeta);
    }
    if (data.containsKey('related_review_id')) {
      context.handle(
        _relatedReviewIdMeta,
        relatedReviewId.isAcceptableOrUnknown(
          data['related_review_id']!,
          _relatedReviewIdMeta,
        ),
      );
    }
    if (data.containsKey('defect_id')) {
      context.handle(
        _defectIdMeta,
        defectId.isAcceptableOrUnknown(data['defect_id']!, _defectIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShortcomingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShortcomingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dateObserved: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_observed'],
      )!,
      relatedReviewId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}related_review_id'],
      ),
      defectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defect_id'],
      ),
    );
  }

  @override
  $ShortcomingLogsTable createAlias(String alias) {
    return $ShortcomingLogsTable(attachedDatabase, alias);
  }
}

class ShortcomingLog extends DataClass implements Insertable<ShortcomingLog> {
  final int id;
  final String description;
  final DateTime dateObserved;
  final int? relatedReviewId;
  final int? defectId;
  const ShortcomingLog({
    required this.id,
    required this.description,
    required this.dateObserved,
    this.relatedReviewId,
    this.defectId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    map['date_observed'] = Variable<DateTime>(dateObserved);
    if (!nullToAbsent || relatedReviewId != null) {
      map['related_review_id'] = Variable<int>(relatedReviewId);
    }
    if (!nullToAbsent || defectId != null) {
      map['defect_id'] = Variable<int>(defectId);
    }
    return map;
  }

  ShortcomingLogsCompanion toCompanion(bool nullToAbsent) {
    return ShortcomingLogsCompanion(
      id: Value(id),
      description: Value(description),
      dateObserved: Value(dateObserved),
      relatedReviewId: relatedReviewId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedReviewId),
      defectId: defectId == null && nullToAbsent
          ? const Value.absent()
          : Value(defectId),
    );
  }

  factory ShortcomingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShortcomingLog(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      dateObserved: serializer.fromJson<DateTime>(json['dateObserved']),
      relatedReviewId: serializer.fromJson<int?>(json['relatedReviewId']),
      defectId: serializer.fromJson<int?>(json['defectId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
      'dateObserved': serializer.toJson<DateTime>(dateObserved),
      'relatedReviewId': serializer.toJson<int?>(relatedReviewId),
      'defectId': serializer.toJson<int?>(defectId),
    };
  }

  ShortcomingLog copyWith({
    int? id,
    String? description,
    DateTime? dateObserved,
    Value<int?> relatedReviewId = const Value.absent(),
    Value<int?> defectId = const Value.absent(),
  }) => ShortcomingLog(
    id: id ?? this.id,
    description: description ?? this.description,
    dateObserved: dateObserved ?? this.dateObserved,
    relatedReviewId: relatedReviewId.present
        ? relatedReviewId.value
        : this.relatedReviewId,
    defectId: defectId.present ? defectId.value : this.defectId,
  );
  ShortcomingLog copyWithCompanion(ShortcomingLogsCompanion data) {
    return ShortcomingLog(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      dateObserved: data.dateObserved.present
          ? data.dateObserved.value
          : this.dateObserved,
      relatedReviewId: data.relatedReviewId.present
          ? data.relatedReviewId.value
          : this.relatedReviewId,
      defectId: data.defectId.present ? data.defectId.value : this.defectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShortcomingLog(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('dateObserved: $dateObserved, ')
          ..write('relatedReviewId: $relatedReviewId, ')
          ..write('defectId: $defectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, description, dateObserved, relatedReviewId, defectId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShortcomingLog &&
          other.id == this.id &&
          other.description == this.description &&
          other.dateObserved == this.dateObserved &&
          other.relatedReviewId == this.relatedReviewId &&
          other.defectId == this.defectId);
}

class ShortcomingLogsCompanion extends UpdateCompanion<ShortcomingLog> {
  final Value<int> id;
  final Value<String> description;
  final Value<DateTime> dateObserved;
  final Value<int?> relatedReviewId;
  final Value<int?> defectId;
  const ShortcomingLogsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.dateObserved = const Value.absent(),
    this.relatedReviewId = const Value.absent(),
    this.defectId = const Value.absent(),
  });
  ShortcomingLogsCompanion.insert({
    this.id = const Value.absent(),
    required String description,
    required DateTime dateObserved,
    this.relatedReviewId = const Value.absent(),
    this.defectId = const Value.absent(),
  }) : description = Value(description),
       dateObserved = Value(dateObserved);
  static Insertable<ShortcomingLog> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<DateTime>? dateObserved,
    Expression<int>? relatedReviewId,
    Expression<int>? defectId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (dateObserved != null) 'date_observed': dateObserved,
      if (relatedReviewId != null) 'related_review_id': relatedReviewId,
      if (defectId != null) 'defect_id': defectId,
    });
  }

  ShortcomingLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? description,
    Value<DateTime>? dateObserved,
    Value<int?>? relatedReviewId,
    Value<int?>? defectId,
  }) {
    return ShortcomingLogsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      dateObserved: dateObserved ?? this.dateObserved,
      relatedReviewId: relatedReviewId ?? this.relatedReviewId,
      defectId: defectId ?? this.defectId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dateObserved.present) {
      map['date_observed'] = Variable<DateTime>(dateObserved.value);
    }
    if (relatedReviewId.present) {
      map['related_review_id'] = Variable<int>(relatedReviewId.value);
    }
    if (defectId.present) {
      map['defect_id'] = Variable<int>(defectId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShortcomingLogsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('dateObserved: $dateObserved, ')
          ..write('relatedReviewId: $relatedReviewId, ')
          ..write('defectId: $defectId')
          ..write(')'))
        .toString();
  }
}

class $Step5CompletionsTable extends Step5Completions
    with TableInfo<$Step5CompletionsTable, Step5Completion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Step5CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _admittedToSelfMeta = const VerificationMeta(
    'admittedToSelf',
  );
  @override
  late final GeneratedColumn<bool> admittedToSelf = GeneratedColumn<bool>(
    'admitted_to_self',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("admitted_to_self" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _admittedToHigherPowerMeta =
      const VerificationMeta('admittedToHigherPower');
  @override
  late final GeneratedColumn<bool> admittedToHigherPower =
      GeneratedColumn<bool>(
        'admitted_to_higher_power',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("admitted_to_higher_power" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _admittedToSponsorMeta = const VerificationMeta(
    'admittedToSponsor',
  );
  @override
  late final GeneratedColumn<bool> admittedToSponsor = GeneratedColumn<bool>(
    'admitted_to_sponsor',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("admitted_to_sponsor" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reflectionMeta = const VerificationMeta(
    'reflection',
  );
  @override
  late final GeneratedColumn<String> reflection = GeneratedColumn<String>(
    'reflection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resentmentCountMeta = const VerificationMeta(
    'resentmentCount',
  );
  @override
  late final GeneratedColumn<int> resentmentCount = GeneratedColumn<int>(
    'resentment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fearCountMeta = const VerificationMeta(
    'fearCount',
  );
  @override
  late final GeneratedColumn<int> fearCount = GeneratedColumn<int>(
    'fear_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _harmCountMeta = const VerificationMeta(
    'harmCount',
  );
  @override
  late final GeneratedColumn<int> harmCount = GeneratedColumn<int>(
    'harm_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    admittedToSelf,
    admittedToHigherPower,
    admittedToSponsor,
    reflection,
    resentmentCount,
    fearCount,
    harmCount,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'step5_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Step5Completion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('admitted_to_self')) {
      context.handle(
        _admittedToSelfMeta,
        admittedToSelf.isAcceptableOrUnknown(
          data['admitted_to_self']!,
          _admittedToSelfMeta,
        ),
      );
    }
    if (data.containsKey('admitted_to_higher_power')) {
      context.handle(
        _admittedToHigherPowerMeta,
        admittedToHigherPower.isAcceptableOrUnknown(
          data['admitted_to_higher_power']!,
          _admittedToHigherPowerMeta,
        ),
      );
    }
    if (data.containsKey('admitted_to_sponsor')) {
      context.handle(
        _admittedToSponsorMeta,
        admittedToSponsor.isAcceptableOrUnknown(
          data['admitted_to_sponsor']!,
          _admittedToSponsorMeta,
        ),
      );
    }
    if (data.containsKey('reflection')) {
      context.handle(
        _reflectionMeta,
        reflection.isAcceptableOrUnknown(data['reflection']!, _reflectionMeta),
      );
    }
    if (data.containsKey('resentment_count')) {
      context.handle(
        _resentmentCountMeta,
        resentmentCount.isAcceptableOrUnknown(
          data['resentment_count']!,
          _resentmentCountMeta,
        ),
      );
    }
    if (data.containsKey('fear_count')) {
      context.handle(
        _fearCountMeta,
        fearCount.isAcceptableOrUnknown(data['fear_count']!, _fearCountMeta),
      );
    }
    if (data.containsKey('harm_count')) {
      context.handle(
        _harmCountMeta,
        harmCount.isAcceptableOrUnknown(data['harm_count']!, _harmCountMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Step5Completion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Step5Completion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      admittedToSelf: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}admitted_to_self'],
      )!,
      admittedToHigherPower: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}admitted_to_higher_power'],
      )!,
      admittedToSponsor: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}admitted_to_sponsor'],
      )!,
      reflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection'],
      ),
      resentmentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resentment_count'],
      )!,
      fearCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fear_count'],
      )!,
      harmCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}harm_count'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $Step5CompletionsTable createAlias(String alias) {
    return $Step5CompletionsTable(attachedDatabase, alias);
  }
}

class Step5Completion extends DataClass implements Insertable<Step5Completion> {
  final int id;
  final bool admittedToSelf;
  final bool admittedToHigherPower;
  final bool admittedToSponsor;
  final String? reflection;
  final int resentmentCount;
  final int fearCount;
  final int harmCount;
  final DateTime completedAt;
  const Step5Completion({
    required this.id,
    required this.admittedToSelf,
    required this.admittedToHigherPower,
    required this.admittedToSponsor,
    this.reflection,
    required this.resentmentCount,
    required this.fearCount,
    required this.harmCount,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['admitted_to_self'] = Variable<bool>(admittedToSelf);
    map['admitted_to_higher_power'] = Variable<bool>(admittedToHigherPower);
    map['admitted_to_sponsor'] = Variable<bool>(admittedToSponsor);
    if (!nullToAbsent || reflection != null) {
      map['reflection'] = Variable<String>(reflection);
    }
    map['resentment_count'] = Variable<int>(resentmentCount);
    map['fear_count'] = Variable<int>(fearCount);
    map['harm_count'] = Variable<int>(harmCount);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  Step5CompletionsCompanion toCompanion(bool nullToAbsent) {
    return Step5CompletionsCompanion(
      id: Value(id),
      admittedToSelf: Value(admittedToSelf),
      admittedToHigherPower: Value(admittedToHigherPower),
      admittedToSponsor: Value(admittedToSponsor),
      reflection: reflection == null && nullToAbsent
          ? const Value.absent()
          : Value(reflection),
      resentmentCount: Value(resentmentCount),
      fearCount: Value(fearCount),
      harmCount: Value(harmCount),
      completedAt: Value(completedAt),
    );
  }

  factory Step5Completion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Step5Completion(
      id: serializer.fromJson<int>(json['id']),
      admittedToSelf: serializer.fromJson<bool>(json['admittedToSelf']),
      admittedToHigherPower: serializer.fromJson<bool>(
        json['admittedToHigherPower'],
      ),
      admittedToSponsor: serializer.fromJson<bool>(json['admittedToSponsor']),
      reflection: serializer.fromJson<String?>(json['reflection']),
      resentmentCount: serializer.fromJson<int>(json['resentmentCount']),
      fearCount: serializer.fromJson<int>(json['fearCount']),
      harmCount: serializer.fromJson<int>(json['harmCount']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'admittedToSelf': serializer.toJson<bool>(admittedToSelf),
      'admittedToHigherPower': serializer.toJson<bool>(admittedToHigherPower),
      'admittedToSponsor': serializer.toJson<bool>(admittedToSponsor),
      'reflection': serializer.toJson<String?>(reflection),
      'resentmentCount': serializer.toJson<int>(resentmentCount),
      'fearCount': serializer.toJson<int>(fearCount),
      'harmCount': serializer.toJson<int>(harmCount),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  Step5Completion copyWith({
    int? id,
    bool? admittedToSelf,
    bool? admittedToHigherPower,
    bool? admittedToSponsor,
    Value<String?> reflection = const Value.absent(),
    int? resentmentCount,
    int? fearCount,
    int? harmCount,
    DateTime? completedAt,
  }) => Step5Completion(
    id: id ?? this.id,
    admittedToSelf: admittedToSelf ?? this.admittedToSelf,
    admittedToHigherPower: admittedToHigherPower ?? this.admittedToHigherPower,
    admittedToSponsor: admittedToSponsor ?? this.admittedToSponsor,
    reflection: reflection.present ? reflection.value : this.reflection,
    resentmentCount: resentmentCount ?? this.resentmentCount,
    fearCount: fearCount ?? this.fearCount,
    harmCount: harmCount ?? this.harmCount,
    completedAt: completedAt ?? this.completedAt,
  );
  Step5Completion copyWithCompanion(Step5CompletionsCompanion data) {
    return Step5Completion(
      id: data.id.present ? data.id.value : this.id,
      admittedToSelf: data.admittedToSelf.present
          ? data.admittedToSelf.value
          : this.admittedToSelf,
      admittedToHigherPower: data.admittedToHigherPower.present
          ? data.admittedToHigherPower.value
          : this.admittedToHigherPower,
      admittedToSponsor: data.admittedToSponsor.present
          ? data.admittedToSponsor.value
          : this.admittedToSponsor,
      reflection: data.reflection.present
          ? data.reflection.value
          : this.reflection,
      resentmentCount: data.resentmentCount.present
          ? data.resentmentCount.value
          : this.resentmentCount,
      fearCount: data.fearCount.present ? data.fearCount.value : this.fearCount,
      harmCount: data.harmCount.present ? data.harmCount.value : this.harmCount,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Step5Completion(')
          ..write('id: $id, ')
          ..write('admittedToSelf: $admittedToSelf, ')
          ..write('admittedToHigherPower: $admittedToHigherPower, ')
          ..write('admittedToSponsor: $admittedToSponsor, ')
          ..write('reflection: $reflection, ')
          ..write('resentmentCount: $resentmentCount, ')
          ..write('fearCount: $fearCount, ')
          ..write('harmCount: $harmCount, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    admittedToSelf,
    admittedToHigherPower,
    admittedToSponsor,
    reflection,
    resentmentCount,
    fearCount,
    harmCount,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Step5Completion &&
          other.id == this.id &&
          other.admittedToSelf == this.admittedToSelf &&
          other.admittedToHigherPower == this.admittedToHigherPower &&
          other.admittedToSponsor == this.admittedToSponsor &&
          other.reflection == this.reflection &&
          other.resentmentCount == this.resentmentCount &&
          other.fearCount == this.fearCount &&
          other.harmCount == this.harmCount &&
          other.completedAt == this.completedAt);
}

class Step5CompletionsCompanion extends UpdateCompanion<Step5Completion> {
  final Value<int> id;
  final Value<bool> admittedToSelf;
  final Value<bool> admittedToHigherPower;
  final Value<bool> admittedToSponsor;
  final Value<String?> reflection;
  final Value<int> resentmentCount;
  final Value<int> fearCount;
  final Value<int> harmCount;
  final Value<DateTime> completedAt;
  const Step5CompletionsCompanion({
    this.id = const Value.absent(),
    this.admittedToSelf = const Value.absent(),
    this.admittedToHigherPower = const Value.absent(),
    this.admittedToSponsor = const Value.absent(),
    this.reflection = const Value.absent(),
    this.resentmentCount = const Value.absent(),
    this.fearCount = const Value.absent(),
    this.harmCount = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  Step5CompletionsCompanion.insert({
    this.id = const Value.absent(),
    this.admittedToSelf = const Value.absent(),
    this.admittedToHigherPower = const Value.absent(),
    this.admittedToSponsor = const Value.absent(),
    this.reflection = const Value.absent(),
    this.resentmentCount = const Value.absent(),
    this.fearCount = const Value.absent(),
    this.harmCount = const Value.absent(),
    required DateTime completedAt,
  }) : completedAt = Value(completedAt);
  static Insertable<Step5Completion> custom({
    Expression<int>? id,
    Expression<bool>? admittedToSelf,
    Expression<bool>? admittedToHigherPower,
    Expression<bool>? admittedToSponsor,
    Expression<String>? reflection,
    Expression<int>? resentmentCount,
    Expression<int>? fearCount,
    Expression<int>? harmCount,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (admittedToSelf != null) 'admitted_to_self': admittedToSelf,
      if (admittedToHigherPower != null)
        'admitted_to_higher_power': admittedToHigherPower,
      if (admittedToSponsor != null) 'admitted_to_sponsor': admittedToSponsor,
      if (reflection != null) 'reflection': reflection,
      if (resentmentCount != null) 'resentment_count': resentmentCount,
      if (fearCount != null) 'fear_count': fearCount,
      if (harmCount != null) 'harm_count': harmCount,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  Step5CompletionsCompanion copyWith({
    Value<int>? id,
    Value<bool>? admittedToSelf,
    Value<bool>? admittedToHigherPower,
    Value<bool>? admittedToSponsor,
    Value<String?>? reflection,
    Value<int>? resentmentCount,
    Value<int>? fearCount,
    Value<int>? harmCount,
    Value<DateTime>? completedAt,
  }) {
    return Step5CompletionsCompanion(
      id: id ?? this.id,
      admittedToSelf: admittedToSelf ?? this.admittedToSelf,
      admittedToHigherPower:
          admittedToHigherPower ?? this.admittedToHigherPower,
      admittedToSponsor: admittedToSponsor ?? this.admittedToSponsor,
      reflection: reflection ?? this.reflection,
      resentmentCount: resentmentCount ?? this.resentmentCount,
      fearCount: fearCount ?? this.fearCount,
      harmCount: harmCount ?? this.harmCount,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (admittedToSelf.present) {
      map['admitted_to_self'] = Variable<bool>(admittedToSelf.value);
    }
    if (admittedToHigherPower.present) {
      map['admitted_to_higher_power'] = Variable<bool>(
        admittedToHigherPower.value,
      );
    }
    if (admittedToSponsor.present) {
      map['admitted_to_sponsor'] = Variable<bool>(admittedToSponsor.value);
    }
    if (reflection.present) {
      map['reflection'] = Variable<String>(reflection.value);
    }
    if (resentmentCount.present) {
      map['resentment_count'] = Variable<int>(resentmentCount.value);
    }
    if (fearCount.present) {
      map['fear_count'] = Variable<int>(fearCount.value);
    }
    if (harmCount.present) {
      map['harm_count'] = Variable<int>(harmCount.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Step5CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('admittedToSelf: $admittedToSelf, ')
          ..write('admittedToHigherPower: $admittedToHigherPower, ')
          ..write('admittedToSponsor: $admittedToSponsor, ')
          ..write('reflection: $reflection, ')
          ..write('resentmentCount: $resentmentCount, ')
          ..write('fearCount: $fearCount, ')
          ..write('harmCount: $harmCount, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $MeditationSessionsTable extends MeditationSessions
    with TableInfo<$MeditationSessionsTable, MeditationSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeditationSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
    'session_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reflectionThemeMeta = const VerificationMeta(
    'reflectionTheme',
  );
  @override
  late final GeneratedColumn<String> reflectionTheme = GeneratedColumn<String>(
    'reflection_theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reflectionKeyMeta = const VerificationMeta(
    'reflectionKey',
  );
  @override
  late final GeneratedColumn<String> reflectionKey = GeneratedColumn<String>(
    'reflection_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionType,
    reflectionTheme,
    reflectionKey,
    durationSeconds,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meditation_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeditationSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('reflection_theme')) {
      context.handle(
        _reflectionThemeMeta,
        reflectionTheme.isAcceptableOrUnknown(
          data['reflection_theme']!,
          _reflectionThemeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reflectionThemeMeta);
    }
    if (data.containsKey('reflection_key')) {
      context.handle(
        _reflectionKeyMeta,
        reflectionKey.isAcceptableOrUnknown(
          data['reflection_key']!,
          _reflectionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reflectionKeyMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeditationSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeditationSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_type'],
      )!,
      reflectionTheme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_theme'],
      )!,
      reflectionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_key'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $MeditationSessionsTable createAlias(String alias) {
    return $MeditationSessionsTable(attachedDatabase, alias);
  }
}

class MeditationSession extends DataClass
    implements Insertable<MeditationSession> {
  final int id;
  final String sessionType;
  final String reflectionTheme;
  final String reflectionKey;
  final int durationSeconds;
  final DateTime completedAt;
  const MeditationSession({
    required this.id,
    required this.sessionType,
    required this.reflectionTheme,
    required this.reflectionKey,
    required this.durationSeconds,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_type'] = Variable<String>(sessionType);
    map['reflection_theme'] = Variable<String>(reflectionTheme);
    map['reflection_key'] = Variable<String>(reflectionKey);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  MeditationSessionsCompanion toCompanion(bool nullToAbsent) {
    return MeditationSessionsCompanion(
      id: Value(id),
      sessionType: Value(sessionType),
      reflectionTheme: Value(reflectionTheme),
      reflectionKey: Value(reflectionKey),
      durationSeconds: Value(durationSeconds),
      completedAt: Value(completedAt),
    );
  }

  factory MeditationSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeditationSession(
      id: serializer.fromJson<int>(json['id']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      reflectionTheme: serializer.fromJson<String>(json['reflectionTheme']),
      reflectionKey: serializer.fromJson<String>(json['reflectionKey']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionType': serializer.toJson<String>(sessionType),
      'reflectionTheme': serializer.toJson<String>(reflectionTheme),
      'reflectionKey': serializer.toJson<String>(reflectionKey),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  MeditationSession copyWith({
    int? id,
    String? sessionType,
    String? reflectionTheme,
    String? reflectionKey,
    int? durationSeconds,
    DateTime? completedAt,
  }) => MeditationSession(
    id: id ?? this.id,
    sessionType: sessionType ?? this.sessionType,
    reflectionTheme: reflectionTheme ?? this.reflectionTheme,
    reflectionKey: reflectionKey ?? this.reflectionKey,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    completedAt: completedAt ?? this.completedAt,
  );
  MeditationSession copyWithCompanion(MeditationSessionsCompanion data) {
    return MeditationSession(
      id: data.id.present ? data.id.value : this.id,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      reflectionTheme: data.reflectionTheme.present
          ? data.reflectionTheme.value
          : this.reflectionTheme,
      reflectionKey: data.reflectionKey.present
          ? data.reflectionKey.value
          : this.reflectionKey,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeditationSession(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('reflectionTheme: $reflectionTheme, ')
          ..write('reflectionKey: $reflectionKey, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionType,
    reflectionTheme,
    reflectionKey,
    durationSeconds,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeditationSession &&
          other.id == this.id &&
          other.sessionType == this.sessionType &&
          other.reflectionTheme == this.reflectionTheme &&
          other.reflectionKey == this.reflectionKey &&
          other.durationSeconds == this.durationSeconds &&
          other.completedAt == this.completedAt);
}

class MeditationSessionsCompanion extends UpdateCompanion<MeditationSession> {
  final Value<int> id;
  final Value<String> sessionType;
  final Value<String> reflectionTheme;
  final Value<String> reflectionKey;
  final Value<int> durationSeconds;
  final Value<DateTime> completedAt;
  const MeditationSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.reflectionTheme = const Value.absent(),
    this.reflectionKey = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  MeditationSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionType,
    required String reflectionTheme,
    required String reflectionKey,
    this.durationSeconds = const Value.absent(),
    required DateTime completedAt,
  }) : sessionType = Value(sessionType),
       reflectionTheme = Value(reflectionTheme),
       reflectionKey = Value(reflectionKey),
       completedAt = Value(completedAt);
  static Insertable<MeditationSession> custom({
    Expression<int>? id,
    Expression<String>? sessionType,
    Expression<String>? reflectionTheme,
    Expression<String>? reflectionKey,
    Expression<int>? durationSeconds,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionType != null) 'session_type': sessionType,
      if (reflectionTheme != null) 'reflection_theme': reflectionTheme,
      if (reflectionKey != null) 'reflection_key': reflectionKey,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  MeditationSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionType,
    Value<String>? reflectionTheme,
    Value<String>? reflectionKey,
    Value<int>? durationSeconds,
    Value<DateTime>? completedAt,
  }) {
    return MeditationSessionsCompanion(
      id: id ?? this.id,
      sessionType: sessionType ?? this.sessionType,
      reflectionTheme: reflectionTheme ?? this.reflectionTheme,
      reflectionKey: reflectionKey ?? this.reflectionKey,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (reflectionTheme.present) {
      map['reflection_theme'] = Variable<String>(reflectionTheme.value);
    }
    if (reflectionKey.present) {
      map['reflection_key'] = Variable<String>(reflectionKey.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeditationSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('reflectionTheme: $reflectionTheme, ')
          ..write('reflectionKey: $reflectionKey, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $StepTwelveEventsTable extends StepTwelveEvents
    with TableInfo<$StepTwelveEventsTable, StepTwelveEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepTwelveEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    location,
    startTime,
    endTime,
    eventType,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'step_twelve_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<StepTwelveEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StepTwelveEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StepTwelveEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StepTwelveEventsTable createAlias(String alias) {
    return $StepTwelveEventsTable(attachedDatabase, alias);
  }
}

class StepTwelveEvent extends DataClass implements Insertable<StepTwelveEvent> {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime? endTime;
  final String eventType;
  final DateTime createdAt;
  const StepTwelveEvent({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    this.endTime,
    required this.eventType,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['event_type'] = Variable<String>(eventType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StepTwelveEventsCompanion toCompanion(bool nullToAbsent) {
    return StepTwelveEventsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      eventType: Value(eventType),
      createdAt: Value(createdAt),
    );
  }

  factory StepTwelveEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StepTwelveEvent(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      location: serializer.fromJson<String?>(json['location']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      eventType: serializer.fromJson<String>(json['eventType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'location': serializer.toJson<String?>(location),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'eventType': serializer.toJson<String>(eventType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StepTwelveEvent copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> location = const Value.absent(),
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    String? eventType,
    DateTime? createdAt,
  }) => StepTwelveEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    location: location.present ? location.value : this.location,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    eventType: eventType ?? this.eventType,
    createdAt: createdAt ?? this.createdAt,
  );
  StepTwelveEvent copyWithCompanion(StepTwelveEventsCompanion data) {
    return StepTwelveEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      location: data.location.present ? data.location.value : this.location,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StepTwelveEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('eventType: $eventType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    location,
    startTime,
    endTime,
    eventType,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StepTwelveEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.location == this.location &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.eventType == this.eventType &&
          other.createdAt == this.createdAt);
}

class StepTwelveEventsCompanion extends UpdateCompanion<StepTwelveEvent> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> location;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<String> eventType;
  final Value<DateTime> createdAt;
  const StepTwelveEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.eventType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StepTwelveEventsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.eventType = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       startTime = Value(startTime);
  static Insertable<StepTwelveEvent> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? location,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? eventType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (eventType != null) 'event_type': eventType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StepTwelveEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? location,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<String>? eventType,
    Value<DateTime>? createdAt,
  }) {
    return StepTwelveEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      eventType: eventType ?? this.eventType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepTwelveEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('eventType: $eventType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeetingsTable extends Meetings with TableInfo<$MeetingsTable, Meeting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeetingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fellowshipMeta = const VerificationMeta(
    'fellowship',
  );
  @override
  late final GeneratedColumn<String> fellowship = GeneratedColumn<String>(
    'fellowship',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AA'),
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('US'),
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeCodesMeta = const VerificationMeta(
    'typeCodes',
  );
  @override
  late final GeneratedColumn<String> typeCodes = GeneratedColumn<String>(
    'type_codes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isOnlineMeta = const VerificationMeta(
    'isOnline',
  );
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
    'is_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _conferenceUrlMeta = const VerificationMeta(
    'conferenceUrl',
  );
  @override
  late final GeneratedColumn<String> conferenceUrl = GeneratedColumn<String>(
    'conference_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conferencePhoneMeta = const VerificationMeta(
    'conferencePhone',
  );
  @override
  late final GeneratedColumn<String> conferencePhone = GeneratedColumn<String>(
    'conference_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onlinePlatformMeta = const VerificationMeta(
    'onlinePlatform',
  );
  @override
  late final GeneratedColumn<String> onlinePlatform = GeneratedColumn<String>(
    'online_platform',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHybridMeta = const VerificationMeta(
    'isHybrid',
  );
  @override
  late final GeneratedColumn<bool> isHybrid = GeneratedColumn<bool>(
    'is_hybrid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hybrid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBookmarkedMeta = const VerificationMeta(
    'isBookmarked',
  );
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
    'is_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isHomeGroupMeta = const VerificationMeta(
    'isHomeGroup',
  );
  @override
  late final GeneratedColumn<bool> isHomeGroup = GeneratedColumn<bool>(
    'is_home_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_home_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPlannedAttendanceMeta =
      const VerificationMeta('isPlannedAttendance');
  @override
  late final GeneratedColumn<bool> isPlannedAttendance = GeneratedColumn<bool>(
    'is_planned_attendance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_planned_attendance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isTemporarilyClosedMeta =
      const VerificationMeta('isTemporarilyClosed');
  @override
  late final GeneratedColumn<bool> isTemporarilyClosed = GeneratedColumn<bool>(
    'is_temporarily_closed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_temporarily_closed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    externalId,
    name,
    fellowship,
    locationName,
    latitude,
    longitude,
    address,
    city,
    state,
    country,
    weekday,
    startTime,
    durationMinutes,
    typeCodes,
    isOnline,
    conferenceUrl,
    conferencePhone,
    onlinePlatform,
    isHybrid,
    notes,
    isBookmarked,
    isHomeGroup,
    isPlannedAttendance,
    isTemporarilyClosed,
    language,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meetings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meeting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fellowship')) {
      context.handle(
        _fellowshipMeta,
        fellowship.isAcceptableOrUnknown(data['fellowship']!, _fellowshipMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('type_codes')) {
      context.handle(
        _typeCodesMeta,
        typeCodes.isAcceptableOrUnknown(data['type_codes']!, _typeCodesMeta),
      );
    }
    if (data.containsKey('is_online')) {
      context.handle(
        _isOnlineMeta,
        isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta),
      );
    }
    if (data.containsKey('conference_url')) {
      context.handle(
        _conferenceUrlMeta,
        conferenceUrl.isAcceptableOrUnknown(
          data['conference_url']!,
          _conferenceUrlMeta,
        ),
      );
    }
    if (data.containsKey('conference_phone')) {
      context.handle(
        _conferencePhoneMeta,
        conferencePhone.isAcceptableOrUnknown(
          data['conference_phone']!,
          _conferencePhoneMeta,
        ),
      );
    }
    if (data.containsKey('online_platform')) {
      context.handle(
        _onlinePlatformMeta,
        onlinePlatform.isAcceptableOrUnknown(
          data['online_platform']!,
          _onlinePlatformMeta,
        ),
      );
    }
    if (data.containsKey('is_hybrid')) {
      context.handle(
        _isHybridMeta,
        isHybrid.isAcceptableOrUnknown(data['is_hybrid']!, _isHybridMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
        _isBookmarkedMeta,
        isBookmarked.isAcceptableOrUnknown(
          data['is_bookmarked']!,
          _isBookmarkedMeta,
        ),
      );
    }
    if (data.containsKey('is_home_group')) {
      context.handle(
        _isHomeGroupMeta,
        isHomeGroup.isAcceptableOrUnknown(
          data['is_home_group']!,
          _isHomeGroupMeta,
        ),
      );
    }
    if (data.containsKey('is_planned_attendance')) {
      context.handle(
        _isPlannedAttendanceMeta,
        isPlannedAttendance.isAcceptableOrUnknown(
          data['is_planned_attendance']!,
          _isPlannedAttendanceMeta,
        ),
      );
    }
    if (data.containsKey('is_temporarily_closed')) {
      context.handle(
        _isTemporarilyClosedMeta,
        isTemporarilyClosed.isAcceptableOrUnknown(
          data['is_temporarily_closed']!,
          _isTemporarilyClosedMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceId, externalId},
  ];
  @override
  Meeting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meeting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fellowship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fellowship'],
      )!,
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      typeCodes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_codes'],
      )!,
      isOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_online'],
      )!,
      conferenceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conference_url'],
      ),
      conferencePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conference_phone'],
      ),
      onlinePlatform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}online_platform'],
      ),
      isHybrid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hybrid'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bookmarked'],
      )!,
      isHomeGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_home_group'],
      )!,
      isPlannedAttendance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_planned_attendance'],
      )!,
      isTemporarilyClosed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_temporarily_closed'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $MeetingsTable createAlias(String alias) {
    return $MeetingsTable(attachedDatabase, alias);
  }
}

class Meeting extends DataClass implements Insertable<Meeting> {
  final int id;

  /// Stable adapter identifier — e.g. 'meeting-guide', 'na-api'
  final String sourceId;

  /// Stable meeting ID from the upstream source (used for upsert dedup)
  final String externalId;
  final String name;
  final String fellowship;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String city;
  final String state;
  final String country;

  /// 0 = Sunday … 6 = Saturday
  final int weekday;

  /// Wall-clock start in "HH:mm" 24-h format
  final String startTime;
  final int? durationMinutes;

  /// JSON-encoded list of type codes: '["O","BB","ST"]'
  final String typeCodes;
  final bool isOnline;
  final String? conferenceUrl;
  final String? conferencePhone;

  /// 'zoom' | 'phone' | 'teams' | null
  final String? onlinePlatform;
  final bool isHybrid;
  final String? notes;
  final bool isBookmarked;
  final bool isHomeGroup;

  /// When true, this meeting appears on the Step 12 calendar every week
  /// on its [weekday].  Added in schema v12.
  final bool isPlannedAttendance;
  final bool isTemporarilyClosed;

  /// BCP-47 language code: 'en', 'es', 'fr', etc.  Default 'en' (English).
  /// Added in schema v10.
  final String language;
  final DateTime lastSyncedAt;
  const Meeting({
    required this.id,
    required this.sourceId,
    required this.externalId,
    required this.name,
    required this.fellowship,
    this.locationName,
    this.latitude,
    this.longitude,
    this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.weekday,
    required this.startTime,
    this.durationMinutes,
    required this.typeCodes,
    required this.isOnline,
    this.conferenceUrl,
    this.conferencePhone,
    this.onlinePlatform,
    required this.isHybrid,
    this.notes,
    required this.isBookmarked,
    required this.isHomeGroup,
    required this.isPlannedAttendance,
    required this.isTemporarilyClosed,
    required this.language,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['external_id'] = Variable<String>(externalId);
    map['name'] = Variable<String>(name);
    map['fellowship'] = Variable<String>(fellowship);
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['city'] = Variable<String>(city);
    map['state'] = Variable<String>(state);
    map['country'] = Variable<String>(country);
    map['weekday'] = Variable<int>(weekday);
    map['start_time'] = Variable<String>(startTime);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    map['type_codes'] = Variable<String>(typeCodes);
    map['is_online'] = Variable<bool>(isOnline);
    if (!nullToAbsent || conferenceUrl != null) {
      map['conference_url'] = Variable<String>(conferenceUrl);
    }
    if (!nullToAbsent || conferencePhone != null) {
      map['conference_phone'] = Variable<String>(conferencePhone);
    }
    if (!nullToAbsent || onlinePlatform != null) {
      map['online_platform'] = Variable<String>(onlinePlatform);
    }
    map['is_hybrid'] = Variable<bool>(isHybrid);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    map['is_home_group'] = Variable<bool>(isHomeGroup);
    map['is_planned_attendance'] = Variable<bool>(isPlannedAttendance);
    map['is_temporarily_closed'] = Variable<bool>(isTemporarilyClosed);
    map['language'] = Variable<String>(language);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  MeetingsCompanion toCompanion(bool nullToAbsent) {
    return MeetingsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      externalId: Value(externalId),
      name: Value(name),
      fellowship: Value(fellowship),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      city: Value(city),
      state: Value(state),
      country: Value(country),
      weekday: Value(weekday),
      startTime: Value(startTime),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      typeCodes: Value(typeCodes),
      isOnline: Value(isOnline),
      conferenceUrl: conferenceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(conferenceUrl),
      conferencePhone: conferencePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(conferencePhone),
      onlinePlatform: onlinePlatform == null && nullToAbsent
          ? const Value.absent()
          : Value(onlinePlatform),
      isHybrid: Value(isHybrid),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isBookmarked: Value(isBookmarked),
      isHomeGroup: Value(isHomeGroup),
      isPlannedAttendance: Value(isPlannedAttendance),
      isTemporarilyClosed: Value(isTemporarilyClosed),
      language: Value(language),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory Meeting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meeting(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      externalId: serializer.fromJson<String>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      fellowship: serializer.fromJson<String>(json['fellowship']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      address: serializer.fromJson<String?>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      state: serializer.fromJson<String>(json['state']),
      country: serializer.fromJson<String>(json['country']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startTime: serializer.fromJson<String>(json['startTime']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      typeCodes: serializer.fromJson<String>(json['typeCodes']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      conferenceUrl: serializer.fromJson<String?>(json['conferenceUrl']),
      conferencePhone: serializer.fromJson<String?>(json['conferencePhone']),
      onlinePlatform: serializer.fromJson<String?>(json['onlinePlatform']),
      isHybrid: serializer.fromJson<bool>(json['isHybrid']),
      notes: serializer.fromJson<String?>(json['notes']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      isHomeGroup: serializer.fromJson<bool>(json['isHomeGroup']),
      isPlannedAttendance: serializer.fromJson<bool>(
        json['isPlannedAttendance'],
      ),
      isTemporarilyClosed: serializer.fromJson<bool>(
        json['isTemporarilyClosed'],
      ),
      language: serializer.fromJson<String>(json['language']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'externalId': serializer.toJson<String>(externalId),
      'name': serializer.toJson<String>(name),
      'fellowship': serializer.toJson<String>(fellowship),
      'locationName': serializer.toJson<String?>(locationName),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'address': serializer.toJson<String?>(address),
      'city': serializer.toJson<String>(city),
      'state': serializer.toJson<String>(state),
      'country': serializer.toJson<String>(country),
      'weekday': serializer.toJson<int>(weekday),
      'startTime': serializer.toJson<String>(startTime),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'typeCodes': serializer.toJson<String>(typeCodes),
      'isOnline': serializer.toJson<bool>(isOnline),
      'conferenceUrl': serializer.toJson<String?>(conferenceUrl),
      'conferencePhone': serializer.toJson<String?>(conferencePhone),
      'onlinePlatform': serializer.toJson<String?>(onlinePlatform),
      'isHybrid': serializer.toJson<bool>(isHybrid),
      'notes': serializer.toJson<String?>(notes),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'isHomeGroup': serializer.toJson<bool>(isHomeGroup),
      'isPlannedAttendance': serializer.toJson<bool>(isPlannedAttendance),
      'isTemporarilyClosed': serializer.toJson<bool>(isTemporarilyClosed),
      'language': serializer.toJson<String>(language),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  Meeting copyWith({
    int? id,
    String? sourceId,
    String? externalId,
    String? name,
    String? fellowship,
    Value<String?> locationName = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> address = const Value.absent(),
    String? city,
    String? state,
    String? country,
    int? weekday,
    String? startTime,
    Value<int?> durationMinutes = const Value.absent(),
    String? typeCodes,
    bool? isOnline,
    Value<String?> conferenceUrl = const Value.absent(),
    Value<String?> conferencePhone = const Value.absent(),
    Value<String?> onlinePlatform = const Value.absent(),
    bool? isHybrid,
    Value<String?> notes = const Value.absent(),
    bool? isBookmarked,
    bool? isHomeGroup,
    bool? isPlannedAttendance,
    bool? isTemporarilyClosed,
    String? language,
    DateTime? lastSyncedAt,
  }) => Meeting(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    externalId: externalId ?? this.externalId,
    name: name ?? this.name,
    fellowship: fellowship ?? this.fellowship,
    locationName: locationName.present ? locationName.value : this.locationName,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    address: address.present ? address.value : this.address,
    city: city ?? this.city,
    state: state ?? this.state,
    country: country ?? this.country,
    weekday: weekday ?? this.weekday,
    startTime: startTime ?? this.startTime,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    typeCodes: typeCodes ?? this.typeCodes,
    isOnline: isOnline ?? this.isOnline,
    conferenceUrl: conferenceUrl.present
        ? conferenceUrl.value
        : this.conferenceUrl,
    conferencePhone: conferencePhone.present
        ? conferencePhone.value
        : this.conferencePhone,
    onlinePlatform: onlinePlatform.present
        ? onlinePlatform.value
        : this.onlinePlatform,
    isHybrid: isHybrid ?? this.isHybrid,
    notes: notes.present ? notes.value : this.notes,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    isHomeGroup: isHomeGroup ?? this.isHomeGroup,
    isPlannedAttendance: isPlannedAttendance ?? this.isPlannedAttendance,
    isTemporarilyClosed: isTemporarilyClosed ?? this.isTemporarilyClosed,
    language: language ?? this.language,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  Meeting copyWithCompanion(MeetingsCompanion data) {
    return Meeting(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      fellowship: data.fellowship.present
          ? data.fellowship.value
          : this.fellowship,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      country: data.country.present ? data.country.value : this.country,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      typeCodes: data.typeCodes.present ? data.typeCodes.value : this.typeCodes,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      conferenceUrl: data.conferenceUrl.present
          ? data.conferenceUrl.value
          : this.conferenceUrl,
      conferencePhone: data.conferencePhone.present
          ? data.conferencePhone.value
          : this.conferencePhone,
      onlinePlatform: data.onlinePlatform.present
          ? data.onlinePlatform.value
          : this.onlinePlatform,
      isHybrid: data.isHybrid.present ? data.isHybrid.value : this.isHybrid,
      notes: data.notes.present ? data.notes.value : this.notes,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      isHomeGroup: data.isHomeGroup.present
          ? data.isHomeGroup.value
          : this.isHomeGroup,
      isPlannedAttendance: data.isPlannedAttendance.present
          ? data.isPlannedAttendance.value
          : this.isPlannedAttendance,
      isTemporarilyClosed: data.isTemporarilyClosed.present
          ? data.isTemporarilyClosed.value
          : this.isTemporarilyClosed,
      language: data.language.present ? data.language.value : this.language,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meeting(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('fellowship: $fellowship, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('weekday: $weekday, ')
          ..write('startTime: $startTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('typeCodes: $typeCodes, ')
          ..write('isOnline: $isOnline, ')
          ..write('conferenceUrl: $conferenceUrl, ')
          ..write('conferencePhone: $conferencePhone, ')
          ..write('onlinePlatform: $onlinePlatform, ')
          ..write('isHybrid: $isHybrid, ')
          ..write('notes: $notes, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('isHomeGroup: $isHomeGroup, ')
          ..write('isPlannedAttendance: $isPlannedAttendance, ')
          ..write('isTemporarilyClosed: $isTemporarilyClosed, ')
          ..write('language: $language, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sourceId,
    externalId,
    name,
    fellowship,
    locationName,
    latitude,
    longitude,
    address,
    city,
    state,
    country,
    weekday,
    startTime,
    durationMinutes,
    typeCodes,
    isOnline,
    conferenceUrl,
    conferencePhone,
    onlinePlatform,
    isHybrid,
    notes,
    isBookmarked,
    isHomeGroup,
    isPlannedAttendance,
    isTemporarilyClosed,
    language,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meeting &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.fellowship == this.fellowship &&
          other.locationName == this.locationName &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.address == this.address &&
          other.city == this.city &&
          other.state == this.state &&
          other.country == this.country &&
          other.weekday == this.weekday &&
          other.startTime == this.startTime &&
          other.durationMinutes == this.durationMinutes &&
          other.typeCodes == this.typeCodes &&
          other.isOnline == this.isOnline &&
          other.conferenceUrl == this.conferenceUrl &&
          other.conferencePhone == this.conferencePhone &&
          other.onlinePlatform == this.onlinePlatform &&
          other.isHybrid == this.isHybrid &&
          other.notes == this.notes &&
          other.isBookmarked == this.isBookmarked &&
          other.isHomeGroup == this.isHomeGroup &&
          other.isPlannedAttendance == this.isPlannedAttendance &&
          other.isTemporarilyClosed == this.isTemporarilyClosed &&
          other.language == this.language &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class MeetingsCompanion extends UpdateCompanion<Meeting> {
  final Value<int> id;
  final Value<String> sourceId;
  final Value<String> externalId;
  final Value<String> name;
  final Value<String> fellowship;
  final Value<String?> locationName;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> address;
  final Value<String> city;
  final Value<String> state;
  final Value<String> country;
  final Value<int> weekday;
  final Value<String> startTime;
  final Value<int?> durationMinutes;
  final Value<String> typeCodes;
  final Value<bool> isOnline;
  final Value<String?> conferenceUrl;
  final Value<String?> conferencePhone;
  final Value<String?> onlinePlatform;
  final Value<bool> isHybrid;
  final Value<String?> notes;
  final Value<bool> isBookmarked;
  final Value<bool> isHomeGroup;
  final Value<bool> isPlannedAttendance;
  final Value<bool> isTemporarilyClosed;
  final Value<String> language;
  final Value<DateTime> lastSyncedAt;
  const MeetingsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.fellowship = const Value.absent(),
    this.locationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.country = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startTime = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.typeCodes = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.conferenceUrl = const Value.absent(),
    this.conferencePhone = const Value.absent(),
    this.onlinePlatform = const Value.absent(),
    this.isHybrid = const Value.absent(),
    this.notes = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.isHomeGroup = const Value.absent(),
    this.isPlannedAttendance = const Value.absent(),
    this.isTemporarilyClosed = const Value.absent(),
    this.language = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  MeetingsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceId,
    required String externalId,
    required String name,
    this.fellowship = const Value.absent(),
    this.locationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.address = const Value.absent(),
    required String city,
    required String state,
    this.country = const Value.absent(),
    required int weekday,
    required String startTime,
    this.durationMinutes = const Value.absent(),
    this.typeCodes = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.conferenceUrl = const Value.absent(),
    this.conferencePhone = const Value.absent(),
    this.onlinePlatform = const Value.absent(),
    this.isHybrid = const Value.absent(),
    this.notes = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.isHomeGroup = const Value.absent(),
    this.isPlannedAttendance = const Value.absent(),
    this.isTemporarilyClosed = const Value.absent(),
    this.language = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : sourceId = Value(sourceId),
       externalId = Value(externalId),
       name = Value(name),
       city = Value(city),
       state = Value(state),
       weekday = Value(weekday),
       startTime = Value(startTime);
  static Insertable<Meeting> custom({
    Expression<int>? id,
    Expression<String>? sourceId,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? fellowship,
    Expression<String>? locationName,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? country,
    Expression<int>? weekday,
    Expression<String>? startTime,
    Expression<int>? durationMinutes,
    Expression<String>? typeCodes,
    Expression<bool>? isOnline,
    Expression<String>? conferenceUrl,
    Expression<String>? conferencePhone,
    Expression<String>? onlinePlatform,
    Expression<bool>? isHybrid,
    Expression<String>? notes,
    Expression<bool>? isBookmarked,
    Expression<bool>? isHomeGroup,
    Expression<bool>? isPlannedAttendance,
    Expression<bool>? isTemporarilyClosed,
    Expression<String>? language,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (fellowship != null) 'fellowship': fellowship,
      if (locationName != null) 'location_name': locationName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (weekday != null) 'weekday': weekday,
      if (startTime != null) 'start_time': startTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (typeCodes != null) 'type_codes': typeCodes,
      if (isOnline != null) 'is_online': isOnline,
      if (conferenceUrl != null) 'conference_url': conferenceUrl,
      if (conferencePhone != null) 'conference_phone': conferencePhone,
      if (onlinePlatform != null) 'online_platform': onlinePlatform,
      if (isHybrid != null) 'is_hybrid': isHybrid,
      if (notes != null) 'notes': notes,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (isHomeGroup != null) 'is_home_group': isHomeGroup,
      if (isPlannedAttendance != null)
        'is_planned_attendance': isPlannedAttendance,
      if (isTemporarilyClosed != null)
        'is_temporarily_closed': isTemporarilyClosed,
      if (language != null) 'language': language,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  MeetingsCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceId,
    Value<String>? externalId,
    Value<String>? name,
    Value<String>? fellowship,
    Value<String?>? locationName,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? address,
    Value<String>? city,
    Value<String>? state,
    Value<String>? country,
    Value<int>? weekday,
    Value<String>? startTime,
    Value<int?>? durationMinutes,
    Value<String>? typeCodes,
    Value<bool>? isOnline,
    Value<String?>? conferenceUrl,
    Value<String?>? conferencePhone,
    Value<String?>? onlinePlatform,
    Value<bool>? isHybrid,
    Value<String?>? notes,
    Value<bool>? isBookmarked,
    Value<bool>? isHomeGroup,
    Value<bool>? isPlannedAttendance,
    Value<bool>? isTemporarilyClosed,
    Value<String>? language,
    Value<DateTime>? lastSyncedAt,
  }) {
    return MeetingsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      fellowship: fellowship ?? this.fellowship,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      typeCodes: typeCodes ?? this.typeCodes,
      isOnline: isOnline ?? this.isOnline,
      conferenceUrl: conferenceUrl ?? this.conferenceUrl,
      conferencePhone: conferencePhone ?? this.conferencePhone,
      onlinePlatform: onlinePlatform ?? this.onlinePlatform,
      isHybrid: isHybrid ?? this.isHybrid,
      notes: notes ?? this.notes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isHomeGroup: isHomeGroup ?? this.isHomeGroup,
      isPlannedAttendance: isPlannedAttendance ?? this.isPlannedAttendance,
      isTemporarilyClosed: isTemporarilyClosed ?? this.isTemporarilyClosed,
      language: language ?? this.language,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fellowship.present) {
      map['fellowship'] = Variable<String>(fellowship.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (typeCodes.present) {
      map['type_codes'] = Variable<String>(typeCodes.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (conferenceUrl.present) {
      map['conference_url'] = Variable<String>(conferenceUrl.value);
    }
    if (conferencePhone.present) {
      map['conference_phone'] = Variable<String>(conferencePhone.value);
    }
    if (onlinePlatform.present) {
      map['online_platform'] = Variable<String>(onlinePlatform.value);
    }
    if (isHybrid.present) {
      map['is_hybrid'] = Variable<bool>(isHybrid.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (isHomeGroup.present) {
      map['is_home_group'] = Variable<bool>(isHomeGroup.value);
    }
    if (isPlannedAttendance.present) {
      map['is_planned_attendance'] = Variable<bool>(isPlannedAttendance.value);
    }
    if (isTemporarilyClosed.present) {
      map['is_temporarily_closed'] = Variable<bool>(isTemporarilyClosed.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeetingsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('fellowship: $fellowship, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('weekday: $weekday, ')
          ..write('startTime: $startTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('typeCodes: $typeCodes, ')
          ..write('isOnline: $isOnline, ')
          ..write('conferenceUrl: $conferenceUrl, ')
          ..write('conferencePhone: $conferencePhone, ')
          ..write('onlinePlatform: $onlinePlatform, ')
          ..write('isHybrid: $isHybrid, ')
          ..write('notes: $notes, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('isHomeGroup: $isHomeGroup, ')
          ..write('isPlannedAttendance: $isPlannedAttendance, ')
          ..write('isTemporarilyClosed: $isTemporarilyClosed, ')
          ..write('language: $language, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $AttendanceLogsTable extends AttendanceLogs
    with TableInfo<$AttendanceLogsTable, AttendanceLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<int> meetingId = GeneratedColumn<int>(
    'meeting_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES meetings (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _meetingNameMeta = const VerificationMeta(
    'meetingName',
  );
  @override
  late final GeneratedColumn<String> meetingName = GeneratedColumn<String>(
    'meeting_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendedAtMeta = const VerificationMeta(
    'attendedAt',
  );
  @override
  late final GeneratedColumn<DateTime> attendedAt = GeneratedColumn<DateTime>(
    'attended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sharedAtMeetingMeta = const VerificationMeta(
    'sharedAtMeeting',
  );
  @override
  late final GeneratedColumn<bool> sharedAtMeeting = GeneratedColumn<bool>(
    'shared_at_meeting',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shared_at_meeting" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasSponsorContactMeta = const VerificationMeta(
    'hasSponsorContact',
  );
  @override
  late final GeneratedColumn<bool> hasSponsorContact = GeneratedColumn<bool>(
    'has_sponsor_contact',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_sponsor_contact" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasServiceWorkMeta = const VerificationMeta(
    'hasServiceWork',
  );
  @override
  late final GeneratedColumn<bool> hasServiceWork = GeneratedColumn<bool>(
    'has_service_work',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_service_work" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    meetingId,
    meetingName,
    attendedAt,
    notes,
    sharedAtMeeting,
    hasSponsorContact,
    hasServiceWork,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    }
    if (data.containsKey('meeting_name')) {
      context.handle(
        _meetingNameMeta,
        meetingName.isAcceptableOrUnknown(
          data['meeting_name']!,
          _meetingNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meetingNameMeta);
    }
    if (data.containsKey('attended_at')) {
      context.handle(
        _attendedAtMeta,
        attendedAt.isAcceptableOrUnknown(data['attended_at']!, _attendedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_attendedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('shared_at_meeting')) {
      context.handle(
        _sharedAtMeetingMeta,
        sharedAtMeeting.isAcceptableOrUnknown(
          data['shared_at_meeting']!,
          _sharedAtMeetingMeta,
        ),
      );
    }
    if (data.containsKey('has_sponsor_contact')) {
      context.handle(
        _hasSponsorContactMeta,
        hasSponsorContact.isAcceptableOrUnknown(
          data['has_sponsor_contact']!,
          _hasSponsorContactMeta,
        ),
      );
    }
    if (data.containsKey('has_service_work')) {
      context.handle(
        _hasServiceWorkMeta,
        hasServiceWork.isAcceptableOrUnknown(
          data['has_service_work']!,
          _hasServiceWorkMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meeting_id'],
      ),
      meetingName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meeting_name'],
      )!,
      attendedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attended_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sharedAtMeeting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shared_at_meeting'],
      )!,
      hasSponsorContact: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_sponsor_contact'],
      )!,
      hasServiceWork: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_service_work'],
      )!,
    );
  }

  @override
  $AttendanceLogsTable createAlias(String alias) {
    return $AttendanceLogsTable(attachedDatabase, alias);
  }
}

class AttendanceLog extends DataClass implements Insertable<AttendanceLog> {
  final int id;
  final int? meetingId;

  /// Denormalized: preserve the name even after meeting deletion
  final String meetingName;
  final DateTime attendedAt;
  final String? notes;
  final bool sharedAtMeeting;
  final bool hasSponsorContact;
  final bool hasServiceWork;
  const AttendanceLog({
    required this.id,
    this.meetingId,
    required this.meetingName,
    required this.attendedAt,
    this.notes,
    required this.sharedAtMeeting,
    required this.hasSponsorContact,
    required this.hasServiceWork,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || meetingId != null) {
      map['meeting_id'] = Variable<int>(meetingId);
    }
    map['meeting_name'] = Variable<String>(meetingName);
    map['attended_at'] = Variable<DateTime>(attendedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['shared_at_meeting'] = Variable<bool>(sharedAtMeeting);
    map['has_sponsor_contact'] = Variable<bool>(hasSponsorContact);
    map['has_service_work'] = Variable<bool>(hasServiceWork);
    return map;
  }

  AttendanceLogsCompanion toCompanion(bool nullToAbsent) {
    return AttendanceLogsCompanion(
      id: Value(id),
      meetingId: meetingId == null && nullToAbsent
          ? const Value.absent()
          : Value(meetingId),
      meetingName: Value(meetingName),
      attendedAt: Value(attendedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      sharedAtMeeting: Value(sharedAtMeeting),
      hasSponsorContact: Value(hasSponsorContact),
      hasServiceWork: Value(hasServiceWork),
    );
  }

  factory AttendanceLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceLog(
      id: serializer.fromJson<int>(json['id']),
      meetingId: serializer.fromJson<int?>(json['meetingId']),
      meetingName: serializer.fromJson<String>(json['meetingName']),
      attendedAt: serializer.fromJson<DateTime>(json['attendedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      sharedAtMeeting: serializer.fromJson<bool>(json['sharedAtMeeting']),
      hasSponsorContact: serializer.fromJson<bool>(json['hasSponsorContact']),
      hasServiceWork: serializer.fromJson<bool>(json['hasServiceWork']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'meetingId': serializer.toJson<int?>(meetingId),
      'meetingName': serializer.toJson<String>(meetingName),
      'attendedAt': serializer.toJson<DateTime>(attendedAt),
      'notes': serializer.toJson<String?>(notes),
      'sharedAtMeeting': serializer.toJson<bool>(sharedAtMeeting),
      'hasSponsorContact': serializer.toJson<bool>(hasSponsorContact),
      'hasServiceWork': serializer.toJson<bool>(hasServiceWork),
    };
  }

  AttendanceLog copyWith({
    int? id,
    Value<int?> meetingId = const Value.absent(),
    String? meetingName,
    DateTime? attendedAt,
    Value<String?> notes = const Value.absent(),
    bool? sharedAtMeeting,
    bool? hasSponsorContact,
    bool? hasServiceWork,
  }) => AttendanceLog(
    id: id ?? this.id,
    meetingId: meetingId.present ? meetingId.value : this.meetingId,
    meetingName: meetingName ?? this.meetingName,
    attendedAt: attendedAt ?? this.attendedAt,
    notes: notes.present ? notes.value : this.notes,
    sharedAtMeeting: sharedAtMeeting ?? this.sharedAtMeeting,
    hasSponsorContact: hasSponsorContact ?? this.hasSponsorContact,
    hasServiceWork: hasServiceWork ?? this.hasServiceWork,
  );
  AttendanceLog copyWithCompanion(AttendanceLogsCompanion data) {
    return AttendanceLog(
      id: data.id.present ? data.id.value : this.id,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      meetingName: data.meetingName.present
          ? data.meetingName.value
          : this.meetingName,
      attendedAt: data.attendedAt.present
          ? data.attendedAt.value
          : this.attendedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      sharedAtMeeting: data.sharedAtMeeting.present
          ? data.sharedAtMeeting.value
          : this.sharedAtMeeting,
      hasSponsorContact: data.hasSponsorContact.present
          ? data.hasSponsorContact.value
          : this.hasSponsorContact,
      hasServiceWork: data.hasServiceWork.present
          ? data.hasServiceWork.value
          : this.hasServiceWork,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceLog(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('meetingName: $meetingName, ')
          ..write('attendedAt: $attendedAt, ')
          ..write('notes: $notes, ')
          ..write('sharedAtMeeting: $sharedAtMeeting, ')
          ..write('hasSponsorContact: $hasSponsorContact, ')
          ..write('hasServiceWork: $hasServiceWork')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    meetingId,
    meetingName,
    attendedAt,
    notes,
    sharedAtMeeting,
    hasSponsorContact,
    hasServiceWork,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceLog &&
          other.id == this.id &&
          other.meetingId == this.meetingId &&
          other.meetingName == this.meetingName &&
          other.attendedAt == this.attendedAt &&
          other.notes == this.notes &&
          other.sharedAtMeeting == this.sharedAtMeeting &&
          other.hasSponsorContact == this.hasSponsorContact &&
          other.hasServiceWork == this.hasServiceWork);
}

class AttendanceLogsCompanion extends UpdateCompanion<AttendanceLog> {
  final Value<int> id;
  final Value<int?> meetingId;
  final Value<String> meetingName;
  final Value<DateTime> attendedAt;
  final Value<String?> notes;
  final Value<bool> sharedAtMeeting;
  final Value<bool> hasSponsorContact;
  final Value<bool> hasServiceWork;
  const AttendanceLogsCompanion({
    this.id = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.meetingName = const Value.absent(),
    this.attendedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.sharedAtMeeting = const Value.absent(),
    this.hasSponsorContact = const Value.absent(),
    this.hasServiceWork = const Value.absent(),
  });
  AttendanceLogsCompanion.insert({
    this.id = const Value.absent(),
    this.meetingId = const Value.absent(),
    required String meetingName,
    required DateTime attendedAt,
    this.notes = const Value.absent(),
    this.sharedAtMeeting = const Value.absent(),
    this.hasSponsorContact = const Value.absent(),
    this.hasServiceWork = const Value.absent(),
  }) : meetingName = Value(meetingName),
       attendedAt = Value(attendedAt);
  static Insertable<AttendanceLog> custom({
    Expression<int>? id,
    Expression<int>? meetingId,
    Expression<String>? meetingName,
    Expression<DateTime>? attendedAt,
    Expression<String>? notes,
    Expression<bool>? sharedAtMeeting,
    Expression<bool>? hasSponsorContact,
    Expression<bool>? hasServiceWork,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meetingId != null) 'meeting_id': meetingId,
      if (meetingName != null) 'meeting_name': meetingName,
      if (attendedAt != null) 'attended_at': attendedAt,
      if (notes != null) 'notes': notes,
      if (sharedAtMeeting != null) 'shared_at_meeting': sharedAtMeeting,
      if (hasSponsorContact != null) 'has_sponsor_contact': hasSponsorContact,
      if (hasServiceWork != null) 'has_service_work': hasServiceWork,
    });
  }

  AttendanceLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? meetingId,
    Value<String>? meetingName,
    Value<DateTime>? attendedAt,
    Value<String?>? notes,
    Value<bool>? sharedAtMeeting,
    Value<bool>? hasSponsorContact,
    Value<bool>? hasServiceWork,
  }) {
    return AttendanceLogsCompanion(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      meetingName: meetingName ?? this.meetingName,
      attendedAt: attendedAt ?? this.attendedAt,
      notes: notes ?? this.notes,
      sharedAtMeeting: sharedAtMeeting ?? this.sharedAtMeeting,
      hasSponsorContact: hasSponsorContact ?? this.hasSponsorContact,
      hasServiceWork: hasServiceWork ?? this.hasServiceWork,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<int>(meetingId.value);
    }
    if (meetingName.present) {
      map['meeting_name'] = Variable<String>(meetingName.value);
    }
    if (attendedAt.present) {
      map['attended_at'] = Variable<DateTime>(attendedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sharedAtMeeting.present) {
      map['shared_at_meeting'] = Variable<bool>(sharedAtMeeting.value);
    }
    if (hasSponsorContact.present) {
      map['has_sponsor_contact'] = Variable<bool>(hasSponsorContact.value);
    }
    if (hasServiceWork.present) {
      map['has_service_work'] = Variable<bool>(hasServiceWork.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceLogsCompanion(')
          ..write('id: $id, ')
          ..write('meetingId: $meetingId, ')
          ..write('meetingName: $meetingName, ')
          ..write('attendedAt: $attendedAt, ')
          ..write('notes: $notes, ')
          ..write('sharedAtMeeting: $sharedAtMeeting, ')
          ..write('hasSponsorContact: $hasSponsorContact, ')
          ..write('hasServiceWork: $hasServiceWork')
          ..write(')'))
        .toString();
  }
}

class $SyncMetasTable extends SyncMetas
    with TableInfo<$SyncMetasTable, SourceMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeetingsMeta = const VerificationMeta(
    'totalMeetings',
  );
  @override
  late final GeneratedColumn<int> totalMeetings = GeneratedColumn<int>(
    'total_meetings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    displayName,
    isEnabled,
    lastSyncAt,
    totalMeetings,
    syncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metas';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceMeta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('total_meetings')) {
      context.handle(
        _totalMeetingsMeta,
        totalMeetings.isAcceptableOrUnknown(
          data['total_meetings']!,
          _totalMeetingsMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  SourceMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceMeta(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      totalMeetings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_meetings'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
    );
  }

  @override
  $SyncMetasTable createAlias(String alias) {
    return $SyncMetasTable(attachedDatabase, alias);
  }
}

class SourceMeta extends DataClass implements Insertable<SourceMeta> {
  /// Matches MeetingSourceAdapter.sourceId
  final String sourceId;
  final String displayName;
  final bool isEnabled;
  final DateTime? lastSyncAt;
  final int totalMeetings;
  final String? syncError;
  const SourceMeta({
    required this.sourceId,
    required this.displayName,
    required this.isEnabled,
    this.lastSyncAt,
    required this.totalMeetings,
    this.syncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['display_name'] = Variable<String>(displayName);
    map['is_enabled'] = Variable<bool>(isEnabled);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['total_meetings'] = Variable<int>(totalMeetings);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  SyncMetasCompanion toCompanion(bool nullToAbsent) {
    return SyncMetasCompanion(
      sourceId: Value(sourceId),
      displayName: Value(displayName),
      isEnabled: Value(isEnabled),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      totalMeetings: Value(totalMeetings),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory SourceMeta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceMeta(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      totalMeetings: serializer.fromJson<int>(json['totalMeetings']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'displayName': serializer.toJson<String>(displayName),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'totalMeetings': serializer.toJson<int>(totalMeetings),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  SourceMeta copyWith({
    String? sourceId,
    String? displayName,
    bool? isEnabled,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    int? totalMeetings,
    Value<String?> syncError = const Value.absent(),
  }) => SourceMeta(
    sourceId: sourceId ?? this.sourceId,
    displayName: displayName ?? this.displayName,
    isEnabled: isEnabled ?? this.isEnabled,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    totalMeetings: totalMeetings ?? this.totalMeetings,
    syncError: syncError.present ? syncError.value : this.syncError,
  );
  SourceMeta copyWithCompanion(SyncMetasCompanion data) {
    return SourceMeta(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      totalMeetings: data.totalMeetings.present
          ? data.totalMeetings.value
          : this.totalMeetings,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceMeta(')
          ..write('sourceId: $sourceId, ')
          ..write('displayName: $displayName, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('totalMeetings: $totalMeetings, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    displayName,
    isEnabled,
    lastSyncAt,
    totalMeetings,
    syncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceMeta &&
          other.sourceId == this.sourceId &&
          other.displayName == this.displayName &&
          other.isEnabled == this.isEnabled &&
          other.lastSyncAt == this.lastSyncAt &&
          other.totalMeetings == this.totalMeetings &&
          other.syncError == this.syncError);
}

class SyncMetasCompanion extends UpdateCompanion<SourceMeta> {
  final Value<String> sourceId;
  final Value<String> displayName;
  final Value<bool> isEnabled;
  final Value<DateTime?> lastSyncAt;
  final Value<int> totalMeetings;
  final Value<String?> syncError;
  final Value<int> rowid;
  const SyncMetasCompanion({
    this.sourceId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.totalMeetings = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetasCompanion.insert({
    required String sourceId,
    required String displayName,
    this.isEnabled = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.totalMeetings = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       displayName = Value(displayName);
  static Insertable<SourceMeta> custom({
    Expression<String>? sourceId,
    Expression<String>? displayName,
    Expression<bool>? isEnabled,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? totalMeetings,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (displayName != null) 'display_name': displayName,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (totalMeetings != null) 'total_meetings': totalMeetings,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetasCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? displayName,
    Value<bool>? isEnabled,
    Value<DateTime?>? lastSyncAt,
    Value<int>? totalMeetings,
    Value<String?>? syncError,
    Value<int>? rowid,
  }) {
    return SyncMetasCompanion(
      sourceId: sourceId ?? this.sourceId,
      displayName: displayName ?? this.displayName,
      isEnabled: isEnabled ?? this.isEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      totalMeetings: totalMeetings ?? this.totalMeetings,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (totalMeetings.present) {
      map['total_meetings'] = Variable<int>(totalMeetings.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetasCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('displayName: $displayName, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('totalMeetings: $totalMeetings, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceCommitmentsTable extends ServiceCommitments
    with TableInfo<$ServiceCommitmentsTable, ServiceCommitment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceCommitmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  @override
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurringWeekdayMeta = const VerificationMeta(
    'recurringWeekday',
  );
  @override
  late final GeneratedColumn<int> recurringWeekday = GeneratedColumn<int>(
    'recurring_weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringTimeMeta = const VerificationMeta(
    'recurringTime',
  );
  @override
  late final GeneratedColumn<String> recurringTime = GeneratedColumn<String>(
    'recurring_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderMinutesBeforeMeta =
      const VerificationMeta('reminderMinutesBefore');
  @override
  late final GeneratedColumn<int> reminderMinutesBefore = GeneratedColumn<int>(
    'reminder_minutes_before',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    organization,
    startDate,
    endDate,
    isActive,
    isRecurring,
    recurringWeekday,
    recurringTime,
    reminderEnabled,
    reminderMinutesBefore,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_commitments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceCommitment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('recurring_weekday')) {
      context.handle(
        _recurringWeekdayMeta,
        recurringWeekday.isAcceptableOrUnknown(
          data['recurring_weekday']!,
          _recurringWeekdayMeta,
        ),
      );
    }
    if (data.containsKey('recurring_time')) {
      context.handle(
        _recurringTimeMeta,
        recurringTime.isAcceptableOrUnknown(
          data['recurring_time']!,
          _recurringTimeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes_before')) {
      context.handle(
        _reminderMinutesBeforeMeta,
        reminderMinutesBefore.isAcceptableOrUnknown(
          data['reminder_minutes_before']!,
          _reminderMinutesBeforeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceCommitment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceCommitment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      recurringWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_weekday'],
      ),
      recurringTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_time'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderMinutesBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes_before'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ServiceCommitmentsTable createAlias(String alias) {
    return $ServiceCommitmentsTable(attachedDatabase, alias);
  }
}

class ServiceCommitment extends DataClass
    implements Insertable<ServiceCommitment> {
  final int id;

  /// 'position'  — home-group or intergroup role (GSR, Secretary, etc.)
  /// 'speaking'  — speaking or sharing commitment at a specific meeting
  /// 'general'   — any other service work
  final String type;

  /// Short description, e.g. "GSR", "Coffee Maker", "Speaker at Unity Group"
  final String title;

  /// Group, intergroup, district, or event name.
  final String? organization;
  final DateTime startDate;

  /// null = open-ended / ongoing
  final DateTime? endDate;
  final bool isActive;
  final bool isRecurring;

  /// 0 = Sunday … 6 = Saturday; null when not recurring.
  final int? recurringWeekday;

  /// Wall-clock time in "HH:mm" 24-h format; null when not recurring.
  final String? recurringTime;
  final bool reminderEnabled;

  /// Minutes before the commitment time to fire the reminder.
  final int? reminderMinutesBefore;
  final String? notes;
  final DateTime createdAt;
  const ServiceCommitment({
    required this.id,
    required this.type,
    required this.title,
    this.organization,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.isRecurring,
    this.recurringWeekday,
    this.recurringTime,
    required this.reminderEnabled,
    this.reminderMinutesBefore,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || organization != null) {
      map['organization'] = Variable<String>(organization);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurringWeekday != null) {
      map['recurring_weekday'] = Variable<int>(recurringWeekday);
    }
    if (!nullToAbsent || recurringTime != null) {
      map['recurring_time'] = Variable<String>(recurringTime);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    if (!nullToAbsent || reminderMinutesBefore != null) {
      map['reminder_minutes_before'] = Variable<int>(reminderMinutesBefore);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServiceCommitmentsCompanion toCompanion(bool nullToAbsent) {
    return ServiceCommitmentsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      organization: organization == null && nullToAbsent
          ? const Value.absent()
          : Value(organization),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      isRecurring: Value(isRecurring),
      recurringWeekday: recurringWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringWeekday),
      recurringTime: recurringTime == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringTime),
      reminderEnabled: Value(reminderEnabled),
      reminderMinutesBefore: reminderMinutesBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutesBefore),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ServiceCommitment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceCommitment(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      organization: serializer.fromJson<String?>(json['organization']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringWeekday: serializer.fromJson<int?>(json['recurringWeekday']),
      recurringTime: serializer.fromJson<String?>(json['recurringTime']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderMinutesBefore: serializer.fromJson<int?>(
        json['reminderMinutesBefore'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'organization': serializer.toJson<String?>(organization),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringWeekday': serializer.toJson<int?>(recurringWeekday),
      'recurringTime': serializer.toJson<String?>(recurringTime),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderMinutesBefore': serializer.toJson<int?>(reminderMinutesBefore),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceCommitment copyWith({
    int? id,
    String? type,
    String? title,
    Value<String?> organization = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
    bool? isRecurring,
    Value<int?> recurringWeekday = const Value.absent(),
    Value<String?> recurringTime = const Value.absent(),
    bool? reminderEnabled,
    Value<int?> reminderMinutesBefore = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => ServiceCommitment(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    organization: organization.present ? organization.value : this.organization,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    isRecurring: isRecurring ?? this.isRecurring,
    recurringWeekday: recurringWeekday.present
        ? recurringWeekday.value
        : this.recurringWeekday,
    recurringTime: recurringTime.present
        ? recurringTime.value
        : this.recurringTime,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderMinutesBefore: reminderMinutesBefore.present
        ? reminderMinutesBefore.value
        : this.reminderMinutesBefore,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  ServiceCommitment copyWithCompanion(ServiceCommitmentsCompanion data) {
    return ServiceCommitment(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      recurringWeekday: data.recurringWeekday.present
          ? data.recurringWeekday.value
          : this.recurringWeekday,
      recurringTime: data.recurringTime.present
          ? data.recurringTime.value
          : this.recurringTime,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderMinutesBefore: data.reminderMinutesBefore.present
          ? data.reminderMinutesBefore.value
          : this.reminderMinutesBefore,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceCommitment(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('organization: $organization, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringWeekday: $recurringWeekday, ')
          ..write('recurringTime: $recurringTime, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    organization,
    startDate,
    endDate,
    isActive,
    isRecurring,
    recurringWeekday,
    recurringTime,
    reminderEnabled,
    reminderMinutesBefore,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceCommitment &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.organization == this.organization &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.isRecurring == this.isRecurring &&
          other.recurringWeekday == this.recurringWeekday &&
          other.recurringTime == this.recurringTime &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderMinutesBefore == this.reminderMinutesBefore &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ServiceCommitmentsCompanion extends UpdateCompanion<ServiceCommitment> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> organization;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<bool> isRecurring;
  final Value<int?> recurringWeekday;
  final Value<String?> recurringTime;
  final Value<bool> reminderEnabled;
  final Value<int?> reminderMinutesBefore;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ServiceCommitmentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.organization = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringWeekday = const Value.absent(),
    this.recurringTime = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ServiceCommitmentsCompanion.insert({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    required String title,
    this.organization = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringWeekday = const Value.absent(),
    this.recurringTime = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       startDate = Value(startDate);
  static Insertable<ServiceCommitment> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? organization,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<bool>? isRecurring,
    Expression<int>? recurringWeekday,
    Expression<String>? recurringTime,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderMinutesBefore,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (organization != null) 'organization': organization,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringWeekday != null) 'recurring_weekday': recurringWeekday,
      if (recurringTime != null) 'recurring_time': recurringTime,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderMinutesBefore != null)
        'reminder_minutes_before': reminderMinutesBefore,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ServiceCommitmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? organization,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<bool>? isRecurring,
    Value<int?>? recurringWeekday,
    Value<String?>? recurringTime,
    Value<bool>? reminderEnabled,
    Value<int?>? reminderMinutesBefore,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return ServiceCommitmentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringWeekday: recurringWeekday ?? this.recurringWeekday,
      recurringTime: recurringTime ?? this.recurringTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringWeekday.present) {
      map['recurring_weekday'] = Variable<int>(recurringWeekday.value);
    }
    if (recurringTime.present) {
      map['recurring_time'] = Variable<String>(recurringTime.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderMinutesBefore.present) {
      map['reminder_minutes_before'] = Variable<int>(
        reminderMinutesBefore.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceCommitmentsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('organization: $organization, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringWeekday: $recurringWeekday, ')
          ..write('recurringTime: $recurringTime, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SponseesTable extends Sponsees with TableInfo<$SponseesTable, Sponsee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SponseesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sobrietyDateMeta = const VerificationMeta(
    'sobrietyDate',
  );
  @override
  late final GeneratedColumn<DateTime> sobrietyDate = GeneratedColumn<DateTime>(
    'sobriety_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedSponsoringDateMeta =
      const VerificationMeta('startedSponsoringDate');
  @override
  late final GeneratedColumn<DateTime> startedSponsoringDate =
      GeneratedColumn<DateTime>(
        'started_sponsoring_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentStepMeta = const VerificationMeta(
    'currentStep',
  );
  @override
  late final GeneratedColumn<int> currentStep = GeneratedColumn<int>(
    'current_step',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    sobrietyDate,
    startedSponsoringDate,
    currentStep,
    isActive,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sponsees';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sponsee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('sobriety_date')) {
      context.handle(
        _sobrietyDateMeta,
        sobrietyDate.isAcceptableOrUnknown(
          data['sobriety_date']!,
          _sobrietyDateMeta,
        ),
      );
    }
    if (data.containsKey('started_sponsoring_date')) {
      context.handle(
        _startedSponsoringDateMeta,
        startedSponsoringDate.isAcceptableOrUnknown(
          data['started_sponsoring_date']!,
          _startedSponsoringDateMeta,
        ),
      );
    }
    if (data.containsKey('current_step')) {
      context.handle(
        _currentStepMeta,
        currentStep.isAcceptableOrUnknown(
          data['current_step']!,
          _currentStepMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sponsee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sponsee(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      sobrietyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sobriety_date'],
      ),
      startedSponsoringDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_sponsoring_date'],
      ),
      currentStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_step'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SponseesTable createAlias(String alias) {
    return $SponseesTable(attachedDatabase, alias);
  }
}

class Sponsee extends DataClass implements Insertable<Sponsee> {
  final int id;
  final String name;
  final String? phone;
  final String? email;

  /// The sponsee's own sobriety start date (for milestone tracking).
  final DateTime? sobrietyDate;

  /// When this sponsoring relationship began.
  final DateTime? startedSponsoringDate;

  /// Current active step (1–12), null if not yet started.
  final int? currentStep;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  const Sponsee({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.sobrietyDate,
    this.startedSponsoringDate,
    this.currentStep,
    required this.isActive,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || sobrietyDate != null) {
      map['sobriety_date'] = Variable<DateTime>(sobrietyDate);
    }
    if (!nullToAbsent || startedSponsoringDate != null) {
      map['started_sponsoring_date'] = Variable<DateTime>(
        startedSponsoringDate,
      );
    }
    if (!nullToAbsent || currentStep != null) {
      map['current_step'] = Variable<int>(currentStep);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SponseesCompanion toCompanion(bool nullToAbsent) {
    return SponseesCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      sobrietyDate: sobrietyDate == null && nullToAbsent
          ? const Value.absent()
          : Value(sobrietyDate),
      startedSponsoringDate: startedSponsoringDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startedSponsoringDate),
      currentStep: currentStep == null && nullToAbsent
          ? const Value.absent()
          : Value(currentStep),
      isActive: Value(isActive),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Sponsee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sponsee(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      sobrietyDate: serializer.fromJson<DateTime?>(json['sobrietyDate']),
      startedSponsoringDate: serializer.fromJson<DateTime?>(
        json['startedSponsoringDate'],
      ),
      currentStep: serializer.fromJson<int?>(json['currentStep']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'sobrietyDate': serializer.toJson<DateTime?>(sobrietyDate),
      'startedSponsoringDate': serializer.toJson<DateTime?>(
        startedSponsoringDate,
      ),
      'currentStep': serializer.toJson<int?>(currentStep),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Sponsee copyWith({
    int? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<DateTime?> sobrietyDate = const Value.absent(),
    Value<DateTime?> startedSponsoringDate = const Value.absent(),
    Value<int?> currentStep = const Value.absent(),
    bool? isActive,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Sponsee(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    sobrietyDate: sobrietyDate.present ? sobrietyDate.value : this.sobrietyDate,
    startedSponsoringDate: startedSponsoringDate.present
        ? startedSponsoringDate.value
        : this.startedSponsoringDate,
    currentStep: currentStep.present ? currentStep.value : this.currentStep,
    isActive: isActive ?? this.isActive,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Sponsee copyWithCompanion(SponseesCompanion data) {
    return Sponsee(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      sobrietyDate: data.sobrietyDate.present
          ? data.sobrietyDate.value
          : this.sobrietyDate,
      startedSponsoringDate: data.startedSponsoringDate.present
          ? data.startedSponsoringDate.value
          : this.startedSponsoringDate,
      currentStep: data.currentStep.present
          ? data.currentStep.value
          : this.currentStep,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sponsee(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('sobrietyDate: $sobrietyDate, ')
          ..write('startedSponsoringDate: $startedSponsoringDate, ')
          ..write('currentStep: $currentStep, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    email,
    sobrietyDate,
    startedSponsoringDate,
    currentStep,
    isActive,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sponsee &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.sobrietyDate == this.sobrietyDate &&
          other.startedSponsoringDate == this.startedSponsoringDate &&
          other.currentStep == this.currentStep &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SponseesCompanion extends UpdateCompanion<Sponsee> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<DateTime?> sobrietyDate;
  final Value<DateTime?> startedSponsoringDate;
  final Value<int?> currentStep;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const SponseesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.sobrietyDate = const Value.absent(),
    this.startedSponsoringDate = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SponseesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.sobrietyDate = const Value.absent(),
    this.startedSponsoringDate = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Sponsee> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<DateTime>? sobrietyDate,
    Expression<DateTime>? startedSponsoringDate,
    Expression<int>? currentStep,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (sobrietyDate != null) 'sobriety_date': sobrietyDate,
      if (startedSponsoringDate != null)
        'started_sponsoring_date': startedSponsoringDate,
      if (currentStep != null) 'current_step': currentStep,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SponseesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<DateTime?>? sobrietyDate,
    Value<DateTime?>? startedSponsoringDate,
    Value<int?>? currentStep,
    Value<bool>? isActive,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return SponseesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      sobrietyDate: sobrietyDate ?? this.sobrietyDate,
      startedSponsoringDate:
          startedSponsoringDate ?? this.startedSponsoringDate,
      currentStep: currentStep ?? this.currentStep,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (sobrietyDate.present) {
      map['sobriety_date'] = Variable<DateTime>(sobrietyDate.value);
    }
    if (startedSponsoringDate.present) {
      map['started_sponsoring_date'] = Variable<DateTime>(
        startedSponsoringDate.value,
      );
    }
    if (currentStep.present) {
      map['current_step'] = Variable<int>(currentStep.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SponseesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('sobrietyDate: $sobrietyDate, ')
          ..write('startedSponsoringDate: $startedSponsoringDate, ')
          ..write('currentStep: $currentStep, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TwelfthStepCallsTable extends TwelfthStepCalls
    with TableInfo<$TwelfthStepCallsTable, TwelfthStepCall> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TwelfthStepCallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _callTypeMeta = const VerificationMeta(
    'callType',
  );
  @override
  late final GeneratedColumn<String> callType = GeneratedColumn<String>(
    'call_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('call'),
  );
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sponseeIdMeta = const VerificationMeta(
    'sponseeId',
  );
  @override
  late final GeneratedColumn<int> sponseeId = GeneratedColumn<int>(
    'sponsee_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sponsees (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    callType,
    person,
    description,
    outcome,
    occurredAt,
    scheduledAt,
    sponseeId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'twelfth_step_calls';
  @override
  VerificationContext validateIntegrity(
    Insertable<TwelfthStepCall> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('call_type')) {
      context.handle(
        _callTypeMeta,
        callType.isAcceptableOrUnknown(data['call_type']!, _callTypeMeta),
      );
    }
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('sponsee_id')) {
      context.handle(
        _sponseeIdMeta,
        sponseeId.isAcceptableOrUnknown(data['sponsee_id']!, _sponseeIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TwelfthStepCall map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TwelfthStepCall(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      callType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_type'],
      )!,
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      sponseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sponsee_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TwelfthStepCallsTable createAlias(String alias) {
    return $TwelfthStepCallsTable(attachedDatabase, alias);
  }
}

class TwelfthStepCall extends DataClass implements Insertable<TwelfthStepCall> {
  final int id;

  /// 'call'        — phone / text outreach
  /// 'visit'       — in-person 12th-step visit
  /// 'sponsorship' — sponsee-related interaction
  /// 'general'     — other 12th-step work
  final String callType;

  /// First name only (or null) — preserved for the user's own reference,
  /// never required.
  final String? person;

  /// Brief description of the work done.
  final String description;

  /// What happened / how it went.
  final String? outcome;

  /// When the call took place (or is planned to take place).
  final DateTime occurredAt;

  /// Non-null = this is a future planned call (not yet completed).
  /// The calendar event is created at save-time; null = already logged.
  final DateTime? scheduledAt;

  /// Optional link to a sponsee record.
  final int? sponseeId;
  final DateTime createdAt;
  const TwelfthStepCall({
    required this.id,
    required this.callType,
    this.person,
    required this.description,
    this.outcome,
    required this.occurredAt,
    this.scheduledAt,
    this.sponseeId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['call_type'] = Variable<String>(callType);
    if (!nullToAbsent || person != null) {
      map['person'] = Variable<String>(person);
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || sponseeId != null) {
      map['sponsee_id'] = Variable<int>(sponseeId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TwelfthStepCallsCompanion toCompanion(bool nullToAbsent) {
    return TwelfthStepCallsCompanion(
      id: Value(id),
      callType: Value(callType),
      person: person == null && nullToAbsent
          ? const Value.absent()
          : Value(person),
      description: Value(description),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      occurredAt: Value(occurredAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      sponseeId: sponseeId == null && nullToAbsent
          ? const Value.absent()
          : Value(sponseeId),
      createdAt: Value(createdAt),
    );
  }

  factory TwelfthStepCall.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TwelfthStepCall(
      id: serializer.fromJson<int>(json['id']),
      callType: serializer.fromJson<String>(json['callType']),
      person: serializer.fromJson<String?>(json['person']),
      description: serializer.fromJson<String>(json['description']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      sponseeId: serializer.fromJson<int?>(json['sponseeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'callType': serializer.toJson<String>(callType),
      'person': serializer.toJson<String?>(person),
      'description': serializer.toJson<String>(description),
      'outcome': serializer.toJson<String?>(outcome),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'sponseeId': serializer.toJson<int?>(sponseeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TwelfthStepCall copyWith({
    int? id,
    String? callType,
    Value<String?> person = const Value.absent(),
    String? description,
    Value<String?> outcome = const Value.absent(),
    DateTime? occurredAt,
    Value<DateTime?> scheduledAt = const Value.absent(),
    Value<int?> sponseeId = const Value.absent(),
    DateTime? createdAt,
  }) => TwelfthStepCall(
    id: id ?? this.id,
    callType: callType ?? this.callType,
    person: person.present ? person.value : this.person,
    description: description ?? this.description,
    outcome: outcome.present ? outcome.value : this.outcome,
    occurredAt: occurredAt ?? this.occurredAt,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    sponseeId: sponseeId.present ? sponseeId.value : this.sponseeId,
    createdAt: createdAt ?? this.createdAt,
  );
  TwelfthStepCall copyWithCompanion(TwelfthStepCallsCompanion data) {
    return TwelfthStepCall(
      id: data.id.present ? data.id.value : this.id,
      callType: data.callType.present ? data.callType.value : this.callType,
      person: data.person.present ? data.person.value : this.person,
      description: data.description.present
          ? data.description.value
          : this.description,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      sponseeId: data.sponseeId.present ? data.sponseeId.value : this.sponseeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TwelfthStepCall(')
          ..write('id: $id, ')
          ..write('callType: $callType, ')
          ..write('person: $person, ')
          ..write('description: $description, ')
          ..write('outcome: $outcome, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    callType,
    person,
    description,
    outcome,
    occurredAt,
    scheduledAt,
    sponseeId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TwelfthStepCall &&
          other.id == this.id &&
          other.callType == this.callType &&
          other.person == this.person &&
          other.description == this.description &&
          other.outcome == this.outcome &&
          other.occurredAt == this.occurredAt &&
          other.scheduledAt == this.scheduledAt &&
          other.sponseeId == this.sponseeId &&
          other.createdAt == this.createdAt);
}

class TwelfthStepCallsCompanion extends UpdateCompanion<TwelfthStepCall> {
  final Value<int> id;
  final Value<String> callType;
  final Value<String?> person;
  final Value<String> description;
  final Value<String?> outcome;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> scheduledAt;
  final Value<int?> sponseeId;
  final Value<DateTime> createdAt;
  const TwelfthStepCallsCompanion({
    this.id = const Value.absent(),
    this.callType = const Value.absent(),
    this.person = const Value.absent(),
    this.description = const Value.absent(),
    this.outcome = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.sponseeId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TwelfthStepCallsCompanion.insert({
    this.id = const Value.absent(),
    this.callType = const Value.absent(),
    this.person = const Value.absent(),
    required String description,
    this.outcome = const Value.absent(),
    required DateTime occurredAt,
    this.scheduledAt = const Value.absent(),
    this.sponseeId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : description = Value(description),
       occurredAt = Value(occurredAt);
  static Insertable<TwelfthStepCall> custom({
    Expression<int>? id,
    Expression<String>? callType,
    Expression<String>? person,
    Expression<String>? description,
    Expression<String>? outcome,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? scheduledAt,
    Expression<int>? sponseeId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (callType != null) 'call_type': callType,
      if (person != null) 'person': person,
      if (description != null) 'description': description,
      if (outcome != null) 'outcome': outcome,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (sponseeId != null) 'sponsee_id': sponseeId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TwelfthStepCallsCompanion copyWith({
    Value<int>? id,
    Value<String>? callType,
    Value<String?>? person,
    Value<String>? description,
    Value<String?>? outcome,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? scheduledAt,
    Value<int?>? sponseeId,
    Value<DateTime>? createdAt,
  }) {
    return TwelfthStepCallsCompanion(
      id: id ?? this.id,
      callType: callType ?? this.callType,
      person: person ?? this.person,
      description: description ?? this.description,
      outcome: outcome ?? this.outcome,
      occurredAt: occurredAt ?? this.occurredAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sponseeId: sponseeId ?? this.sponseeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (callType.present) {
      map['call_type'] = Variable<String>(callType.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (sponseeId.present) {
      map['sponsee_id'] = Variable<int>(sponseeId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TwelfthStepCallsCompanion(')
          ..write('id: $id, ')
          ..write('callType: $callType, ')
          ..write('person: $person, ')
          ..write('description: $description, ')
          ..write('outcome: $outcome, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SponseeStepProgressTable extends SponseeStepProgress
    with TableInfo<$SponseeStepProgressTable, SponseeStepEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SponseeStepProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sponseeIdMeta = const VerificationMeta(
    'sponseeId',
  );
  @override
  late final GeneratedColumn<int> sponseeId = GeneratedColumn<int>(
    'sponsee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sponsees (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stepNumberMeta = const VerificationMeta(
    'stepNumber',
  );
  @override
  late final GeneratedColumn<int> stepNumber = GeneratedColumn<int>(
    'step_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('not_started'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sponseeId,
    stepNumber,
    status,
    completedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sponsee_step_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<SponseeStepEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sponsee_id')) {
      context.handle(
        _sponseeIdMeta,
        sponseeId.isAcceptableOrUnknown(data['sponsee_id']!, _sponseeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sponseeIdMeta);
    }
    if (data.containsKey('step_number')) {
      context.handle(
        _stepNumberMeta,
        stepNumber.isAcceptableOrUnknown(data['step_number']!, _stepNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_stepNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SponseeStepEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SponseeStepEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sponseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sponsee_id'],
      )!,
      stepNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SponseeStepProgressTable createAlias(String alias) {
    return $SponseeStepProgressTable(attachedDatabase, alias);
  }
}

class SponseeStepEntry extends DataClass
    implements Insertable<SponseeStepEntry> {
  final int id;
  final int sponseeId;

  /// 1 through 12.
  final int stepNumber;

  /// 'not_started' | 'in_progress' | 'completed'
  final String status;
  final DateTime? completedAt;
  final String? notes;
  const SponseeStepEntry({
    required this.id,
    required this.sponseeId,
    required this.stepNumber,
    required this.status,
    this.completedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sponsee_id'] = Variable<int>(sponseeId);
    map['step_number'] = Variable<int>(stepNumber);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SponseeStepProgressCompanion toCompanion(bool nullToAbsent) {
    return SponseeStepProgressCompanion(
      id: Value(id),
      sponseeId: Value(sponseeId),
      stepNumber: Value(stepNumber),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SponseeStepEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SponseeStepEntry(
      id: serializer.fromJson<int>(json['id']),
      sponseeId: serializer.fromJson<int>(json['sponseeId']),
      stepNumber: serializer.fromJson<int>(json['stepNumber']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sponseeId': serializer.toJson<int>(sponseeId),
      'stepNumber': serializer.toJson<int>(stepNumber),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SponseeStepEntry copyWith({
    int? id,
    int? sponseeId,
    int? stepNumber,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SponseeStepEntry(
    id: id ?? this.id,
    sponseeId: sponseeId ?? this.sponseeId,
    stepNumber: stepNumber ?? this.stepNumber,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  SponseeStepEntry copyWithCompanion(SponseeStepProgressCompanion data) {
    return SponseeStepEntry(
      id: data.id.present ? data.id.value : this.id,
      sponseeId: data.sponseeId.present ? data.sponseeId.value : this.sponseeId,
      stepNumber: data.stepNumber.present
          ? data.stepNumber.value
          : this.stepNumber,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SponseeStepEntry(')
          ..write('id: $id, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sponseeId, stepNumber, status, completedAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SponseeStepEntry &&
          other.id == this.id &&
          other.sponseeId == this.sponseeId &&
          other.stepNumber == this.stepNumber &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes);
}

class SponseeStepProgressCompanion extends UpdateCompanion<SponseeStepEntry> {
  final Value<int> id;
  final Value<int> sponseeId;
  final Value<int> stepNumber;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  const SponseeStepProgressCompanion({
    this.id = const Value.absent(),
    this.sponseeId = const Value.absent(),
    this.stepNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SponseeStepProgressCompanion.insert({
    this.id = const Value.absent(),
    required int sponseeId,
    required int stepNumber,
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : sponseeId = Value(sponseeId),
       stepNumber = Value(stepNumber);
  static Insertable<SponseeStepEntry> custom({
    Expression<int>? id,
    Expression<int>? sponseeId,
    Expression<int>? stepNumber,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sponseeId != null) 'sponsee_id': sponseeId,
      if (stepNumber != null) 'step_number': stepNumber,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
    });
  }

  SponseeStepProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? sponseeId,
    Value<int>? stepNumber,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<String?>? notes,
  }) {
    return SponseeStepProgressCompanion(
      id: id ?? this.id,
      sponseeId: sponseeId ?? this.sponseeId,
      stepNumber: stepNumber ?? this.stepNumber,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sponseeId.present) {
      map['sponsee_id'] = Variable<int>(sponseeId.value);
    }
    if (stepNumber.present) {
      map['step_number'] = Variable<int>(stepNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SponseeStepProgressCompanion(')
          ..write('id: $id, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SponseeCheckInsTable extends SponseeCheckIns
    with TableInfo<$SponseeCheckInsTable, SponseeCheckIn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SponseeCheckInsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sponseeIdMeta = const VerificationMeta(
    'sponseeId',
  );
  @override
  late final GeneratedColumn<int> sponseeId = GeneratedColumn<int>(
    'sponsee_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sponsees (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sponseeId,
    scheduledAt,
    completedAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sponsee_check_ins';
  @override
  VerificationContext validateIntegrity(
    Insertable<SponseeCheckIn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sponsee_id')) {
      context.handle(
        _sponseeIdMeta,
        sponseeId.isAcceptableOrUnknown(data['sponsee_id']!, _sponseeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sponseeIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SponseeCheckIn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SponseeCheckIn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sponseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sponsee_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SponseeCheckInsTable createAlias(String alias) {
    return $SponseeCheckInsTable(attachedDatabase, alias);
  }
}

class SponseeCheckIn extends DataClass implements Insertable<SponseeCheckIn> {
  final int id;
  final int sponseeId;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  const SponseeCheckIn({
    required this.id,
    required this.sponseeId,
    required this.scheduledAt,
    this.completedAt,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sponsee_id'] = Variable<int>(sponseeId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SponseeCheckInsCompanion toCompanion(bool nullToAbsent) {
    return SponseeCheckInsCompanion(
      id: Value(id),
      sponseeId: Value(sponseeId),
      scheduledAt: Value(scheduledAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory SponseeCheckIn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SponseeCheckIn(
      id: serializer.fromJson<int>(json['id']),
      sponseeId: serializer.fromJson<int>(json['sponseeId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sponseeId': serializer.toJson<int>(sponseeId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SponseeCheckIn copyWith({
    int? id,
    int? sponseeId,
    DateTime? scheduledAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => SponseeCheckIn(
    id: id ?? this.id,
    sponseeId: sponseeId ?? this.sponseeId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  SponseeCheckIn copyWithCompanion(SponseeCheckInsCompanion data) {
    return SponseeCheckIn(
      id: data.id.present ? data.id.value : this.id,
      sponseeId: data.sponseeId.present ? data.sponseeId.value : this.sponseeId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SponseeCheckIn(')
          ..write('id: $id, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sponseeId, scheduledAt, completedAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SponseeCheckIn &&
          other.id == this.id &&
          other.sponseeId == this.sponseeId &&
          other.scheduledAt == this.scheduledAt &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SponseeCheckInsCompanion extends UpdateCompanion<SponseeCheckIn> {
  final Value<int> id;
  final Value<int> sponseeId;
  final Value<DateTime> scheduledAt;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const SponseeCheckInsCompanion({
    this.id = const Value.absent(),
    this.sponseeId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SponseeCheckInsCompanion.insert({
    this.id = const Value.absent(),
    required int sponseeId,
    required DateTime scheduledAt,
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sponseeId = Value(sponseeId),
       scheduledAt = Value(scheduledAt);
  static Insertable<SponseeCheckIn> custom({
    Expression<int>? id,
    Expression<int>? sponseeId,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sponseeId != null) 'sponsee_id': sponseeId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SponseeCheckInsCompanion copyWith({
    Value<int>? id,
    Value<int>? sponseeId,
    Value<DateTime>? scheduledAt,
    Value<DateTime?>? completedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return SponseeCheckInsCompanion(
      id: id ?? this.id,
      sponseeId: sponseeId ?? this.sponseeId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sponseeId.present) {
      map['sponsee_id'] = Variable<int>(sponseeId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SponseeCheckInsCompanion(')
          ..write('id: $id, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepNumberMeta = const VerificationMeta(
    'stepNumber',
  );
  @override
  late final GeneratedColumn<int> stepNumber = GeneratedColumn<int>(
    'step_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _traditionNumberMeta = const VerificationMeta(
    'traditionNumber',
  );
  @override
  late final GeneratedColumn<int> traditionNumber = GeneratedColumn<int>(
    'tradition_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptIdMeta = const VerificationMeta(
    'promptId',
  );
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
    'prompt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    title,
    stepNumber,
    traditionNumber,
    promptId,
    tags,
    mood,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('step_number')) {
      context.handle(
        _stepNumberMeta,
        stepNumber.isAcceptableOrUnknown(data['step_number']!, _stepNumberMeta),
      );
    }
    if (data.containsKey('tradition_number')) {
      context.handle(
        _traditionNumberMeta,
        traditionNumber.isAcceptableOrUnknown(
          data['tradition_number']!,
          _traditionNumberMeta,
        ),
      );
    }
    if (data.containsKey('prompt_id')) {
      context.handle(
        _promptIdMeta,
        promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      stepNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_number'],
      ),
      traditionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tradition_number'],
      ),
      promptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_id'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  final int id;

  /// The user's written reflection.  Required — never empty.
  final String content;

  /// Optional user-supplied headline for the entry.
  final String? title;

  /// Which step (1–12) this entry is associated with.
  /// Null when the entry is tradition-related or uncategorised.
  final int? stepNumber;

  /// Which tradition (1–12) this entry is associated with.
  /// Null when the entry is step-related or uncategorised.
  final int? traditionNumber;

  /// Future: stable ID of the contemplative prompt that inspired this entry.
  /// Populated by the AI recovery-bot feature; null for self-initiated entries.
  final String? promptId;

  /// Future: comma-separated user tags, e.g. "gratitude,fear,hope".
  final String? tags;

  /// Future: emotional tone at write-time — e.g. "hopeful" | "struggling".
  final String? mood;
  final DateTime createdAt;
  final DateTime updatedAt;
  const JournalEntry({
    required this.id,
    required this.content,
    this.title,
    this.stepNumber,
    this.traditionNumber,
    this.promptId,
    this.tags,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || stepNumber != null) {
      map['step_number'] = Variable<int>(stepNumber);
    }
    if (!nullToAbsent || traditionNumber != null) {
      map['tradition_number'] = Variable<int>(traditionNumber);
    }
    if (!nullToAbsent || promptId != null) {
      map['prompt_id'] = Variable<String>(promptId);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      content: Value(content),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      stepNumber: stepNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(stepNumber),
      traditionNumber: traditionNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(traditionNumber),
      promptId: promptId == null && nullToAbsent
          ? const Value.absent()
          : Value(promptId),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      title: serializer.fromJson<String?>(json['title']),
      stepNumber: serializer.fromJson<int?>(json['stepNumber']),
      traditionNumber: serializer.fromJson<int?>(json['traditionNumber']),
      promptId: serializer.fromJson<String?>(json['promptId']),
      tags: serializer.fromJson<String?>(json['tags']),
      mood: serializer.fromJson<String?>(json['mood']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'title': serializer.toJson<String?>(title),
      'stepNumber': serializer.toJson<int?>(stepNumber),
      'traditionNumber': serializer.toJson<int?>(traditionNumber),
      'promptId': serializer.toJson<String?>(promptId),
      'tags': serializer.toJson<String?>(tags),
      'mood': serializer.toJson<String?>(mood),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JournalEntry copyWith({
    int? id,
    String? content,
    Value<String?> title = const Value.absent(),
    Value<int?> stepNumber = const Value.absent(),
    Value<int?> traditionNumber = const Value.absent(),
    Value<String?> promptId = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> mood = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JournalEntry(
    id: id ?? this.id,
    content: content ?? this.content,
    title: title.present ? title.value : this.title,
    stepNumber: stepNumber.present ? stepNumber.value : this.stepNumber,
    traditionNumber: traditionNumber.present
        ? traditionNumber.value
        : this.traditionNumber,
    promptId: promptId.present ? promptId.value : this.promptId,
    tags: tags.present ? tags.value : this.tags,
    mood: mood.present ? mood.value : this.mood,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      title: data.title.present ? data.title.value : this.title,
      stepNumber: data.stepNumber.present
          ? data.stepNumber.value
          : this.stepNumber,
      traditionNumber: data.traditionNumber.present
          ? data.traditionNumber.value
          : this.traditionNumber,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      tags: data.tags.present ? data.tags.value : this.tags,
      mood: data.mood.present ? data.mood.value : this.mood,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('traditionNumber: $traditionNumber, ')
          ..write('promptId: $promptId, ')
          ..write('tags: $tags, ')
          ..write('mood: $mood, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    title,
    stepNumber,
    traditionNumber,
    promptId,
    tags,
    mood,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.content == this.content &&
          other.title == this.title &&
          other.stepNumber == this.stepNumber &&
          other.traditionNumber == this.traditionNumber &&
          other.promptId == this.promptId &&
          other.tags == this.tags &&
          other.mood == this.mood &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<String> content;
  final Value<String?> title;
  final Value<int?> stepNumber;
  final Value<int?> traditionNumber;
  final Value<String?> promptId;
  final Value<String?> tags;
  final Value<String?> mood;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.title = const Value.absent(),
    this.stepNumber = const Value.absent(),
    this.traditionNumber = const Value.absent(),
    this.promptId = const Value.absent(),
    this.tags = const Value.absent(),
    this.mood = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.title = const Value.absent(),
    this.stepNumber = const Value.absent(),
    this.traditionNumber = const Value.absent(),
    this.promptId = const Value.absent(),
    this.tags = const Value.absent(),
    this.mood = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : content = Value(content);
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<String>? title,
    Expression<int>? stepNumber,
    Expression<int>? traditionNumber,
    Expression<String>? promptId,
    Expression<String>? tags,
    Expression<String>? mood,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (title != null) 'title': title,
      if (stepNumber != null) 'step_number': stepNumber,
      if (traditionNumber != null) 'tradition_number': traditionNumber,
      if (promptId != null) 'prompt_id': promptId,
      if (tags != null) 'tags': tags,
      if (mood != null) 'mood': mood,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? content,
    Value<String?>? title,
    Value<int?>? stepNumber,
    Value<int?>? traditionNumber,
    Value<String?>? promptId,
    Value<String?>? tags,
    Value<String?>? mood,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      title: title ?? this.title,
      stepNumber: stepNumber ?? this.stepNumber,
      traditionNumber: traditionNumber ?? this.traditionNumber,
      promptId: promptId ?? this.promptId,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (stepNumber.present) {
      map['step_number'] = Variable<int>(stepNumber.value);
    }
    if (traditionNumber.present) {
      map['tradition_number'] = Variable<int>(traditionNumber.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('traditionNumber: $traditionNumber, ')
          ..write('promptId: $promptId, ')
          ..write('tags: $tags, ')
          ..write('mood: $mood, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LiteratureBookmarksTable extends LiteratureBookmarks
    with TableInfo<$LiteratureBookmarksTable, LiteratureBookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiteratureBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookKeyMeta = const VerificationMeta(
    'bookKey',
  );
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
    'book_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterKeyMeta = const VerificationMeta(
    'chapterKey',
  );
  @override
  late final GeneratedColumn<String> chapterKey = GeneratedColumn<String>(
    'chapter_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterTitleMeta = const VerificationMeta(
    'chapterTitle',
  );
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
    'chapter_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookKey,
    chapterKey,
    chapterTitle,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'literature_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LiteratureBookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_key')) {
      context.handle(
        _bookKeyMeta,
        bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('chapter_key')) {
      context.handle(
        _chapterKeyMeta,
        chapterKey.isAcceptableOrUnknown(data['chapter_key']!, _chapterKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterKeyMeta);
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
        _chapterTitleMeta,
        chapterTitle.isAcceptableOrUnknown(
          data['chapter_title']!,
          _chapterTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterTitleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {bookKey, chapterKey},
  ];
  @override
  LiteratureBookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LiteratureBookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_key'],
      )!,
      chapterKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_key'],
      )!,
      chapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LiteratureBookmarksTable createAlias(String alias) {
    return $LiteratureBookmarksTable(attachedDatabase, alias);
  }
}

class LiteratureBookmark extends DataClass
    implements Insertable<LiteratureBookmark> {
  final int id;

  /// 'bigbook' | 'twelve_twelve'
  final String bookKey;

  /// Stable chapter identifier, e.g. 'bb_ch5', 'tt_step7'.
  final String chapterKey;

  /// Human-readable chapter title, e.g. "How It Works".
  final String chapterTitle;

  /// Optional personal note about why this chapter was bookmarked.
  final String? note;
  final DateTime createdAt;
  const LiteratureBookmark({
    required this.id,
    required this.bookKey,
    required this.chapterKey,
    required this.chapterTitle,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_key'] = Variable<String>(chapterKey);
    map['chapter_title'] = Variable<String>(chapterTitle);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LiteratureBookmarksCompanion toCompanion(bool nullToAbsent) {
    return LiteratureBookmarksCompanion(
      id: Value(id),
      bookKey: Value(bookKey),
      chapterKey: Value(chapterKey),
      chapterTitle: Value(chapterTitle),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory LiteratureBookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LiteratureBookmark(
      id: serializer.fromJson<int>(json['id']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterKey: serializer.fromJson<String>(json['chapterKey']),
      chapterTitle: serializer.fromJson<String>(json['chapterTitle']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterKey': serializer.toJson<String>(chapterKey),
      'chapterTitle': serializer.toJson<String>(chapterTitle),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LiteratureBookmark copyWith({
    int? id,
    String? bookKey,
    String? chapterKey,
    String? chapterTitle,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => LiteratureBookmark(
    id: id ?? this.id,
    bookKey: bookKey ?? this.bookKey,
    chapterKey: chapterKey ?? this.chapterKey,
    chapterTitle: chapterTitle ?? this.chapterTitle,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  LiteratureBookmark copyWithCompanion(LiteratureBookmarksCompanion data) {
    return LiteratureBookmark(
      id: data.id.present ? data.id.value : this.id,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      chapterKey: data.chapterKey.present
          ? data.chapterKey.value
          : this.chapterKey,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LiteratureBookmark(')
          ..write('id: $id, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterKey: $chapterKey, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookKey, chapterKey, chapterTitle, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LiteratureBookmark &&
          other.id == this.id &&
          other.bookKey == this.bookKey &&
          other.chapterKey == this.chapterKey &&
          other.chapterTitle == this.chapterTitle &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class LiteratureBookmarksCompanion extends UpdateCompanion<LiteratureBookmark> {
  final Value<int> id;
  final Value<String> bookKey;
  final Value<String> chapterKey;
  final Value<String> chapterTitle;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const LiteratureBookmarksCompanion({
    this.id = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.chapterKey = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LiteratureBookmarksCompanion.insert({
    this.id = const Value.absent(),
    required String bookKey,
    required String chapterKey,
    required String chapterTitle,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : bookKey = Value(bookKey),
       chapterKey = Value(chapterKey),
       chapterTitle = Value(chapterTitle);
  static Insertable<LiteratureBookmark> custom({
    Expression<int>? id,
    Expression<String>? bookKey,
    Expression<String>? chapterKey,
    Expression<String>? chapterTitle,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookKey != null) 'book_key': bookKey,
      if (chapterKey != null) 'chapter_key': chapterKey,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LiteratureBookmarksCompanion copyWith({
    Value<int>? id,
    Value<String>? bookKey,
    Value<String>? chapterKey,
    Value<String>? chapterTitle,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return LiteratureBookmarksCompanion(
      id: id ?? this.id,
      bookKey: bookKey ?? this.bookKey,
      chapterKey: chapterKey ?? this.chapterKey,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (chapterKey.present) {
      map['chapter_key'] = Variable<String>(chapterKey.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiteratureBookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterKey: $chapterKey, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SponsorCallLogsTable extends SponsorCallLogs
    with TableInfo<$SponsorCallLogsTable, SponsorCallLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SponsorCallLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calledViaAppMeta = const VerificationMeta(
    'calledViaApp',
  );
  @override
  late final GeneratedColumn<bool> calledViaApp = GeneratedColumn<bool>(
    'called_via_app',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("called_via_app" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduledFor,
    confirmedAt,
    calledViaApp,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sponsor_call_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SponsorCallLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confirmedAtMeta);
    }
    if (data.containsKey('called_via_app')) {
      context.handle(
        _calledViaAppMeta,
        calledViaApp.isAcceptableOrUnknown(
          data['called_via_app']!,
          _calledViaAppMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SponsorCallLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SponsorCallLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      ),
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      )!,
      calledViaApp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}called_via_app'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SponsorCallLogsTable createAlias(String alias) {
    return $SponsorCallLogsTable(attachedDatabase, alias);
  }
}

class SponsorCallLog extends DataClass implements Insertable<SponsorCallLog> {
  final int id;

  /// The datetime the reminder notification was scheduled to fire.
  /// null when the call was logged manually outside a reminder cycle.
  final DateTime? scheduledFor;

  /// When the user confirmed the call happened.
  final DateTime confirmedAt;

  /// True if the user tapped the in-app "Call Now" button; false = "Already
  /// called" self-report.
  final bool calledViaApp;
  final String? notes;
  const SponsorCallLog({
    required this.id,
    this.scheduledFor,
    required this.confirmedAt,
    required this.calledViaApp,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || scheduledFor != null) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    }
    map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    map['called_via_app'] = Variable<bool>(calledViaApp);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SponsorCallLogsCompanion toCompanion(bool nullToAbsent) {
    return SponsorCallLogsCompanion(
      id: Value(id),
      scheduledFor: scheduledFor == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledFor),
      confirmedAt: Value(confirmedAt),
      calledViaApp: Value(calledViaApp),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SponsorCallLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SponsorCallLog(
      id: serializer.fromJson<int>(json['id']),
      scheduledFor: serializer.fromJson<DateTime?>(json['scheduledFor']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
      calledViaApp: serializer.fromJson<bool>(json['calledViaApp']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduledFor': serializer.toJson<DateTime?>(scheduledFor),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
      'calledViaApp': serializer.toJson<bool>(calledViaApp),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SponsorCallLog copyWith({
    int? id,
    Value<DateTime?> scheduledFor = const Value.absent(),
    DateTime? confirmedAt,
    bool? calledViaApp,
    Value<String?> notes = const Value.absent(),
  }) => SponsorCallLog(
    id: id ?? this.id,
    scheduledFor: scheduledFor.present ? scheduledFor.value : this.scheduledFor,
    confirmedAt: confirmedAt ?? this.confirmedAt,
    calledViaApp: calledViaApp ?? this.calledViaApp,
    notes: notes.present ? notes.value : this.notes,
  );
  SponsorCallLog copyWithCompanion(SponsorCallLogsCompanion data) {
    return SponsorCallLog(
      id: data.id.present ? data.id.value : this.id,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      calledViaApp: data.calledViaApp.present
          ? data.calledViaApp.value
          : this.calledViaApp,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SponsorCallLog(')
          ..write('id: $id, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('calledViaApp: $calledViaApp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scheduledFor, confirmedAt, calledViaApp, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SponsorCallLog &&
          other.id == this.id &&
          other.scheduledFor == this.scheduledFor &&
          other.confirmedAt == this.confirmedAt &&
          other.calledViaApp == this.calledViaApp &&
          other.notes == this.notes);
}

class SponsorCallLogsCompanion extends UpdateCompanion<SponsorCallLog> {
  final Value<int> id;
  final Value<DateTime?> scheduledFor;
  final Value<DateTime> confirmedAt;
  final Value<bool> calledViaApp;
  final Value<String?> notes;
  const SponsorCallLogsCompanion({
    this.id = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.calledViaApp = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SponsorCallLogsCompanion.insert({
    this.id = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    required DateTime confirmedAt,
    this.calledViaApp = const Value.absent(),
    this.notes = const Value.absent(),
  }) : confirmedAt = Value(confirmedAt);
  static Insertable<SponsorCallLog> custom({
    Expression<int>? id,
    Expression<DateTime>? scheduledFor,
    Expression<DateTime>? confirmedAt,
    Expression<bool>? calledViaApp,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (calledViaApp != null) 'called_via_app': calledViaApp,
      if (notes != null) 'notes': notes,
    });
  }

  SponsorCallLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? scheduledFor,
    Value<DateTime>? confirmedAt,
    Value<bool>? calledViaApp,
    Value<String?>? notes,
  }) {
    return SponsorCallLogsCompanion(
      id: id ?? this.id,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      calledViaApp: calledViaApp ?? this.calledViaApp,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (calledViaApp.present) {
      map['called_via_app'] = Variable<bool>(calledViaApp.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SponsorCallLogsCompanion(')
          ..write('id: $id, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('calledViaApp: $calledViaApp, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RolodexContactsTable extends RolodexContacts
    with TableInfo<$RolodexContactsTable, RolodexContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolodexContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<int> meetingId = GeneratedColumn<int>(
    'meeting_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES meetings (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _isSponsorMeta = const VerificationMeta(
    'isSponsor',
  );
  @override
  late final GeneratedColumn<bool> isSponsor = GeneratedColumn<bool>(
    'is_sponsor',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sponsor" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sponseeIdMeta = const VerificationMeta(
    'sponseeId',
  );
  @override
  late final GeneratedColumn<int> sponseeId = GeneratedColumn<int>(
    'sponsee_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sponsees (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    address,
    notes,
    meetingId,
    isSponsor,
    sponseeId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rolodex_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RolodexContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    }
    if (data.containsKey('is_sponsor')) {
      context.handle(
        _isSponsorMeta,
        isSponsor.isAcceptableOrUnknown(data['is_sponsor']!, _isSponsorMeta),
      );
    }
    if (data.containsKey('sponsee_id')) {
      context.handle(
        _sponseeIdMeta,
        sponseeId.isAcceptableOrUnknown(data['sponsee_id']!, _sponseeIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RolodexContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RolodexContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meeting_id'],
      ),
      isSponsor: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sponsor'],
      )!,
      sponseeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sponsee_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RolodexContactsTable createAlias(String alias) {
    return $RolodexContactsTable(attachedDatabase, alias);
  }
}

class RolodexContact extends DataClass implements Insertable<RolodexContact> {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;

  /// Meeting where this person was met (nullable; SET NULL on meeting delete).
  final int? meetingId;

  /// True when this contact is the user's current sponsor.
  /// Only one row should be true at a time — enforced by [RolodexRepository].
  final bool isSponsor;

  /// Set when this contact has been converted to a Sponsee entry.
  /// SET NULL if the linked Sponsee row is deleted.
  final int? sponseeId;
  final DateTime createdAt;
  const RolodexContact({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.meetingId,
    required this.isSponsor,
    this.sponseeId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || meetingId != null) {
      map['meeting_id'] = Variable<int>(meetingId);
    }
    map['is_sponsor'] = Variable<bool>(isSponsor);
    if (!nullToAbsent || sponseeId != null) {
      map['sponsee_id'] = Variable<int>(sponseeId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RolodexContactsCompanion toCompanion(bool nullToAbsent) {
    return RolodexContactsCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      meetingId: meetingId == null && nullToAbsent
          ? const Value.absent()
          : Value(meetingId),
      isSponsor: Value(isSponsor),
      sponseeId: sponseeId == null && nullToAbsent
          ? const Value.absent()
          : Value(sponseeId),
      createdAt: Value(createdAt),
    );
  }

  factory RolodexContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RolodexContact(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      meetingId: serializer.fromJson<int?>(json['meetingId']),
      isSponsor: serializer.fromJson<bool>(json['isSponsor']),
      sponseeId: serializer.fromJson<int?>(json['sponseeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'meetingId': serializer.toJson<int?>(meetingId),
      'isSponsor': serializer.toJson<bool>(isSponsor),
      'sponseeId': serializer.toJson<int?>(sponseeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RolodexContact copyWith({
    int? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> meetingId = const Value.absent(),
    bool? isSponsor,
    Value<int?> sponseeId = const Value.absent(),
    DateTime? createdAt,
  }) => RolodexContact(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    meetingId: meetingId.present ? meetingId.value : this.meetingId,
    isSponsor: isSponsor ?? this.isSponsor,
    sponseeId: sponseeId.present ? sponseeId.value : this.sponseeId,
    createdAt: createdAt ?? this.createdAt,
  );
  RolodexContact copyWithCompanion(RolodexContactsCompanion data) {
    return RolodexContact(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      isSponsor: data.isSponsor.present ? data.isSponsor.value : this.isSponsor,
      sponseeId: data.sponseeId.present ? data.sponseeId.value : this.sponseeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RolodexContact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('meetingId: $meetingId, ')
          ..write('isSponsor: $isSponsor, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    email,
    address,
    notes,
    meetingId,
    isSponsor,
    sponseeId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RolodexContact &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.meetingId == this.meetingId &&
          other.isSponsor == this.isSponsor &&
          other.sponseeId == this.sponseeId &&
          other.createdAt == this.createdAt);
}

class RolodexContactsCompanion extends UpdateCompanion<RolodexContact> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<int?> meetingId;
  final Value<bool> isSponsor;
  final Value<int?> sponseeId;
  final Value<DateTime> createdAt;
  const RolodexContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.isSponsor = const Value.absent(),
    this.sponseeId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RolodexContactsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.meetingId = const Value.absent(),
    this.isSponsor = const Value.absent(),
    this.sponseeId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<RolodexContact> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<int>? meetingId,
    Expression<bool>? isSponsor,
    Expression<int>? sponseeId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (meetingId != null) 'meeting_id': meetingId,
      if (isSponsor != null) 'is_sponsor': isSponsor,
      if (sponseeId != null) 'sponsee_id': sponseeId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RolodexContactsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? notes,
    Value<int?>? meetingId,
    Value<bool>? isSponsor,
    Value<int?>? sponseeId,
    Value<DateTime>? createdAt,
  }) {
    return RolodexContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      meetingId: meetingId ?? this.meetingId,
      isSponsor: isSponsor ?? this.isSponsor,
      sponseeId: sponseeId ?? this.sponseeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (meetingId.present) {
      map['meeting_id'] = Variable<int>(meetingId.value);
    }
    if (isSponsor.present) {
      map['is_sponsor'] = Variable<bool>(isSponsor.value);
    }
    if (sponseeId.present) {
      map['sponsee_id'] = Variable<int>(sponseeId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolodexContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('meetingId: $meetingId, ')
          ..write('isSponsor: $isSponsor, ')
          ..write('sponseeId: $sponseeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ResentmentsTable resentments = $ResentmentsTable(this);
  late final $FearsTable fears = $FearsTable(this);
  late final $HarmsTable harms = $HarmsTable(this);
  late final $DailyReviewsTable dailyReviews = $DailyReviewsTable(this);
  late final $AmendsTable amends = $AmendsTable(this);
  late final $DefectsTable defects = $DefectsTable(this);
  late final $ShortcomingLogsTable shortcomingLogs = $ShortcomingLogsTable(
    this,
  );
  late final $Step5CompletionsTable step5Completions = $Step5CompletionsTable(
    this,
  );
  late final $MeditationSessionsTable meditationSessions =
      $MeditationSessionsTable(this);
  late final $StepTwelveEventsTable stepTwelveEvents = $StepTwelveEventsTable(
    this,
  );
  late final $MeetingsTable meetings = $MeetingsTable(this);
  late final $AttendanceLogsTable attendanceLogs = $AttendanceLogsTable(this);
  late final $SyncMetasTable syncMetas = $SyncMetasTable(this);
  late final $ServiceCommitmentsTable serviceCommitments =
      $ServiceCommitmentsTable(this);
  late final $SponseesTable sponsees = $SponseesTable(this);
  late final $TwelfthStepCallsTable twelfthStepCalls = $TwelfthStepCallsTable(
    this,
  );
  late final $SponseeStepProgressTable sponseeStepProgress =
      $SponseeStepProgressTable(this);
  late final $SponseeCheckInsTable sponseeCheckIns = $SponseeCheckInsTable(
    this,
  );
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $LiteratureBookmarksTable literatureBookmarks =
      $LiteratureBookmarksTable(this);
  late final $SponsorCallLogsTable sponsorCallLogs = $SponsorCallLogsTable(
    this,
  );
  late final $RolodexContactsTable rolodexContacts = $RolodexContactsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    resentments,
    fears,
    harms,
    dailyReviews,
    amends,
    defects,
    shortcomingLogs,
    step5Completions,
    meditationSessions,
    stepTwelveEvents,
    meetings,
    attendanceLogs,
    syncMetas,
    serviceCommitments,
    sponsees,
    twelfthStepCalls,
    sponseeStepProgress,
    sponseeCheckIns,
    journalEntries,
    literatureBookmarks,
    sponsorCallLogs,
    rolodexContacts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'harms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('amends', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'defects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shortcoming_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'meetings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attendance_logs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sponsees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('twelfth_step_calls', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sponsees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sponsee_step_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sponsees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sponsee_check_ins', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'meetings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rolodex_contacts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sponsees',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rolodex_contacts', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ResentmentsTableCreateCompanionBuilder =
    ResentmentsCompanion Function({
      Value<int> id,
      required String person,
      required String cause,
      required String affects,
      required String myPart,
      Value<String?> sponsorNote,
      Value<bool> flagForReview,
      required DateTime createdAt,
    });
typedef $$ResentmentsTableUpdateCompanionBuilder =
    ResentmentsCompanion Function({
      Value<int> id,
      Value<String> person,
      Value<String> cause,
      Value<String> affects,
      Value<String> myPart,
      Value<String?> sponsorNote,
      Value<bool> flagForReview,
      Value<DateTime> createdAt,
    });

class $$ResentmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ResentmentsTable> {
  $$ResentmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cause => $composableBuilder(
    column: $table.cause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get affects => $composableBuilder(
    column: $table.affects,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myPart => $composableBuilder(
    column: $table.myPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResentmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResentmentsTable> {
  $$ResentmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cause => $composableBuilder(
    column: $table.cause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get affects => $composableBuilder(
    column: $table.affects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myPart => $composableBuilder(
    column: $table.myPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResentmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResentmentsTable> {
  $$ResentmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<String> get cause =>
      $composableBuilder(column: $table.cause, builder: (column) => column);

  GeneratedColumn<String> get affects =>
      $composableBuilder(column: $table.affects, builder: (column) => column);

  GeneratedColumn<String> get myPart =>
      $composableBuilder(column: $table.myPart, builder: (column) => column);

  GeneratedColumn<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ResentmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResentmentsTable,
          Resentment,
          $$ResentmentsTableFilterComposer,
          $$ResentmentsTableOrderingComposer,
          $$ResentmentsTableAnnotationComposer,
          $$ResentmentsTableCreateCompanionBuilder,
          $$ResentmentsTableUpdateCompanionBuilder,
          (
            Resentment,
            BaseReferences<_$AppDatabase, $ResentmentsTable, Resentment>,
          ),
          Resentment,
          PrefetchHooks Function()
        > {
  $$ResentmentsTableTableManager(_$AppDatabase db, $ResentmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResentmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResentmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResentmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> person = const Value.absent(),
                Value<String> cause = const Value.absent(),
                Value<String> affects = const Value.absent(),
                Value<String> myPart = const Value.absent(),
                Value<String?> sponsorNote = const Value.absent(),
                Value<bool> flagForReview = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ResentmentsCompanion(
                id: id,
                person: person,
                cause: cause,
                affects: affects,
                myPart: myPart,
                sponsorNote: sponsorNote,
                flagForReview: flagForReview,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String person,
                required String cause,
                required String affects,
                required String myPart,
                Value<String?> sponsorNote = const Value.absent(),
                Value<bool> flagForReview = const Value.absent(),
                required DateTime createdAt,
              }) => ResentmentsCompanion.insert(
                id: id,
                person: person,
                cause: cause,
                affects: affects,
                myPart: myPart,
                sponsorNote: sponsorNote,
                flagForReview: flagForReview,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResentmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResentmentsTable,
      Resentment,
      $$ResentmentsTableFilterComposer,
      $$ResentmentsTableOrderingComposer,
      $$ResentmentsTableAnnotationComposer,
      $$ResentmentsTableCreateCompanionBuilder,
      $$ResentmentsTableUpdateCompanionBuilder,
      (
        Resentment,
        BaseReferences<_$AppDatabase, $ResentmentsTable, Resentment>,
      ),
      Resentment,
      PrefetchHooks Function()
    >;
typedef $$FearsTableCreateCompanionBuilder =
    FearsCompanion Function({
      Value<int> id,
      required String subject,
      required String why,
      required String myPart,
      Value<String?> sponsorNote,
      Value<bool> flagForReview,
      required DateTime createdAt,
    });
typedef $$FearsTableUpdateCompanionBuilder =
    FearsCompanion Function({
      Value<int> id,
      Value<String> subject,
      Value<String> why,
      Value<String> myPart,
      Value<String?> sponsorNote,
      Value<bool> flagForReview,
      Value<DateTime> createdAt,
    });

class $$FearsTableFilterComposer extends Composer<_$AppDatabase, $FearsTable> {
  $$FearsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get why => $composableBuilder(
    column: $table.why,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myPart => $composableBuilder(
    column: $table.myPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FearsTableOrderingComposer
    extends Composer<_$AppDatabase, $FearsTable> {
  $$FearsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get why => $composableBuilder(
    column: $table.why,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myPart => $composableBuilder(
    column: $table.myPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FearsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FearsTable> {
  $$FearsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get why =>
      $composableBuilder(column: $table.why, builder: (column) => column);

  GeneratedColumn<String> get myPart =>
      $composableBuilder(column: $table.myPart, builder: (column) => column);

  GeneratedColumn<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FearsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FearsTable,
          Fear,
          $$FearsTableFilterComposer,
          $$FearsTableOrderingComposer,
          $$FearsTableAnnotationComposer,
          $$FearsTableCreateCompanionBuilder,
          $$FearsTableUpdateCompanionBuilder,
          (Fear, BaseReferences<_$AppDatabase, $FearsTable, Fear>),
          Fear,
          PrefetchHooks Function()
        > {
  $$FearsTableTableManager(_$AppDatabase db, $FearsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FearsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FearsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FearsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> why = const Value.absent(),
                Value<String> myPart = const Value.absent(),
                Value<String?> sponsorNote = const Value.absent(),
                Value<bool> flagForReview = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FearsCompanion(
                id: id,
                subject: subject,
                why: why,
                myPart: myPart,
                sponsorNote: sponsorNote,
                flagForReview: flagForReview,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String subject,
                required String why,
                required String myPart,
                Value<String?> sponsorNote = const Value.absent(),
                Value<bool> flagForReview = const Value.absent(),
                required DateTime createdAt,
              }) => FearsCompanion.insert(
                id: id,
                subject: subject,
                why: why,
                myPart: myPart,
                sponsorNote: sponsorNote,
                flagForReview: flagForReview,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FearsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FearsTable,
      Fear,
      $$FearsTableFilterComposer,
      $$FearsTableOrderingComposer,
      $$FearsTableAnnotationComposer,
      $$FearsTableCreateCompanionBuilder,
      $$FearsTableUpdateCompanionBuilder,
      (Fear, BaseReferences<_$AppDatabase, $FearsTable, Fear>),
      Fear,
      PrefetchHooks Function()
    >;
typedef $$HarmsTableCreateCompanionBuilder =
    HarmsCompanion Function({
      Value<int> id,
      required String person,
      required String conduct,
      required String myPart,
      Value<String?> amendsPlan,
      Value<bool> isAmendsDone,
      Value<DateTime?> dateAmendsDone,
      Value<String?> sponsorNote,
      Value<bool> flagForReview,
      required DateTime createdAt,
    });
typedef $$HarmsTableUpdateCompanionBuilder =
    HarmsCompanion Function({
      Value<int> id,
      Value<String> person,
      Value<String> conduct,
      Value<String> myPart,
      Value<String?> amendsPlan,
      Value<bool> isAmendsDone,
      Value<DateTime?> dateAmendsDone,
      Value<String?> sponsorNote,
      Value<bool> flagForReview,
      Value<DateTime> createdAt,
    });

final class $$HarmsTableReferences
    extends BaseReferences<_$AppDatabase, $HarmsTable, Harm> {
  $$HarmsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AmendsTable, List<Amend>> _amendsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.amends,
    aliasName: $_aliasNameGenerator(db.harms.id, db.amends.harmId),
  );

  $$AmendsTableProcessedTableManager get amendsRefs {
    final manager = $$AmendsTableTableManager(
      $_db,
      $_db.amends,
    ).filter((f) => f.harmId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_amendsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HarmsTableFilterComposer extends Composer<_$AppDatabase, $HarmsTable> {
  $$HarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conduct => $composableBuilder(
    column: $table.conduct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myPart => $composableBuilder(
    column: $table.myPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amendsPlan => $composableBuilder(
    column: $table.amendsPlan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAmendsDone => $composableBuilder(
    column: $table.isAmendsDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAmendsDone => $composableBuilder(
    column: $table.dateAmendsDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> amendsRefs(
    Expression<bool> Function($$AmendsTableFilterComposer f) f,
  ) {
    final $$AmendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.amends,
      getReferencedColumn: (t) => t.harmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AmendsTableFilterComposer(
            $db: $db,
            $table: $db.amends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $HarmsTable> {
  $$HarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conduct => $composableBuilder(
    column: $table.conduct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myPart => $composableBuilder(
    column: $table.myPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amendsPlan => $composableBuilder(
    column: $table.amendsPlan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAmendsDone => $composableBuilder(
    column: $table.isAmendsDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAmendsDone => $composableBuilder(
    column: $table.dateAmendsDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HarmsTable> {
  $$HarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<String> get conduct =>
      $composableBuilder(column: $table.conduct, builder: (column) => column);

  GeneratedColumn<String> get myPart =>
      $composableBuilder(column: $table.myPart, builder: (column) => column);

  GeneratedColumn<String> get amendsPlan => $composableBuilder(
    column: $table.amendsPlan,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAmendsDone => $composableBuilder(
    column: $table.isAmendsDone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAmendsDone => $composableBuilder(
    column: $table.dateAmendsDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sponsorNote => $composableBuilder(
    column: $table.sponsorNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get flagForReview => $composableBuilder(
    column: $table.flagForReview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> amendsRefs<T extends Object>(
    Expression<T> Function($$AmendsTableAnnotationComposer a) f,
  ) {
    final $$AmendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.amends,
      getReferencedColumn: (t) => t.harmId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AmendsTableAnnotationComposer(
            $db: $db,
            $table: $db.amends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HarmsTable,
          Harm,
          $$HarmsTableFilterComposer,
          $$HarmsTableOrderingComposer,
          $$HarmsTableAnnotationComposer,
          $$HarmsTableCreateCompanionBuilder,
          $$HarmsTableUpdateCompanionBuilder,
          (Harm, $$HarmsTableReferences),
          Harm,
          PrefetchHooks Function({bool amendsRefs})
        > {
  $$HarmsTableTableManager(_$AppDatabase db, $HarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> person = const Value.absent(),
                Value<String> conduct = const Value.absent(),
                Value<String> myPart = const Value.absent(),
                Value<String?> amendsPlan = const Value.absent(),
                Value<bool> isAmendsDone = const Value.absent(),
                Value<DateTime?> dateAmendsDone = const Value.absent(),
                Value<String?> sponsorNote = const Value.absent(),
                Value<bool> flagForReview = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HarmsCompanion(
                id: id,
                person: person,
                conduct: conduct,
                myPart: myPart,
                amendsPlan: amendsPlan,
                isAmendsDone: isAmendsDone,
                dateAmendsDone: dateAmendsDone,
                sponsorNote: sponsorNote,
                flagForReview: flagForReview,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String person,
                required String conduct,
                required String myPart,
                Value<String?> amendsPlan = const Value.absent(),
                Value<bool> isAmendsDone = const Value.absent(),
                Value<DateTime?> dateAmendsDone = const Value.absent(),
                Value<String?> sponsorNote = const Value.absent(),
                Value<bool> flagForReview = const Value.absent(),
                required DateTime createdAt,
              }) => HarmsCompanion.insert(
                id: id,
                person: person,
                conduct: conduct,
                myPart: myPart,
                amendsPlan: amendsPlan,
                isAmendsDone: isAmendsDone,
                dateAmendsDone: dateAmendsDone,
                sponsorNote: sponsorNote,
                flagForReview: flagForReview,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HarmsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({amendsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (amendsRefs) db.amends],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (amendsRefs)
                    await $_getPrefetchedData<Harm, $HarmsTable, Amend>(
                      currentTable: table,
                      referencedTable: $$HarmsTableReferences._amendsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$HarmsTableReferences(db, table, p0).amendsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.harmId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HarmsTable,
      Harm,
      $$HarmsTableFilterComposer,
      $$HarmsTableOrderingComposer,
      $$HarmsTableAnnotationComposer,
      $$HarmsTableCreateCompanionBuilder,
      $$HarmsTableUpdateCompanionBuilder,
      (Harm, $$HarmsTableReferences),
      Harm,
      PrefetchHooks Function({bool amendsRefs})
    >;
typedef $$DailyReviewsTableCreateCompanionBuilder =
    DailyReviewsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<bool> wasResentful,
      Value<bool> wasSelfish,
      Value<bool> wasDishonest,
      Value<bool> wasAfraid,
      Value<String?> notes,
      Value<String?> gratitude,
      Value<String> reviewType,
      required DateTime createdAt,
    });
typedef $$DailyReviewsTableUpdateCompanionBuilder =
    DailyReviewsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<bool> wasResentful,
      Value<bool> wasSelfish,
      Value<bool> wasDishonest,
      Value<bool> wasAfraid,
      Value<String?> notes,
      Value<String?> gratitude,
      Value<String> reviewType,
      Value<DateTime> createdAt,
    });

final class $$DailyReviewsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyReviewsTable, DailyReview> {
  $$DailyReviewsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShortcomingLogsTable, List<ShortcomingLog>>
  _shortcomingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shortcomingLogs,
    aliasName: $_aliasNameGenerator(
      db.dailyReviews.id,
      db.shortcomingLogs.relatedReviewId,
    ),
  );

  $$ShortcomingLogsTableProcessedTableManager get shortcomingLogsRefs {
    final manager = $$ShortcomingLogsTableTableManager(
      $_db,
      $_db.shortcomingLogs,
    ).filter((f) => f.relatedReviewId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _shortcomingLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DailyReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyReviewsTable> {
  $$DailyReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasResentful => $composableBuilder(
    column: $table.wasResentful,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasSelfish => $composableBuilder(
    column: $table.wasSelfish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasDishonest => $composableBuilder(
    column: $table.wasDishonest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasAfraid => $composableBuilder(
    column: $table.wasAfraid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gratitude => $composableBuilder(
    column: $table.gratitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewType => $composableBuilder(
    column: $table.reviewType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shortcomingLogsRefs(
    Expression<bool> Function($$ShortcomingLogsTableFilterComposer f) f,
  ) {
    final $$ShortcomingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortcomingLogs,
      getReferencedColumn: (t) => t.relatedReviewId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortcomingLogsTableFilterComposer(
            $db: $db,
            $table: $db.shortcomingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyReviewsTable> {
  $$DailyReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasResentful => $composableBuilder(
    column: $table.wasResentful,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasSelfish => $composableBuilder(
    column: $table.wasSelfish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasDishonest => $composableBuilder(
    column: $table.wasDishonest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasAfraid => $composableBuilder(
    column: $table.wasAfraid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gratitude => $composableBuilder(
    column: $table.gratitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewType => $composableBuilder(
    column: $table.reviewType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyReviewsTable> {
  $$DailyReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get wasResentful => $composableBuilder(
    column: $table.wasResentful,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasSelfish => $composableBuilder(
    column: $table.wasSelfish,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasDishonest => $composableBuilder(
    column: $table.wasDishonest,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasAfraid =>
      $composableBuilder(column: $table.wasAfraid, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get gratitude =>
      $composableBuilder(column: $table.gratitude, builder: (column) => column);

  GeneratedColumn<String> get reviewType => $composableBuilder(
    column: $table.reviewType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> shortcomingLogsRefs<T extends Object>(
    Expression<T> Function($$ShortcomingLogsTableAnnotationComposer a) f,
  ) {
    final $$ShortcomingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortcomingLogs,
      getReferencedColumn: (t) => t.relatedReviewId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortcomingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.shortcomingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DailyReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyReviewsTable,
          DailyReview,
          $$DailyReviewsTableFilterComposer,
          $$DailyReviewsTableOrderingComposer,
          $$DailyReviewsTableAnnotationComposer,
          $$DailyReviewsTableCreateCompanionBuilder,
          $$DailyReviewsTableUpdateCompanionBuilder,
          (DailyReview, $$DailyReviewsTableReferences),
          DailyReview,
          PrefetchHooks Function({bool shortcomingLogsRefs})
        > {
  $$DailyReviewsTableTableManager(_$AppDatabase db, $DailyReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> wasResentful = const Value.absent(),
                Value<bool> wasSelfish = const Value.absent(),
                Value<bool> wasDishonest = const Value.absent(),
                Value<bool> wasAfraid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> gratitude = const Value.absent(),
                Value<String> reviewType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailyReviewsCompanion(
                id: id,
                date: date,
                wasResentful: wasResentful,
                wasSelfish: wasSelfish,
                wasDishonest: wasDishonest,
                wasAfraid: wasAfraid,
                notes: notes,
                gratitude: gratitude,
                reviewType: reviewType,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<bool> wasResentful = const Value.absent(),
                Value<bool> wasSelfish = const Value.absent(),
                Value<bool> wasDishonest = const Value.absent(),
                Value<bool> wasAfraid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> gratitude = const Value.absent(),
                Value<String> reviewType = const Value.absent(),
                required DateTime createdAt,
              }) => DailyReviewsCompanion.insert(
                id: id,
                date: date,
                wasResentful: wasResentful,
                wasSelfish: wasSelfish,
                wasDishonest: wasDishonest,
                wasAfraid: wasAfraid,
                notes: notes,
                gratitude: gratitude,
                reviewType: reviewType,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyReviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shortcomingLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shortcomingLogsRefs) db.shortcomingLogs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shortcomingLogsRefs)
                    await $_getPrefetchedData<
                      DailyReview,
                      $DailyReviewsTable,
                      ShortcomingLog
                    >(
                      currentTable: table,
                      referencedTable: $$DailyReviewsTableReferences
                          ._shortcomingLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DailyReviewsTableReferences(
                            db,
                            table,
                            p0,
                          ).shortcomingLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.relatedReviewId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DailyReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyReviewsTable,
      DailyReview,
      $$DailyReviewsTableFilterComposer,
      $$DailyReviewsTableOrderingComposer,
      $$DailyReviewsTableAnnotationComposer,
      $$DailyReviewsTableCreateCompanionBuilder,
      $$DailyReviewsTableUpdateCompanionBuilder,
      (DailyReview, $$DailyReviewsTableReferences),
      DailyReview,
      PrefetchHooks Function({bool shortcomingLogsRefs})
    >;
typedef $$AmendsTableCreateCompanionBuilder =
    AmendsCompanion Function({
      Value<int> id,
      Value<int?> harmId,
      required String person,
      Value<AmendsType?> amendsType,
      Value<String?> plan,
      Value<int> priority,
      Value<String> status,
      Value<String?> timeframe,
      Value<DateTime?> datePlanned,
      Value<DateTime?> dateCompleted,
      Value<DateTime> createdAt,
    });
typedef $$AmendsTableUpdateCompanionBuilder =
    AmendsCompanion Function({
      Value<int> id,
      Value<int?> harmId,
      Value<String> person,
      Value<AmendsType?> amendsType,
      Value<String?> plan,
      Value<int> priority,
      Value<String> status,
      Value<String?> timeframe,
      Value<DateTime?> datePlanned,
      Value<DateTime?> dateCompleted,
      Value<DateTime> createdAt,
    });

final class $$AmendsTableReferences
    extends BaseReferences<_$AppDatabase, $AmendsTable, Amend> {
  $$AmendsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HarmsTable _harmIdTable(_$AppDatabase db) =>
      db.harms.createAlias($_aliasNameGenerator(db.amends.harmId, db.harms.id));

  $$HarmsTableProcessedTableManager? get harmId {
    final $_column = $_itemColumn<int>('harm_id');
    if ($_column == null) return null;
    final manager = $$HarmsTableTableManager(
      $_db,
      $_db.harms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_harmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AmendsTableFilterComposer
    extends Composer<_$AppDatabase, $AmendsTable> {
  $$AmendsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AmendsType?, AmendsType, int> get amendsType =>
      $composableBuilder(
        column: $table.amendsType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeframe => $composableBuilder(
    column: $table.timeframe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get datePlanned => $composableBuilder(
    column: $table.datePlanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HarmsTableFilterComposer get harmId {
    final $$HarmsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.harmId,
      referencedTable: $db.harms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarmsTableFilterComposer(
            $db: $db,
            $table: $db.harms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AmendsTableOrderingComposer
    extends Composer<_$AppDatabase, $AmendsTable> {
  $$AmendsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amendsType => $composableBuilder(
    column: $table.amendsType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeframe => $composableBuilder(
    column: $table.timeframe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get datePlanned => $composableBuilder(
    column: $table.datePlanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HarmsTableOrderingComposer get harmId {
    final $$HarmsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.harmId,
      referencedTable: $db.harms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarmsTableOrderingComposer(
            $db: $db,
            $table: $db.harms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AmendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AmendsTable> {
  $$AmendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AmendsType?, int> get amendsType =>
      $composableBuilder(
        column: $table.amendsType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get timeframe =>
      $composableBuilder(column: $table.timeframe, builder: (column) => column);

  GeneratedColumn<DateTime> get datePlanned => $composableBuilder(
    column: $table.datePlanned,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCompleted => $composableBuilder(
    column: $table.dateCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$HarmsTableAnnotationComposer get harmId {
    final $$HarmsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.harmId,
      referencedTable: $db.harms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HarmsTableAnnotationComposer(
            $db: $db,
            $table: $db.harms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AmendsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AmendsTable,
          Amend,
          $$AmendsTableFilterComposer,
          $$AmendsTableOrderingComposer,
          $$AmendsTableAnnotationComposer,
          $$AmendsTableCreateCompanionBuilder,
          $$AmendsTableUpdateCompanionBuilder,
          (Amend, $$AmendsTableReferences),
          Amend,
          PrefetchHooks Function({bool harmId})
        > {
  $$AmendsTableTableManager(_$AppDatabase db, $AmendsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AmendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AmendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AmendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> harmId = const Value.absent(),
                Value<String> person = const Value.absent(),
                Value<AmendsType?> amendsType = const Value.absent(),
                Value<String?> plan = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> timeframe = const Value.absent(),
                Value<DateTime?> datePlanned = const Value.absent(),
                Value<DateTime?> dateCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AmendsCompanion(
                id: id,
                harmId: harmId,
                person: person,
                amendsType: amendsType,
                plan: plan,
                priority: priority,
                status: status,
                timeframe: timeframe,
                datePlanned: datePlanned,
                dateCompleted: dateCompleted,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> harmId = const Value.absent(),
                required String person,
                Value<AmendsType?> amendsType = const Value.absent(),
                Value<String?> plan = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> timeframe = const Value.absent(),
                Value<DateTime?> datePlanned = const Value.absent(),
                Value<DateTime?> dateCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AmendsCompanion.insert(
                id: id,
                harmId: harmId,
                person: person,
                amendsType: amendsType,
                plan: plan,
                priority: priority,
                status: status,
                timeframe: timeframe,
                datePlanned: datePlanned,
                dateCompleted: dateCompleted,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AmendsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({harmId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (harmId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.harmId,
                                referencedTable: $$AmendsTableReferences
                                    ._harmIdTable(db),
                                referencedColumn: $$AmendsTableReferences
                                    ._harmIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AmendsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AmendsTable,
      Amend,
      $$AmendsTableFilterComposer,
      $$AmendsTableOrderingComposer,
      $$AmendsTableAnnotationComposer,
      $$AmendsTableCreateCompanionBuilder,
      $$AmendsTableUpdateCompanionBuilder,
      (Amend, $$AmendsTableReferences),
      Amend,
      PrefetchHooks Function({bool harmId})
    >;
typedef $$DefectsTableCreateCompanionBuilder =
    DefectsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> category,
      Value<bool> isReady,
      required DateTime createdAt,
    });
typedef $$DefectsTableUpdateCompanionBuilder =
    DefectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> category,
      Value<bool> isReady,
      Value<DateTime> createdAt,
    });

final class $$DefectsTableReferences
    extends BaseReferences<_$AppDatabase, $DefectsTable, Defect> {
  $$DefectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShortcomingLogsTable, List<ShortcomingLog>>
  _shortcomingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shortcomingLogs,
    aliasName: $_aliasNameGenerator(db.defects.id, db.shortcomingLogs.defectId),
  );

  $$ShortcomingLogsTableProcessedTableManager get shortcomingLogsRefs {
    final manager = $$ShortcomingLogsTableTableManager(
      $_db,
      $_db.shortcomingLogs,
    ).filter((f) => f.defectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _shortcomingLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DefectsTableFilterComposer
    extends Composer<_$AppDatabase, $DefectsTable> {
  $$DefectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReady => $composableBuilder(
    column: $table.isReady,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shortcomingLogsRefs(
    Expression<bool> Function($$ShortcomingLogsTableFilterComposer f) f,
  ) {
    final $$ShortcomingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortcomingLogs,
      getReferencedColumn: (t) => t.defectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortcomingLogsTableFilterComposer(
            $db: $db,
            $table: $db.shortcomingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DefectsTableOrderingComposer
    extends Composer<_$AppDatabase, $DefectsTable> {
  $$DefectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReady => $composableBuilder(
    column: $table.isReady,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DefectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DefectsTable> {
  $$DefectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isReady =>
      $composableBuilder(column: $table.isReady, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> shortcomingLogsRefs<T extends Object>(
    Expression<T> Function($$ShortcomingLogsTableAnnotationComposer a) f,
  ) {
    final $$ShortcomingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortcomingLogs,
      getReferencedColumn: (t) => t.defectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortcomingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.shortcomingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DefectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DefectsTable,
          Defect,
          $$DefectsTableFilterComposer,
          $$DefectsTableOrderingComposer,
          $$DefectsTableAnnotationComposer,
          $$DefectsTableCreateCompanionBuilder,
          $$DefectsTableUpdateCompanionBuilder,
          (Defect, $$DefectsTableReferences),
          Defect,
          PrefetchHooks Function({bool shortcomingLogsRefs})
        > {
  $$DefectsTableTableManager(_$AppDatabase db, $DefectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DefectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DefectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DefectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isReady = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DefectsCompanion(
                id: id,
                name: name,
                category: category,
                isReady: isReady,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> category = const Value.absent(),
                Value<bool> isReady = const Value.absent(),
                required DateTime createdAt,
              }) => DefectsCompanion.insert(
                id: id,
                name: name,
                category: category,
                isReady: isReady,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DefectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shortcomingLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shortcomingLogsRefs) db.shortcomingLogs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shortcomingLogsRefs)
                    await $_getPrefetchedData<
                      Defect,
                      $DefectsTable,
                      ShortcomingLog
                    >(
                      currentTable: table,
                      referencedTable: $$DefectsTableReferences
                          ._shortcomingLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$DefectsTableReferences(
                        db,
                        table,
                        p0,
                      ).shortcomingLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.defectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DefectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DefectsTable,
      Defect,
      $$DefectsTableFilterComposer,
      $$DefectsTableOrderingComposer,
      $$DefectsTableAnnotationComposer,
      $$DefectsTableCreateCompanionBuilder,
      $$DefectsTableUpdateCompanionBuilder,
      (Defect, $$DefectsTableReferences),
      Defect,
      PrefetchHooks Function({bool shortcomingLogsRefs})
    >;
typedef $$ShortcomingLogsTableCreateCompanionBuilder =
    ShortcomingLogsCompanion Function({
      Value<int> id,
      required String description,
      required DateTime dateObserved,
      Value<int?> relatedReviewId,
      Value<int?> defectId,
    });
typedef $$ShortcomingLogsTableUpdateCompanionBuilder =
    ShortcomingLogsCompanion Function({
      Value<int> id,
      Value<String> description,
      Value<DateTime> dateObserved,
      Value<int?> relatedReviewId,
      Value<int?> defectId,
    });

final class $$ShortcomingLogsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShortcomingLogsTable, ShortcomingLog> {
  $$ShortcomingLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DailyReviewsTable _relatedReviewIdTable(_$AppDatabase db) =>
      db.dailyReviews.createAlias(
        $_aliasNameGenerator(
          db.shortcomingLogs.relatedReviewId,
          db.dailyReviews.id,
        ),
      );

  $$DailyReviewsTableProcessedTableManager? get relatedReviewId {
    final $_column = $_itemColumn<int>('related_review_id');
    if ($_column == null) return null;
    final manager = $$DailyReviewsTableTableManager(
      $_db,
      $_db.dailyReviews,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_relatedReviewIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DefectsTable _defectIdTable(_$AppDatabase db) =>
      db.defects.createAlias(
        $_aliasNameGenerator(db.shortcomingLogs.defectId, db.defects.id),
      );

  $$DefectsTableProcessedTableManager? get defectId {
    final $_column = $_itemColumn<int>('defect_id');
    if ($_column == null) return null;
    final manager = $$DefectsTableTableManager(
      $_db,
      $_db.defects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShortcomingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ShortcomingLogsTable> {
  $$ShortcomingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateObserved => $composableBuilder(
    column: $table.dateObserved,
    builder: (column) => ColumnFilters(column),
  );

  $$DailyReviewsTableFilterComposer get relatedReviewId {
    final $$DailyReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedReviewId,
      referencedTable: $db.dailyReviews,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyReviewsTableFilterComposer(
            $db: $db,
            $table: $db.dailyReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DefectsTableFilterComposer get defectId {
    final $$DefectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defectId,
      referencedTable: $db.defects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefectsTableFilterComposer(
            $db: $db,
            $table: $db.defects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortcomingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShortcomingLogsTable> {
  $$ShortcomingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateObserved => $composableBuilder(
    column: $table.dateObserved,
    builder: (column) => ColumnOrderings(column),
  );

  $$DailyReviewsTableOrderingComposer get relatedReviewId {
    final $$DailyReviewsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedReviewId,
      referencedTable: $db.dailyReviews,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyReviewsTableOrderingComposer(
            $db: $db,
            $table: $db.dailyReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DefectsTableOrderingComposer get defectId {
    final $$DefectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defectId,
      referencedTable: $db.defects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefectsTableOrderingComposer(
            $db: $db,
            $table: $db.defects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortcomingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShortcomingLogsTable> {
  $$ShortcomingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateObserved => $composableBuilder(
    column: $table.dateObserved,
    builder: (column) => column,
  );

  $$DailyReviewsTableAnnotationComposer get relatedReviewId {
    final $$DailyReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.relatedReviewId,
      referencedTable: $db.dailyReviews,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DefectsTableAnnotationComposer get defectId {
    final $$DefectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defectId,
      referencedTable: $db.defects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefectsTableAnnotationComposer(
            $db: $db,
            $table: $db.defects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortcomingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShortcomingLogsTable,
          ShortcomingLog,
          $$ShortcomingLogsTableFilterComposer,
          $$ShortcomingLogsTableOrderingComposer,
          $$ShortcomingLogsTableAnnotationComposer,
          $$ShortcomingLogsTableCreateCompanionBuilder,
          $$ShortcomingLogsTableUpdateCompanionBuilder,
          (ShortcomingLog, $$ShortcomingLogsTableReferences),
          ShortcomingLog,
          PrefetchHooks Function({bool relatedReviewId, bool defectId})
        > {
  $$ShortcomingLogsTableTableManager(
    _$AppDatabase db,
    $ShortcomingLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShortcomingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShortcomingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShortcomingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> dateObserved = const Value.absent(),
                Value<int?> relatedReviewId = const Value.absent(),
                Value<int?> defectId = const Value.absent(),
              }) => ShortcomingLogsCompanion(
                id: id,
                description: description,
                dateObserved: dateObserved,
                relatedReviewId: relatedReviewId,
                defectId: defectId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String description,
                required DateTime dateObserved,
                Value<int?> relatedReviewId = const Value.absent(),
                Value<int?> defectId = const Value.absent(),
              }) => ShortcomingLogsCompanion.insert(
                id: id,
                description: description,
                dateObserved: dateObserved,
                relatedReviewId: relatedReviewId,
                defectId: defectId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShortcomingLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({relatedReviewId = false, defectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (relatedReviewId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.relatedReviewId,
                                referencedTable:
                                    $$ShortcomingLogsTableReferences
                                        ._relatedReviewIdTable(db),
                                referencedColumn:
                                    $$ShortcomingLogsTableReferences
                                        ._relatedReviewIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (defectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.defectId,
                                referencedTable:
                                    $$ShortcomingLogsTableReferences
                                        ._defectIdTable(db),
                                referencedColumn:
                                    $$ShortcomingLogsTableReferences
                                        ._defectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShortcomingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShortcomingLogsTable,
      ShortcomingLog,
      $$ShortcomingLogsTableFilterComposer,
      $$ShortcomingLogsTableOrderingComposer,
      $$ShortcomingLogsTableAnnotationComposer,
      $$ShortcomingLogsTableCreateCompanionBuilder,
      $$ShortcomingLogsTableUpdateCompanionBuilder,
      (ShortcomingLog, $$ShortcomingLogsTableReferences),
      ShortcomingLog,
      PrefetchHooks Function({bool relatedReviewId, bool defectId})
    >;
typedef $$Step5CompletionsTableCreateCompanionBuilder =
    Step5CompletionsCompanion Function({
      Value<int> id,
      Value<bool> admittedToSelf,
      Value<bool> admittedToHigherPower,
      Value<bool> admittedToSponsor,
      Value<String?> reflection,
      Value<int> resentmentCount,
      Value<int> fearCount,
      Value<int> harmCount,
      required DateTime completedAt,
    });
typedef $$Step5CompletionsTableUpdateCompanionBuilder =
    Step5CompletionsCompanion Function({
      Value<int> id,
      Value<bool> admittedToSelf,
      Value<bool> admittedToHigherPower,
      Value<bool> admittedToSponsor,
      Value<String?> reflection,
      Value<int> resentmentCount,
      Value<int> fearCount,
      Value<int> harmCount,
      Value<DateTime> completedAt,
    });

class $$Step5CompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $Step5CompletionsTable> {
  $$Step5CompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get admittedToSelf => $composableBuilder(
    column: $table.admittedToSelf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get admittedToHigherPower => $composableBuilder(
    column: $table.admittedToHigherPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get admittedToSponsor => $composableBuilder(
    column: $table.admittedToSponsor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resentmentCount => $composableBuilder(
    column: $table.resentmentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fearCount => $composableBuilder(
    column: $table.fearCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get harmCount => $composableBuilder(
    column: $table.harmCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$Step5CompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $Step5CompletionsTable> {
  $$Step5CompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get admittedToSelf => $composableBuilder(
    column: $table.admittedToSelf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get admittedToHigherPower => $composableBuilder(
    column: $table.admittedToHigherPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get admittedToSponsor => $composableBuilder(
    column: $table.admittedToSponsor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resentmentCount => $composableBuilder(
    column: $table.resentmentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fearCount => $composableBuilder(
    column: $table.fearCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get harmCount => $composableBuilder(
    column: $table.harmCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$Step5CompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $Step5CompletionsTable> {
  $$Step5CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get admittedToSelf => $composableBuilder(
    column: $table.admittedToSelf,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get admittedToHigherPower => $composableBuilder(
    column: $table.admittedToHigherPower,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get admittedToSponsor => $composableBuilder(
    column: $table.admittedToSponsor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resentmentCount => $composableBuilder(
    column: $table.resentmentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fearCount =>
      $composableBuilder(column: $table.fearCount, builder: (column) => column);

  GeneratedColumn<int> get harmCount =>
      $composableBuilder(column: $table.harmCount, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$Step5CompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $Step5CompletionsTable,
          Step5Completion,
          $$Step5CompletionsTableFilterComposer,
          $$Step5CompletionsTableOrderingComposer,
          $$Step5CompletionsTableAnnotationComposer,
          $$Step5CompletionsTableCreateCompanionBuilder,
          $$Step5CompletionsTableUpdateCompanionBuilder,
          (
            Step5Completion,
            BaseReferences<
              _$AppDatabase,
              $Step5CompletionsTable,
              Step5Completion
            >,
          ),
          Step5Completion,
          PrefetchHooks Function()
        > {
  $$Step5CompletionsTableTableManager(
    _$AppDatabase db,
    $Step5CompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$Step5CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$Step5CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$Step5CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> admittedToSelf = const Value.absent(),
                Value<bool> admittedToHigherPower = const Value.absent(),
                Value<bool> admittedToSponsor = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<int> resentmentCount = const Value.absent(),
                Value<int> fearCount = const Value.absent(),
                Value<int> harmCount = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => Step5CompletionsCompanion(
                id: id,
                admittedToSelf: admittedToSelf,
                admittedToHigherPower: admittedToHigherPower,
                admittedToSponsor: admittedToSponsor,
                reflection: reflection,
                resentmentCount: resentmentCount,
                fearCount: fearCount,
                harmCount: harmCount,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> admittedToSelf = const Value.absent(),
                Value<bool> admittedToHigherPower = const Value.absent(),
                Value<bool> admittedToSponsor = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<int> resentmentCount = const Value.absent(),
                Value<int> fearCount = const Value.absent(),
                Value<int> harmCount = const Value.absent(),
                required DateTime completedAt,
              }) => Step5CompletionsCompanion.insert(
                id: id,
                admittedToSelf: admittedToSelf,
                admittedToHigherPower: admittedToHigherPower,
                admittedToSponsor: admittedToSponsor,
                reflection: reflection,
                resentmentCount: resentmentCount,
                fearCount: fearCount,
                harmCount: harmCount,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$Step5CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $Step5CompletionsTable,
      Step5Completion,
      $$Step5CompletionsTableFilterComposer,
      $$Step5CompletionsTableOrderingComposer,
      $$Step5CompletionsTableAnnotationComposer,
      $$Step5CompletionsTableCreateCompanionBuilder,
      $$Step5CompletionsTableUpdateCompanionBuilder,
      (
        Step5Completion,
        BaseReferences<_$AppDatabase, $Step5CompletionsTable, Step5Completion>,
      ),
      Step5Completion,
      PrefetchHooks Function()
    >;
typedef $$MeditationSessionsTableCreateCompanionBuilder =
    MeditationSessionsCompanion Function({
      Value<int> id,
      required String sessionType,
      required String reflectionTheme,
      required String reflectionKey,
      Value<int> durationSeconds,
      required DateTime completedAt,
    });
typedef $$MeditationSessionsTableUpdateCompanionBuilder =
    MeditationSessionsCompanion Function({
      Value<int> id,
      Value<String> sessionType,
      Value<String> reflectionTheme,
      Value<String> reflectionKey,
      Value<int> durationSeconds,
      Value<DateTime> completedAt,
    });

class $$MeditationSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $MeditationSessionsTable> {
  $$MeditationSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflectionTheme => $composableBuilder(
    column: $table.reflectionTheme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflectionKey => $composableBuilder(
    column: $table.reflectionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeditationSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeditationSessionsTable> {
  $$MeditationSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionTheme => $composableBuilder(
    column: $table.reflectionTheme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionKey => $composableBuilder(
    column: $table.reflectionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeditationSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeditationSessionsTable> {
  $$MeditationSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflectionTheme => $composableBuilder(
    column: $table.reflectionTheme,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflectionKey => $composableBuilder(
    column: $table.reflectionKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$MeditationSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeditationSessionsTable,
          MeditationSession,
          $$MeditationSessionsTableFilterComposer,
          $$MeditationSessionsTableOrderingComposer,
          $$MeditationSessionsTableAnnotationComposer,
          $$MeditationSessionsTableCreateCompanionBuilder,
          $$MeditationSessionsTableUpdateCompanionBuilder,
          (
            MeditationSession,
            BaseReferences<
              _$AppDatabase,
              $MeditationSessionsTable,
              MeditationSession
            >,
          ),
          MeditationSession,
          PrefetchHooks Function()
        > {
  $$MeditationSessionsTableTableManager(
    _$AppDatabase db,
    $MeditationSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeditationSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeditationSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeditationSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionType = const Value.absent(),
                Value<String> reflectionTheme = const Value.absent(),
                Value<String> reflectionKey = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => MeditationSessionsCompanion(
                id: id,
                sessionType: sessionType,
                reflectionTheme: reflectionTheme,
                reflectionKey: reflectionKey,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionType,
                required String reflectionTheme,
                required String reflectionKey,
                Value<int> durationSeconds = const Value.absent(),
                required DateTime completedAt,
              }) => MeditationSessionsCompanion.insert(
                id: id,
                sessionType: sessionType,
                reflectionTheme: reflectionTheme,
                reflectionKey: reflectionKey,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeditationSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeditationSessionsTable,
      MeditationSession,
      $$MeditationSessionsTableFilterComposer,
      $$MeditationSessionsTableOrderingComposer,
      $$MeditationSessionsTableAnnotationComposer,
      $$MeditationSessionsTableCreateCompanionBuilder,
      $$MeditationSessionsTableUpdateCompanionBuilder,
      (
        MeditationSession,
        BaseReferences<
          _$AppDatabase,
          $MeditationSessionsTable,
          MeditationSession
        >,
      ),
      MeditationSession,
      PrefetchHooks Function()
    >;
typedef $$StepTwelveEventsTableCreateCompanionBuilder =
    StepTwelveEventsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<String?> location,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<String> eventType,
      Value<DateTime> createdAt,
    });
typedef $$StepTwelveEventsTableUpdateCompanionBuilder =
    StepTwelveEventsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> location,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<String> eventType,
      Value<DateTime> createdAt,
    });

class $$StepTwelveEventsTableFilterComposer
    extends Composer<_$AppDatabase, $StepTwelveEventsTable> {
  $$StepTwelveEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StepTwelveEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $StepTwelveEventsTable> {
  $$StepTwelveEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StepTwelveEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StepTwelveEventsTable> {
  $$StepTwelveEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StepTwelveEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StepTwelveEventsTable,
          StepTwelveEvent,
          $$StepTwelveEventsTableFilterComposer,
          $$StepTwelveEventsTableOrderingComposer,
          $$StepTwelveEventsTableAnnotationComposer,
          $$StepTwelveEventsTableCreateCompanionBuilder,
          $$StepTwelveEventsTableUpdateCompanionBuilder,
          (
            StepTwelveEvent,
            BaseReferences<
              _$AppDatabase,
              $StepTwelveEventsTable,
              StepTwelveEvent
            >,
          ),
          StepTwelveEvent,
          PrefetchHooks Function()
        > {
  $$StepTwelveEventsTableTableManager(
    _$AppDatabase db,
    $StepTwelveEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StepTwelveEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StepTwelveEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StepTwelveEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StepTwelveEventsCompanion(
                id: id,
                title: title,
                description: description,
                location: location,
                startTime: startTime,
                endTime: endTime,
                eventType: eventType,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StepTwelveEventsCompanion.insert(
                id: id,
                title: title,
                description: description,
                location: location,
                startTime: startTime,
                endTime: endTime,
                eventType: eventType,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StepTwelveEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StepTwelveEventsTable,
      StepTwelveEvent,
      $$StepTwelveEventsTableFilterComposer,
      $$StepTwelveEventsTableOrderingComposer,
      $$StepTwelveEventsTableAnnotationComposer,
      $$StepTwelveEventsTableCreateCompanionBuilder,
      $$StepTwelveEventsTableUpdateCompanionBuilder,
      (
        StepTwelveEvent,
        BaseReferences<_$AppDatabase, $StepTwelveEventsTable, StepTwelveEvent>,
      ),
      StepTwelveEvent,
      PrefetchHooks Function()
    >;
typedef $$MeetingsTableCreateCompanionBuilder =
    MeetingsCompanion Function({
      Value<int> id,
      required String sourceId,
      required String externalId,
      required String name,
      Value<String> fellowship,
      Value<String?> locationName,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> address,
      required String city,
      required String state,
      Value<String> country,
      required int weekday,
      required String startTime,
      Value<int?> durationMinutes,
      Value<String> typeCodes,
      Value<bool> isOnline,
      Value<String?> conferenceUrl,
      Value<String?> conferencePhone,
      Value<String?> onlinePlatform,
      Value<bool> isHybrid,
      Value<String?> notes,
      Value<bool> isBookmarked,
      Value<bool> isHomeGroup,
      Value<bool> isPlannedAttendance,
      Value<bool> isTemporarilyClosed,
      Value<String> language,
      Value<DateTime> lastSyncedAt,
    });
typedef $$MeetingsTableUpdateCompanionBuilder =
    MeetingsCompanion Function({
      Value<int> id,
      Value<String> sourceId,
      Value<String> externalId,
      Value<String> name,
      Value<String> fellowship,
      Value<String?> locationName,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> address,
      Value<String> city,
      Value<String> state,
      Value<String> country,
      Value<int> weekday,
      Value<String> startTime,
      Value<int?> durationMinutes,
      Value<String> typeCodes,
      Value<bool> isOnline,
      Value<String?> conferenceUrl,
      Value<String?> conferencePhone,
      Value<String?> onlinePlatform,
      Value<bool> isHybrid,
      Value<String?> notes,
      Value<bool> isBookmarked,
      Value<bool> isHomeGroup,
      Value<bool> isPlannedAttendance,
      Value<bool> isTemporarilyClosed,
      Value<String> language,
      Value<DateTime> lastSyncedAt,
    });

final class $$MeetingsTableReferences
    extends BaseReferences<_$AppDatabase, $MeetingsTable, Meeting> {
  $$MeetingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AttendanceLogsTable, List<AttendanceLog>>
  _attendanceLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendanceLogs,
    aliasName: $_aliasNameGenerator(
      db.meetings.id,
      db.attendanceLogs.meetingId,
    ),
  );

  $$AttendanceLogsTableProcessedTableManager get attendanceLogsRefs {
    final manager = $$AttendanceLogsTableTableManager(
      $_db,
      $_db.attendanceLogs,
    ).filter((f) => f.meetingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RolodexContactsTable, List<RolodexContact>>
  _rolodexContactsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rolodexContacts,
    aliasName: $_aliasNameGenerator(
      db.meetings.id,
      db.rolodexContacts.meetingId,
    ),
  );

  $$RolodexContactsTableProcessedTableManager get rolodexContactsRefs {
    final manager = $$RolodexContactsTableTableManager(
      $_db,
      $_db.rolodexContacts,
    ).filter((f) => f.meetingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rolodexContactsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeetingsTableFilterComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fellowship => $composableBuilder(
    column: $table.fellowship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeCodes => $composableBuilder(
    column: $table.typeCodes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conferenceUrl => $composableBuilder(
    column: $table.conferenceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conferencePhone => $composableBuilder(
    column: $table.conferencePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onlinePlatform => $composableBuilder(
    column: $table.onlinePlatform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHybrid => $composableBuilder(
    column: $table.isHybrid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHomeGroup => $composableBuilder(
    column: $table.isHomeGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPlannedAttendance => $composableBuilder(
    column: $table.isPlannedAttendance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTemporarilyClosed => $composableBuilder(
    column: $table.isTemporarilyClosed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> attendanceLogsRefs(
    Expression<bool> Function($$AttendanceLogsTableFilterComposer f) f,
  ) {
    final $$AttendanceLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceLogs,
      getReferencedColumn: (t) => t.meetingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceLogsTableFilterComposer(
            $db: $db,
            $table: $db.attendanceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rolodexContactsRefs(
    Expression<bool> Function($$RolodexContactsTableFilterComposer f) f,
  ) {
    final $$RolodexContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolodexContacts,
      getReferencedColumn: (t) => t.meetingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolodexContactsTableFilterComposer(
            $db: $db,
            $table: $db.rolodexContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeetingsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fellowship => $composableBuilder(
    column: $table.fellowship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeCodes => $composableBuilder(
    column: $table.typeCodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOnline => $composableBuilder(
    column: $table.isOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conferenceUrl => $composableBuilder(
    column: $table.conferenceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conferencePhone => $composableBuilder(
    column: $table.conferencePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onlinePlatform => $composableBuilder(
    column: $table.onlinePlatform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHybrid => $composableBuilder(
    column: $table.isHybrid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHomeGroup => $composableBuilder(
    column: $table.isHomeGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPlannedAttendance => $composableBuilder(
    column: $table.isPlannedAttendance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTemporarilyClosed => $composableBuilder(
    column: $table.isTemporarilyClosed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeetingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeetingsTable> {
  $$MeetingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fellowship => $composableBuilder(
    column: $table.fellowship,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typeCodes =>
      $composableBuilder(column: $table.typeCodes, builder: (column) => column);

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<String> get conferenceUrl => $composableBuilder(
    column: $table.conferenceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conferencePhone => $composableBuilder(
    column: $table.conferencePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onlinePlatform => $composableBuilder(
    column: $table.onlinePlatform,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHybrid =>
      $composableBuilder(column: $table.isHybrid, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHomeGroup => $composableBuilder(
    column: $table.isHomeGroup,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPlannedAttendance => $composableBuilder(
    column: $table.isPlannedAttendance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTemporarilyClosed => $composableBuilder(
    column: $table.isTemporarilyClosed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  Expression<T> attendanceLogsRefs<T extends Object>(
    Expression<T> Function($$AttendanceLogsTableAnnotationComposer a) f,
  ) {
    final $$AttendanceLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendanceLogs,
      getReferencedColumn: (t) => t.meetingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendanceLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.attendanceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rolodexContactsRefs<T extends Object>(
    Expression<T> Function($$RolodexContactsTableAnnotationComposer a) f,
  ) {
    final $$RolodexContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolodexContacts,
      getReferencedColumn: (t) => t.meetingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolodexContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.rolodexContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeetingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeetingsTable,
          Meeting,
          $$MeetingsTableFilterComposer,
          $$MeetingsTableOrderingComposer,
          $$MeetingsTableAnnotationComposer,
          $$MeetingsTableCreateCompanionBuilder,
          $$MeetingsTableUpdateCompanionBuilder,
          (Meeting, $$MeetingsTableReferences),
          Meeting,
          PrefetchHooks Function({
            bool attendanceLogsRefs,
            bool rolodexContactsRefs,
          })
        > {
  $$MeetingsTableTableManager(_$AppDatabase db, $MeetingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeetingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeetingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeetingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fellowship = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<String> typeCodes = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<String?> conferenceUrl = const Value.absent(),
                Value<String?> conferencePhone = const Value.absent(),
                Value<String?> onlinePlatform = const Value.absent(),
                Value<bool> isHybrid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<bool> isHomeGroup = const Value.absent(),
                Value<bool> isPlannedAttendance = const Value.absent(),
                Value<bool> isTemporarilyClosed = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
              }) => MeetingsCompanion(
                id: id,
                sourceId: sourceId,
                externalId: externalId,
                name: name,
                fellowship: fellowship,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                address: address,
                city: city,
                state: state,
                country: country,
                weekday: weekday,
                startTime: startTime,
                durationMinutes: durationMinutes,
                typeCodes: typeCodes,
                isOnline: isOnline,
                conferenceUrl: conferenceUrl,
                conferencePhone: conferencePhone,
                onlinePlatform: onlinePlatform,
                isHybrid: isHybrid,
                notes: notes,
                isBookmarked: isBookmarked,
                isHomeGroup: isHomeGroup,
                isPlannedAttendance: isPlannedAttendance,
                isTemporarilyClosed: isTemporarilyClosed,
                language: language,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceId,
                required String externalId,
                required String name,
                Value<String> fellowship = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> address = const Value.absent(),
                required String city,
                required String state,
                Value<String> country = const Value.absent(),
                required int weekday,
                required String startTime,
                Value<int?> durationMinutes = const Value.absent(),
                Value<String> typeCodes = const Value.absent(),
                Value<bool> isOnline = const Value.absent(),
                Value<String?> conferenceUrl = const Value.absent(),
                Value<String?> conferencePhone = const Value.absent(),
                Value<String?> onlinePlatform = const Value.absent(),
                Value<bool> isHybrid = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<bool> isHomeGroup = const Value.absent(),
                Value<bool> isPlannedAttendance = const Value.absent(),
                Value<bool> isTemporarilyClosed = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
              }) => MeetingsCompanion.insert(
                id: id,
                sourceId: sourceId,
                externalId: externalId,
                name: name,
                fellowship: fellowship,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                address: address,
                city: city,
                state: state,
                country: country,
                weekday: weekday,
                startTime: startTime,
                durationMinutes: durationMinutes,
                typeCodes: typeCodes,
                isOnline: isOnline,
                conferenceUrl: conferenceUrl,
                conferencePhone: conferencePhone,
                onlinePlatform: onlinePlatform,
                isHybrid: isHybrid,
                notes: notes,
                isBookmarked: isBookmarked,
                isHomeGroup: isHomeGroup,
                isPlannedAttendance: isPlannedAttendance,
                isTemporarilyClosed: isTemporarilyClosed,
                language: language,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeetingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({attendanceLogsRefs = false, rolodexContactsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attendanceLogsRefs) db.attendanceLogs,
                    if (rolodexContactsRefs) db.rolodexContacts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attendanceLogsRefs)
                        await $_getPrefetchedData<
                          Meeting,
                          $MeetingsTable,
                          AttendanceLog
                        >(
                          currentTable: table,
                          referencedTable: $$MeetingsTableReferences
                              ._attendanceLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MeetingsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendanceLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.meetingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rolodexContactsRefs)
                        await $_getPrefetchedData<
                          Meeting,
                          $MeetingsTable,
                          RolodexContact
                        >(
                          currentTable: table,
                          referencedTable: $$MeetingsTableReferences
                              ._rolodexContactsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MeetingsTableReferences(
                                db,
                                table,
                                p0,
                              ).rolodexContactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.meetingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MeetingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeetingsTable,
      Meeting,
      $$MeetingsTableFilterComposer,
      $$MeetingsTableOrderingComposer,
      $$MeetingsTableAnnotationComposer,
      $$MeetingsTableCreateCompanionBuilder,
      $$MeetingsTableUpdateCompanionBuilder,
      (Meeting, $$MeetingsTableReferences),
      Meeting,
      PrefetchHooks Function({
        bool attendanceLogsRefs,
        bool rolodexContactsRefs,
      })
    >;
typedef $$AttendanceLogsTableCreateCompanionBuilder =
    AttendanceLogsCompanion Function({
      Value<int> id,
      Value<int?> meetingId,
      required String meetingName,
      required DateTime attendedAt,
      Value<String?> notes,
      Value<bool> sharedAtMeeting,
      Value<bool> hasSponsorContact,
      Value<bool> hasServiceWork,
    });
typedef $$AttendanceLogsTableUpdateCompanionBuilder =
    AttendanceLogsCompanion Function({
      Value<int> id,
      Value<int?> meetingId,
      Value<String> meetingName,
      Value<DateTime> attendedAt,
      Value<String?> notes,
      Value<bool> sharedAtMeeting,
      Value<bool> hasSponsorContact,
      Value<bool> hasServiceWork,
    });

final class $$AttendanceLogsTableReferences
    extends BaseReferences<_$AppDatabase, $AttendanceLogsTable, AttendanceLog> {
  $$AttendanceLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeetingsTable _meetingIdTable(_$AppDatabase db) =>
      db.meetings.createAlias(
        $_aliasNameGenerator(db.attendanceLogs.meetingId, db.meetings.id),
      );

  $$MeetingsTableProcessedTableManager? get meetingId {
    final $_column = $_itemColumn<int>('meeting_id');
    if ($_column == null) return null;
    final manager = $$MeetingsTableTableManager(
      $_db,
      $_db.meetings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_meetingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendanceLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceLogsTable> {
  $$AttendanceLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meetingName => $composableBuilder(
    column: $table.meetingName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attendedAt => $composableBuilder(
    column: $table.attendedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sharedAtMeeting => $composableBuilder(
    column: $table.sharedAtMeeting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasSponsorContact => $composableBuilder(
    column: $table.hasSponsorContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasServiceWork => $composableBuilder(
    column: $table.hasServiceWork,
    builder: (column) => ColumnFilters(column),
  );

  $$MeetingsTableFilterComposer get meetingId {
    final $$MeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableFilterComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceLogsTable> {
  $$AttendanceLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meetingName => $composableBuilder(
    column: $table.meetingName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attendedAt => $composableBuilder(
    column: $table.attendedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sharedAtMeeting => $composableBuilder(
    column: $table.sharedAtMeeting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSponsorContact => $composableBuilder(
    column: $table.hasSponsorContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasServiceWork => $composableBuilder(
    column: $table.hasServiceWork,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeetingsTableOrderingComposer get meetingId {
    final $$MeetingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableOrderingComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceLogsTable> {
  $$AttendanceLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get meetingName => $composableBuilder(
    column: $table.meetingName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get attendedAt => $composableBuilder(
    column: $table.attendedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get sharedAtMeeting => $composableBuilder(
    column: $table.sharedAtMeeting,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasSponsorContact => $composableBuilder(
    column: $table.hasSponsorContact,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasServiceWork => $composableBuilder(
    column: $table.hasServiceWork,
    builder: (column) => column,
  );

  $$MeetingsTableAnnotationComposer get meetingId {
    final $$MeetingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableAnnotationComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendanceLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceLogsTable,
          AttendanceLog,
          $$AttendanceLogsTableFilterComposer,
          $$AttendanceLogsTableOrderingComposer,
          $$AttendanceLogsTableAnnotationComposer,
          $$AttendanceLogsTableCreateCompanionBuilder,
          $$AttendanceLogsTableUpdateCompanionBuilder,
          (AttendanceLog, $$AttendanceLogsTableReferences),
          AttendanceLog,
          PrefetchHooks Function({bool meetingId})
        > {
  $$AttendanceLogsTableTableManager(
    _$AppDatabase db,
    $AttendanceLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> meetingId = const Value.absent(),
                Value<String> meetingName = const Value.absent(),
                Value<DateTime> attendedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> sharedAtMeeting = const Value.absent(),
                Value<bool> hasSponsorContact = const Value.absent(),
                Value<bool> hasServiceWork = const Value.absent(),
              }) => AttendanceLogsCompanion(
                id: id,
                meetingId: meetingId,
                meetingName: meetingName,
                attendedAt: attendedAt,
                notes: notes,
                sharedAtMeeting: sharedAtMeeting,
                hasSponsorContact: hasSponsorContact,
                hasServiceWork: hasServiceWork,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> meetingId = const Value.absent(),
                required String meetingName,
                required DateTime attendedAt,
                Value<String?> notes = const Value.absent(),
                Value<bool> sharedAtMeeting = const Value.absent(),
                Value<bool> hasSponsorContact = const Value.absent(),
                Value<bool> hasServiceWork = const Value.absent(),
              }) => AttendanceLogsCompanion.insert(
                id: id,
                meetingId: meetingId,
                meetingName: meetingName,
                attendedAt: attendedAt,
                notes: notes,
                sharedAtMeeting: sharedAtMeeting,
                hasSponsorContact: hasSponsorContact,
                hasServiceWork: hasServiceWork,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendanceLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({meetingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (meetingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.meetingId,
                                referencedTable: $$AttendanceLogsTableReferences
                                    ._meetingIdTable(db),
                                referencedColumn:
                                    $$AttendanceLogsTableReferences
                                        ._meetingIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttendanceLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceLogsTable,
      AttendanceLog,
      $$AttendanceLogsTableFilterComposer,
      $$AttendanceLogsTableOrderingComposer,
      $$AttendanceLogsTableAnnotationComposer,
      $$AttendanceLogsTableCreateCompanionBuilder,
      $$AttendanceLogsTableUpdateCompanionBuilder,
      (AttendanceLog, $$AttendanceLogsTableReferences),
      AttendanceLog,
      PrefetchHooks Function({bool meetingId})
    >;
typedef $$SyncMetasTableCreateCompanionBuilder =
    SyncMetasCompanion Function({
      required String sourceId,
      required String displayName,
      Value<bool> isEnabled,
      Value<DateTime?> lastSyncAt,
      Value<int> totalMeetings,
      Value<String?> syncError,
      Value<int> rowid,
    });
typedef $$SyncMetasTableUpdateCompanionBuilder =
    SyncMetasCompanion Function({
      Value<String> sourceId,
      Value<String> displayName,
      Value<bool> isEnabled,
      Value<DateTime?> lastSyncAt,
      Value<int> totalMeetings,
      Value<String?> syncError,
      Value<int> rowid,
    });

class $$SyncMetasTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetasTable> {
  $$SyncMetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMeetings => $composableBuilder(
    column: $table.totalMeetings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetasTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetasTable> {
  $$SyncMetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMeetings => $composableBuilder(
    column: $table.totalMeetings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetasTable> {
  $$SyncMetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMeetings => $composableBuilder(
    column: $table.totalMeetings,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$SyncMetasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetasTable,
          SourceMeta,
          $$SyncMetasTableFilterComposer,
          $$SyncMetasTableOrderingComposer,
          $$SyncMetasTableAnnotationComposer,
          $$SyncMetasTableCreateCompanionBuilder,
          $$SyncMetasTableUpdateCompanionBuilder,
          (
            SourceMeta,
            BaseReferences<_$AppDatabase, $SyncMetasTable, SourceMeta>,
          ),
          SourceMeta,
          PrefetchHooks Function()
        > {
  $$SyncMetasTableTableManager(_$AppDatabase db, $SyncMetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> totalMeetings = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetasCompanion(
                sourceId: sourceId,
                displayName: displayName,
                isEnabled: isEnabled,
                lastSyncAt: lastSyncAt,
                totalMeetings: totalMeetings,
                syncError: syncError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String displayName,
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> totalMeetings = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetasCompanion.insert(
                sourceId: sourceId,
                displayName: displayName,
                isEnabled: isEnabled,
                lastSyncAt: lastSyncAt,
                totalMeetings: totalMeetings,
                syncError: syncError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetasTable,
      SourceMeta,
      $$SyncMetasTableFilterComposer,
      $$SyncMetasTableOrderingComposer,
      $$SyncMetasTableAnnotationComposer,
      $$SyncMetasTableCreateCompanionBuilder,
      $$SyncMetasTableUpdateCompanionBuilder,
      (SourceMeta, BaseReferences<_$AppDatabase, $SyncMetasTable, SourceMeta>),
      SourceMeta,
      PrefetchHooks Function()
    >;
typedef $$ServiceCommitmentsTableCreateCompanionBuilder =
    ServiceCommitmentsCompanion Function({
      Value<int> id,
      Value<String> type,
      required String title,
      Value<String?> organization,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<bool> isRecurring,
      Value<int?> recurringWeekday,
      Value<String?> recurringTime,
      Value<bool> reminderEnabled,
      Value<int?> reminderMinutesBefore,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$ServiceCommitmentsTableUpdateCompanionBuilder =
    ServiceCommitmentsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> title,
      Value<String?> organization,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<bool> isRecurring,
      Value<int?> recurringWeekday,
      Value<String?> recurringTime,
      Value<bool> reminderEnabled,
      Value<int?> reminderMinutesBefore,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$ServiceCommitmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceCommitmentsTable> {
  $$ServiceCommitmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurringWeekday => $composableBuilder(
    column: $table.recurringWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringTime => $composableBuilder(
    column: $table.recurringTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServiceCommitmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceCommitmentsTable> {
  $$ServiceCommitmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurringWeekday => $composableBuilder(
    column: $table.recurringWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringTime => $composableBuilder(
    column: $table.recurringTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceCommitmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceCommitmentsTable> {
  $$ServiceCommitmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurringWeekday => $composableBuilder(
    column: $table.recurringWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringTime => $composableBuilder(
    column: $table.recurringTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutesBefore => $composableBuilder(
    column: $table.reminderMinutesBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ServiceCommitmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceCommitmentsTable,
          ServiceCommitment,
          $$ServiceCommitmentsTableFilterComposer,
          $$ServiceCommitmentsTableOrderingComposer,
          $$ServiceCommitmentsTableAnnotationComposer,
          $$ServiceCommitmentsTableCreateCompanionBuilder,
          $$ServiceCommitmentsTableUpdateCompanionBuilder,
          (
            ServiceCommitment,
            BaseReferences<
              _$AppDatabase,
              $ServiceCommitmentsTable,
              ServiceCommitment
            >,
          ),
          ServiceCommitment,
          PrefetchHooks Function()
        > {
  $$ServiceCommitmentsTableTableManager(
    _$AppDatabase db,
    $ServiceCommitmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceCommitmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceCommitmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceCommitmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> organization = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<int?> recurringWeekday = const Value.absent(),
                Value<String?> recurringTime = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int?> reminderMinutesBefore = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ServiceCommitmentsCompanion(
                id: id,
                type: type,
                title: title,
                organization: organization,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                isRecurring: isRecurring,
                recurringWeekday: recurringWeekday,
                recurringTime: recurringTime,
                reminderEnabled: reminderEnabled,
                reminderMinutesBefore: reminderMinutesBefore,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                required String title,
                Value<String?> organization = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<int?> recurringWeekday = const Value.absent(),
                Value<String?> recurringTime = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int?> reminderMinutesBefore = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ServiceCommitmentsCompanion.insert(
                id: id,
                type: type,
                title: title,
                organization: organization,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                isRecurring: isRecurring,
                recurringWeekday: recurringWeekday,
                recurringTime: recurringTime,
                reminderEnabled: reminderEnabled,
                reminderMinutesBefore: reminderMinutesBefore,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServiceCommitmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceCommitmentsTable,
      ServiceCommitment,
      $$ServiceCommitmentsTableFilterComposer,
      $$ServiceCommitmentsTableOrderingComposer,
      $$ServiceCommitmentsTableAnnotationComposer,
      $$ServiceCommitmentsTableCreateCompanionBuilder,
      $$ServiceCommitmentsTableUpdateCompanionBuilder,
      (
        ServiceCommitment,
        BaseReferences<
          _$AppDatabase,
          $ServiceCommitmentsTable,
          ServiceCommitment
        >,
      ),
      ServiceCommitment,
      PrefetchHooks Function()
    >;
typedef $$SponseesTableCreateCompanionBuilder =
    SponseesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> phone,
      Value<String?> email,
      Value<DateTime?> sobrietyDate,
      Value<DateTime?> startedSponsoringDate,
      Value<int?> currentStep,
      Value<bool> isActive,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$SponseesTableUpdateCompanionBuilder =
    SponseesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> email,
      Value<DateTime?> sobrietyDate,
      Value<DateTime?> startedSponsoringDate,
      Value<int?> currentStep,
      Value<bool> isActive,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$SponseesTableReferences
    extends BaseReferences<_$AppDatabase, $SponseesTable, Sponsee> {
  $$SponseesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TwelfthStepCallsTable, List<TwelfthStepCall>>
  _twelfthStepCallsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.twelfthStepCalls,
    aliasName: $_aliasNameGenerator(
      db.sponsees.id,
      db.twelfthStepCalls.sponseeId,
    ),
  );

  $$TwelfthStepCallsTableProcessedTableManager get twelfthStepCallsRefs {
    final manager = $$TwelfthStepCallsTableTableManager(
      $_db,
      $_db.twelfthStepCalls,
    ).filter((f) => f.sponseeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _twelfthStepCallsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SponseeStepProgressTable, List<SponseeStepEntry>>
  _sponseeStepProgressRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sponseeStepProgress,
        aliasName: $_aliasNameGenerator(
          db.sponsees.id,
          db.sponseeStepProgress.sponseeId,
        ),
      );

  $$SponseeStepProgressTableProcessedTableManager get sponseeStepProgressRefs {
    final manager = $$SponseeStepProgressTableTableManager(
      $_db,
      $_db.sponseeStepProgress,
    ).filter((f) => f.sponseeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sponseeStepProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SponseeCheckInsTable, List<SponseeCheckIn>>
  _sponseeCheckInsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sponseeCheckIns,
    aliasName: $_aliasNameGenerator(
      db.sponsees.id,
      db.sponseeCheckIns.sponseeId,
    ),
  );

  $$SponseeCheckInsTableProcessedTableManager get sponseeCheckInsRefs {
    final manager = $$SponseeCheckInsTableTableManager(
      $_db,
      $_db.sponseeCheckIns,
    ).filter((f) => f.sponseeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sponseeCheckInsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RolodexContactsTable, List<RolodexContact>>
  _rolodexContactsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rolodexContacts,
    aliasName: $_aliasNameGenerator(
      db.sponsees.id,
      db.rolodexContacts.sponseeId,
    ),
  );

  $$RolodexContactsTableProcessedTableManager get rolodexContactsRefs {
    final manager = $$RolodexContactsTableTableManager(
      $_db,
      $_db.rolodexContacts,
    ).filter((f) => f.sponseeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rolodexContactsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SponseesTableFilterComposer
    extends Composer<_$AppDatabase, $SponseesTable> {
  $$SponseesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sobrietyDate => $composableBuilder(
    column: $table.sobrietyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedSponsoringDate => $composableBuilder(
    column: $table.startedSponsoringDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> twelfthStepCallsRefs(
    Expression<bool> Function($$TwelfthStepCallsTableFilterComposer f) f,
  ) {
    final $$TwelfthStepCallsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.twelfthStepCalls,
      getReferencedColumn: (t) => t.sponseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TwelfthStepCallsTableFilterComposer(
            $db: $db,
            $table: $db.twelfthStepCalls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sponseeStepProgressRefs(
    Expression<bool> Function($$SponseeStepProgressTableFilterComposer f) f,
  ) {
    final $$SponseeStepProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sponseeStepProgress,
      getReferencedColumn: (t) => t.sponseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseeStepProgressTableFilterComposer(
            $db: $db,
            $table: $db.sponseeStepProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sponseeCheckInsRefs(
    Expression<bool> Function($$SponseeCheckInsTableFilterComposer f) f,
  ) {
    final $$SponseeCheckInsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sponseeCheckIns,
      getReferencedColumn: (t) => t.sponseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseeCheckInsTableFilterComposer(
            $db: $db,
            $table: $db.sponseeCheckIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rolodexContactsRefs(
    Expression<bool> Function($$RolodexContactsTableFilterComposer f) f,
  ) {
    final $$RolodexContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolodexContacts,
      getReferencedColumn: (t) => t.sponseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolodexContactsTableFilterComposer(
            $db: $db,
            $table: $db.rolodexContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SponseesTableOrderingComposer
    extends Composer<_$AppDatabase, $SponseesTable> {
  $$SponseesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sobrietyDate => $composableBuilder(
    column: $table.sobrietyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedSponsoringDate => $composableBuilder(
    column: $table.startedSponsoringDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SponseesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SponseesTable> {
  $$SponseesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get sobrietyDate => $composableBuilder(
    column: $table.sobrietyDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedSponsoringDate => $composableBuilder(
    column: $table.startedSponsoringDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStep => $composableBuilder(
    column: $table.currentStep,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> twelfthStepCallsRefs<T extends Object>(
    Expression<T> Function($$TwelfthStepCallsTableAnnotationComposer a) f,
  ) {
    final $$TwelfthStepCallsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.twelfthStepCalls,
      getReferencedColumn: (t) => t.sponseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TwelfthStepCallsTableAnnotationComposer(
            $db: $db,
            $table: $db.twelfthStepCalls,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sponseeStepProgressRefs<T extends Object>(
    Expression<T> Function($$SponseeStepProgressTableAnnotationComposer a) f,
  ) {
    final $$SponseeStepProgressTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sponseeStepProgress,
          getReferencedColumn: (t) => t.sponseeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SponseeStepProgressTableAnnotationComposer(
                $db: $db,
                $table: $db.sponseeStepProgress,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> sponseeCheckInsRefs<T extends Object>(
    Expression<T> Function($$SponseeCheckInsTableAnnotationComposer a) f,
  ) {
    final $$SponseeCheckInsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sponseeCheckIns,
      getReferencedColumn: (t) => t.sponseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseeCheckInsTableAnnotationComposer(
            $db: $db,
            $table: $db.sponseeCheckIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rolodexContactsRefs<T extends Object>(
    Expression<T> Function($$RolodexContactsTableAnnotationComposer a) f,
  ) {
    final $$RolodexContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rolodexContacts,
      getReferencedColumn: (t) => t.sponseeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolodexContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.rolodexContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SponseesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SponseesTable,
          Sponsee,
          $$SponseesTableFilterComposer,
          $$SponseesTableOrderingComposer,
          $$SponseesTableAnnotationComposer,
          $$SponseesTableCreateCompanionBuilder,
          $$SponseesTableUpdateCompanionBuilder,
          (Sponsee, $$SponseesTableReferences),
          Sponsee,
          PrefetchHooks Function({
            bool twelfthStepCallsRefs,
            bool sponseeStepProgressRefs,
            bool sponseeCheckInsRefs,
            bool rolodexContactsRefs,
          })
        > {
  $$SponseesTableTableManager(_$AppDatabase db, $SponseesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SponseesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SponseesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SponseesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> sobrietyDate = const Value.absent(),
                Value<DateTime?> startedSponsoringDate = const Value.absent(),
                Value<int?> currentStep = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SponseesCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                sobrietyDate: sobrietyDate,
                startedSponsoringDate: startedSponsoringDate,
                currentStep: currentStep,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> sobrietyDate = const Value.absent(),
                Value<DateTime?> startedSponsoringDate = const Value.absent(),
                Value<int?> currentStep = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SponseesCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                sobrietyDate: sobrietyDate,
                startedSponsoringDate: startedSponsoringDate,
                currentStep: currentStep,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SponseesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                twelfthStepCallsRefs = false,
                sponseeStepProgressRefs = false,
                sponseeCheckInsRefs = false,
                rolodexContactsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (twelfthStepCallsRefs) db.twelfthStepCalls,
                    if (sponseeStepProgressRefs) db.sponseeStepProgress,
                    if (sponseeCheckInsRefs) db.sponseeCheckIns,
                    if (rolodexContactsRefs) db.rolodexContacts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (twelfthStepCallsRefs)
                        await $_getPrefetchedData<
                          Sponsee,
                          $SponseesTable,
                          TwelfthStepCall
                        >(
                          currentTable: table,
                          referencedTable: $$SponseesTableReferences
                              ._twelfthStepCallsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SponseesTableReferences(
                                db,
                                table,
                                p0,
                              ).twelfthStepCallsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sponseeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sponseeStepProgressRefs)
                        await $_getPrefetchedData<
                          Sponsee,
                          $SponseesTable,
                          SponseeStepEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SponseesTableReferences
                              ._sponseeStepProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SponseesTableReferences(
                                db,
                                table,
                                p0,
                              ).sponseeStepProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sponseeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sponseeCheckInsRefs)
                        await $_getPrefetchedData<
                          Sponsee,
                          $SponseesTable,
                          SponseeCheckIn
                        >(
                          currentTable: table,
                          referencedTable: $$SponseesTableReferences
                              ._sponseeCheckInsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SponseesTableReferences(
                                db,
                                table,
                                p0,
                              ).sponseeCheckInsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sponseeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rolodexContactsRefs)
                        await $_getPrefetchedData<
                          Sponsee,
                          $SponseesTable,
                          RolodexContact
                        >(
                          currentTable: table,
                          referencedTable: $$SponseesTableReferences
                              ._rolodexContactsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SponseesTableReferences(
                                db,
                                table,
                                p0,
                              ).rolodexContactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sponseeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SponseesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SponseesTable,
      Sponsee,
      $$SponseesTableFilterComposer,
      $$SponseesTableOrderingComposer,
      $$SponseesTableAnnotationComposer,
      $$SponseesTableCreateCompanionBuilder,
      $$SponseesTableUpdateCompanionBuilder,
      (Sponsee, $$SponseesTableReferences),
      Sponsee,
      PrefetchHooks Function({
        bool twelfthStepCallsRefs,
        bool sponseeStepProgressRefs,
        bool sponseeCheckInsRefs,
        bool rolodexContactsRefs,
      })
    >;
typedef $$TwelfthStepCallsTableCreateCompanionBuilder =
    TwelfthStepCallsCompanion Function({
      Value<int> id,
      Value<String> callType,
      Value<String?> person,
      required String description,
      Value<String?> outcome,
      required DateTime occurredAt,
      Value<DateTime?> scheduledAt,
      Value<int?> sponseeId,
      Value<DateTime> createdAt,
    });
typedef $$TwelfthStepCallsTableUpdateCompanionBuilder =
    TwelfthStepCallsCompanion Function({
      Value<int> id,
      Value<String> callType,
      Value<String?> person,
      Value<String> description,
      Value<String?> outcome,
      Value<DateTime> occurredAt,
      Value<DateTime?> scheduledAt,
      Value<int?> sponseeId,
      Value<DateTime> createdAt,
    });

final class $$TwelfthStepCallsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TwelfthStepCallsTable, TwelfthStepCall> {
  $$TwelfthStepCallsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SponseesTable _sponseeIdTable(_$AppDatabase db) =>
      db.sponsees.createAlias(
        $_aliasNameGenerator(db.twelfthStepCalls.sponseeId, db.sponsees.id),
      );

  $$SponseesTableProcessedTableManager? get sponseeId {
    final $_column = $_itemColumn<int>('sponsee_id');
    if ($_column == null) return null;
    final manager = $$SponseesTableTableManager(
      $_db,
      $_db.sponsees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sponseeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TwelfthStepCallsTableFilterComposer
    extends Composer<_$AppDatabase, $TwelfthStepCallsTable> {
  $$TwelfthStepCallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SponseesTableFilterComposer get sponseeId {
    final $$SponseesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableFilterComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TwelfthStepCallsTableOrderingComposer
    extends Composer<_$AppDatabase, $TwelfthStepCallsTable> {
  $$TwelfthStepCallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callType => $composableBuilder(
    column: $table.callType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SponseesTableOrderingComposer get sponseeId {
    final $$SponseesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableOrderingComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TwelfthStepCallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TwelfthStepCallsTable> {
  $$TwelfthStepCallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get callType =>
      $composableBuilder(column: $table.callType, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SponseesTableAnnotationComposer get sponseeId {
    final $$SponseesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableAnnotationComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TwelfthStepCallsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TwelfthStepCallsTable,
          TwelfthStepCall,
          $$TwelfthStepCallsTableFilterComposer,
          $$TwelfthStepCallsTableOrderingComposer,
          $$TwelfthStepCallsTableAnnotationComposer,
          $$TwelfthStepCallsTableCreateCompanionBuilder,
          $$TwelfthStepCallsTableUpdateCompanionBuilder,
          (TwelfthStepCall, $$TwelfthStepCallsTableReferences),
          TwelfthStepCall,
          PrefetchHooks Function({bool sponseeId})
        > {
  $$TwelfthStepCallsTableTableManager(
    _$AppDatabase db,
    $TwelfthStepCallsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TwelfthStepCallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TwelfthStepCallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TwelfthStepCallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> callType = const Value.absent(),
                Value<String?> person = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<int?> sponseeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TwelfthStepCallsCompanion(
                id: id,
                callType: callType,
                person: person,
                description: description,
                outcome: outcome,
                occurredAt: occurredAt,
                scheduledAt: scheduledAt,
                sponseeId: sponseeId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> callType = const Value.absent(),
                Value<String?> person = const Value.absent(),
                required String description,
                Value<String?> outcome = const Value.absent(),
                required DateTime occurredAt,
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<int?> sponseeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TwelfthStepCallsCompanion.insert(
                id: id,
                callType: callType,
                person: person,
                description: description,
                outcome: outcome,
                occurredAt: occurredAt,
                scheduledAt: scheduledAt,
                sponseeId: sponseeId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TwelfthStepCallsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sponseeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sponseeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sponseeId,
                                referencedTable:
                                    $$TwelfthStepCallsTableReferences
                                        ._sponseeIdTable(db),
                                referencedColumn:
                                    $$TwelfthStepCallsTableReferences
                                        ._sponseeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TwelfthStepCallsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TwelfthStepCallsTable,
      TwelfthStepCall,
      $$TwelfthStepCallsTableFilterComposer,
      $$TwelfthStepCallsTableOrderingComposer,
      $$TwelfthStepCallsTableAnnotationComposer,
      $$TwelfthStepCallsTableCreateCompanionBuilder,
      $$TwelfthStepCallsTableUpdateCompanionBuilder,
      (TwelfthStepCall, $$TwelfthStepCallsTableReferences),
      TwelfthStepCall,
      PrefetchHooks Function({bool sponseeId})
    >;
typedef $$SponseeStepProgressTableCreateCompanionBuilder =
    SponseeStepProgressCompanion Function({
      Value<int> id,
      required int sponseeId,
      required int stepNumber,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<String?> notes,
    });
typedef $$SponseeStepProgressTableUpdateCompanionBuilder =
    SponseeStepProgressCompanion Function({
      Value<int> id,
      Value<int> sponseeId,
      Value<int> stepNumber,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<String?> notes,
    });

final class $$SponseeStepProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SponseeStepProgressTable,
          SponseeStepEntry
        > {
  $$SponseeStepProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SponseesTable _sponseeIdTable(_$AppDatabase db) =>
      db.sponsees.createAlias(
        $_aliasNameGenerator(db.sponseeStepProgress.sponseeId, db.sponsees.id),
      );

  $$SponseesTableProcessedTableManager get sponseeId {
    final $_column = $_itemColumn<int>('sponsee_id')!;

    final manager = $$SponseesTableTableManager(
      $_db,
      $_db.sponsees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sponseeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SponseeStepProgressTableFilterComposer
    extends Composer<_$AppDatabase, $SponseeStepProgressTable> {
  $$SponseeStepProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SponseesTableFilterComposer get sponseeId {
    final $$SponseesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableFilterComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SponseeStepProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $SponseeStepProgressTable> {
  $$SponseeStepProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SponseesTableOrderingComposer get sponseeId {
    final $$SponseesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableOrderingComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SponseeStepProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $SponseeStepProgressTable> {
  $$SponseeStepProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SponseesTableAnnotationComposer get sponseeId {
    final $$SponseesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableAnnotationComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SponseeStepProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SponseeStepProgressTable,
          SponseeStepEntry,
          $$SponseeStepProgressTableFilterComposer,
          $$SponseeStepProgressTableOrderingComposer,
          $$SponseeStepProgressTableAnnotationComposer,
          $$SponseeStepProgressTableCreateCompanionBuilder,
          $$SponseeStepProgressTableUpdateCompanionBuilder,
          (SponseeStepEntry, $$SponseeStepProgressTableReferences),
          SponseeStepEntry,
          PrefetchHooks Function({bool sponseeId})
        > {
  $$SponseeStepProgressTableTableManager(
    _$AppDatabase db,
    $SponseeStepProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SponseeStepProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SponseeStepProgressTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SponseeStepProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sponseeId = const Value.absent(),
                Value<int> stepNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SponseeStepProgressCompanion(
                id: id,
                sponseeId: sponseeId,
                stepNumber: stepNumber,
                status: status,
                completedAt: completedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sponseeId,
                required int stepNumber,
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SponseeStepProgressCompanion.insert(
                id: id,
                sponseeId: sponseeId,
                stepNumber: stepNumber,
                status: status,
                completedAt: completedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SponseeStepProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sponseeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sponseeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sponseeId,
                                referencedTable:
                                    $$SponseeStepProgressTableReferences
                                        ._sponseeIdTable(db),
                                referencedColumn:
                                    $$SponseeStepProgressTableReferences
                                        ._sponseeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SponseeStepProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SponseeStepProgressTable,
      SponseeStepEntry,
      $$SponseeStepProgressTableFilterComposer,
      $$SponseeStepProgressTableOrderingComposer,
      $$SponseeStepProgressTableAnnotationComposer,
      $$SponseeStepProgressTableCreateCompanionBuilder,
      $$SponseeStepProgressTableUpdateCompanionBuilder,
      (SponseeStepEntry, $$SponseeStepProgressTableReferences),
      SponseeStepEntry,
      PrefetchHooks Function({bool sponseeId})
    >;
typedef $$SponseeCheckInsTableCreateCompanionBuilder =
    SponseeCheckInsCompanion Function({
      Value<int> id,
      required int sponseeId,
      required DateTime scheduledAt,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$SponseeCheckInsTableUpdateCompanionBuilder =
    SponseeCheckInsCompanion Function({
      Value<int> id,
      Value<int> sponseeId,
      Value<DateTime> scheduledAt,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$SponseeCheckInsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SponseeCheckInsTable, SponseeCheckIn> {
  $$SponseeCheckInsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SponseesTable _sponseeIdTable(_$AppDatabase db) =>
      db.sponsees.createAlias(
        $_aliasNameGenerator(db.sponseeCheckIns.sponseeId, db.sponsees.id),
      );

  $$SponseesTableProcessedTableManager get sponseeId {
    final $_column = $_itemColumn<int>('sponsee_id')!;

    final manager = $$SponseesTableTableManager(
      $_db,
      $_db.sponsees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sponseeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SponseeCheckInsTableFilterComposer
    extends Composer<_$AppDatabase, $SponseeCheckInsTable> {
  $$SponseeCheckInsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SponseesTableFilterComposer get sponseeId {
    final $$SponseesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableFilterComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SponseeCheckInsTableOrderingComposer
    extends Composer<_$AppDatabase, $SponseeCheckInsTable> {
  $$SponseeCheckInsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SponseesTableOrderingComposer get sponseeId {
    final $$SponseesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableOrderingComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SponseeCheckInsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SponseeCheckInsTable> {
  $$SponseeCheckInsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SponseesTableAnnotationComposer get sponseeId {
    final $$SponseesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableAnnotationComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SponseeCheckInsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SponseeCheckInsTable,
          SponseeCheckIn,
          $$SponseeCheckInsTableFilterComposer,
          $$SponseeCheckInsTableOrderingComposer,
          $$SponseeCheckInsTableAnnotationComposer,
          $$SponseeCheckInsTableCreateCompanionBuilder,
          $$SponseeCheckInsTableUpdateCompanionBuilder,
          (SponseeCheckIn, $$SponseeCheckInsTableReferences),
          SponseeCheckIn,
          PrefetchHooks Function({bool sponseeId})
        > {
  $$SponseeCheckInsTableTableManager(
    _$AppDatabase db,
    $SponseeCheckInsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SponseeCheckInsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SponseeCheckInsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SponseeCheckInsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sponseeId = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SponseeCheckInsCompanion(
                id: id,
                sponseeId: sponseeId,
                scheduledAt: scheduledAt,
                completedAt: completedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sponseeId,
                required DateTime scheduledAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SponseeCheckInsCompanion.insert(
                id: id,
                sponseeId: sponseeId,
                scheduledAt: scheduledAt,
                completedAt: completedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SponseeCheckInsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sponseeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sponseeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sponseeId,
                                referencedTable:
                                    $$SponseeCheckInsTableReferences
                                        ._sponseeIdTable(db),
                                referencedColumn:
                                    $$SponseeCheckInsTableReferences
                                        ._sponseeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SponseeCheckInsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SponseeCheckInsTable,
      SponseeCheckIn,
      $$SponseeCheckInsTableFilterComposer,
      $$SponseeCheckInsTableOrderingComposer,
      $$SponseeCheckInsTableAnnotationComposer,
      $$SponseeCheckInsTableCreateCompanionBuilder,
      $$SponseeCheckInsTableUpdateCompanionBuilder,
      (SponseeCheckIn, $$SponseeCheckInsTableReferences),
      SponseeCheckIn,
      PrefetchHooks Function({bool sponseeId})
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      required String content,
      Value<String?> title,
      Value<int?> stepNumber,
      Value<int?> traditionNumber,
      Value<String?> promptId,
      Value<String?> tags,
      Value<String?> mood,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<int> id,
      Value<String> content,
      Value<String?> title,
      Value<int?> stepNumber,
      Value<int?> traditionNumber,
      Value<String?> promptId,
      Value<String?> tags,
      Value<String?> mood,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$JournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get traditionNumber => $composableBuilder(
    column: $table.traditionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get traditionNumber => $composableBuilder(
    column: $table.traditionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get stepNumber => $composableBuilder(
    column: $table.stepNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get traditionNumber => $composableBuilder(
    column: $table.traditionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$JournalEntriesTableTableManager(
    _$AppDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int?> stepNumber = const Value.absent(),
                Value<int?> traditionNumber = const Value.absent(),
                Value<String?> promptId = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                content: content,
                title: title,
                stepNumber: stepNumber,
                traditionNumber: traditionNumber,
                promptId: promptId,
                tags: tags,
                mood: mood,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String content,
                Value<String?> title = const Value.absent(),
                Value<int?> stepNumber = const Value.absent(),
                Value<int?> traditionNumber = const Value.absent(),
                Value<String?> promptId = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                content: content,
                title: title,
                stepNumber: stepNumber,
                traditionNumber: traditionNumber,
                promptId: promptId,
                tags: tags,
                mood: mood,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $JournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$LiteratureBookmarksTableCreateCompanionBuilder =
    LiteratureBookmarksCompanion Function({
      Value<int> id,
      required String bookKey,
      required String chapterKey,
      required String chapterTitle,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$LiteratureBookmarksTableUpdateCompanionBuilder =
    LiteratureBookmarksCompanion Function({
      Value<int> id,
      Value<String> bookKey,
      Value<String> chapterKey,
      Value<String> chapterTitle,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

class $$LiteratureBookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $LiteratureBookmarksTable> {
  $$LiteratureBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookKey => $composableBuilder(
    column: $table.bookKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterKey => $composableBuilder(
    column: $table.chapterKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LiteratureBookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $LiteratureBookmarksTable> {
  $$LiteratureBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookKey => $composableBuilder(
    column: $table.bookKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterKey => $composableBuilder(
    column: $table.chapterKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiteratureBookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiteratureBookmarksTable> {
  $$LiteratureBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<String> get chapterKey => $composableBuilder(
    column: $table.chapterKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LiteratureBookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiteratureBookmarksTable,
          LiteratureBookmark,
          $$LiteratureBookmarksTableFilterComposer,
          $$LiteratureBookmarksTableOrderingComposer,
          $$LiteratureBookmarksTableAnnotationComposer,
          $$LiteratureBookmarksTableCreateCompanionBuilder,
          $$LiteratureBookmarksTableUpdateCompanionBuilder,
          (
            LiteratureBookmark,
            BaseReferences<
              _$AppDatabase,
              $LiteratureBookmarksTable,
              LiteratureBookmark
            >,
          ),
          LiteratureBookmark,
          PrefetchHooks Function()
        > {
  $$LiteratureBookmarksTableTableManager(
    _$AppDatabase db,
    $LiteratureBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiteratureBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiteratureBookmarksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LiteratureBookmarksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookKey = const Value.absent(),
                Value<String> chapterKey = const Value.absent(),
                Value<String> chapterTitle = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LiteratureBookmarksCompanion(
                id: id,
                bookKey: bookKey,
                chapterKey: chapterKey,
                chapterTitle: chapterTitle,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookKey,
                required String chapterKey,
                required String chapterTitle,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LiteratureBookmarksCompanion.insert(
                id: id,
                bookKey: bookKey,
                chapterKey: chapterKey,
                chapterTitle: chapterTitle,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LiteratureBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiteratureBookmarksTable,
      LiteratureBookmark,
      $$LiteratureBookmarksTableFilterComposer,
      $$LiteratureBookmarksTableOrderingComposer,
      $$LiteratureBookmarksTableAnnotationComposer,
      $$LiteratureBookmarksTableCreateCompanionBuilder,
      $$LiteratureBookmarksTableUpdateCompanionBuilder,
      (
        LiteratureBookmark,
        BaseReferences<
          _$AppDatabase,
          $LiteratureBookmarksTable,
          LiteratureBookmark
        >,
      ),
      LiteratureBookmark,
      PrefetchHooks Function()
    >;
typedef $$SponsorCallLogsTableCreateCompanionBuilder =
    SponsorCallLogsCompanion Function({
      Value<int> id,
      Value<DateTime?> scheduledFor,
      required DateTime confirmedAt,
      Value<bool> calledViaApp,
      Value<String?> notes,
    });
typedef $$SponsorCallLogsTableUpdateCompanionBuilder =
    SponsorCallLogsCompanion Function({
      Value<int> id,
      Value<DateTime?> scheduledFor,
      Value<DateTime> confirmedAt,
      Value<bool> calledViaApp,
      Value<String?> notes,
    });

class $$SponsorCallLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SponsorCallLogsTable> {
  $$SponsorCallLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get calledViaApp => $composableBuilder(
    column: $table.calledViaApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SponsorCallLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SponsorCallLogsTable> {
  $$SponsorCallLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get calledViaApp => $composableBuilder(
    column: $table.calledViaApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SponsorCallLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SponsorCallLogsTable> {
  $$SponsorCallLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get calledViaApp => $composableBuilder(
    column: $table.calledViaApp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$SponsorCallLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SponsorCallLogsTable,
          SponsorCallLog,
          $$SponsorCallLogsTableFilterComposer,
          $$SponsorCallLogsTableOrderingComposer,
          $$SponsorCallLogsTableAnnotationComposer,
          $$SponsorCallLogsTableCreateCompanionBuilder,
          $$SponsorCallLogsTableUpdateCompanionBuilder,
          (
            SponsorCallLog,
            BaseReferences<
              _$AppDatabase,
              $SponsorCallLogsTable,
              SponsorCallLog
            >,
          ),
          SponsorCallLog,
          PrefetchHooks Function()
        > {
  $$SponsorCallLogsTableTableManager(
    _$AppDatabase db,
    $SponsorCallLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SponsorCallLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SponsorCallLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SponsorCallLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> scheduledFor = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<bool> calledViaApp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SponsorCallLogsCompanion(
                id: id,
                scheduledFor: scheduledFor,
                confirmedAt: confirmedAt,
                calledViaApp: calledViaApp,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> scheduledFor = const Value.absent(),
                required DateTime confirmedAt,
                Value<bool> calledViaApp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SponsorCallLogsCompanion.insert(
                id: id,
                scheduledFor: scheduledFor,
                confirmedAt: confirmedAt,
                calledViaApp: calledViaApp,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SponsorCallLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SponsorCallLogsTable,
      SponsorCallLog,
      $$SponsorCallLogsTableFilterComposer,
      $$SponsorCallLogsTableOrderingComposer,
      $$SponsorCallLogsTableAnnotationComposer,
      $$SponsorCallLogsTableCreateCompanionBuilder,
      $$SponsorCallLogsTableUpdateCompanionBuilder,
      (
        SponsorCallLog,
        BaseReferences<_$AppDatabase, $SponsorCallLogsTable, SponsorCallLog>,
      ),
      SponsorCallLog,
      PrefetchHooks Function()
    >;
typedef $$RolodexContactsTableCreateCompanionBuilder =
    RolodexContactsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> notes,
      Value<int?> meetingId,
      Value<bool> isSponsor,
      Value<int?> sponseeId,
      Value<DateTime> createdAt,
    });
typedef $$RolodexContactsTableUpdateCompanionBuilder =
    RolodexContactsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> notes,
      Value<int?> meetingId,
      Value<bool> isSponsor,
      Value<int?> sponseeId,
      Value<DateTime> createdAt,
    });

final class $$RolodexContactsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RolodexContactsTable, RolodexContact> {
  $$RolodexContactsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeetingsTable _meetingIdTable(_$AppDatabase db) =>
      db.meetings.createAlias(
        $_aliasNameGenerator(db.rolodexContacts.meetingId, db.meetings.id),
      );

  $$MeetingsTableProcessedTableManager? get meetingId {
    final $_column = $_itemColumn<int>('meeting_id');
    if ($_column == null) return null;
    final manager = $$MeetingsTableTableManager(
      $_db,
      $_db.meetings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_meetingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SponseesTable _sponseeIdTable(_$AppDatabase db) =>
      db.sponsees.createAlias(
        $_aliasNameGenerator(db.rolodexContacts.sponseeId, db.sponsees.id),
      );

  $$SponseesTableProcessedTableManager? get sponseeId {
    final $_column = $_itemColumn<int>('sponsee_id');
    if ($_column == null) return null;
    final manager = $$SponseesTableTableManager(
      $_db,
      $_db.sponsees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sponseeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RolodexContactsTableFilterComposer
    extends Composer<_$AppDatabase, $RolodexContactsTable> {
  $$RolodexContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSponsor => $composableBuilder(
    column: $table.isSponsor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MeetingsTableFilterComposer get meetingId {
    final $$MeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableFilterComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SponseesTableFilterComposer get sponseeId {
    final $$SponseesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableFilterComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RolodexContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $RolodexContactsTable> {
  $$RolodexContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSponsor => $composableBuilder(
    column: $table.isSponsor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeetingsTableOrderingComposer get meetingId {
    final $$MeetingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableOrderingComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SponseesTableOrderingComposer get sponseeId {
    final $$SponseesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableOrderingComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RolodexContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolodexContactsTable> {
  $$RolodexContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSponsor =>
      $composableBuilder(column: $table.isSponsor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MeetingsTableAnnotationComposer get meetingId {
    final $$MeetingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.meetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingsTableAnnotationComposer(
            $db: $db,
            $table: $db.meetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SponseesTableAnnotationComposer get sponseeId {
    final $$SponseesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sponseeId,
      referencedTable: $db.sponsees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SponseesTableAnnotationComposer(
            $db: $db,
            $table: $db.sponsees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RolodexContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolodexContactsTable,
          RolodexContact,
          $$RolodexContactsTableFilterComposer,
          $$RolodexContactsTableOrderingComposer,
          $$RolodexContactsTableAnnotationComposer,
          $$RolodexContactsTableCreateCompanionBuilder,
          $$RolodexContactsTableUpdateCompanionBuilder,
          (RolodexContact, $$RolodexContactsTableReferences),
          RolodexContact,
          PrefetchHooks Function({bool meetingId, bool sponseeId})
        > {
  $$RolodexContactsTableTableManager(
    _$AppDatabase db,
    $RolodexContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolodexContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolodexContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolodexContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> meetingId = const Value.absent(),
                Value<bool> isSponsor = const Value.absent(),
                Value<int?> sponseeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RolodexContactsCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
                meetingId: meetingId,
                isSponsor: isSponsor,
                sponseeId: sponseeId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> meetingId = const Value.absent(),
                Value<bool> isSponsor = const Value.absent(),
                Value<int?> sponseeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RolodexContactsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
                meetingId: meetingId,
                isSponsor: isSponsor,
                sponseeId: sponseeId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RolodexContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({meetingId = false, sponseeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (meetingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.meetingId,
                                referencedTable:
                                    $$RolodexContactsTableReferences
                                        ._meetingIdTable(db),
                                referencedColumn:
                                    $$RolodexContactsTableReferences
                                        ._meetingIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sponseeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sponseeId,
                                referencedTable:
                                    $$RolodexContactsTableReferences
                                        ._sponseeIdTable(db),
                                referencedColumn:
                                    $$RolodexContactsTableReferences
                                        ._sponseeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RolodexContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolodexContactsTable,
      RolodexContact,
      $$RolodexContactsTableFilterComposer,
      $$RolodexContactsTableOrderingComposer,
      $$RolodexContactsTableAnnotationComposer,
      $$RolodexContactsTableCreateCompanionBuilder,
      $$RolodexContactsTableUpdateCompanionBuilder,
      (RolodexContact, $$RolodexContactsTableReferences),
      RolodexContact,
      PrefetchHooks Function({bool meetingId, bool sponseeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ResentmentsTableTableManager get resentments =>
      $$ResentmentsTableTableManager(_db, _db.resentments);
  $$FearsTableTableManager get fears =>
      $$FearsTableTableManager(_db, _db.fears);
  $$HarmsTableTableManager get harms =>
      $$HarmsTableTableManager(_db, _db.harms);
  $$DailyReviewsTableTableManager get dailyReviews =>
      $$DailyReviewsTableTableManager(_db, _db.dailyReviews);
  $$AmendsTableTableManager get amends =>
      $$AmendsTableTableManager(_db, _db.amends);
  $$DefectsTableTableManager get defects =>
      $$DefectsTableTableManager(_db, _db.defects);
  $$ShortcomingLogsTableTableManager get shortcomingLogs =>
      $$ShortcomingLogsTableTableManager(_db, _db.shortcomingLogs);
  $$Step5CompletionsTableTableManager get step5Completions =>
      $$Step5CompletionsTableTableManager(_db, _db.step5Completions);
  $$MeditationSessionsTableTableManager get meditationSessions =>
      $$MeditationSessionsTableTableManager(_db, _db.meditationSessions);
  $$StepTwelveEventsTableTableManager get stepTwelveEvents =>
      $$StepTwelveEventsTableTableManager(_db, _db.stepTwelveEvents);
  $$MeetingsTableTableManager get meetings =>
      $$MeetingsTableTableManager(_db, _db.meetings);
  $$AttendanceLogsTableTableManager get attendanceLogs =>
      $$AttendanceLogsTableTableManager(_db, _db.attendanceLogs);
  $$SyncMetasTableTableManager get syncMetas =>
      $$SyncMetasTableTableManager(_db, _db.syncMetas);
  $$ServiceCommitmentsTableTableManager get serviceCommitments =>
      $$ServiceCommitmentsTableTableManager(_db, _db.serviceCommitments);
  $$SponseesTableTableManager get sponsees =>
      $$SponseesTableTableManager(_db, _db.sponsees);
  $$TwelfthStepCallsTableTableManager get twelfthStepCalls =>
      $$TwelfthStepCallsTableTableManager(_db, _db.twelfthStepCalls);
  $$SponseeStepProgressTableTableManager get sponseeStepProgress =>
      $$SponseeStepProgressTableTableManager(_db, _db.sponseeStepProgress);
  $$SponseeCheckInsTableTableManager get sponseeCheckIns =>
      $$SponseeCheckInsTableTableManager(_db, _db.sponseeCheckIns);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$LiteratureBookmarksTableTableManager get literatureBookmarks =>
      $$LiteratureBookmarksTableTableManager(_db, _db.literatureBookmarks);
  $$SponsorCallLogsTableTableManager get sponsorCallLogs =>
      $$SponsorCallLogsTableTableManager(_db, _db.sponsorCallLogs);
  $$RolodexContactsTableTableManager get rolodexContacts =>
      $$RolodexContactsTableTableManager(_db, _db.rolodexContacts);
}
