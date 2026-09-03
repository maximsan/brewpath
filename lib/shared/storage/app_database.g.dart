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
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gradedTotalMeta = const VerificationMeta(
    'gradedTotal',
  );
  @override
  late final GeneratedColumn<int> gradedTotal = GeneratedColumn<int>(
    'graded_total',
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
    correctCount,
    gradedTotal,
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
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('graded_total')) {
      context.handle(
        _gradedTotalMeta,
        gradedTotal.isAcceptableOrUnknown(
          data['graded_total']!,
          _gradedTotalMeta,
        ),
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
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      gradedTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}graded_total'],
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

  /// Whether the lesson's full payout has already been awarded.
  ///
  /// ⚠️ **Dead: always `true`.** A completion row only ever exists once the
  /// lesson has paid, so the flag never distinguished anything. Dropped by the
  /// destructive rebuild (#79); a column cannot go while the mapper round-trips
  /// it.
  final bool fullXpAwarded;

  /// Graded cards answered right in the lesson's best run.
  ///
  /// Stored as the pair `correctCount` / `gradedTotal` rather than a
  /// percentage: the mastery band derives from the wrong-answer count
  /// (`gradedTotal - correctCount`) and the node gauge fills to the ratio, and
  /// neither survives being flattened into one number. A row with
  /// `gradedTotal == 0` holds no score and reads as deliberately neutral.
  final int correctCount;

  /// Graded cards in the lesson's best run; `0` means unscored.
  final int gradedTotal;

  /// Calendar day the per-day practice reward was last paid for this lesson.
  ///
  /// ⚠️ **Dead: nothing writes it.** The reward was retired with #160 —
  /// replays pay zero (§5.1). Keep Sharp's "was a lesson replayed today?"
  /// derivation used to read this stamp and now reads the day's activity
  /// entries instead, so no rule depends on it. Dropped by #79.
  final DateTime? lastPracticeXpDate;
  const ProgressRow({
    required this.id,
    required this.lessonId,
    required this.isCompleted,
    required this.xpEarned,
    required this.completedAt,
    required this.fullXpAwarded,
    required this.correctCount,
    required this.gradedTotal,
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
    map['correct_count'] = Variable<int>(correctCount);
    map['graded_total'] = Variable<int>(gradedTotal);
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
      correctCount: Value(correctCount),
      gradedTotal: Value(gradedTotal),
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
      correctCount: serializer.fromJson<int>(json['correctCount']),
      gradedTotal: serializer.fromJson<int>(json['gradedTotal']),
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
      'correctCount': serializer.toJson<int>(correctCount),
      'gradedTotal': serializer.toJson<int>(gradedTotal),
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
    int? correctCount,
    int? gradedTotal,
    Value<DateTime?> lastPracticeXpDate = const Value.absent(),
  }) => ProgressRow(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    isCompleted: isCompleted ?? this.isCompleted,
    xpEarned: xpEarned ?? this.xpEarned,
    completedAt: completedAt ?? this.completedAt,
    fullXpAwarded: fullXpAwarded ?? this.fullXpAwarded,
    correctCount: correctCount ?? this.correctCount,
    gradedTotal: gradedTotal ?? this.gradedTotal,
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
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      gradedTotal: data.gradedTotal.present
          ? data.gradedTotal.value
          : this.gradedTotal,
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
          ..write('correctCount: $correctCount, ')
          ..write('gradedTotal: $gradedTotal, ')
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
    correctCount,
    gradedTotal,
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
          other.correctCount == this.correctCount &&
          other.gradedTotal == this.gradedTotal &&
          other.lastPracticeXpDate == this.lastPracticeXpDate);
}

class ProgressRecordsCompanion extends UpdateCompanion<ProgressRow> {
  final Value<int> id;
  final Value<String> lessonId;
  final Value<bool> isCompleted;
  final Value<int> xpEarned;
  final Value<DateTime> completedAt;
  final Value<bool> fullXpAwarded;
  final Value<int> correctCount;
  final Value<int> gradedTotal;
  final Value<DateTime?> lastPracticeXpDate;
  const ProgressRecordsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.fullXpAwarded = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.gradedTotal = const Value.absent(),
    this.lastPracticeXpDate = const Value.absent(),
  });
  ProgressRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String lessonId,
    required bool isCompleted,
    required int xpEarned,
    required DateTime completedAt,
    this.fullXpAwarded = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.gradedTotal = const Value.absent(),
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
    Expression<int>? correctCount,
    Expression<int>? gradedTotal,
    Expression<DateTime>? lastPracticeXpDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (completedAt != null) 'completed_at': completedAt,
      if (fullXpAwarded != null) 'full_xp_awarded': fullXpAwarded,
      if (correctCount != null) 'correct_count': correctCount,
      if (gradedTotal != null) 'graded_total': gradedTotal,
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
    Value<int>? correctCount,
    Value<int>? gradedTotal,
    Value<DateTime?>? lastPracticeXpDate,
  }) {
    return ProgressRecordsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      isCompleted: isCompleted ?? this.isCompleted,
      xpEarned: xpEarned ?? this.xpEarned,
      completedAt: completedAt ?? this.completedAt,
      fullXpAwarded: fullXpAwarded ?? this.fullXpAwarded,
      correctCount: correctCount ?? this.correctCount,
      gradedTotal: gradedTotal ?? this.gradedTotal,
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
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (gradedTotal.present) {
      map['graded_total'] = Variable<int>(gradedTotal.value);
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
          ..write('correctCount: $correctCount, ')
          ..write('gradedTotal: $gradedTotal, ')
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
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dark'),
  );
  static const VerificationMeta _tourSeenMeta = const VerificationMeta(
    'tourSeen',
  );
  @override
  late final GeneratedColumn<bool> tourSeen = GeneratedColumn<bool>(
    'tour_seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tour_seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _learnerNameMeta = const VerificationMeta(
    'learnerName',
  );
  @override
  late final GeneratedColumn<String> learnerName = GeneratedColumn<String>(
    'learner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyReminderTimeMeta = const VerificationMeta(
    'dailyReminderTime',
  );
  @override
  late final GeneratedColumn<String> dailyReminderTime =
      GeneratedColumn<String>(
        'daily_reminder_time',
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
    onboardingCompleted,
    onboardingGoal,
    onboardingBrewer,
    themeMode,
    tourSeen,
    learnerName,
    notificationsEnabled,
    dailyReminderTime,
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
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('tour_seen')) {
      context.handle(
        _tourSeenMeta,
        tourSeen.isAcceptableOrUnknown(data['tour_seen']!, _tourSeenMeta),
      );
    }
    if (data.containsKey('learner_name')) {
      context.handle(
        _learnerNameMeta,
        learnerName.isAcceptableOrUnknown(
          data['learner_name']!,
          _learnerNameMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('daily_reminder_time')) {
      context.handle(
        _dailyReminderTimeMeta,
        dailyReminderTime.isAcceptableOrUnknown(
          data['daily_reminder_time']!,
          _dailyReminderTimeMeta,
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
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      tourSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tour_seen'],
      )!,
      learnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learner_name'],
      ),
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      dailyReminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_reminder_time'],
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

  /// The learner's running points total.
  ///
  /// ⚠️ **Dead: nothing reads or writes it.** The total is derived from the
  /// completion rows and the snapshot's logged challenges (#160) — a counter is
  /// a second copy of a derivable fact. Dropped by #79.
  final int totalXp;

  /// Whether the user has completed the post-install onboarding flow.
  /// Defaults to `false` so rows migrated from schema v2 force the gate.
  final bool onboardingCompleted;

  /// Was the onboarding goal. **Nothing reads or writes it any more** —
  /// ADR-0010 moved the question to v2 and #407 removed the screen that asked
  /// it, so on every install from that point on it stays null.
  ///
  /// Kept rather than dropped because the schema fixtures under
  /// `test/generated/` are frozen at the versions that carry it: removing the
  /// column is a new schema version and a new fixture, which is worth doing
  /// when the question comes back, not to tidy away two nulls.
  final String? onboardingGoal;

  /// Was the selected brewer. Left in place for the same reason as
  /// [onboardingGoal], and read by nothing.
  final String? onboardingBrewer;

  /// Appearance preference — `system` / `light` / `dark`, persisted as the
  /// enum's storage string. Device-local: never written to the sync snapshot,
  /// because two devices the same person owns may legitimately differ.
  final String themeMode;

  /// Whether the learner has answered the Tour's intro overlay.
  ///
  /// Written the moment either button is pressed, so mid-tour abandonment never
  /// re-arms the auto-run. Defaults to `false` so every device migrated from an
  /// earlier schema is offered the Tour once.
  ///
  /// **Fate-shares with [onboardingCompleted].** The two are the app's pair of
  /// "this learner has been shown the introductions" bits, and a wipe that
  /// clears one while keeping the other produces a state no learner can reach
  /// on their own: onboarding replayed with the Tour suppressed, or the
  /// reverse.
  /// The three places that decide are `AccountWipe.resetProgress` (keeps both,
  /// by leaving this row alone), `SettingsRepository.deleteAll` (clears both,
  /// with the row) and `OnboardingRepository.resetOnboarding` (clears both, by
  /// name). Device-local: never written to the progress snapshot.
  final bool tourSeen;

  /// What the learner asked to be called, or null when they did not say.
  ///
  /// Nullable rather than defaulted to a placeholder: "no name given" and "the
  /// name is empty" are the same fact to the greeting, and only one of them
  /// needs representing.
  final String? learnerName;

  /// Whether the learner asked for a daily reminder.
  ///
  /// Off by default: a notification nobody asked for is the fastest way to be
  /// switched off for good, and the design's own row starts as a choice rather
  /// than as something to undo.
  ///
  /// **Stored, not yet acted on.** Nothing schedules anything from this bit —
  /// whether reminders ship at all has never been ruled, and the platform work
  /// behind it is #443. Device-local either way: a reminder is a property of
  /// the phone in your pocket, not of the account.
  final bool notificationsEnabled;

  /// The time of day the reminder is set for, as one of the design's eight
  /// slots (`prototype/settings.jsx:103`).
  ///
  /// Nullable rather than defaulted: "never chose a time" is a different fact
  /// from "chose 8:00 AM", and the row reads *Off* for the first.
  final String? dailyReminderTime;
  const SettingsRow({
    required this.id,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.totalXp,
    required this.onboardingCompleted,
    this.onboardingGoal,
    this.onboardingBrewer,
    required this.themeMode,
    required this.tourSeen,
    this.learnerName,
    required this.notificationsEnabled,
    this.dailyReminderTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['haptics_enabled'] = Variable<bool>(hapticsEnabled);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['total_xp'] = Variable<int>(totalXp);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || onboardingGoal != null) {
      map['onboarding_goal'] = Variable<String>(onboardingGoal);
    }
    if (!nullToAbsent || onboardingBrewer != null) {
      map['onboarding_brewer'] = Variable<String>(onboardingBrewer);
    }
    map['theme_mode'] = Variable<String>(themeMode);
    map['tour_seen'] = Variable<bool>(tourSeen);
    if (!nullToAbsent || learnerName != null) {
      map['learner_name'] = Variable<String>(learnerName);
    }
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    if (!nullToAbsent || dailyReminderTime != null) {
      map['daily_reminder_time'] = Variable<String>(dailyReminderTime);
    }
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      hapticsEnabled: Value(hapticsEnabled),
      soundEnabled: Value(soundEnabled),
      totalXp: Value(totalXp),
      onboardingCompleted: Value(onboardingCompleted),
      onboardingGoal: onboardingGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingGoal),
      onboardingBrewer: onboardingBrewer == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingBrewer),
      themeMode: Value(themeMode),
      tourSeen: Value(tourSeen),
      learnerName: learnerName == null && nullToAbsent
          ? const Value.absent()
          : Value(learnerName),
      notificationsEnabled: Value(notificationsEnabled),
      dailyReminderTime: dailyReminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyReminderTime),
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
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      onboardingGoal: serializer.fromJson<String?>(json['onboardingGoal']),
      onboardingBrewer: serializer.fromJson<String?>(json['onboardingBrewer']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      tourSeen: serializer.fromJson<bool>(json['tourSeen']),
      learnerName: serializer.fromJson<String?>(json['learnerName']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      dailyReminderTime: serializer.fromJson<String?>(
        json['dailyReminderTime'],
      ),
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
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'onboardingGoal': serializer.toJson<String?>(onboardingGoal),
      'onboardingBrewer': serializer.toJson<String?>(onboardingBrewer),
      'themeMode': serializer.toJson<String>(themeMode),
      'tourSeen': serializer.toJson<bool>(tourSeen),
      'learnerName': serializer.toJson<String?>(learnerName),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'dailyReminderTime': serializer.toJson<String?>(dailyReminderTime),
    };
  }

  SettingsRow copyWith({
    int? id,
    bool? hapticsEnabled,
    bool? soundEnabled,
    int? totalXp,
    bool? onboardingCompleted,
    Value<String?> onboardingGoal = const Value.absent(),
    Value<String?> onboardingBrewer = const Value.absent(),
    String? themeMode,
    bool? tourSeen,
    Value<String?> learnerName = const Value.absent(),
    bool? notificationsEnabled,
    Value<String?> dailyReminderTime = const Value.absent(),
  }) => SettingsRow(
    id: id ?? this.id,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    totalXp: totalXp ?? this.totalXp,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    onboardingGoal: onboardingGoal.present
        ? onboardingGoal.value
        : this.onboardingGoal,
    onboardingBrewer: onboardingBrewer.present
        ? onboardingBrewer.value
        : this.onboardingBrewer,
    themeMode: themeMode ?? this.themeMode,
    tourSeen: tourSeen ?? this.tourSeen,
    learnerName: learnerName.present ? learnerName.value : this.learnerName,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    dailyReminderTime: dailyReminderTime.present
        ? dailyReminderTime.value
        : this.dailyReminderTime,
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
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      onboardingGoal: data.onboardingGoal.present
          ? data.onboardingGoal.value
          : this.onboardingGoal,
      onboardingBrewer: data.onboardingBrewer.present
          ? data.onboardingBrewer.value
          : this.onboardingBrewer,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      tourSeen: data.tourSeen.present ? data.tourSeen.value : this.tourSeen,
      learnerName: data.learnerName.present
          ? data.learnerName.value
          : this.learnerName,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      dailyReminderTime: data.dailyReminderTime.present
          ? data.dailyReminderTime.value
          : this.dailyReminderTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('hapticsEnabled: $hapticsEnabled, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('totalXp: $totalXp, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingGoal: $onboardingGoal, ')
          ..write('onboardingBrewer: $onboardingBrewer, ')
          ..write('themeMode: $themeMode, ')
          ..write('tourSeen: $tourSeen, ')
          ..write('learnerName: $learnerName, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('dailyReminderTime: $dailyReminderTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hapticsEnabled,
    soundEnabled,
    totalXp,
    onboardingCompleted,
    onboardingGoal,
    onboardingBrewer,
    themeMode,
    tourSeen,
    learnerName,
    notificationsEnabled,
    dailyReminderTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.hapticsEnabled == this.hapticsEnabled &&
          other.soundEnabled == this.soundEnabled &&
          other.totalXp == this.totalXp &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.onboardingGoal == this.onboardingGoal &&
          other.onboardingBrewer == this.onboardingBrewer &&
          other.themeMode == this.themeMode &&
          other.tourSeen == this.tourSeen &&
          other.learnerName == this.learnerName &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.dailyReminderTime == this.dailyReminderTime);
}

class UserSettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<bool> hapticsEnabled;
  final Value<bool> soundEnabled;
  final Value<int> totalXp;
  final Value<bool> onboardingCompleted;
  final Value<String?> onboardingGoal;
  final Value<String?> onboardingBrewer;
  final Value<String> themeMode;
  final Value<bool> tourSeen;
  final Value<String?> learnerName;
  final Value<bool> notificationsEnabled;
  final Value<String?> dailyReminderTime;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingGoal = const Value.absent(),
    this.onboardingBrewer = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.tourSeen = const Value.absent(),
    this.learnerName = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailyReminderTime = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    required bool hapticsEnabled,
    required bool soundEnabled,
    required int totalXp,
    this.onboardingCompleted = const Value.absent(),
    this.onboardingGoal = const Value.absent(),
    this.onboardingBrewer = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.tourSeen = const Value.absent(),
    this.learnerName = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailyReminderTime = const Value.absent(),
  }) : hapticsEnabled = Value(hapticsEnabled),
       soundEnabled = Value(soundEnabled),
       totalXp = Value(totalXp);
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<bool>? hapticsEnabled,
    Expression<bool>? soundEnabled,
    Expression<int>? totalXp,
    Expression<bool>? onboardingCompleted,
    Expression<String>? onboardingGoal,
    Expression<String>? onboardingBrewer,
    Expression<String>? themeMode,
    Expression<bool>? tourSeen,
    Expression<String>? learnerName,
    Expression<bool>? notificationsEnabled,
    Expression<String>? dailyReminderTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (totalXp != null) 'total_xp': totalXp,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (onboardingGoal != null) 'onboarding_goal': onboardingGoal,
      if (onboardingBrewer != null) 'onboarding_brewer': onboardingBrewer,
      if (themeMode != null) 'theme_mode': themeMode,
      if (tourSeen != null) 'tour_seen': tourSeen,
      if (learnerName != null) 'learner_name': learnerName,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (dailyReminderTime != null) 'daily_reminder_time': dailyReminderTime,
    });
  }

  UserSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? hapticsEnabled,
    Value<bool>? soundEnabled,
    Value<int>? totalXp,
    Value<bool>? onboardingCompleted,
    Value<String?>? onboardingGoal,
    Value<String?>? onboardingBrewer,
    Value<String>? themeMode,
    Value<bool>? tourSeen,
    Value<String?>? learnerName,
    Value<bool>? notificationsEnabled,
    Value<String?>? dailyReminderTime,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      totalXp: totalXp ?? this.totalXp,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingGoal: onboardingGoal ?? this.onboardingGoal,
      onboardingBrewer: onboardingBrewer ?? this.onboardingBrewer,
      themeMode: themeMode ?? this.themeMode,
      tourSeen: tourSeen ?? this.tourSeen,
      learnerName: learnerName ?? this.learnerName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
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
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (onboardingGoal.present) {
      map['onboarding_goal'] = Variable<String>(onboardingGoal.value);
    }
    if (onboardingBrewer.present) {
      map['onboarding_brewer'] = Variable<String>(onboardingBrewer.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (tourSeen.present) {
      map['tour_seen'] = Variable<bool>(tourSeen.value);
    }
    if (learnerName.present) {
      map['learner_name'] = Variable<String>(learnerName.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (dailyReminderTime.present) {
      map['daily_reminder_time'] = Variable<String>(dailyReminderTime.value);
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
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingGoal: $onboardingGoal, ')
          ..write('onboardingBrewer: $onboardingBrewer, ')
          ..write('themeMode: $themeMode, ')
          ..write('tourSeen: $tourSeen, ')
          ..write('learnerName: $learnerName, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('dailyReminderTime: $dailyReminderTime')
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

class $ProgressSnapshotsTable extends ProgressSnapshots
    with TableInfo<$ProgressSnapshotsTable, SnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ProgressSnapshotsTable createAlias(String alias) {
    return $ProgressSnapshotsTable(attachedDatabase, alias);
  }
}

class SnapshotRow extends DataClass implements Insertable<SnapshotRow> {
  final int id;

  /// The snapshot, encoded. Unknown keys ride along inside it untouched, so a
  /// build that has never heard of a field still writes it back.
  final String payload;
  const SnapshotRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  ProgressSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ProgressSnapshotsCompanion(id: Value(id), payload: Value(payload));
  }

  factory SnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnapshotRow(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  SnapshotRow copyWith({int? id, String? payload}) =>
      SnapshotRow(id: id ?? this.id, payload: payload ?? this.payload);
  SnapshotRow copyWithCompanion(ProgressSnapshotsCompanion data) {
    return SnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotRow(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnapshotRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class ProgressSnapshotsCompanion extends UpdateCompanion<SnapshotRow> {
  final Value<int> id;
  final Value<String> payload;
  const ProgressSnapshotsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
  });
  ProgressSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
  }) : payload = Value(payload);
  static Insertable<SnapshotRow> custom({
    Expression<int>? id,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
    });
  }

  ProgressSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? payload,
  }) {
    return ProgressSnapshotsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $AppInstallsTable extends AppInstalls
    with TableInfo<$AppInstallsTable, InstallRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppInstallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, installedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_installs';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
    );
  }

  @override
  $AppInstallsTable createAlias(String alias) {
    return $AppInstallsTable(attachedDatabase, alias);
  }
}

class InstallRow extends DataClass implements Insertable<InstallRow> {
  final int id;

  /// The instant the database was created, which is the app's first run.
  final DateTime installedAt;
  const InstallRow({required this.id, required this.installedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['installed_at'] = Variable<DateTime>(installedAt);
    return map;
  }

  AppInstallsCompanion toCompanion(bool nullToAbsent) {
    return AppInstallsCompanion(id: Value(id), installedAt: Value(installedAt));
  }

  factory InstallRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallRow(
      id: serializer.fromJson<int>(json['id']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'installedAt': serializer.toJson<DateTime>(installedAt),
    };
  }

  InstallRow copyWith({int? id, DateTime? installedAt}) => InstallRow(
    id: id ?? this.id,
    installedAt: installedAt ?? this.installedAt,
  );
  InstallRow copyWithCompanion(AppInstallsCompanion data) {
    return InstallRow(
      id: data.id.present ? data.id.value : this.id,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallRow(')
          ..write('id: $id, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, installedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallRow &&
          other.id == this.id &&
          other.installedAt == this.installedAt);
}

class AppInstallsCompanion extends UpdateCompanion<InstallRow> {
  final Value<int> id;
  final Value<DateTime> installedAt;
  const AppInstallsCompanion({
    this.id = const Value.absent(),
    this.installedAt = const Value.absent(),
  });
  AppInstallsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime installedAt,
  }) : installedAt = Value(installedAt);
  static Insertable<InstallRow> custom({
    Expression<int>? id,
    Expression<DateTime>? installedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (installedAt != null) 'installed_at': installedAt,
    });
  }

  AppInstallsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? installedAt,
  }) {
    return AppInstallsCompanion(
      id: id ?? this.id,
      installedAt: installedAt ?? this.installedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppInstallsCompanion(')
          ..write('id: $id, ')
          ..write('installedAt: $installedAt')
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
  late final $ProgressSnapshotsTable progressSnapshots =
      $ProgressSnapshotsTable(this);
  late final $AppInstallsTable appInstalls = $AppInstallsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    progressRecords,
    cardRecords,
    userSettings,
    moduleProgressRecords,
    progressSnapshots,
    appInstalls,
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
      Value<int> correctCount,
      Value<int> gradedTotal,
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
      Value<int> correctCount,
      Value<int> gradedTotal,
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

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gradedTotal => $composableBuilder(
    column: $table.gradedTotal,
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

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gradedTotal => $composableBuilder(
    column: $table.gradedTotal,
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

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gradedTotal => $composableBuilder(
    column: $table.gradedTotal,
    builder: (column) => column,
  );

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
                Value<int> correctCount = const Value.absent(),
                Value<int> gradedTotal = const Value.absent(),
                Value<DateTime?> lastPracticeXpDate = const Value.absent(),
              }) => ProgressRecordsCompanion(
                id: id,
                lessonId: lessonId,
                isCompleted: isCompleted,
                xpEarned: xpEarned,
                completedAt: completedAt,
                fullXpAwarded: fullXpAwarded,
                correctCount: correctCount,
                gradedTotal: gradedTotal,
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
                Value<int> correctCount = const Value.absent(),
                Value<int> gradedTotal = const Value.absent(),
                Value<DateTime?> lastPracticeXpDate = const Value.absent(),
              }) => ProgressRecordsCompanion.insert(
                id: id,
                lessonId: lessonId,
                isCompleted: isCompleted,
                xpEarned: xpEarned,
                completedAt: completedAt,
                fullXpAwarded: fullXpAwarded,
                correctCount: correctCount,
                gradedTotal: gradedTotal,
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
      Value<bool> onboardingCompleted,
      Value<String?> onboardingGoal,
      Value<String?> onboardingBrewer,
      Value<String> themeMode,
      Value<bool> tourSeen,
      Value<String?> learnerName,
      Value<bool> notificationsEnabled,
      Value<String?> dailyReminderTime,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<bool> hapticsEnabled,
      Value<bool> soundEnabled,
      Value<int> totalXp,
      Value<bool> onboardingCompleted,
      Value<String?> onboardingGoal,
      Value<String?> onboardingBrewer,
      Value<String> themeMode,
      Value<bool> tourSeen,
      Value<String?> learnerName,
      Value<bool> notificationsEnabled,
      Value<String?> dailyReminderTime,
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

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tourSeen => $composableBuilder(
    column: $table.tourSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learnerName => $composableBuilder(
    column: $table.learnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyReminderTime => $composableBuilder(
    column: $table.dailyReminderTime,
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

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tourSeen => $composableBuilder(
    column: $table.tourSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learnerName => $composableBuilder(
    column: $table.learnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyReminderTime => $composableBuilder(
    column: $table.dailyReminderTime,
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

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get tourSeen =>
      $composableBuilder(column: $table.tourSeen, builder: (column) => column);

  GeneratedColumn<String> get learnerName => $composableBuilder(
    column: $table.learnerName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyReminderTime => $composableBuilder(
    column: $table.dailyReminderTime,
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
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> onboardingGoal = const Value.absent(),
                Value<String?> onboardingBrewer = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> tourSeen = const Value.absent(),
                Value<String?> learnerName = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String?> dailyReminderTime = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                hapticsEnabled: hapticsEnabled,
                soundEnabled: soundEnabled,
                totalXp: totalXp,
                onboardingCompleted: onboardingCompleted,
                onboardingGoal: onboardingGoal,
                onboardingBrewer: onboardingBrewer,
                themeMode: themeMode,
                tourSeen: tourSeen,
                learnerName: learnerName,
                notificationsEnabled: notificationsEnabled,
                dailyReminderTime: dailyReminderTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool hapticsEnabled,
                required bool soundEnabled,
                required int totalXp,
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> onboardingGoal = const Value.absent(),
                Value<String?> onboardingBrewer = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> tourSeen = const Value.absent(),
                Value<String?> learnerName = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String?> dailyReminderTime = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                hapticsEnabled: hapticsEnabled,
                soundEnabled: soundEnabled,
                totalXp: totalXp,
                onboardingCompleted: onboardingCompleted,
                onboardingGoal: onboardingGoal,
                onboardingBrewer: onboardingBrewer,
                themeMode: themeMode,
                tourSeen: tourSeen,
                learnerName: learnerName,
                notificationsEnabled: notificationsEnabled,
                dailyReminderTime: dailyReminderTime,
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
typedef $$ProgressSnapshotsTableCreateCompanionBuilder =
    ProgressSnapshotsCompanion Function({
      Value<int> id,
      required String payload,
    });
typedef $$ProgressSnapshotsTableUpdateCompanionBuilder =
    ProgressSnapshotsCompanion Function({Value<int> id, Value<String> payload});

class $$ProgressSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgressSnapshotsTable> {
  $$ProgressSnapshotsTableFilterComposer({
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

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgressSnapshotsTable> {
  $$ProgressSnapshotsTableOrderingComposer({
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

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgressSnapshotsTable> {
  $$ProgressSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$ProgressSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgressSnapshotsTable,
          SnapshotRow,
          $$ProgressSnapshotsTableFilterComposer,
          $$ProgressSnapshotsTableOrderingComposer,
          $$ProgressSnapshotsTableAnnotationComposer,
          $$ProgressSnapshotsTableCreateCompanionBuilder,
          $$ProgressSnapshotsTableUpdateCompanionBuilder,
          (
            SnapshotRow,
            BaseReferences<_$AppDatabase, $ProgressSnapshotsTable, SnapshotRow>,
          ),
          SnapshotRow,
          PrefetchHooks Function()
        > {
  $$ProgressSnapshotsTableTableManager(
    _$AppDatabase db,
    $ProgressSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgressSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
              }) => ProgressSnapshotsCompanion(id: id, payload: payload),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
              }) => ProgressSnapshotsCompanion.insert(id: id, payload: payload),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgressSnapshotsTable,
      SnapshotRow,
      $$ProgressSnapshotsTableFilterComposer,
      $$ProgressSnapshotsTableOrderingComposer,
      $$ProgressSnapshotsTableAnnotationComposer,
      $$ProgressSnapshotsTableCreateCompanionBuilder,
      $$ProgressSnapshotsTableUpdateCompanionBuilder,
      (
        SnapshotRow,
        BaseReferences<_$AppDatabase, $ProgressSnapshotsTable, SnapshotRow>,
      ),
      SnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$AppInstallsTableCreateCompanionBuilder =
    AppInstallsCompanion Function({
      Value<int> id,
      required DateTime installedAt,
    });
typedef $$AppInstallsTableUpdateCompanionBuilder =
    AppInstallsCompanion Function({Value<int> id, Value<DateTime> installedAt});

class $$AppInstallsTableFilterComposer
    extends Composer<_$AppDatabase, $AppInstallsTable> {
  $$AppInstallsTableFilterComposer({
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

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppInstallsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppInstallsTable> {
  $$AppInstallsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppInstallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppInstallsTable> {
  $$AppInstallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );
}

class $$AppInstallsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppInstallsTable,
          InstallRow,
          $$AppInstallsTableFilterComposer,
          $$AppInstallsTableOrderingComposer,
          $$AppInstallsTableAnnotationComposer,
          $$AppInstallsTableCreateCompanionBuilder,
          $$AppInstallsTableUpdateCompanionBuilder,
          (
            InstallRow,
            BaseReferences<_$AppDatabase, $AppInstallsTable, InstallRow>,
          ),
          InstallRow,
          PrefetchHooks Function()
        > {
  $$AppInstallsTableTableManager(_$AppDatabase db, $AppInstallsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppInstallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppInstallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppInstallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
              }) => AppInstallsCompanion(id: id, installedAt: installedAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime installedAt,
              }) =>
                  AppInstallsCompanion.insert(id: id, installedAt: installedAt),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppInstallsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppInstallsTable,
      InstallRow,
      $$AppInstallsTableFilterComposer,
      $$AppInstallsTableOrderingComposer,
      $$AppInstallsTableAnnotationComposer,
      $$AppInstallsTableCreateCompanionBuilder,
      $$AppInstallsTableUpdateCompanionBuilder,
      (
        InstallRow,
        BaseReferences<_$AppDatabase, $AppInstallsTable, InstallRow>,
      ),
      InstallRow,
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
  $$ProgressSnapshotsTableTableManager get progressSnapshots =>
      $$ProgressSnapshotsTableTableManager(_db, _db.progressSnapshots);
  $$AppInstallsTableTableManager get appInstalls =>
      $$AppInstallsTableTableManager(_db, _db.appInstalls);
}
