// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProgressRecordsTable extends ProgressRecords
    with TableInfo<$ProgressRecordsTable, ProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _fullXpAwardedMeta = const VerificationMeta(
    'fullXpAwarded',
  );
  @override
  late final GeneratedColumn<bool> fullXpAwarded = GeneratedColumn<bool>(
    'full_xp_awarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("full_xp_awarded" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPracticeXpDateMeta =
      const VerificationMeta('lastPracticeXpDate');
  @override
  late final GeneratedColumn<DateTime> lastPracticeXpDate =
      GeneratedColumn<DateTime>(
        'last_practice_xp_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    isCompleted,
    xpEarned,
    completedAt,
    fullXpAwarded,
    bestScore,
    lastPracticeXpDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isCompletedMeta);
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    } else if (isInserting) {
      context.missing(_xpEarnedMeta);
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
    if (data.containsKey('full_xp_awarded')) {
      context.handle(
        _fullXpAwardedMeta,
        fullXpAwarded.isAcceptableOrUnknown(
          data['full_xp_awarded']!,
          _fullXpAwardedMeta,
        ),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('last_practice_xp_date')) {
      context.handle(
        _lastPracticeXpDateMeta,
        lastPracticeXpDate.isAcceptableOrUnknown(
          data['last_practice_xp_date']!,
          _lastPracticeXpDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      fullXpAwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}full_xp_awarded'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      lastPracticeXpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_practice_xp_date'],
      ),
    );
  }

  @override
  $ProgressRecordsTable createAlias(String alias) {
    return $ProgressRecordsTable(attachedDatabase, alias);
  }
}

class ProgressRow extends DataClass implements Insertable<ProgressRow> {
  final int id;
  final String lessonId;
  final bool isCompleted;
  final int xpEarned;
  final DateTime completedAt;

  /// Whether full lesson XP has already been awarded. Defaults to `true` so
  /// rows migrated from schema v1 (which were created only on first
  /// completion) keep their already-earned status.
  final bool fullXpAwarded;

  /// Best first-try accuracy across all runs, as an integer percentage 0–100.
  final int bestScore;

  /// Calendar day practice XP was last awarded for this lesson during review.
  final DateTime? lastPracticeXpDate;
  const ProgressRow({
    required this.id,
    required this.lessonId,
    required this.isCompleted,
    required this.xpEarned,
    required this.completedAt,
    required this.fullXpAwarded,
    required this.bestScore,
    this.lastPracticeXpDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['xp_earned'] = Variable<int>(xpEarned);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['full_xp_awarded'] = Variable<bool>(fullXpAwarded);
    map['best_score'] = Variable<int>(bestScore);
    if (!nullToAbsent || lastPracticeXpDate != null) {
      map['last_practice_xp_date'] = Variable<DateTime>(lastPracticeXpDate);
    }
    return map;
  }

  ProgressRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProgressRecordsCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      isCompleted: Value(isCompleted),
      xpEarned: Value(xpEarned),
      completedAt: Value(completedAt),
      fullXpAwarded: Value(fullXpAwarded),
      bestScore: Value(bestScore),
      lastPracticeXpDate: lastPracticeXpDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPracticeXpDate),
    );
  }

  factory ProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressRow(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      fullXpAwarded: serializer.fromJson<bool>(json['fullXpAwarded']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      lastPracticeXpDate: serializer.fromJson<DateTime?>(
        json['lastPracticeXpDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'fullXpAwarded': serializer.toJson<bool>(fullXpAwarded),
      'bestScore': serializer.toJson<int>(bestScore),
      'lastPracticeXpDate': serializer.toJson<DateTime?>(lastPracticeXpDate),
    };
  }

  ProgressRow copyWith({
    int? id,
    String? lessonId,
    bool? isCompleted,
    int? xpEarned,
    DateTime? completedAt,
    bool? fullXpAwarded,
    int? bestScore,
    Value<DateTime?> lastPracticeXpDate = const Value.absent(),
  }) => ProgressRow(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    isCompleted: isCompleted ?? this.isCompleted,
    xpEarned: xpEarned ?? this.xpEarned,
    completedAt: completedAt ?? this.completedAt,
    fullXpAwarded: fullXpAwarded ?? this.fullXpAwarded,
    bestScore: bestScore ?? this.bestScore,
    lastPracticeXpDate: lastPracticeXpDate.present
        ? lastPracticeXpDate.value
        : this.lastPracticeXpDate,
  );
  ProgressRow copyWithCompanion(ProgressRecordsCompanion data) {
    return ProgressRow(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      fullXpAwarded: data.fullXpAwarded.present
          ? data.fullXpAwarded.value
          : this.fullXpAwarded,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      lastPracticeXpDate: data.lastPracticeXpDate.present
          ? data.lastPracticeXpDate.value
          : this.lastPracticeXpDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressRow(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('completedAt: $completedAt, ')
          ..write('fullXpAwarded: $fullXpAwarded, ')
          ..write('bestScore: $bestScore, ')
          ..write('lastPracticeXpDate: $lastPracticeXpDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    isCompleted,
    xpEarned,
    completedAt,
    fullXpAwarded,
    bestScore,
    lastPracticeXpDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressRow &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.isCompleted == this.isCompleted &&
          other.xpEarned == this.xpEarned &&
          other.completedAt == this.completedAt &&
          other.fullXpAwarded == this.fullXpAwarded &&
          other.bestScore == this.bestScore &&
          other.lastPracticeXpDate == this.lastPracticeXpDate);
}

class ProgressRecordsCompanion extends UpdateCompanion<ProgressRow> {
  final Value<int> id;
  final Value<String> lessonId;
  final Value<bool> isCompleted;
  final Value<int> xpEarned;
  final Value<DateTime> completedAt;
  final Value<bool> fullXpAwarded;
  final Value<int> bestScore;
  final Value<DateTime?> lastPracticeXpDate;
  const ProgressRecordsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.fullXpAwarded = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.lastPracticeXpDate = const Value.absent(),
  });
  ProgressRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String lessonId,
    required bool isCompleted,
    required int xpEarned,
    required DateTime completedAt,
    this.fullXpAwarded = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.lastPracticeXpDate = const Value.absent(),
  }) : lessonId = Value(lessonId),
       isCompleted = Value(isCompleted),
       xpEarned = Value(xpEarned),
       completedAt = Value(completedAt);
  static Insertable<ProgressRow> custom({
    Expression<int>? id,
    Expression<String>? lessonId,
    Expression<bool>? isCompleted,
    Expression<int>? xpEarned,
    Expression<DateTime>? completedAt,
    Expression<bool>? fullXpAwarded,
    Expression<int>? bestScore,
    Expression<DateTime>? lastPracticeXpDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (completedAt != null) 'completed_at': completedAt,
      if (fullXpAwarded != null) 'full_xp_awarded': fullXpAwarded,
      if (bestScore != null) 'best_score': bestScore,
      if (lastPracticeXpDate != null)
        'last_practice_xp_date': lastPracticeXpDate,
    });
  }

  ProgressRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? lessonId,
    Value<bool>? isCompleted,
    Value<int>? xpEarned,
    Value<DateTime>? completedAt,
    Value<bool>? fullXpAwarded,
    Value<int>? bestScore,
    Value<DateTime?>? lastPracticeXpDate,
  }) {
    return ProgressRecordsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      isCompleted: isCompleted ?? this.isCompleted,
      xpEarned: xpEarned ?? this.xpEarned,
      completedAt: completedAt ?? this.completedAt,
      fullXpAwarded: fullXpAwarded ?? this.fullXpAwarded,
      bestScore: bestScore ?? this.bestScore,
      lastPracticeXpDate: lastPracticeXpDate ?? this.lastPracticeXpDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (fullXpAwarded.present) {
      map['full_xp_awarded'] = Variable<bool>(fullXpAwarded.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (lastPracticeXpDate.present) {
      map['last_practice_xp_date'] = Variable<DateTime>(
        lastPracticeXpDate.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressRecordsCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('completedAt: $completedAt, ')
          ..write('fullXpAwarded: $fullXpAwarded, ')
          ..write('bestScore: $bestScore, ')
          ..write('lastPracticeXpDate: $lastPracticeXpDate')
          ..write(')'))
        .toString();
  }
}

class $CardRecordsTable extends CardRecords
    with TableInfo<$CardRecordsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cardId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $CardRecordsTable createAlias(String alias) {
    return $CardRecordsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final int id;
  final String cardId;
  final DateTime unlockedAt;
  const CardRow({
    required this.id,
    required this.cardId,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  CardRecordsCompanion toCompanion(bool nullToAbsent) {
    return CardRecordsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  CardRow copyWith({int? id, String? cardId, DateTime? unlockedAt}) => CardRow(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  CardRow copyWithCompanion(CardRecordsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.unlockedAt == this.unlockedAt);
}

class CardRecordsCompanion extends UpdateCompanion<CardRow> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<DateTime> unlockedAt;
  const CardRecordsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  CardRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required DateTime unlockedAt,
  }) : cardId = Value(cardId),
       unlockedAt = Value(unlockedAt);
  static Insertable<CardRow> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  CardRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<DateTime>? unlockedAt,
  }) {
    return CardRecordsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardRecordsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hapticsEnabledMeta = const VerificationMeta(
    'hapticsEnabled',
  );
  @override
  late final GeneratedColumn<bool> hapticsEnabled = GeneratedColumn<bool>(
    'haptics_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("haptics_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActivityDateMeta = const VerificationMeta(
    'lastActivityDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivityDate =
      GeneratedColumn<DateTime>(
        'last_activity_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _onboardingGoalMeta = const VerificationMeta(
    'onboardingGoal',
  );
  @override
  late final GeneratedColumn<String> onboardingGoal = GeneratedColumn<String>(
    'onboarding_goal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardingBrewerMeta = const VerificationMeta(
    'onboardingBrewer',
  );
  @override
  late final GeneratedColumn<String> onboardingBrewer = GeneratedColumn<String>(
    'onboarding_brewer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hapticsEnabled,
    soundEnabled,
    totalXp,
    streakDays,
    lastActivityDate,
    onboardingCompleted,
    onboardingGoal,
    onboardingBrewer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('haptics_enabled')) {
      context.handle(
        _hapticsEnabledMeta,
        hapticsEnabled.isAcceptableOrUnknown(
          data['haptics_enabled']!,
          _hapticsEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hapticsEnabledMeta);
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soundEnabledMeta);
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    } else if (isInserting) {
      context.missing(_totalXpMeta);
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_streakDaysMeta);
    }
    if (data.containsKey('last_activity_date')) {
      context.handle(
        _lastActivityDateMeta,
        lastActivityDate.isAcceptableOrUnknown(
          data['last_activity_date']!,
          _lastActivityDateMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_goal')) {
      context.handle(
        _onboardingGoalMeta,
        onboardingGoal.isAcceptableOrUnknown(
          data['onboarding_goal']!,
          _onboardingGoalMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_brewer')) {
      context.handle(
        _onboardingBrewerMeta,
        onboardingBrewer.isAcceptableOrUnknown(
          data['onboarding_brewer']!,
          _onboardingBrewerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      hapticsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}haptics_enabled'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      lastActivityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity_date'],
      ),
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      onboardingGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onboarding_goal'],
      ),
      onboardingBrewer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}onboarding_brewer'],
      ),
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int id;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final int totalXp;
  final int streakDays;
  final DateTime? lastActivityDate;

  /// Whether the user has completed the post-install onboarding flow.
  /// Defaults to `false` so rows migrated from schema v2 force the gate.
  final bool onboardingCompleted;

  /// User-selected onboarding goal (e.g. "brew_better"). Nullable so an
  /// in-progress install does not coerce a value.
  final String? onboardingGoal;

  /// User-selected brewer (e.g. "v60", "aeropress", "not_sure"). Nullable.
  final String? onboardingBrewer;
  const SettingsRow({
    required this.id,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.totalXp,
    required this.streakDays,
    this.lastActivityDate,
    required this.onboardingCompleted,
    this.onboardingGoal,
    this.onboardingBrewer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['haptics_enabled'] = Variable<bool>(hapticsEnabled);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['total_xp'] = Variable<int>(totalXp);
    map['streak_days'] = Variable<int>(streakDays);
    if (!nullToAbsent || lastActivityDate != null) {
      map['last_activity_date'] = Variable<DateTime>(lastActivityDate);
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || onboardingGoal != null) {
      map['onboarding_goal'] = Variable<String>(onboardingGoal);
    }
    if (!nullToAbsent || onboardingBrewer != null) {
      map['onboarding_brewer'] = Variable<String>(onboardingBrewer);
    }
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      hapticsEnabled: Value(hapticsEnabled),
      soundEnabled: Value(soundEnabled),
      totalXp: Value(totalXp),
      streakDays: Value(streakDays),
      lastActivityDate: lastActivityDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivityDate),
      onboardingCompleted: Value(onboardingCompleted),
      onboardingGoal: onboardingGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingGoal),
      onboardingBrewer: onboardingBrewer == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingBrewer),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      hapticsEnabled: serializer.fromJson<bool>(json['hapticsEnabled']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      lastActivityDate: serializer.fromJson<DateTime?>(
        json['lastActivityDate'],
      ),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      onboardingGoal: serializer.fromJson<String?>(json['onboardingGoal']),
      onboardingBrewer: serializer.fromJson<String?>(json['onboardingBrewer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hapticsEnabled': serializer.toJson<bool>(hapticsEnabled),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'totalXp': serializer.toJson<int>(totalXp),
      'streakDays': serializer.toJson<int>(streakDays),
      'lastActivityDate': serializer.toJson<DateTime?>(lastActivityDate),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'onboardingGoal': serializer.toJson<String?>(onboardingGoal),
      'onboardingBrewer': serializer.toJson<String?>(onboardingBrewer),
    };
  }

  SettingsRow copyWith({
    int? id,
    bool? hapticsEnabled,
    bool? soundEnabled,
    int? totalXp,
    int? streakDays,
    Value<DateTime?> lastActivityDate = const Value.absent(),
    bool? onboardingCompleted,
    Value<String?> onboardingGoal = const Value.absent(),
    Value<String?> onboardingBrewer = const Value.absent(),
  }) => SettingsRow(
    id: id ?? this.id,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    totalXp: totalXp ?? this.totalXp,
    streakDays: streakDays ?? this.streakDays,
    lastActivityDate: lastActivityDate.present
        ? lastActivityDate.value
        : this.lastActivityDate,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    onboardingGoal: onboardingGoal.present
        ? onboardingGoal.value
        : this.onboardingGoal,
    onboardingBrewer: onboardingBrewer.present
        ? onboardingBrewer.value
        : this.onboardingBrewer,
  );
  SettingsRow copyWithCompanion(UserSettingsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      hapticsEnabled: data.hapticsEnabled.present
          ? data.hapticsEnabled.value
          : this.hapticsEnabled,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      lastActivityDate: data.lastActivityDate.present
          ? data.lastActivityDate.value
          : this.lastActivityDate,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      onboardingGoal: data.onboardingGoal.present
          ? data.onboardingGoal.value
          : this.onboardingGoal,
      onboardingBrewer: data.onboardingBrewer.present
          ? data.onboardingBrewer.value
          : this.onboardingBrewer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('totalXp: $totalXp, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActivityDate: $lastActivityDate, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingGoal: $onboardingGoal, ')
          ..write('onboardingBrewer: $onboardingBrewer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hapticsEnabled,
    soundEnabled,
    totalXp,
    streakDays,
    lastActivityDate,
    onboardingCompleted,
    onboardingGoal,
    onboardingBrewer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.hapticsEnabled == this.hapticsEnabled &&
          other.soundEnabled == this.soundEnabled &&
          other.totalXp == this.totalXp &&
          other.streakDays == this.streakDays &&
          other.lastActivityDate == this.lastActivityDate &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.onboardingGoal == this.onboardingGoal &&
          other.onboardingBrewer == this.onboardingBrewer);
}

class UserSettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<bool> hapticsEnabled;
  final Value<bool> soundEnabled;
  final Value<int> totalXp;
  final Value<int> streakDays;
  final Value<DateTime?> lastActivityDate;
  final Value<bool> onboardingCompleted;
  final Value<String?> onboardingGoal;
  final Value<String?> onboardingBrewer;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActivityDate = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingGoal = const Value.absent(),
    this.onboardingBrewer = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    required bool hapticsEnabled,
    required bool soundEnabled,
    required int totalXp,
    required int streakDays,
    this.lastActivityDate = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingGoal = const Value.absent(),
    this.onboardingBrewer = const Value.absent(),
  }) : hapticsEnabled = Value(hapticsEnabled),
       soundEnabled = Value(soundEnabled),
       totalXp = Value(totalXp),
       streakDays = Value(streakDays);
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<bool>? hapticsEnabled,
    Expression<bool>? soundEnabled,
    Expression<int>? totalXp,
    Expression<int>? streakDays,
    Expression<DateTime>? lastActivityDate,
    Expression<bool>? onboardingCompleted,
    Expression<String>? onboardingGoal,
    Expression<String>? onboardingBrewer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (totalXp != null) 'total_xp': totalXp,
      if (streakDays != null) 'streak_days': streakDays,
      if (lastActivityDate != null) 'last_activity_date': lastActivityDate,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (onboardingGoal != null) 'onboarding_goal': onboardingGoal,
      if (onboardingBrewer != null) 'onboarding_brewer': onboardingBrewer,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? hapticsEnabled,
    Value<bool>? soundEnabled,
    Value<int>? totalXp,
    Value<int>? streakDays,
    Value<DateTime?>? lastActivityDate,
    Value<bool>? onboardingCompleted,
    Value<String?>? onboardingGoal,
    Value<String?>? onboardingBrewer,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingGoal: onboardingGoal ?? this.onboardingGoal,
      onboardingBrewer: onboardingBrewer ?? this.onboardingBrewer,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hapticsEnabled.present) {
      map['haptics_enabled'] = Variable<bool>(hapticsEnabled.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (lastActivityDate.present) {
      map['last_activity_date'] = Variable<DateTime>(lastActivityDate.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (onboardingGoal.present) {
      map['onboarding_goal'] = Variable<String>(onboardingGoal.value);
    }
    if (onboardingBrewer.present) {
      map['onboarding_brewer'] = Variable<String>(onboardingBrewer.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('totalXp: $totalXp, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActivityDate: $lastActivityDate, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingGoal: $onboardingGoal, ')
          ..write('onboardingBrewer: $onboardingBrewer')
          ..write(')'))
        .toString();
  }
}

class $ModuleProgressRecordsTable extends ModuleProgressRecords
    with TableInfo<$ModuleProgressRecordsTable, ModuleProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModuleProgressRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _moduleXpAwardedMeta = const VerificationMeta(
    'moduleXpAwarded',
  );
  @override
  late final GeneratedColumn<bool> moduleXpAwarded = GeneratedColumn<bool>(
    'module_xp_awarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("module_xp_awarded" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, moduleId, moduleXpAwarded];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_progress_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModuleProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('module_xp_awarded')) {
      context.handle(
        _moduleXpAwardedMeta,
        moduleXpAwarded.isAcceptableOrUnknown(
          data['module_xp_awarded']!,
          _moduleXpAwardedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_moduleXpAwardedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModuleProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleProgressRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      moduleXpAwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}module_xp_awarded'],
      )!,
    );
  }

  @override
  $ModuleProgressRecordsTable createAlias(String alias) {
    return $ModuleProgressRecordsTable(attachedDatabase, alias);
  }
}

class ModuleProgressRow extends DataClass
    implements Insertable<ModuleProgressRow> {
  final int id;
  final String moduleId;
  final bool moduleXpAwarded;
  const ModuleProgressRow({
    required this.id,
    required this.moduleId,
    required this.moduleXpAwarded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['module_id'] = Variable<String>(moduleId);
    map['module_xp_awarded'] = Variable<bool>(moduleXpAwarded);
    return map;
  }

  ModuleProgressRecordsCompanion toCompanion(bool nullToAbsent) {
    return ModuleProgressRecordsCompanion(
      id: Value(id),
      moduleId: Value(moduleId),
      moduleXpAwarded: Value(moduleXpAwarded),
    );
  }

  factory ModuleProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleProgressRow(
      id: serializer.fromJson<int>(json['id']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      moduleXpAwarded: serializer.fromJson<bool>(json['moduleXpAwarded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'moduleId': serializer.toJson<String>(moduleId),
      'moduleXpAwarded': serializer.toJson<bool>(moduleXpAwarded),
    };
  }

  ModuleProgressRow copyWith({
    int? id,
    String? moduleId,
    bool? moduleXpAwarded,
  }) => ModuleProgressRow(
    id: id ?? this.id,
    moduleId: moduleId ?? this.moduleId,
    moduleXpAwarded: moduleXpAwarded ?? this.moduleXpAwarded,
  );
  ModuleProgressRow copyWithCompanion(ModuleProgressRecordsCompanion data) {
    return ModuleProgressRow(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      moduleXpAwarded: data.moduleXpAwarded.present
          ? data.moduleXpAwarded.value
          : this.moduleXpAwarded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleProgressRow(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('moduleXpAwarded: $moduleXpAwarded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moduleId, moduleXpAwarded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleProgressRow &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.moduleXpAwarded == this.moduleXpAwarded);
}

class ModuleProgressRecordsCompanion
    extends UpdateCompanion<ModuleProgressRow> {
  final Value<int> id;
  final Value<String> moduleId;
  final Value<bool> moduleXpAwarded;
  const ModuleProgressRecordsCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.moduleXpAwarded = const Value.absent(),
  });
  ModuleProgressRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String moduleId,
    required bool moduleXpAwarded,
  }) : moduleId = Value(moduleId),
       moduleXpAwarded = Value(moduleXpAwarded);
  static Insertable<ModuleProgressRow> custom({
    Expression<int>? id,
    Expression<String>? moduleId,
    Expression<bool>? moduleXpAwarded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (moduleXpAwarded != null) 'module_xp_awarded': moduleXpAwarded,
    });
  }

  ModuleProgressRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? moduleId,
    Value<bool>? moduleXpAwarded,
  }) {
    return ModuleProgressRecordsCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      moduleXpAwarded: moduleXpAwarded ?? this.moduleXpAwarded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (moduleXpAwarded.present) {
      map['module_xp_awarded'] = Variable<bool>(moduleXpAwarded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleProgressRecordsCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('moduleXpAwarded: $moduleXpAwarded')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProgressRecordsTable progressRecords = $ProgressRecordsTable(
    this,
  );
  late final $CardRecordsTable cardRecords = $CardRecordsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $ModuleProgressRecordsTable moduleProgressRecords =
      $ModuleProgressRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    progressRecords,
    cardRecords,
    userSettings,
    moduleProgressRecords,
  ];
}

typedef $$ProgressRecordsTableCreateCompanionBuilder =
    ProgressRecordsCompanion Function({
      Value<int> id,
      required String lessonId,
      required bool isCompleted,
      required int xpEarned,
      required DateTime completedAt,
      Value<bool> fullXpAwarded,
      Value<int> bestScore,
      Value<DateTime?> lastPracticeXpDate,
    });
typedef $$ProgressRecordsTableUpdateCompanionBuilder =
    ProgressRecordsCompanion Function({
      Value<int> id,
      Value<String> lessonId,
      Value<bool> isCompleted,
      Value<int> xpEarned,
      Value<DateTime> completedAt,
      Value<bool> fullXpAwarded,
      Value<int> bestScore,
      Value<DateTime?> lastPracticeXpDate,
    });

class $$ProgressRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressRecordsTable> {
  $$ProgressRecordsTableFilterComposer({
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

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fullXpAwarded => $composableBuilder(
    column: $table.fullXpAwarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPracticeXpDate => $composableBuilder(
    column: $table.lastPracticeXpDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressRecordsTable> {
  $$ProgressRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fullXpAwarded => $composableBuilder(
    column: $table.fullXpAwarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPracticeXpDate => $composableBuilder(
    column: $table.lastPracticeXpDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressRecordsTable> {
  $$ProgressRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fullXpAwarded => $composableBuilder(
    column: $table.fullXpAwarded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPracticeXpDate => $composableBuilder(
    column: $table.lastPracticeXpDate,
    builder: (column) => column,
  );
}

class $$ProgressRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressRecordsTable,
          ProgressRow,
          $$ProgressRecordsTableFilterComposer,
          $$ProgressRecordsTableOrderingComposer,
          $$ProgressRecordsTableAnnotationComposer,
          $$ProgressRecordsTableCreateCompanionBuilder,
          $$ProgressRecordsTableUpdateCompanionBuilder,
          (
            ProgressRow,
            BaseReferences<_$AppDatabase, $ProgressRecordsTable, ProgressRow>,
          ),
          ProgressRow,
          PrefetchHooks Function()
        > {
  $$ProgressRecordsTableTableManager(
    _$AppDatabase db,
    $ProgressRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<bool> fullXpAwarded = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<DateTime?> lastPracticeXpDate = const Value.absent(),
              }) => ProgressRecordsCompanion(
                id: id,
                lessonId: lessonId,
                isCompleted: isCompleted,
                xpEarned: xpEarned,
                completedAt: completedAt,
                fullXpAwarded: fullXpAwarded,
                bestScore: bestScore,
                lastPracticeXpDate: lastPracticeXpDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String lessonId,
                required bool isCompleted,
                required int xpEarned,
                required DateTime completedAt,
                Value<bool> fullXpAwarded = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<DateTime?> lastPracticeXpDate = const Value.absent(),
              }) => ProgressRecordsCompanion.insert(
                id: id,
                lessonId: lessonId,
                isCompleted: isCompleted,
                xpEarned: xpEarned,
                completedAt: completedAt,
                fullXpAwarded: fullXpAwarded,
                bestScore: bestScore,
                lastPracticeXpDate: lastPracticeXpDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressRecordsTable,
      ProgressRow,
      $$ProgressRecordsTableFilterComposer,
      $$ProgressRecordsTableOrderingComposer,
      $$ProgressRecordsTableAnnotationComposer,
      $$ProgressRecordsTableCreateCompanionBuilder,
      $$ProgressRecordsTableUpdateCompanionBuilder,
      (
        ProgressRow,
        BaseReferences<_$AppDatabase, $ProgressRecordsTable, ProgressRow>,
      ),
      ProgressRow,
      PrefetchHooks Function()
    >;
typedef $$CardRecordsTableCreateCompanionBuilder =
    CardRecordsCompanion Function({
      Value<int> id,
      required String cardId,
      required DateTime unlockedAt,
    });
typedef $$CardRecordsTableUpdateCompanionBuilder =
    CardRecordsCompanion Function({
      Value<int> id,
      Value<String> cardId,
      Value<DateTime> unlockedAt,
    });

class $$CardRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CardRecordsTable> {
  $$CardRecordsTableFilterComposer({
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

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardRecordsTable> {
  $$CardRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardRecordsTable> {
  $$CardRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$CardRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardRecordsTable,
          CardRow,
          $$CardRecordsTableFilterComposer,
          $$CardRecordsTableOrderingComposer,
          $$CardRecordsTableAnnotationComposer,
          $$CardRecordsTableCreateCompanionBuilder,
          $$CardRecordsTableUpdateCompanionBuilder,
          (CardRow, BaseReferences<_$AppDatabase, $CardRecordsTable, CardRow>),
          CardRow,
          PrefetchHooks Function()
        > {
  $$CardRecordsTableTableManager(_$AppDatabase db, $CardRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => CardRecordsCompanion(
                id: id,
                cardId: cardId,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardId,
                required DateTime unlockedAt,
              }) => CardRecordsCompanion.insert(
                id: id,
                cardId: cardId,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardRecordsTable,
      CardRow,
      $$CardRecordsTableFilterComposer,
      $$CardRecordsTableOrderingComposer,
      $$CardRecordsTableAnnotationComposer,
      $$CardRecordsTableCreateCompanionBuilder,
      $$CardRecordsTableUpdateCompanionBuilder,
      (CardRow, BaseReferences<_$AppDatabase, $CardRecordsTable, CardRow>),
      CardRow,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      required bool hapticsEnabled,
      required bool soundEnabled,
      required int totalXp,
      required int streakDays,
      Value<DateTime?> lastActivityDate,
      Value<bool> onboardingCompleted,
      Value<String?> onboardingGoal,
      Value<String?> onboardingBrewer,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<bool> hapticsEnabled,
      Value<bool> soundEnabled,
      Value<int> totalXp,
      Value<int> streakDays,
      Value<DateTime?> lastActivityDate,
      Value<bool> onboardingCompleted,
      Value<String?> onboardingGoal,
      Value<String?> onboardingBrewer,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

  ColumnFilters<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivityDate => $composableBuilder(
    column: $table.lastActivityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onboardingGoal => $composableBuilder(
    column: $table.onboardingGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get onboardingBrewer => $composableBuilder(
    column: $table.onboardingBrewer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivityDate => $composableBuilder(
    column: $table.lastActivityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onboardingGoal => $composableBuilder(
    column: $table.onboardingGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get onboardingBrewer => $composableBuilder(
    column: $table.onboardingBrewer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get hapticsEnabled => $composableBuilder(
    column: $table.hapticsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActivityDate => $composableBuilder(
    column: $table.lastActivityDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onboardingGoal => $composableBuilder(
    column: $table.onboardingGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get onboardingBrewer => $composableBuilder(
    column: $table.onboardingBrewer,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          SettingsRow,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $UserSettingsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> hapticsEnabled = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActivityDate = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> onboardingGoal = const Value.absent(),
                Value<String?> onboardingBrewer = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                hapticsEnabled: hapticsEnabled,
                soundEnabled: soundEnabled,
                totalXp: totalXp,
                streakDays: streakDays,
                lastActivityDate: lastActivityDate,
                onboardingCompleted: onboardingCompleted,
                onboardingGoal: onboardingGoal,
                onboardingBrewer: onboardingBrewer,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool hapticsEnabled,
                required bool soundEnabled,
                required int totalXp,
                required int streakDays,
                Value<DateTime?> lastActivityDate = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> onboardingGoal = const Value.absent(),
                Value<String?> onboardingBrewer = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                hapticsEnabled: hapticsEnabled,
                soundEnabled: soundEnabled,
                totalXp: totalXp,
                streakDays: streakDays,
                lastActivityDate: lastActivityDate,
                onboardingCompleted: onboardingCompleted,
                onboardingGoal: onboardingGoal,
                onboardingBrewer: onboardingBrewer,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      SettingsRow,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$AppDatabase, $UserSettingsTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$ModuleProgressRecordsTableCreateCompanionBuilder =
    ModuleProgressRecordsCompanion Function({
      Value<int> id,
      required String moduleId,
      required bool moduleXpAwarded,
    });
typedef $$ModuleProgressRecordsTableUpdateCompanionBuilder =
    ModuleProgressRecordsCompanion Function({
      Value<int> id,
      Value<String> moduleId,
      Value<bool> moduleXpAwarded,
    });

class $$ModuleProgressRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ModuleProgressRecordsTable> {
  $$ModuleProgressRecordsTableFilterComposer({
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

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get moduleXpAwarded => $composableBuilder(
    column: $table.moduleXpAwarded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModuleProgressRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModuleProgressRecordsTable> {
  $$ModuleProgressRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get moduleXpAwarded => $composableBuilder(
    column: $table.moduleXpAwarded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModuleProgressRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModuleProgressRecordsTable> {
  $$ModuleProgressRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<bool> get moduleXpAwarded => $composableBuilder(
    column: $table.moduleXpAwarded,
    builder: (column) => column,
  );
}

class $$ModuleProgressRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ModuleProgressRecordsTable,
          ModuleProgressRow,
          $$ModuleProgressRecordsTableFilterComposer,
          $$ModuleProgressRecordsTableOrderingComposer,
          $$ModuleProgressRecordsTableAnnotationComposer,
          $$ModuleProgressRecordsTableCreateCompanionBuilder,
          $$ModuleProgressRecordsTableUpdateCompanionBuilder,
          (
            ModuleProgressRow,
            BaseReferences<
              _$AppDatabase,
              $ModuleProgressRecordsTable,
              ModuleProgressRow
            >,
          ),
          ModuleProgressRow,
          PrefetchHooks Function()
        > {
  $$ModuleProgressRecordsTableTableManager(
    _$AppDatabase db,
    $ModuleProgressRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModuleProgressRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ModuleProgressRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ModuleProgressRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<bool> moduleXpAwarded = const Value.absent(),
              }) => ModuleProgressRecordsCompanion(
                id: id,
                moduleId: moduleId,
                moduleXpAwarded: moduleXpAwarded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String moduleId,
                required bool moduleXpAwarded,
              }) => ModuleProgressRecordsCompanion.insert(
                id: id,
                moduleId: moduleId,
                moduleXpAwarded: moduleXpAwarded,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModuleProgressRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ModuleProgressRecordsTable,
      ModuleProgressRow,
      $$ModuleProgressRecordsTableFilterComposer,
      $$ModuleProgressRecordsTableOrderingComposer,
      $$ModuleProgressRecordsTableAnnotationComposer,
      $$ModuleProgressRecordsTableCreateCompanionBuilder,
      $$ModuleProgressRecordsTableUpdateCompanionBuilder,
      (
        ModuleProgressRow,
        BaseReferences<
          _$AppDatabase,
          $ModuleProgressRecordsTable,
          ModuleProgressRow
        >,
      ),
      ModuleProgressRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProgressRecordsTableTableManager get progressRecords =>
      $$ProgressRecordsTableTableManager(_db, _db.progressRecords);
  $$CardRecordsTableTableManager get cardRecords =>
      $$CardRecordsTableTableManager(_db, _db.cardRecords);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$ModuleProgressRecordsTableTableManager get moduleProgressRecords =>
      $$ModuleProgressRecordsTableTableManager(_db, _db.moduleProgressRecords);
}
