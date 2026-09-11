// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _tipsSeenMeta = const VerificationMeta(
    'tipsSeen',
  );
  @override
  late final GeneratedColumn<String> tipsSeen = GeneratedColumn<String>(
    'tips_seen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    onboardingCompleted,
    onboardingGoal,
    onboardingBrewer,
    themeMode,
    tourSeen,
    tipsSeen,
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
    if (data.containsKey('tips_seen')) {
      context.handle(
        _tipsSeenMeta,
        tipsSeen.isAcceptableOrUnknown(data['tips_seen']!, _tipsSeenMeta),
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
      tipsSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tips_seen'],
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

  /// Whether the user has completed the post-install onboarding flow.
  /// Defaults to `false` so rows migrated from schema v2 force the gate.
  final bool onboardingCompleted;

  /// The onboarding goal. Nothing reads or writes it since ADR-0010 moved the
  /// question to v2 and its screen was parked; the column stays for the
  /// reason that ADR gives.
  final String? onboardingGoal;

  /// The selected brewer. Same as [onboardingGoal].
  final String? onboardingBrewer;

  /// Appearance preference — `system` / `light` / `dark`, persisted as the
  /// enum's storage string. Device-local: never written to the sync snapshot,
  /// because two devices the same person owns may legitimately differ.
  final String themeMode;

  /// Whether the Tour's first run has ended — by Skip, Done or leaving the
  /// tab — so it runs once and never asks (#537).
  ///
  /// Fate-shares with [onboardingCompleted]: `AccountWipe.resetProgress`
  /// keeps both, `SettingsRepository.deleteAll` and
  /// `OnboardingRepository.resetOnboarding` clear both. Device-local.
  final bool tourSeen;

  /// Micro-tip ids the learner has been shown, comma-separated; empty for
  /// none. Under [tourSeen]'s wipe rule (#342): not progress, so it survives
  /// Reset and goes with Delete Account. One column rather than one per tip,
  /// because the guide layer names the set; unknown ids are kept as read, so
  /// an older build never trims a newer device's record. Device-local.
  final String tipsSeen;

  /// What the learner asked to be called, or null when they did not say.
  ///
  /// Nullable rather than defaulted to a placeholder: "no name given" and "the
  /// name is empty" are the same fact to the greeting, and only one of them
  /// needs representing.
  final String? learnerName;

  /// Whether the learner asked for a daily reminder. Off by default.
  ///
  /// Stored, not yet acted on: nothing schedules from this bit, and whether
  /// reminders ship at all is unruled; the platform work is #443. Device-local.
  final bool notificationsEnabled;

  /// The time of day the reminder is set for, as one of the design's eight
  /// slots.
  ///
  /// Nullable rather than defaulted: "never chose a time" is a different fact
  /// from "chose 8:00 AM", and the row reads *Off* for the first.
  final String? dailyReminderTime;
  const SettingsRow({
    required this.id,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.onboardingCompleted,
    this.onboardingGoal,
    this.onboardingBrewer,
    required this.themeMode,
    required this.tourSeen,
    required this.tipsSeen,
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
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || onboardingGoal != null) {
      map['onboarding_goal'] = Variable<String>(onboardingGoal);
    }
    if (!nullToAbsent || onboardingBrewer != null) {
      map['onboarding_brewer'] = Variable<String>(onboardingBrewer);
    }
    map['theme_mode'] = Variable<String>(themeMode);
    map['tour_seen'] = Variable<bool>(tourSeen);
    map['tips_seen'] = Variable<String>(tipsSeen);
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
      onboardingCompleted: Value(onboardingCompleted),
      onboardingGoal: onboardingGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingGoal),
      onboardingBrewer: onboardingBrewer == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingBrewer),
      themeMode: Value(themeMode),
      tourSeen: Value(tourSeen),
      tipsSeen: Value(tipsSeen),
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
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      onboardingGoal: serializer.fromJson<String?>(json['onboardingGoal']),
      onboardingBrewer: serializer.fromJson<String?>(json['onboardingBrewer']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      tourSeen: serializer.fromJson<bool>(json['tourSeen']),
      tipsSeen: serializer.fromJson<String>(json['tipsSeen']),
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
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'onboardingGoal': serializer.toJson<String?>(onboardingGoal),
      'onboardingBrewer': serializer.toJson<String?>(onboardingBrewer),
      'themeMode': serializer.toJson<String>(themeMode),
      'tourSeen': serializer.toJson<bool>(tourSeen),
      'tipsSeen': serializer.toJson<String>(tipsSeen),
      'learnerName': serializer.toJson<String?>(learnerName),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'dailyReminderTime': serializer.toJson<String?>(dailyReminderTime),
    };
  }

  SettingsRow copyWith({
    int? id,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? onboardingCompleted,
    Value<String?> onboardingGoal = const Value.absent(),
    Value<String?> onboardingBrewer = const Value.absent(),
    String? themeMode,
    bool? tourSeen,
    String? tipsSeen,
    Value<String?> learnerName = const Value.absent(),
    bool? notificationsEnabled,
    Value<String?> dailyReminderTime = const Value.absent(),
  }) => SettingsRow(
    id: id ?? this.id,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    onboardingGoal: onboardingGoal.present
        ? onboardingGoal.value
        : this.onboardingGoal,
    onboardingBrewer: onboardingBrewer.present
        ? onboardingBrewer.value
        : this.onboardingBrewer,
    themeMode: themeMode ?? this.themeMode,
    tourSeen: tourSeen ?? this.tourSeen,
    tipsSeen: tipsSeen ?? this.tipsSeen,
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
      tipsSeen: data.tipsSeen.present ? data.tipsSeen.value : this.tipsSeen,
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
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingGoal: $onboardingGoal, ')
          ..write('onboardingBrewer: $onboardingBrewer, ')
          ..write('themeMode: $themeMode, ')
          ..write('tourSeen: $tourSeen, ')
          ..write('tipsSeen: $tipsSeen, ')
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
    onboardingCompleted,
    onboardingGoal,
    onboardingBrewer,
    themeMode,
    tourSeen,
    tipsSeen,
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
          other.onboardingCompleted == this.onboardingCompleted &&
          other.onboardingGoal == this.onboardingGoal &&
          other.onboardingBrewer == this.onboardingBrewer &&
          other.themeMode == this.themeMode &&
          other.tourSeen == this.tourSeen &&
          other.tipsSeen == this.tipsSeen &&
          other.learnerName == this.learnerName &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.dailyReminderTime == this.dailyReminderTime);
}

class UserSettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<bool> hapticsEnabled;
  final Value<bool> soundEnabled;
  final Value<bool> onboardingCompleted;
  final Value<String?> onboardingGoal;
  final Value<String?> onboardingBrewer;
  final Value<String> themeMode;
  final Value<bool> tourSeen;
  final Value<String> tipsSeen;
  final Value<String?> learnerName;
  final Value<bool> notificationsEnabled;
  final Value<String?> dailyReminderTime;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.hapticsEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.onboardingGoal = const Value.absent(),
    this.onboardingBrewer = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.tourSeen = const Value.absent(),
    this.tipsSeen = const Value.absent(),
    this.learnerName = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailyReminderTime = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    required bool hapticsEnabled,
    required bool soundEnabled,
    this.onboardingCompleted = const Value.absent(),
    this.onboardingGoal = const Value.absent(),
    this.onboardingBrewer = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.tourSeen = const Value.absent(),
    this.tipsSeen = const Value.absent(),
    this.learnerName = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.dailyReminderTime = const Value.absent(),
  }) : hapticsEnabled = Value(hapticsEnabled),
       soundEnabled = Value(soundEnabled);
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<bool>? hapticsEnabled,
    Expression<bool>? soundEnabled,
    Expression<bool>? onboardingCompleted,
    Expression<String>? onboardingGoal,
    Expression<String>? onboardingBrewer,
    Expression<String>? themeMode,
    Expression<bool>? tourSeen,
    Expression<String>? tipsSeen,
    Expression<String>? learnerName,
    Expression<bool>? notificationsEnabled,
    Expression<String>? dailyReminderTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hapticsEnabled != null) 'haptics_enabled': hapticsEnabled,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (onboardingGoal != null) 'onboarding_goal': onboardingGoal,
      if (onboardingBrewer != null) 'onboarding_brewer': onboardingBrewer,
      if (themeMode != null) 'theme_mode': themeMode,
      if (tourSeen != null) 'tour_seen': tourSeen,
      if (tipsSeen != null) 'tips_seen': tipsSeen,
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
    Value<bool>? onboardingCompleted,
    Value<String?>? onboardingGoal,
    Value<String?>? onboardingBrewer,
    Value<String>? themeMode,
    Value<bool>? tourSeen,
    Value<String>? tipsSeen,
    Value<String?>? learnerName,
    Value<bool>? notificationsEnabled,
    Value<String?>? dailyReminderTime,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingGoal: onboardingGoal ?? this.onboardingGoal,
      onboardingBrewer: onboardingBrewer ?? this.onboardingBrewer,
      themeMode: themeMode ?? this.themeMode,
      tourSeen: tourSeen ?? this.tourSeen,
      tipsSeen: tipsSeen ?? this.tipsSeen,
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
    if (tipsSeen.present) {
      map['tips_seen'] = Variable<String>(tipsSeen.value);
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
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('onboardingGoal: $onboardingGoal, ')
          ..write('onboardingBrewer: $onboardingBrewer, ')
          ..write('themeMode: $themeMode, ')
          ..write('tourSeen: $tourSeen, ')
          ..write('tipsSeen: $tipsSeen, ')
          ..write('learnerName: $learnerName, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('dailyReminderTime: $dailyReminderTime')
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
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $ProgressSnapshotsTable progressSnapshots =
      $ProgressSnapshotsTable(this);
  late final $AppInstallsTable appInstalls = $AppInstallsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userSettings,
    progressSnapshots,
    appInstalls,
  ];
}

typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      required bool hapticsEnabled,
      required bool soundEnabled,
      Value<bool> onboardingCompleted,
      Value<String?> onboardingGoal,
      Value<String?> onboardingBrewer,
      Value<String> themeMode,
      Value<bool> tourSeen,
      Value<String> tipsSeen,
      Value<String?> learnerName,
      Value<bool> notificationsEnabled,
      Value<String?> dailyReminderTime,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<int> id,
      Value<bool> hapticsEnabled,
      Value<bool> soundEnabled,
      Value<bool> onboardingCompleted,
      Value<String?> onboardingGoal,
      Value<String?> onboardingBrewer,
      Value<String> themeMode,
      Value<bool> tourSeen,
      Value<String> tipsSeen,
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

  ColumnFilters<String> get tipsSeen => $composableBuilder(
    column: $table.tipsSeen,
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

  ColumnOrderings<String> get tipsSeen => $composableBuilder(
    column: $table.tipsSeen,
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

  GeneratedColumn<String> get tipsSeen =>
      $composableBuilder(column: $table.tipsSeen, builder: (column) => column);

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
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> onboardingGoal = const Value.absent(),
                Value<String?> onboardingBrewer = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> tourSeen = const Value.absent(),
                Value<String> tipsSeen = const Value.absent(),
                Value<String?> learnerName = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String?> dailyReminderTime = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                hapticsEnabled: hapticsEnabled,
                soundEnabled: soundEnabled,
                onboardingCompleted: onboardingCompleted,
                onboardingGoal: onboardingGoal,
                onboardingBrewer: onboardingBrewer,
                themeMode: themeMode,
                tourSeen: tourSeen,
                tipsSeen: tipsSeen,
                learnerName: learnerName,
                notificationsEnabled: notificationsEnabled,
                dailyReminderTime: dailyReminderTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool hapticsEnabled,
                required bool soundEnabled,
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String?> onboardingGoal = const Value.absent(),
                Value<String?> onboardingBrewer = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> tourSeen = const Value.absent(),
                Value<String> tipsSeen = const Value.absent(),
                Value<String?> learnerName = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String?> dailyReminderTime = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                hapticsEnabled: hapticsEnabled,
                soundEnabled: soundEnabled,
                onboardingCompleted: onboardingCompleted,
                onboardingGoal: onboardingGoal,
                onboardingBrewer: onboardingBrewer,
                themeMode: themeMode,
                tourSeen: tourSeen,
                tipsSeen: tipsSeen,
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
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$ProgressSnapshotsTableTableManager get progressSnapshots =>
      $$ProgressSnapshotsTableTableManager(_db, _db.progressSnapshots);
  $$AppInstallsTableTableManager get appInstalls =>
      $$AppInstallsTableTableManager(_db, _db.appInstalls);
}
