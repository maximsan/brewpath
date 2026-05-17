// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSettingsRecordCollection on Isar {
  IsarCollection<UserSettingsRecord> get userSettingsRecords =>
      this.collection();
}

const UserSettingsRecordSchema = CollectionSchema(
  name: r'UserSettingsRecord',
  id: -8212927064696236102,
  properties: {
    r'hapticsEnabled': PropertySchema(
      id: 0,
      name: r'hapticsEnabled',
      type: IsarType.bool,
    ),
    r'lastActivityDate': PropertySchema(
      id: 1,
      name: r'lastActivityDate',
      type: IsarType.dateTime,
    ),
    r'soundEnabled': PropertySchema(
      id: 2,
      name: r'soundEnabled',
      type: IsarType.bool,
    ),
    r'streakDays': PropertySchema(
      id: 3,
      name: r'streakDays',
      type: IsarType.long,
    ),
    r'totalXp': PropertySchema(
      id: 4,
      name: r'totalXp',
      type: IsarType.long,
    )
  },
  estimateSize: _userSettingsRecordEstimateSize,
  serialize: _userSettingsRecordSerialize,
  deserialize: _userSettingsRecordDeserialize,
  deserializeProp: _userSettingsRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userSettingsRecordGetId,
  getLinks: _userSettingsRecordGetLinks,
  attach: _userSettingsRecordAttach,
  version: '3.1.0+1',
);

int _userSettingsRecordEstimateSize(
  UserSettingsRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userSettingsRecordSerialize(
  UserSettingsRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hapticsEnabled);
  writer.writeDateTime(offsets[1], object.lastActivityDate);
  writer.writeBool(offsets[2], object.soundEnabled);
  writer.writeLong(offsets[3], object.streakDays);
  writer.writeLong(offsets[4], object.totalXp);
}

UserSettingsRecord _userSettingsRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSettingsRecord();
  object.hapticsEnabled = reader.readBool(offsets[0]);
  object.id = id;
  object.lastActivityDate = reader.readDateTimeOrNull(offsets[1]);
  object.soundEnabled = reader.readBool(offsets[2]);
  object.streakDays = reader.readLong(offsets[3]);
  object.totalXp = reader.readLong(offsets[4]);
  return object;
}

P _userSettingsRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userSettingsRecordGetId(UserSettingsRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSettingsRecordGetLinks(
    UserSettingsRecord object) {
  return [];
}

void _userSettingsRecordAttach(
    IsarCollection<dynamic> col, Id id, UserSettingsRecord object) {
  object.id = id;
}

extension UserSettingsRecordQueryWhereSort
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QWhere> {
  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSettingsRecordQueryWhere
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QWhereClause> {
  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserSettingsRecordQueryFilter
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QFilterCondition> {
  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      hapticsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hapticsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      lastActivityDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastActivityDate',
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      lastActivityDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastActivityDate',
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      lastActivityDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      lastActivityDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      lastActivityDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      lastActivityDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastActivityDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      soundEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      streakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      streakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      streakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      streakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      totalXpEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalXp',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      totalXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalXp',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      totalXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalXp',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterFilterCondition>
      totalXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserSettingsRecordQueryObject
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QFilterCondition> {}

extension UserSettingsRecordQueryLinks
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QFilterCondition> {}

extension UserSettingsRecordQuerySortBy
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QSortBy> {
  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByHapticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByHapticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortBySoundEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortBySoundEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      sortByTotalXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.desc);
    });
  }
}

extension UserSettingsRecordQuerySortThenBy
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QSortThenBy> {
  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByHapticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByHapticsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hapticsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenBySoundEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenBySoundEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QAfterSortBy>
      thenByTotalXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.desc);
    });
  }
}

extension UserSettingsRecordQueryWhereDistinct
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QDistinct> {
  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QDistinct>
      distinctByHapticsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hapticsEnabled');
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QDistinct>
      distinctByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastActivityDate');
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QDistinct>
      distinctBySoundEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'soundEnabled');
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QDistinct>
      distinctByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakDays');
    });
  }

  QueryBuilder<UserSettingsRecord, UserSettingsRecord, QDistinct>
      distinctByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalXp');
    });
  }
}

extension UserSettingsRecordQueryProperty
    on QueryBuilder<UserSettingsRecord, UserSettingsRecord, QQueryProperty> {
  QueryBuilder<UserSettingsRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSettingsRecord, bool, QQueryOperations>
      hapticsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hapticsEnabled');
    });
  }

  QueryBuilder<UserSettingsRecord, DateTime?, QQueryOperations>
      lastActivityDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastActivityDate');
    });
  }

  QueryBuilder<UserSettingsRecord, bool, QQueryOperations>
      soundEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'soundEnabled');
    });
  }

  QueryBuilder<UserSettingsRecord, int, QQueryOperations> streakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakDays');
    });
  }

  QueryBuilder<UserSettingsRecord, int, QQueryOperations> totalXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalXp');
    });
  }
}
