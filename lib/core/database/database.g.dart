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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
      'person', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _causeMeta = const VerificationMeta('cause');
  @override
  late final GeneratedColumn<String> cause = GeneratedColumn<String>(
      'cause', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _affectsMeta =
      const VerificationMeta('affects');
  @override
  late final GeneratedColumn<String> affects = GeneratedColumn<String>(
      'affects', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _myPartMeta = const VerificationMeta('myPart');
  @override
  late final GeneratedColumn<String> myPart = GeneratedColumn<String>(
      'my_part', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, person, cause, affects, myPart, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resentments';
  @override
  VerificationContext validateIntegrity(Insertable<Resentment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person')) {
      context.handle(_personMeta,
          person.isAcceptableOrUnknown(data['person']!, _personMeta));
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('cause')) {
      context.handle(
          _causeMeta, cause.isAcceptableOrUnknown(data['cause']!, _causeMeta));
    } else if (isInserting) {
      context.missing(_causeMeta);
    }
    if (data.containsKey('affects')) {
      context.handle(_affectsMeta,
          affects.isAcceptableOrUnknown(data['affects']!, _affectsMeta));
    } else if (isInserting) {
      context.missing(_affectsMeta);
    }
    if (data.containsKey('my_part')) {
      context.handle(_myPartMeta,
          myPart.isAcceptableOrUnknown(data['my_part']!, _myPartMeta));
    } else if (isInserting) {
      context.missing(_myPartMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      person: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person'])!,
      cause: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cause'])!,
      affects: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}affects'])!,
      myPart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}my_part'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  final DateTime createdAt;
  const Resentment(
      {required this.id,
      required this.person,
      required this.cause,
      required this.affects,
      required this.myPart,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person'] = Variable<String>(person);
    map['cause'] = Variable<String>(cause);
    map['affects'] = Variable<String>(affects);
    map['my_part'] = Variable<String>(myPart);
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
      createdAt: Value(createdAt),
    );
  }

  factory Resentment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Resentment(
      id: serializer.fromJson<int>(json['id']),
      person: serializer.fromJson<String>(json['person']),
      cause: serializer.fromJson<String>(json['cause']),
      affects: serializer.fromJson<String>(json['affects']),
      myPart: serializer.fromJson<String>(json['myPart']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Resentment copyWith(
          {int? id,
          String? person,
          String? cause,
          String? affects,
          String? myPart,
          DateTime? createdAt}) =>
      Resentment(
        id: id ?? this.id,
        person: person ?? this.person,
        cause: cause ?? this.cause,
        affects: affects ?? this.affects,
        myPart: myPart ?? this.myPart,
        createdAt: createdAt ?? this.createdAt,
      );
  Resentment copyWithCompanion(ResentmentsCompanion data) {
    return Resentment(
      id: data.id.present ? data.id.value : this.id,
      person: data.person.present ? data.person.value : this.person,
      cause: data.cause.present ? data.cause.value : this.cause,
      affects: data.affects.present ? data.affects.value : this.affects,
      myPart: data.myPart.present ? data.myPart.value : this.myPart,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, person, cause, affects, myPart, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Resentment &&
          other.id == this.id &&
          other.person == this.person &&
          other.cause == this.cause &&
          other.affects == this.affects &&
          other.myPart == this.myPart &&
          other.createdAt == this.createdAt);
}

class ResentmentsCompanion extends UpdateCompanion<Resentment> {
  final Value<int> id;
  final Value<String> person;
  final Value<String> cause;
  final Value<String> affects;
  final Value<String> myPart;
  final Value<DateTime> createdAt;
  const ResentmentsCompanion({
    this.id = const Value.absent(),
    this.person = const Value.absent(),
    this.cause = const Value.absent(),
    this.affects = const Value.absent(),
    this.myPart = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ResentmentsCompanion.insert({
    this.id = const Value.absent(),
    required String person,
    required String cause,
    required String affects,
    required String myPart,
    required DateTime createdAt,
  })  : person = Value(person),
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
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (person != null) 'person': person,
      if (cause != null) 'cause': cause,
      if (affects != null) 'affects': affects,
      if (myPart != null) 'my_part': myPart,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ResentmentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? person,
      Value<String>? cause,
      Value<String>? affects,
      Value<String>? myPart,
      Value<DateTime>? createdAt}) {
    return ResentmentsCompanion(
      id: id ?? this.id,
      person: person ?? this.person,
      cause: cause ?? this.cause,
      affects: affects ?? this.affects,
      myPart: myPart ?? this.myPart,
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _whyMeta = const VerificationMeta('why');
  @override
  late final GeneratedColumn<String> why = GeneratedColumn<String>(
      'why', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _myPartMeta = const VerificationMeta('myPart');
  @override
  late final GeneratedColumn<String> myPart = GeneratedColumn<String>(
      'my_part', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, subject, why, myPart, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fears';
  @override
  VerificationContext validateIntegrity(Insertable<Fear> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('why')) {
      context.handle(
          _whyMeta, why.isAcceptableOrUnknown(data['why']!, _whyMeta));
    } else if (isInserting) {
      context.missing(_whyMeta);
    }
    if (data.containsKey('my_part')) {
      context.handle(_myPartMeta,
          myPart.isAcceptableOrUnknown(data['my_part']!, _myPartMeta));
    } else if (isInserting) {
      context.missing(_myPartMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      why: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}why'])!,
      myPart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}my_part'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  final DateTime createdAt;
  const Fear(
      {required this.id,
      required this.subject,
      required this.why,
      required this.myPart,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject'] = Variable<String>(subject);
    map['why'] = Variable<String>(why);
    map['my_part'] = Variable<String>(myPart);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FearsCompanion toCompanion(bool nullToAbsent) {
    return FearsCompanion(
      id: Value(id),
      subject: Value(subject),
      why: Value(why),
      myPart: Value(myPart),
      createdAt: Value(createdAt),
    );
  }

  factory Fear.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fear(
      id: serializer.fromJson<int>(json['id']),
      subject: serializer.fromJson<String>(json['subject']),
      why: serializer.fromJson<String>(json['why']),
      myPart: serializer.fromJson<String>(json['myPart']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Fear copyWith(
          {int? id,
          String? subject,
          String? why,
          String? myPart,
          DateTime? createdAt}) =>
      Fear(
        id: id ?? this.id,
        subject: subject ?? this.subject,
        why: why ?? this.why,
        myPart: myPart ?? this.myPart,
        createdAt: createdAt ?? this.createdAt,
      );
  Fear copyWithCompanion(FearsCompanion data) {
    return Fear(
      id: data.id.present ? data.id.value : this.id,
      subject: data.subject.present ? data.subject.value : this.subject,
      why: data.why.present ? data.why.value : this.why,
      myPart: data.myPart.present ? data.myPart.value : this.myPart,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, subject, why, myPart, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fear &&
          other.id == this.id &&
          other.subject == this.subject &&
          other.why == this.why &&
          other.myPart == this.myPart &&
          other.createdAt == this.createdAt);
}

class FearsCompanion extends UpdateCompanion<Fear> {
  final Value<int> id;
  final Value<String> subject;
  final Value<String> why;
  final Value<String> myPart;
  final Value<DateTime> createdAt;
  const FearsCompanion({
    this.id = const Value.absent(),
    this.subject = const Value.absent(),
    this.why = const Value.absent(),
    this.myPart = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FearsCompanion.insert({
    this.id = const Value.absent(),
    required String subject,
    required String why,
    required String myPart,
    required DateTime createdAt,
  })  : subject = Value(subject),
        why = Value(why),
        myPart = Value(myPart),
        createdAt = Value(createdAt);
  static Insertable<Fear> custom({
    Expression<int>? id,
    Expression<String>? subject,
    Expression<String>? why,
    Expression<String>? myPart,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subject != null) 'subject': subject,
      if (why != null) 'why': why,
      if (myPart != null) 'my_part': myPart,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FearsCompanion copyWith(
      {Value<int>? id,
      Value<String>? subject,
      Value<String>? why,
      Value<String>? myPart,
      Value<DateTime>? createdAt}) {
    return FearsCompanion(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      why: why ?? this.why,
      myPart: myPart ?? this.myPart,
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
      'person', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _conductMeta =
      const VerificationMeta('conduct');
  @override
  late final GeneratedColumn<String> conduct = GeneratedColumn<String>(
      'conduct', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _myPartMeta = const VerificationMeta('myPart');
  @override
  late final GeneratedColumn<String> myPart = GeneratedColumn<String>(
      'my_part', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amendsPlanMeta =
      const VerificationMeta('amendsPlan');
  @override
  late final GeneratedColumn<String> amendsPlan = GeneratedColumn<String>(
      'amends_plan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAmendsDoneMeta =
      const VerificationMeta('isAmendsDone');
  @override
  late final GeneratedColumn<bool> isAmendsDone = GeneratedColumn<bool>(
      'is_amends_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_amends_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _dateAmendsDoneMeta =
      const VerificationMeta('dateAmendsDone');
  @override
  late final GeneratedColumn<DateTime> dateAmendsDone =
      GeneratedColumn<DateTime>('date_amends_done', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        person,
        conduct,
        myPart,
        amendsPlan,
        isAmendsDone,
        dateAmendsDone,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'harms';
  @override
  VerificationContext validateIntegrity(Insertable<Harm> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person')) {
      context.handle(_personMeta,
          person.isAcceptableOrUnknown(data['person']!, _personMeta));
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('conduct')) {
      context.handle(_conductMeta,
          conduct.isAcceptableOrUnknown(data['conduct']!, _conductMeta));
    } else if (isInserting) {
      context.missing(_conductMeta);
    }
    if (data.containsKey('my_part')) {
      context.handle(_myPartMeta,
          myPart.isAcceptableOrUnknown(data['my_part']!, _myPartMeta));
    } else if (isInserting) {
      context.missing(_myPartMeta);
    }
    if (data.containsKey('amends_plan')) {
      context.handle(
          _amendsPlanMeta,
          amendsPlan.isAcceptableOrUnknown(
              data['amends_plan']!, _amendsPlanMeta));
    }
    if (data.containsKey('is_amends_done')) {
      context.handle(
          _isAmendsDoneMeta,
          isAmendsDone.isAcceptableOrUnknown(
              data['is_amends_done']!, _isAmendsDoneMeta));
    }
    if (data.containsKey('date_amends_done')) {
      context.handle(
          _dateAmendsDoneMeta,
          dateAmendsDone.isAcceptableOrUnknown(
              data['date_amends_done']!, _dateAmendsDoneMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      person: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person'])!,
      conduct: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conduct'])!,
      myPart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}my_part'])!,
      amendsPlan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amends_plan']),
      isAmendsDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_amends_done'])!,
      dateAmendsDone: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_amends_done']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  final DateTime createdAt;
  const Harm(
      {required this.id,
      required this.person,
      required this.conduct,
      required this.myPart,
      this.amendsPlan,
      required this.isAmendsDone,
      this.dateAmendsDone,
      required this.createdAt});
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
      createdAt: Value(createdAt),
    );
  }

  factory Harm.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Harm(
      id: serializer.fromJson<int>(json['id']),
      person: serializer.fromJson<String>(json['person']),
      conduct: serializer.fromJson<String>(json['conduct']),
      myPart: serializer.fromJson<String>(json['myPart']),
      amendsPlan: serializer.fromJson<String?>(json['amendsPlan']),
      isAmendsDone: serializer.fromJson<bool>(json['isAmendsDone']),
      dateAmendsDone: serializer.fromJson<DateTime?>(json['dateAmendsDone']),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Harm copyWith(
          {int? id,
          String? person,
          String? conduct,
          String? myPart,
          Value<String?> amendsPlan = const Value.absent(),
          bool? isAmendsDone,
          Value<DateTime?> dateAmendsDone = const Value.absent(),
          DateTime? createdAt}) =>
      Harm(
        id: id ?? this.id,
        person: person ?? this.person,
        conduct: conduct ?? this.conduct,
        myPart: myPart ?? this.myPart,
        amendsPlan: amendsPlan.present ? amendsPlan.value : this.amendsPlan,
        isAmendsDone: isAmendsDone ?? this.isAmendsDone,
        dateAmendsDone:
            dateAmendsDone.present ? dateAmendsDone.value : this.dateAmendsDone,
        createdAt: createdAt ?? this.createdAt,
      );
  Harm copyWithCompanion(HarmsCompanion data) {
    return Harm(
      id: data.id.present ? data.id.value : this.id,
      person: data.person.present ? data.person.value : this.person,
      conduct: data.conduct.present ? data.conduct.value : this.conduct,
      myPart: data.myPart.present ? data.myPart.value : this.myPart,
      amendsPlan:
          data.amendsPlan.present ? data.amendsPlan.value : this.amendsPlan,
      isAmendsDone: data.isAmendsDone.present
          ? data.isAmendsDone.value
          : this.isAmendsDone,
      dateAmendsDone: data.dateAmendsDone.present
          ? data.dateAmendsDone.value
          : this.dateAmendsDone,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, person, conduct, myPart, amendsPlan,
      isAmendsDone, dateAmendsDone, createdAt);
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
  final Value<DateTime> createdAt;
  const HarmsCompanion({
    this.id = const Value.absent(),
    this.person = const Value.absent(),
    this.conduct = const Value.absent(),
    this.myPart = const Value.absent(),
    this.amendsPlan = const Value.absent(),
    this.isAmendsDone = const Value.absent(),
    this.dateAmendsDone = const Value.absent(),
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
    required DateTime createdAt,
  })  : person = Value(person),
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
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HarmsCompanion copyWith(
      {Value<int>? id,
      Value<String>? person,
      Value<String>? conduct,
      Value<String>? myPart,
      Value<String?>? amendsPlan,
      Value<bool>? isAmendsDone,
      Value<DateTime?>? dateAmendsDone,
      Value<DateTime>? createdAt}) {
    return HarmsCompanion(
      id: id ?? this.id,
      person: person ?? this.person,
      conduct: conduct ?? this.conduct,
      myPart: myPart ?? this.myPart,
      amendsPlan: amendsPlan ?? this.amendsPlan,
      isAmendsDone: isAmendsDone ?? this.isAmendsDone,
      dateAmendsDone: dateAmendsDone ?? this.dateAmendsDone,
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _wasResentfulMeta =
      const VerificationMeta('wasResentful');
  @override
  late final GeneratedColumn<bool> wasResentful = GeneratedColumn<bool>(
      'was_resentful', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("was_resentful" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wasSelfishMeta =
      const VerificationMeta('wasSelfish');
  @override
  late final GeneratedColumn<bool> wasSelfish = GeneratedColumn<bool>(
      'was_selfish', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("was_selfish" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wasDishonestMeta =
      const VerificationMeta('wasDishonest');
  @override
  late final GeneratedColumn<bool> wasDishonest = GeneratedColumn<bool>(
      'was_dishonest', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("was_dishonest" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wasAfraidMeta =
      const VerificationMeta('wasAfraid');
  @override
  late final GeneratedColumn<bool> wasAfraid = GeneratedColumn<bool>(
      'was_afraid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("was_afraid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gratitudeMeta =
      const VerificationMeta('gratitude');
  @override
  late final GeneratedColumn<String> gratitude = GeneratedColumn<String>(
      'gratitude', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_reviews';
  @override
  VerificationContext validateIntegrity(Insertable<DailyReview> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('was_resentful')) {
      context.handle(
          _wasResentfulMeta,
          wasResentful.isAcceptableOrUnknown(
              data['was_resentful']!, _wasResentfulMeta));
    }
    if (data.containsKey('was_selfish')) {
      context.handle(
          _wasSelfishMeta,
          wasSelfish.isAcceptableOrUnknown(
              data['was_selfish']!, _wasSelfishMeta));
    }
    if (data.containsKey('was_dishonest')) {
      context.handle(
          _wasDishonestMeta,
          wasDishonest.isAcceptableOrUnknown(
              data['was_dishonest']!, _wasDishonestMeta));
    }
    if (data.containsKey('was_afraid')) {
      context.handle(_wasAfraidMeta,
          wasAfraid.isAcceptableOrUnknown(data['was_afraid']!, _wasAfraidMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('gratitude')) {
      context.handle(_gratitudeMeta,
          gratitude.isAcceptableOrUnknown(data['gratitude']!, _gratitudeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      wasResentful: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_resentful'])!,
      wasSelfish: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_selfish'])!,
      wasDishonest: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_dishonest'])!,
      wasAfraid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_afraid'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      gratitude: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gratitude']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
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
  final DateTime createdAt;
  const DailyReview(
      {required this.id,
      required this.date,
      required this.wasResentful,
      required this.wasSelfish,
      required this.wasDishonest,
      required this.wasAfraid,
      this.notes,
      this.gratitude,
      required this.createdAt});
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
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      gratitude: gratitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gratitude),
      createdAt: Value(createdAt),
    );
  }

  factory DailyReview.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyReview copyWith(
          {int? id,
          DateTime? date,
          bool? wasResentful,
          bool? wasSelfish,
          bool? wasDishonest,
          bool? wasAfraid,
          Value<String?> notes = const Value.absent(),
          Value<String?> gratitude = const Value.absent(),
          DateTime? createdAt}) =>
      DailyReview(
        id: id ?? this.id,
        date: date ?? this.date,
        wasResentful: wasResentful ?? this.wasResentful,
        wasSelfish: wasSelfish ?? this.wasSelfish,
        wasDishonest: wasDishonest ?? this.wasDishonest,
        wasAfraid: wasAfraid ?? this.wasAfraid,
        notes: notes.present ? notes.value : this.notes,
        gratitude: gratitude.present ? gratitude.value : this.gratitude,
        createdAt: createdAt ?? this.createdAt,
      );
  DailyReview copyWithCompanion(DailyReviewsCompanion data) {
    return DailyReview(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      wasResentful: data.wasResentful.present
          ? data.wasResentful.value
          : this.wasResentful,
      wasSelfish:
          data.wasSelfish.present ? data.wasSelfish.value : this.wasSelfish,
      wasDishonest: data.wasDishonest.present
          ? data.wasDishonest.value
          : this.wasDishonest,
      wasAfraid: data.wasAfraid.present ? data.wasAfraid.value : this.wasAfraid,
      notes: data.notes.present ? data.notes.value : this.notes,
      gratitude: data.gratitude.present ? data.gratitude.value : this.gratitude,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, wasResentful, wasSelfish,
      wasDishonest, wasAfraid, notes, gratitude, createdAt);
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
    required DateTime createdAt,
  })  : date = Value(date),
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
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailyReviewsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<bool>? wasResentful,
      Value<bool>? wasSelfish,
      Value<bool>? wasDishonest,
      Value<bool>? wasAfraid,
      Value<String?>? notes,
      Value<String?>? gratitude,
      Value<DateTime>? createdAt}) {
    return DailyReviewsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      wasResentful: wasResentful ?? this.wasResentful,
      wasSelfish: wasSelfish ?? this.wasSelfish,
      wasDishonest: wasDishonest ?? this.wasDishonest,
      wasAfraid: wasAfraid ?? this.wasAfraid,
      notes: notes ?? this.notes,
      gratitude: gratitude ?? this.gratitude,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeditationsTable extends Meditations
    with TableInfo<$MeditationsTable, Meditation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeditationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
      'focus', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prayerRequestMeta =
      const VerificationMeta('prayerRequest');
  @override
  late final GeneratedColumn<String> prayerRequest = GeneratedColumn<String>(
      'prayer_request', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, focus, prayerRequest, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meditations';
  @override
  VerificationContext validateIntegrity(Insertable<Meditation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('focus')) {
      context.handle(
          _focusMeta, focus.isAcceptableOrUnknown(data['focus']!, _focusMeta));
    } else if (isInserting) {
      context.missing(_focusMeta);
    }
    if (data.containsKey('prayer_request')) {
      context.handle(
          _prayerRequestMeta,
          prayerRequest.isAcceptableOrUnknown(
              data['prayer_request']!, _prayerRequestMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meditation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meditation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      focus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}focus'])!,
      prayerRequest: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prayer_request']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MeditationsTable createAlias(String alias) {
    return $MeditationsTable(attachedDatabase, alias);
  }
}

class Meditation extends DataClass implements Insertable<Meditation> {
  final int id;
  final DateTime date;
  final String focus;
  final String? prayerRequest;
  final DateTime createdAt;
  const Meditation(
      {required this.id,
      required this.date,
      required this.focus,
      this.prayerRequest,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['focus'] = Variable<String>(focus);
    if (!nullToAbsent || prayerRequest != null) {
      map['prayer_request'] = Variable<String>(prayerRequest);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MeditationsCompanion toCompanion(bool nullToAbsent) {
    return MeditationsCompanion(
      id: Value(id),
      date: Value(date),
      focus: Value(focus),
      prayerRequest: prayerRequest == null && nullToAbsent
          ? const Value.absent()
          : Value(prayerRequest),
      createdAt: Value(createdAt),
    );
  }

  factory Meditation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meditation(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      focus: serializer.fromJson<String>(json['focus']),
      prayerRequest: serializer.fromJson<String?>(json['prayerRequest']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'focus': serializer.toJson<String>(focus),
      'prayerRequest': serializer.toJson<String?>(prayerRequest),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Meditation copyWith(
          {int? id,
          DateTime? date,
          String? focus,
          Value<String?> prayerRequest = const Value.absent(),
          DateTime? createdAt}) =>
      Meditation(
        id: id ?? this.id,
        date: date ?? this.date,
        focus: focus ?? this.focus,
        prayerRequest:
            prayerRequest.present ? prayerRequest.value : this.prayerRequest,
        createdAt: createdAt ?? this.createdAt,
      );
  Meditation copyWithCompanion(MeditationsCompanion data) {
    return Meditation(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      focus: data.focus.present ? data.focus.value : this.focus,
      prayerRequest: data.prayerRequest.present
          ? data.prayerRequest.value
          : this.prayerRequest,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meditation(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('focus: $focus, ')
          ..write('prayerRequest: $prayerRequest, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, focus, prayerRequest, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meditation &&
          other.id == this.id &&
          other.date == this.date &&
          other.focus == this.focus &&
          other.prayerRequest == this.prayerRequest &&
          other.createdAt == this.createdAt);
}

class MeditationsCompanion extends UpdateCompanion<Meditation> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> focus;
  final Value<String?> prayerRequest;
  final Value<DateTime> createdAt;
  const MeditationsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.focus = const Value.absent(),
    this.prayerRequest = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MeditationsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String focus,
    this.prayerRequest = const Value.absent(),
    required DateTime createdAt,
  })  : date = Value(date),
        focus = Value(focus),
        createdAt = Value(createdAt);
  static Insertable<Meditation> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? focus,
    Expression<String>? prayerRequest,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (focus != null) 'focus': focus,
      if (prayerRequest != null) 'prayer_request': prayerRequest,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MeditationsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? focus,
      Value<String?>? prayerRequest,
      Value<DateTime>? createdAt}) {
    return MeditationsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      focus: focus ?? this.focus,
      prayerRequest: prayerRequest ?? this.prayerRequest,
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
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (prayerRequest.present) {
      map['prayer_request'] = Variable<String>(prayerRequest.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeditationsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('focus: $focus, ')
          ..write('prayerRequest: $prayerRequest, ')
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
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _harmIdMeta = const VerificationMeta('harmId');
  @override
  late final GeneratedColumn<int> harmId = GeneratedColumn<int>(
      'harm_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES harms (id)'));
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
      'person', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amendsTypeMeta =
      const VerificationMeta('amendsType');
  @override
  late final GeneratedColumn<String> amendsType = GeneratedColumn<String>(
      'amends_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Personal'));
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
      'plan', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _datePlannedMeta =
      const VerificationMeta('datePlanned');
  @override
  late final GeneratedColumn<DateTime> datePlanned = GeneratedColumn<DateTime>(
      'date_planned', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateCompletedMeta =
      const VerificationMeta('dateCompleted');
  @override
  late final GeneratedColumn<DateTime> dateCompleted =
      GeneratedColumn<DateTime>('date_completed', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        harmId,
        person,
        amendsType,
        plan,
        priority,
        status,
        datePlanned,
        dateCompleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'amends';
  @override
  VerificationContext validateIntegrity(Insertable<Amend> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('harm_id')) {
      context.handle(_harmIdMeta,
          harmId.isAcceptableOrUnknown(data['harm_id']!, _harmIdMeta));
    }
    if (data.containsKey('person')) {
      context.handle(_personMeta,
          person.isAcceptableOrUnknown(data['person']!, _personMeta));
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('amends_type')) {
      context.handle(
          _amendsTypeMeta,
          amendsType.isAcceptableOrUnknown(
              data['amends_type']!, _amendsTypeMeta));
    }
    if (data.containsKey('plan')) {
      context.handle(
          _planMeta, plan.isAcceptableOrUnknown(data['plan']!, _planMeta));
    } else if (isInserting) {
      context.missing(_planMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('date_planned')) {
      context.handle(
          _datePlannedMeta,
          datePlanned.isAcceptableOrUnknown(
              data['date_planned']!, _datePlannedMeta));
    } else if (isInserting) {
      context.missing(_datePlannedMeta);
    }
    if (data.containsKey('date_completed')) {
      context.handle(
          _dateCompletedMeta,
          dateCompleted.isAcceptableOrUnknown(
              data['date_completed']!, _dateCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Amend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Amend(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      harmId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}harm_id']),
      person: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person'])!,
      amendsType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amends_type'])!,
      plan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      datePlanned: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_planned'])!,
      dateCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_completed']),
    );
  }

  @override
  $AmendsTable createAlias(String alias) {
    return $AmendsTable(attachedDatabase, alias);
  }
}

class Amend extends DataClass implements Insertable<Amend> {
  final int id;
  final int? harmId;
  final String person;
  final String amendsType;
  final String plan;
  final int priority;
  final String status;
  final DateTime datePlanned;
  final DateTime? dateCompleted;
  const Amend(
      {required this.id,
      this.harmId,
      required this.person,
      required this.amendsType,
      required this.plan,
      required this.priority,
      required this.status,
      required this.datePlanned,
      this.dateCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || harmId != null) {
      map['harm_id'] = Variable<int>(harmId);
    }
    map['person'] = Variable<String>(person);
    map['amends_type'] = Variable<String>(amendsType);
    map['plan'] = Variable<String>(plan);
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    map['date_planned'] = Variable<DateTime>(datePlanned);
    if (!nullToAbsent || dateCompleted != null) {
      map['date_completed'] = Variable<DateTime>(dateCompleted);
    }
    return map;
  }

  AmendsCompanion toCompanion(bool nullToAbsent) {
    return AmendsCompanion(
      id: Value(id),
      harmId:
          harmId == null && nullToAbsent ? const Value.absent() : Value(harmId),
      person: Value(person),
      amendsType: Value(amendsType),
      plan: Value(plan),
      priority: Value(priority),
      status: Value(status),
      datePlanned: Value(datePlanned),
      dateCompleted: dateCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCompleted),
    );
  }

  factory Amend.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Amend(
      id: serializer.fromJson<int>(json['id']),
      harmId: serializer.fromJson<int?>(json['harmId']),
      person: serializer.fromJson<String>(json['person']),
      amendsType: serializer.fromJson<String>(json['amendsType']),
      plan: serializer.fromJson<String>(json['plan']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      datePlanned: serializer.fromJson<DateTime>(json['datePlanned']),
      dateCompleted: serializer.fromJson<DateTime?>(json['dateCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'harmId': serializer.toJson<int?>(harmId),
      'person': serializer.toJson<String>(person),
      'amendsType': serializer.toJson<String>(amendsType),
      'plan': serializer.toJson<String>(plan),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'datePlanned': serializer.toJson<DateTime>(datePlanned),
      'dateCompleted': serializer.toJson<DateTime?>(dateCompleted),
    };
  }

  Amend copyWith(
          {int? id,
          Value<int?> harmId = const Value.absent(),
          String? person,
          String? amendsType,
          String? plan,
          int? priority,
          String? status,
          DateTime? datePlanned,
          Value<DateTime?> dateCompleted = const Value.absent()}) =>
      Amend(
        id: id ?? this.id,
        harmId: harmId.present ? harmId.value : this.harmId,
        person: person ?? this.person,
        amendsType: amendsType ?? this.amendsType,
        plan: plan ?? this.plan,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        datePlanned: datePlanned ?? this.datePlanned,
        dateCompleted:
            dateCompleted.present ? dateCompleted.value : this.dateCompleted,
      );
  Amend copyWithCompanion(AmendsCompanion data) {
    return Amend(
      id: data.id.present ? data.id.value : this.id,
      harmId: data.harmId.present ? data.harmId.value : this.harmId,
      person: data.person.present ? data.person.value : this.person,
      amendsType:
          data.amendsType.present ? data.amendsType.value : this.amendsType,
      plan: data.plan.present ? data.plan.value : this.plan,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      datePlanned:
          data.datePlanned.present ? data.datePlanned.value : this.datePlanned,
      dateCompleted: data.dateCompleted.present
          ? data.dateCompleted.value
          : this.dateCompleted,
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
          ..write('datePlanned: $datePlanned, ')
          ..write('dateCompleted: $dateCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, harmId, person, amendsType, plan,
      priority, status, datePlanned, dateCompleted);
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
          other.datePlanned == this.datePlanned &&
          other.dateCompleted == this.dateCompleted);
}

class AmendsCompanion extends UpdateCompanion<Amend> {
  final Value<int> id;
  final Value<int?> harmId;
  final Value<String> person;
  final Value<String> amendsType;
  final Value<String> plan;
  final Value<int> priority;
  final Value<String> status;
  final Value<DateTime> datePlanned;
  final Value<DateTime?> dateCompleted;
  const AmendsCompanion({
    this.id = const Value.absent(),
    this.harmId = const Value.absent(),
    this.person = const Value.absent(),
    this.amendsType = const Value.absent(),
    this.plan = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.datePlanned = const Value.absent(),
    this.dateCompleted = const Value.absent(),
  });
  AmendsCompanion.insert({
    this.id = const Value.absent(),
    this.harmId = const Value.absent(),
    required String person,
    this.amendsType = const Value.absent(),
    required String plan,
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime datePlanned,
    this.dateCompleted = const Value.absent(),
  })  : person = Value(person),
        plan = Value(plan),
        datePlanned = Value(datePlanned);
  static Insertable<Amend> custom({
    Expression<int>? id,
    Expression<int>? harmId,
    Expression<String>? person,
    Expression<String>? amendsType,
    Expression<String>? plan,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<DateTime>? datePlanned,
    Expression<DateTime>? dateCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (harmId != null) 'harm_id': harmId,
      if (person != null) 'person': person,
      if (amendsType != null) 'amends_type': amendsType,
      if (plan != null) 'plan': plan,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (datePlanned != null) 'date_planned': datePlanned,
      if (dateCompleted != null) 'date_completed': dateCompleted,
    });
  }

  AmendsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? harmId,
      Value<String>? person,
      Value<String>? amendsType,
      Value<String>? plan,
      Value<int>? priority,
      Value<String>? status,
      Value<DateTime>? datePlanned,
      Value<DateTime?>? dateCompleted}) {
    return AmendsCompanion(
      id: id ?? this.id,
      harmId: harmId ?? this.harmId,
      person: person ?? this.person,
      amendsType: amendsType ?? this.amendsType,
      plan: plan ?? this.plan,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      datePlanned: datePlanned ?? this.datePlanned,
      dateCompleted: dateCompleted ?? this.dateCompleted,
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
      map['amends_type'] = Variable<String>(amendsType.value);
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
    if (datePlanned.present) {
      map['date_planned'] = Variable<DateTime>(datePlanned.value);
    }
    if (dateCompleted.present) {
      map['date_completed'] = Variable<DateTime>(dateCompleted.value);
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
          ..write('datePlanned: $datePlanned, ')
          ..write('dateCompleted: $dateCompleted')
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
  late final $MeditationsTable meditations = $MeditationsTable(this);
  late final $AmendsTable amends = $AmendsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [resentments, fears, harms, dailyReviews, meditations, amends];
}

typedef $$ResentmentsTableCreateCompanionBuilder = ResentmentsCompanion
    Function({
  Value<int> id,
  required String person,
  required String cause,
  required String affects,
  required String myPart,
  required DateTime createdAt,
});
typedef $$ResentmentsTableUpdateCompanionBuilder = ResentmentsCompanion
    Function({
  Value<int> id,
  Value<String> person,
  Value<String> cause,
  Value<String> affects,
  Value<String> myPart,
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cause => $composableBuilder(
      column: $table.cause, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get affects => $composableBuilder(
      column: $table.affects, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get myPart => $composableBuilder(
      column: $table.myPart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cause => $composableBuilder(
      column: $table.cause, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get affects => $composableBuilder(
      column: $table.affects, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get myPart => $composableBuilder(
      column: $table.myPart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ResentmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ResentmentsTable,
    Resentment,
    $$ResentmentsTableFilterComposer,
    $$ResentmentsTableOrderingComposer,
    $$ResentmentsTableAnnotationComposer,
    $$ResentmentsTableCreateCompanionBuilder,
    $$ResentmentsTableUpdateCompanionBuilder,
    (Resentment, BaseReferences<_$AppDatabase, $ResentmentsTable, Resentment>),
    Resentment,
    PrefetchHooks Function()> {
  $$ResentmentsTableTableManager(_$AppDatabase db, $ResentmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResentmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResentmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResentmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> person = const Value.absent(),
            Value<String> cause = const Value.absent(),
            Value<String> affects = const Value.absent(),
            Value<String> myPart = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ResentmentsCompanion(
            id: id,
            person: person,
            cause: cause,
            affects: affects,
            myPart: myPart,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String person,
            required String cause,
            required String affects,
            required String myPart,
            required DateTime createdAt,
          }) =>
              ResentmentsCompanion.insert(
            id: id,
            person: person,
            cause: cause,
            affects: affects,
            myPart: myPart,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ResentmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ResentmentsTable,
    Resentment,
    $$ResentmentsTableFilterComposer,
    $$ResentmentsTableOrderingComposer,
    $$ResentmentsTableAnnotationComposer,
    $$ResentmentsTableCreateCompanionBuilder,
    $$ResentmentsTableUpdateCompanionBuilder,
    (Resentment, BaseReferences<_$AppDatabase, $ResentmentsTable, Resentment>),
    Resentment,
    PrefetchHooks Function()>;
typedef $$FearsTableCreateCompanionBuilder = FearsCompanion Function({
  Value<int> id,
  required String subject,
  required String why,
  required String myPart,
  required DateTime createdAt,
});
typedef $$FearsTableUpdateCompanionBuilder = FearsCompanion Function({
  Value<int> id,
  Value<String> subject,
  Value<String> why,
  Value<String> myPart,
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get why => $composableBuilder(
      column: $table.why, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get myPart => $composableBuilder(
      column: $table.myPart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get why => $composableBuilder(
      column: $table.why, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get myPart => $composableBuilder(
      column: $table.myPart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FearsTableTableManager extends RootTableManager<
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
    PrefetchHooks Function()> {
  $$FearsTableTableManager(_$AppDatabase db, $FearsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FearsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FearsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FearsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> why = const Value.absent(),
            Value<String> myPart = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FearsCompanion(
            id: id,
            subject: subject,
            why: why,
            myPart: myPart,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String subject,
            required String why,
            required String myPart,
            required DateTime createdAt,
          }) =>
              FearsCompanion.insert(
            id: id,
            subject: subject,
            why: why,
            myPart: myPart,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FearsTableProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function()>;
typedef $$HarmsTableCreateCompanionBuilder = HarmsCompanion Function({
  Value<int> id,
  required String person,
  required String conduct,
  required String myPart,
  Value<String?> amendsPlan,
  Value<bool> isAmendsDone,
  Value<DateTime?> dateAmendsDone,
  required DateTime createdAt,
});
typedef $$HarmsTableUpdateCompanionBuilder = HarmsCompanion Function({
  Value<int> id,
  Value<String> person,
  Value<String> conduct,
  Value<String> myPart,
  Value<String?> amendsPlan,
  Value<bool> isAmendsDone,
  Value<DateTime?> dateAmendsDone,
  Value<DateTime> createdAt,
});

final class $$HarmsTableReferences
    extends BaseReferences<_$AppDatabase, $HarmsTable, Harm> {
  $$HarmsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AmendsTable, List<Amend>> _amendsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.amends,
          aliasName: $_aliasNameGenerator(db.harms.id, db.amends.harmId));

  $$AmendsTableProcessedTableManager get amendsRefs {
    final manager = $$AmendsTableTableManager($_db, $_db.amends)
        .filter((f) => f.harmId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_amendsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conduct => $composableBuilder(
      column: $table.conduct, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get myPart => $composableBuilder(
      column: $table.myPart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amendsPlan => $composableBuilder(
      column: $table.amendsPlan, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAmendsDone => $composableBuilder(
      column: $table.isAmendsDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateAmendsDone => $composableBuilder(
      column: $table.dateAmendsDone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> amendsRefs(
      Expression<bool> Function($$AmendsTableFilterComposer f) f) {
    final $$AmendsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.amends,
        getReferencedColumn: (t) => t.harmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AmendsTableFilterComposer(
              $db: $db,
              $table: $db.amends,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conduct => $composableBuilder(
      column: $table.conduct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get myPart => $composableBuilder(
      column: $table.myPart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amendsPlan => $composableBuilder(
      column: $table.amendsPlan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAmendsDone => $composableBuilder(
      column: $table.isAmendsDone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateAmendsDone => $composableBuilder(
      column: $table.dateAmendsDone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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
      column: $table.amendsPlan, builder: (column) => column);

  GeneratedColumn<bool> get isAmendsDone => $composableBuilder(
      column: $table.isAmendsDone, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAmendsDone => $composableBuilder(
      column: $table.dateAmendsDone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> amendsRefs<T extends Object>(
      Expression<T> Function($$AmendsTableAnnotationComposer a) f) {
    final $$AmendsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.amends,
        getReferencedColumn: (t) => t.harmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AmendsTableAnnotationComposer(
              $db: $db,
              $table: $db.amends,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HarmsTableTableManager extends RootTableManager<
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
    PrefetchHooks Function({bool amendsRefs})> {
  $$HarmsTableTableManager(_$AppDatabase db, $HarmsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> person = const Value.absent(),
            Value<String> conduct = const Value.absent(),
            Value<String> myPart = const Value.absent(),
            Value<String?> amendsPlan = const Value.absent(),
            Value<bool> isAmendsDone = const Value.absent(),
            Value<DateTime?> dateAmendsDone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              HarmsCompanion(
            id: id,
            person: person,
            conduct: conduct,
            myPart: myPart,
            amendsPlan: amendsPlan,
            isAmendsDone: isAmendsDone,
            dateAmendsDone: dateAmendsDone,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String person,
            required String conduct,
            required String myPart,
            Value<String?> amendsPlan = const Value.absent(),
            Value<bool> isAmendsDone = const Value.absent(),
            Value<DateTime?> dateAmendsDone = const Value.absent(),
            required DateTime createdAt,
          }) =>
              HarmsCompanion.insert(
            id: id,
            person: person,
            conduct: conduct,
            myPart: myPart,
            amendsPlan: amendsPlan,
            isAmendsDone: isAmendsDone,
            dateAmendsDone: dateAmendsDone,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$HarmsTableReferences(db, table, e)))
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
                        referencedTable:
                            $$HarmsTableReferences._amendsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HarmsTableReferences(db, table, p0).amendsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.harmId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$HarmsTableProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function({bool amendsRefs})>;
typedef $$DailyReviewsTableCreateCompanionBuilder = DailyReviewsCompanion
    Function({
  Value<int> id,
  required DateTime date,
  Value<bool> wasResentful,
  Value<bool> wasSelfish,
  Value<bool> wasDishonest,
  Value<bool> wasAfraid,
  Value<String?> notes,
  Value<String?> gratitude,
  required DateTime createdAt,
});
typedef $$DailyReviewsTableUpdateCompanionBuilder = DailyReviewsCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<bool> wasResentful,
  Value<bool> wasSelfish,
  Value<bool> wasDishonest,
  Value<bool> wasAfraid,
  Value<String?> notes,
  Value<String?> gratitude,
  Value<DateTime> createdAt,
});

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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasResentful => $composableBuilder(
      column: $table.wasResentful, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasSelfish => $composableBuilder(
      column: $table.wasSelfish, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasDishonest => $composableBuilder(
      column: $table.wasDishonest, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasAfraid => $composableBuilder(
      column: $table.wasAfraid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gratitude => $composableBuilder(
      column: $table.gratitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasResentful => $composableBuilder(
      column: $table.wasResentful,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasSelfish => $composableBuilder(
      column: $table.wasSelfish, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasDishonest => $composableBuilder(
      column: $table.wasDishonest,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasAfraid => $composableBuilder(
      column: $table.wasAfraid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gratitude => $composableBuilder(
      column: $table.gratitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
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
      column: $table.wasResentful, builder: (column) => column);

  GeneratedColumn<bool> get wasSelfish => $composableBuilder(
      column: $table.wasSelfish, builder: (column) => column);

  GeneratedColumn<bool> get wasDishonest => $composableBuilder(
      column: $table.wasDishonest, builder: (column) => column);

  GeneratedColumn<bool> get wasAfraid =>
      $composableBuilder(column: $table.wasAfraid, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get gratitude =>
      $composableBuilder(column: $table.gratitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyReviewsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyReviewsTable,
    DailyReview,
    $$DailyReviewsTableFilterComposer,
    $$DailyReviewsTableOrderingComposer,
    $$DailyReviewsTableAnnotationComposer,
    $$DailyReviewsTableCreateCompanionBuilder,
    $$DailyReviewsTableUpdateCompanionBuilder,
    (
      DailyReview,
      BaseReferences<_$AppDatabase, $DailyReviewsTable, DailyReview>
    ),
    DailyReview,
    PrefetchHooks Function()> {
  $$DailyReviewsTableTableManager(_$AppDatabase db, $DailyReviewsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> wasResentful = const Value.absent(),
            Value<bool> wasSelfish = const Value.absent(),
            Value<bool> wasDishonest = const Value.absent(),
            Value<bool> wasAfraid = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> gratitude = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DailyReviewsCompanion(
            id: id,
            date: date,
            wasResentful: wasResentful,
            wasSelfish: wasSelfish,
            wasDishonest: wasDishonest,
            wasAfraid: wasAfraid,
            notes: notes,
            gratitude: gratitude,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            Value<bool> wasResentful = const Value.absent(),
            Value<bool> wasSelfish = const Value.absent(),
            Value<bool> wasDishonest = const Value.absent(),
            Value<bool> wasAfraid = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> gratitude = const Value.absent(),
            required DateTime createdAt,
          }) =>
              DailyReviewsCompanion.insert(
            id: id,
            date: date,
            wasResentful: wasResentful,
            wasSelfish: wasSelfish,
            wasDishonest: wasDishonest,
            wasAfraid: wasAfraid,
            notes: notes,
            gratitude: gratitude,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyReviewsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyReviewsTable,
    DailyReview,
    $$DailyReviewsTableFilterComposer,
    $$DailyReviewsTableOrderingComposer,
    $$DailyReviewsTableAnnotationComposer,
    $$DailyReviewsTableCreateCompanionBuilder,
    $$DailyReviewsTableUpdateCompanionBuilder,
    (
      DailyReview,
      BaseReferences<_$AppDatabase, $DailyReviewsTable, DailyReview>
    ),
    DailyReview,
    PrefetchHooks Function()>;
typedef $$MeditationsTableCreateCompanionBuilder = MeditationsCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required String focus,
  Value<String?> prayerRequest,
  required DateTime createdAt,
});
typedef $$MeditationsTableUpdateCompanionBuilder = MeditationsCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> focus,
  Value<String?> prayerRequest,
  Value<DateTime> createdAt,
});

class $$MeditationsTableFilterComposer
    extends Composer<_$AppDatabase, $MeditationsTable> {
  $$MeditationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get focus => $composableBuilder(
      column: $table.focus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prayerRequest => $composableBuilder(
      column: $table.prayerRequest, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MeditationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeditationsTable> {
  $$MeditationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get focus => $composableBuilder(
      column: $table.focus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prayerRequest => $composableBuilder(
      column: $table.prayerRequest,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MeditationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeditationsTable> {
  $$MeditationsTableAnnotationComposer({
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

  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<String> get prayerRequest => $composableBuilder(
      column: $table.prayerRequest, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MeditationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeditationsTable,
    Meditation,
    $$MeditationsTableFilterComposer,
    $$MeditationsTableOrderingComposer,
    $$MeditationsTableAnnotationComposer,
    $$MeditationsTableCreateCompanionBuilder,
    $$MeditationsTableUpdateCompanionBuilder,
    (Meditation, BaseReferences<_$AppDatabase, $MeditationsTable, Meditation>),
    Meditation,
    PrefetchHooks Function()> {
  $$MeditationsTableTableManager(_$AppDatabase db, $MeditationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeditationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeditationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeditationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> focus = const Value.absent(),
            Value<String?> prayerRequest = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MeditationsCompanion(
            id: id,
            date: date,
            focus: focus,
            prayerRequest: prayerRequest,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String focus,
            Value<String?> prayerRequest = const Value.absent(),
            required DateTime createdAt,
          }) =>
              MeditationsCompanion.insert(
            id: id,
            date: date,
            focus: focus,
            prayerRequest: prayerRequest,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MeditationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MeditationsTable,
    Meditation,
    $$MeditationsTableFilterComposer,
    $$MeditationsTableOrderingComposer,
    $$MeditationsTableAnnotationComposer,
    $$MeditationsTableCreateCompanionBuilder,
    $$MeditationsTableUpdateCompanionBuilder,
    (Meditation, BaseReferences<_$AppDatabase, $MeditationsTable, Meditation>),
    Meditation,
    PrefetchHooks Function()>;
typedef $$AmendsTableCreateCompanionBuilder = AmendsCompanion Function({
  Value<int> id,
  Value<int?> harmId,
  required String person,
  Value<String> amendsType,
  required String plan,
  Value<int> priority,
  Value<String> status,
  required DateTime datePlanned,
  Value<DateTime?> dateCompleted,
});
typedef $$AmendsTableUpdateCompanionBuilder = AmendsCompanion Function({
  Value<int> id,
  Value<int?> harmId,
  Value<String> person,
  Value<String> amendsType,
  Value<String> plan,
  Value<int> priority,
  Value<String> status,
  Value<DateTime> datePlanned,
  Value<DateTime?> dateCompleted,
});

final class $$AmendsTableReferences
    extends BaseReferences<_$AppDatabase, $AmendsTable, Amend> {
  $$AmendsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HarmsTable _harmIdTable(_$AppDatabase db) =>
      db.harms.createAlias($_aliasNameGenerator(db.amends.harmId, db.harms.id));

  $$HarmsTableProcessedTableManager? get harmId {
    final $_column = $_itemColumn<int>('harm_id');
    if ($_column == null) return null;
    final manager = $$HarmsTableTableManager($_db, $_db.harms)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_harmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amendsType => $composableBuilder(
      column: $table.amendsType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get datePlanned => $composableBuilder(
      column: $table.datePlanned, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateCompleted => $composableBuilder(
      column: $table.dateCompleted, builder: (column) => ColumnFilters(column));

  $$HarmsTableFilterComposer get harmId {
    final $$HarmsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.harmId,
        referencedTable: $db.harms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HarmsTableFilterComposer(
              $db: $db,
              $table: $db.harms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amendsType => $composableBuilder(
      column: $table.amendsType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get datePlanned => $composableBuilder(
      column: $table.datePlanned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateCompleted => $composableBuilder(
      column: $table.dateCompleted,
      builder: (column) => ColumnOrderings(column));

  $$HarmsTableOrderingComposer get harmId {
    final $$HarmsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.harmId,
        referencedTable: $db.harms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HarmsTableOrderingComposer(
              $db: $db,
              $table: $db.harms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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

  GeneratedColumn<String> get amendsType => $composableBuilder(
      column: $table.amendsType, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get datePlanned => $composableBuilder(
      column: $table.datePlanned, builder: (column) => column);

  GeneratedColumn<DateTime> get dateCompleted => $composableBuilder(
      column: $table.dateCompleted, builder: (column) => column);

  $$HarmsTableAnnotationComposer get harmId {
    final $$HarmsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.harmId,
        referencedTable: $db.harms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HarmsTableAnnotationComposer(
              $db: $db,
              $table: $db.harms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AmendsTableTableManager extends RootTableManager<
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
    PrefetchHooks Function({bool harmId})> {
  $$AmendsTableTableManager(_$AppDatabase db, $AmendsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AmendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AmendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AmendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> harmId = const Value.absent(),
            Value<String> person = const Value.absent(),
            Value<String> amendsType = const Value.absent(),
            Value<String> plan = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> datePlanned = const Value.absent(),
            Value<DateTime?> dateCompleted = const Value.absent(),
          }) =>
              AmendsCompanion(
            id: id,
            harmId: harmId,
            person: person,
            amendsType: amendsType,
            plan: plan,
            priority: priority,
            status: status,
            datePlanned: datePlanned,
            dateCompleted: dateCompleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> harmId = const Value.absent(),
            required String person,
            Value<String> amendsType = const Value.absent(),
            required String plan,
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime datePlanned,
            Value<DateTime?> dateCompleted = const Value.absent(),
          }) =>
              AmendsCompanion.insert(
            id: id,
            harmId: harmId,
            person: person,
            amendsType: amendsType,
            plan: plan,
            priority: priority,
            status: status,
            datePlanned: datePlanned,
            dateCompleted: dateCompleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AmendsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({harmId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (harmId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.harmId,
                    referencedTable: $$AmendsTableReferences._harmIdTable(db),
                    referencedColumn:
                        $$AmendsTableReferences._harmIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AmendsTableProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function({bool harmId})>;

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
  $$MeditationsTableTableManager get meditations =>
      $$MeditationsTableTableManager(_db, _db.meditations);
  $$AmendsTableTableManager get amends =>
      $$AmendsTableTableManager(_db, _db.amends);
}
