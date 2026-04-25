// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalTitleMeta = const VerificationMeta(
    'goalTitle',
  );
  @override
  late final GeneratedColumn<String> goalTitle = GeneratedColumn<String>(
    'goal_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalTargetHoursMeta = const VerificationMeta(
    'goalTargetHours',
  );
  @override
  late final GeneratedColumn<double> goalTargetHours = GeneratedColumn<double>(
    'goal_target_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalDeadlineMeta = const VerificationMeta(
    'goalDeadline',
  );
  @override
  late final GeneratedColumn<int> goalDeadline = GeneratedColumn<int>(
    'goal_deadline',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalIsActiveMeta = const VerificationMeta(
    'goalIsActive',
  );
  @override
  late final GeneratedColumn<bool> goalIsActive = GeneratedColumn<bool>(
    'goal_is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoTimerOnMeta = const VerificationMeta(
    'autoTimerOn',
  );
  @override
  late final GeneratedColumn<bool> autoTimerOn = GeneratedColumn<bool>(
    'auto_timer_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_timer_on" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    sortOrder,
    isVisible,
    memo,
    goalTitle,
    goalTargetHours,
    goalDeadline,
    goalIsActive,
    autoTimerOn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
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
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('goal_title')) {
      context.handle(
        _goalTitleMeta,
        goalTitle.isAcceptableOrUnknown(data['goal_title']!, _goalTitleMeta),
      );
    }
    if (data.containsKey('goal_target_hours')) {
      context.handle(
        _goalTargetHoursMeta,
        goalTargetHours.isAcceptableOrUnknown(
          data['goal_target_hours']!,
          _goalTargetHoursMeta,
        ),
      );
    }
    if (data.containsKey('goal_deadline')) {
      context.handle(
        _goalDeadlineMeta,
        goalDeadline.isAcceptableOrUnknown(
          data['goal_deadline']!,
          _goalDeadlineMeta,
        ),
      );
    }
    if (data.containsKey('goal_is_active')) {
      context.handle(
        _goalIsActiveMeta,
        goalIsActive.isAcceptableOrUnknown(
          data['goal_is_active']!,
          _goalIsActiveMeta,
        ),
      );
    }
    if (data.containsKey('auto_timer_on')) {
      context.handle(
        _autoTimerOnMeta,
        autoTimerOn.isAcceptableOrUnknown(
          data['auto_timer_on']!,
          _autoTimerOnMeta,
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
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      goalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_title'],
      ),
      goalTargetHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_target_hours'],
      ),
      goalDeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_deadline'],
      ),
      goalIsActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_is_active'],
      )!,
      autoTimerOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_timer_on'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;

  /// hex 색상 (예: '#FF5733')
  final String color;
  final int sortOrder;

  /// 사이드바 표시 여부 (기본: 표시)
  final bool isVisible;

  /// 월별 메모 (커미션 건수 등)
  final String? memo;

  /// 목표명
  final String? goalTitle;

  /// 목표 총 시간 (시간 단위)
  final double? goalTargetHours;

  /// 목표 마감일 (Unix timestamp, 날짜 기준)
  final int? goalDeadline;

  /// 목표 활성화 여부
  final bool goalIsActive;

  /// 포커스 자동 타이머가 idle 상태에서 이 카테고리를 자동 시작할지 여부
  final bool autoTimerOn;

  /// 생성 시각 (Unix timestamp)
  final int createdAt;
  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.isVisible,
    this.memo,
    this.goalTitle,
    this.goalTargetHours,
    this.goalDeadline,
    required this.goalIsActive,
    required this.autoTimerOn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_visible'] = Variable<bool>(isVisible);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || goalTitle != null) {
      map['goal_title'] = Variable<String>(goalTitle);
    }
    if (!nullToAbsent || goalTargetHours != null) {
      map['goal_target_hours'] = Variable<double>(goalTargetHours);
    }
    if (!nullToAbsent || goalDeadline != null) {
      map['goal_deadline'] = Variable<int>(goalDeadline);
    }
    map['goal_is_active'] = Variable<bool>(goalIsActive);
    map['auto_timer_on'] = Variable<bool>(autoTimerOn);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      isVisible: Value(isVisible),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      goalTitle: goalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(goalTitle),
      goalTargetHours: goalTargetHours == null && nullToAbsent
          ? const Value.absent()
          : Value(goalTargetHours),
      goalDeadline: goalDeadline == null && nullToAbsent
          ? const Value.absent()
          : Value(goalDeadline),
      goalIsActive: Value(goalIsActive),
      autoTimerOn: Value(autoTimerOn),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      memo: serializer.fromJson<String?>(json['memo']),
      goalTitle: serializer.fromJson<String?>(json['goalTitle']),
      goalTargetHours: serializer.fromJson<double?>(json['goalTargetHours']),
      goalDeadline: serializer.fromJson<int?>(json['goalDeadline']),
      goalIsActive: serializer.fromJson<bool>(json['goalIsActive']),
      autoTimerOn: serializer.fromJson<bool>(json['autoTimerOn']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isVisible': serializer.toJson<bool>(isVisible),
      'memo': serializer.toJson<String?>(memo),
      'goalTitle': serializer.toJson<String?>(goalTitle),
      'goalTargetHours': serializer.toJson<double?>(goalTargetHours),
      'goalDeadline': serializer.toJson<int?>(goalDeadline),
      'goalIsActive': serializer.toJson<bool>(goalIsActive),
      'autoTimerOn': serializer.toJson<bool>(autoTimerOn),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? color,
    int? sortOrder,
    bool? isVisible,
    Value<String?> memo = const Value.absent(),
    Value<String?> goalTitle = const Value.absent(),
    Value<double?> goalTargetHours = const Value.absent(),
    Value<int?> goalDeadline = const Value.absent(),
    bool? goalIsActive,
    bool? autoTimerOn,
    int? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    isVisible: isVisible ?? this.isVisible,
    memo: memo.present ? memo.value : this.memo,
    goalTitle: goalTitle.present ? goalTitle.value : this.goalTitle,
    goalTargetHours: goalTargetHours.present
        ? goalTargetHours.value
        : this.goalTargetHours,
    goalDeadline: goalDeadline.present ? goalDeadline.value : this.goalDeadline,
    goalIsActive: goalIsActive ?? this.goalIsActive,
    autoTimerOn: autoTimerOn ?? this.autoTimerOn,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      memo: data.memo.present ? data.memo.value : this.memo,
      goalTitle: data.goalTitle.present ? data.goalTitle.value : this.goalTitle,
      goalTargetHours: data.goalTargetHours.present
          ? data.goalTargetHours.value
          : this.goalTargetHours,
      goalDeadline: data.goalDeadline.present
          ? data.goalDeadline.value
          : this.goalDeadline,
      goalIsActive: data.goalIsActive.present
          ? data.goalIsActive.value
          : this.goalIsActive,
      autoTimerOn: data.autoTimerOn.present
          ? data.autoTimerOn.value
          : this.autoTimerOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isVisible: $isVisible, ')
          ..write('memo: $memo, ')
          ..write('goalTitle: $goalTitle, ')
          ..write('goalTargetHours: $goalTargetHours, ')
          ..write('goalDeadline: $goalDeadline, ')
          ..write('goalIsActive: $goalIsActive, ')
          ..write('autoTimerOn: $autoTimerOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    color,
    sortOrder,
    isVisible,
    memo,
    goalTitle,
    goalTargetHours,
    goalDeadline,
    goalIsActive,
    autoTimerOn,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.isVisible == this.isVisible &&
          other.memo == this.memo &&
          other.goalTitle == this.goalTitle &&
          other.goalTargetHours == this.goalTargetHours &&
          other.goalDeadline == this.goalDeadline &&
          other.goalIsActive == this.goalIsActive &&
          other.autoTimerOn == this.autoTimerOn &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<bool> isVisible;
  final Value<String?> memo;
  final Value<String?> goalTitle;
  final Value<double?> goalTargetHours;
  final Value<int?> goalDeadline;
  final Value<bool> goalIsActive;
  final Value<bool> autoTimerOn;
  final Value<int> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.memo = const Value.absent(),
    this.goalTitle = const Value.absent(),
    this.goalTargetHours = const Value.absent(),
    this.goalDeadline = const Value.absent(),
    this.goalIsActive = const Value.absent(),
    this.autoTimerOn = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String color,
    required int sortOrder,
    this.isVisible = const Value.absent(),
    this.memo = const Value.absent(),
    this.goalTitle = const Value.absent(),
    this.goalTargetHours = const Value.absent(),
    this.goalDeadline = const Value.absent(),
    this.goalIsActive = const Value.absent(),
    this.autoTimerOn = const Value.absent(),
    required int createdAt,
  }) : name = Value(name),
       color = Value(color),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<bool>? isVisible,
    Expression<String>? memo,
    Expression<String>? goalTitle,
    Expression<double>? goalTargetHours,
    Expression<int>? goalDeadline,
    Expression<bool>? goalIsActive,
    Expression<bool>? autoTimerOn,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isVisible != null) 'is_visible': isVisible,
      if (memo != null) 'memo': memo,
      if (goalTitle != null) 'goal_title': goalTitle,
      if (goalTargetHours != null) 'goal_target_hours': goalTargetHours,
      if (goalDeadline != null) 'goal_deadline': goalDeadline,
      if (goalIsActive != null) 'goal_is_active': goalIsActive,
      if (autoTimerOn != null) 'auto_timer_on': autoTimerOn,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<bool>? isVisible,
    Value<String?>? memo,
    Value<String?>? goalTitle,
    Value<double?>? goalTargetHours,
    Value<int?>? goalDeadline,
    Value<bool>? goalIsActive,
    Value<bool>? autoTimerOn,
    Value<int>? createdAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isVisible: isVisible ?? this.isVisible,
      memo: memo ?? this.memo,
      goalTitle: goalTitle ?? this.goalTitle,
      goalTargetHours: goalTargetHours ?? this.goalTargetHours,
      goalDeadline: goalDeadline ?? this.goalDeadline,
      goalIsActive: goalIsActive ?? this.goalIsActive,
      autoTimerOn: autoTimerOn ?? this.autoTimerOn,
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
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (goalTitle.present) {
      map['goal_title'] = Variable<String>(goalTitle.value);
    }
    if (goalTargetHours.present) {
      map['goal_target_hours'] = Variable<double>(goalTargetHours.value);
    }
    if (goalDeadline.present) {
      map['goal_deadline'] = Variable<int>(goalDeadline.value);
    }
    if (goalIsActive.present) {
      map['goal_is_active'] = Variable<bool>(goalIsActive.value);
    }
    if (autoTimerOn.present) {
      map['auto_timer_on'] = Variable<bool>(autoTimerOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isVisible: $isVisible, ')
          ..write('memo: $memo, ')
          ..write('goalTitle: $goalTitle, ')
          ..write('goalTargetHours: $goalTargetHours, ')
          ..write('goalDeadline: $goalDeadline, ')
          ..write('goalIsActive: $goalIsActive, ')
          ..write('autoTimerOn: $autoTimerOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShortcutsTable extends Shortcuts
    with TableInfo<$ShortcutsTable, Shortcut> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShortcutsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autoStartMeta = const VerificationMeta(
    'autoStart',
  );
  @override
  late final GeneratedColumn<bool> autoStart = GeneratedColumn<bool>(
    'auto_start',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_start" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    target,
    type,
    sortOrder,
    autoStart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shortcuts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shortcut> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('auto_start')) {
      context.handle(
        _autoStartMeta,
        autoStart.isAcceptableOrUnknown(data['auto_start']!, _autoStartMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shortcut map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shortcut(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      autoStart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_start'],
      )!,
    );
  }

  @override
  $ShortcutsTable createAlias(String alias) {
    return $ShortcutsTable(attachedDatabase, alias);
  }
}

class Shortcut extends DataClass implements Insertable<Shortcut> {
  final int id;

  /// 소속 카테고리 (CASCADE 삭제)
  final int categoryId;
  final String name;

  /// URL 또는 exe 절대경로
  final String target;

  /// 'web' | 'exe'
  final String type;
  final int sortOrder;

  /// 포커스 시 자동 시작 여부 (기본 true)
  final bool autoStart;
  const Shortcut({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.target,
    required this.type,
    required this.sortOrder,
    required this.autoStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['target'] = Variable<String>(target);
    map['type'] = Variable<String>(type);
    map['sort_order'] = Variable<int>(sortOrder);
    map['auto_start'] = Variable<bool>(autoStart);
    return map;
  }

  ShortcutsCompanion toCompanion(bool nullToAbsent) {
    return ShortcutsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      target: Value(target),
      type: Value(type),
      sortOrder: Value(sortOrder),
      autoStart: Value(autoStart),
    );
  }

  factory Shortcut.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shortcut(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      target: serializer.fromJson<String>(json['target']),
      type: serializer.fromJson<String>(json['type']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      autoStart: serializer.fromJson<bool>(json['autoStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'target': serializer.toJson<String>(target),
      'type': serializer.toJson<String>(type),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'autoStart': serializer.toJson<bool>(autoStart),
    };
  }

  Shortcut copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? target,
    String? type,
    int? sortOrder,
    bool? autoStart,
  }) => Shortcut(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    target: target ?? this.target,
    type: type ?? this.type,
    sortOrder: sortOrder ?? this.sortOrder,
    autoStart: autoStart ?? this.autoStart,
  );
  Shortcut copyWithCompanion(ShortcutsCompanion data) {
    return Shortcut(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      target: data.target.present ? data.target.value : this.target,
      type: data.type.present ? data.type.value : this.type,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      autoStart: data.autoStart.present ? data.autoStart.value : this.autoStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shortcut(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('target: $target, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('autoStart: $autoStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, categoryId, name, target, type, sortOrder, autoStart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shortcut &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.target == this.target &&
          other.type == this.type &&
          other.sortOrder == this.sortOrder &&
          other.autoStart == this.autoStart);
}

class ShortcutsCompanion extends UpdateCompanion<Shortcut> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<String> target;
  final Value<String> type;
  final Value<int> sortOrder;
  final Value<bool> autoStart;
  const ShortcutsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.target = const Value.absent(),
    this.type = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.autoStart = const Value.absent(),
  });
  ShortcutsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    required String target,
    required String type,
    required int sortOrder,
    this.autoStart = const Value.absent(),
  }) : categoryId = Value(categoryId),
       name = Value(name),
       target = Value(target),
       type = Value(type),
       sortOrder = Value(sortOrder);
  static Insertable<Shortcut> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<String>? target,
    Expression<String>? type,
    Expression<int>? sortOrder,
    Expression<bool>? autoStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (target != null) 'target': target,
      if (type != null) 'type': type,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (autoStart != null) 'auto_start': autoStart,
    });
  }

  ShortcutsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? name,
    Value<String>? target,
    Value<String>? type,
    Value<int>? sortOrder,
    Value<bool>? autoStart,
  }) {
    return ShortcutsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      target: target ?? this.target,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      autoStart: autoStart ?? this.autoStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (autoStart.present) {
      map['auto_start'] = Variable<bool>(autoStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShortcutsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('target: $target, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('autoStart: $autoStart')
          ..write(')'))
        .toString();
  }
}

class $TimerSessionsTable extends TimerSessions
    with TableInfo<$TimerSessionsTable, TimerSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFocusMeta = const VerificationMeta(
    'isFocus',
  );
  @override
  late final GeneratedColumn<bool> isFocus = GeneratedColumn<bool>(
    'is_focus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_focus" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    startedAt,
    endedAt,
    durationSec,
    mode,
    isFocus,
    memo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('is_focus')) {
      context.handle(
        _isFocusMeta,
        isFocus.isAcceptableOrUnknown(data['is_focus']!, _isFocusMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      isFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_focus'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
    );
  }

  @override
  $TimerSessionsTable createAlias(String alias) {
    return $TimerSessionsTable(attachedDatabase, alias);
  }
}

class TimerSession extends DataClass implements Insertable<TimerSession> {
  final int id;

  /// 소속 카테고리 (CASCADE 삭제)
  final int categoryId;

  /// 세션 시작 시각 (Unix timestamp)
  final int startedAt;

  /// 세션 종료 시각 (null이면 진행 중)
  final int? endedAt;

  /// 종료 시 계산하여 저장 (초 단위)
  final int? durationSec;

  /// 'normal' | 'pomodoro'
  final String mode;

  /// 집중 여부 (false = 휴식, 통계 집계 제외)
  final bool isFocus;

  /// 세션 종료 후 사용자가 남기는 메모 (선택 사항)
  final String? memo;
  const TimerSession({
    required this.id,
    required this.categoryId,
    required this.startedAt,
    this.endedAt,
    this.durationSec,
    required this.mode,
    required this.isFocus,
    this.memo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    map['mode'] = Variable<String>(mode);
    map['is_focus'] = Variable<bool>(isFocus);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  TimerSessionsCompanion toCompanion(bool nullToAbsent) {
    return TimerSessionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSec: durationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSec),
      mode: Value(mode),
      isFocus: Value(isFocus),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory TimerSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerSession(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
      mode: serializer.fromJson<String>(json['mode']),
      isFocus: serializer.fromJson<bool>(json['isFocus']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'durationSec': serializer.toJson<int?>(durationSec),
      'mode': serializer.toJson<String>(mode),
      'isFocus': serializer.toJson<bool>(isFocus),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  TimerSession copyWith({
    int? id,
    int? categoryId,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    Value<int?> durationSec = const Value.absent(),
    String? mode,
    bool? isFocus,
    Value<String?> memo = const Value.absent(),
  }) => TimerSession(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationSec: durationSec.present ? durationSec.value : this.durationSec,
    mode: mode ?? this.mode,
    isFocus: isFocus ?? this.isFocus,
    memo: memo.present ? memo.value : this.memo,
  );
  TimerSession copyWithCompanion(TimerSessionsCompanion data) {
    return TimerSession(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      mode: data.mode.present ? data.mode.value : this.mode,
      isFocus: data.isFocus.present ? data.isFocus.value : this.isFocus,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerSession(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('mode: $mode, ')
          ..write('isFocus: $isFocus, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    startedAt,
    endedAt,
    durationSec,
    mode,
    isFocus,
    memo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerSession &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSec == this.durationSec &&
          other.mode == this.mode &&
          other.isFocus == this.isFocus &&
          other.memo == this.memo);
}

class TimerSessionsCompanion extends UpdateCompanion<TimerSession> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int?> durationSec;
  final Value<String> mode;
  final Value<bool> isFocus;
  final Value<String?> memo;
  const TimerSessionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.mode = const Value.absent(),
    this.isFocus = const Value.absent(),
    this.memo = const Value.absent(),
  });
  TimerSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.durationSec = const Value.absent(),
    required String mode,
    this.isFocus = const Value.absent(),
    this.memo = const Value.absent(),
  }) : categoryId = Value(categoryId),
       startedAt = Value(startedAt),
       mode = Value(mode);
  static Insertable<TimerSession> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? durationSec,
    Expression<String>? mode,
    Expression<bool>? isFocus,
    Expression<String>? memo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSec != null) 'duration_sec': durationSec,
      if (mode != null) 'mode': mode,
      if (isFocus != null) 'is_focus': isFocus,
      if (memo != null) 'memo': memo,
    });
  }

  TimerSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int?>? durationSec,
    Value<String>? mode,
    Value<bool>? isFocus,
    Value<String?>? memo,
  }) {
    return TimerSessionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSec: durationSec ?? this.durationSec,
      mode: mode ?? this.mode,
      isFocus: isFocus ?? this.isFocus,
      memo: memo ?? this.memo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (isFocus.present) {
      map['is_focus'] = Variable<bool>(isFocus.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerSessionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('mode: $mode, ')
          ..write('isFocus: $isFocus, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }
}

class $ConditionLogsTable extends ConditionLogs
    with TableInfo<$ConditionLogsTable, ConditionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConditionLogsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, level];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'condition_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConditionLog> instance, {
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
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConditionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConditionLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
    );
  }

  @override
  $ConditionLogsTable createAlias(String alias) {
    return $ConditionLogsTable(attachedDatabase, alias);
  }
}

class ConditionLog extends DataClass implements Insertable<ConditionLog> {
  final int id;

  /// 날짜 (YYYY-MM-DD), 하루 1건 고유
  final String date;

  /// 컨디션 수준 1~5
  final int level;
  const ConditionLog({
    required this.id,
    required this.date,
    required this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['level'] = Variable<int>(level);
    return map;
  }

  ConditionLogsCompanion toCompanion(bool nullToAbsent) {
    return ConditionLogsCompanion(
      id: Value(id),
      date: Value(date),
      level: Value(level),
    );
  }

  factory ConditionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConditionLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'level': serializer.toJson<int>(level),
    };
  }

  ConditionLog copyWith({int? id, String? date, int? level}) => ConditionLog(
    id: id ?? this.id,
    date: date ?? this.date,
    level: level ?? this.level,
  );
  ConditionLog copyWithCompanion(ConditionLogsCompanion data) {
    return ConditionLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConditionLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConditionLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.level == this.level);
}

class ConditionLogsCompanion extends UpdateCompanion<ConditionLog> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> level;
  const ConditionLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.level = const Value.absent(),
  });
  ConditionLogsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required int level,
  }) : date = Value(date),
       level = Value(level);
  static Insertable<ConditionLog> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? level,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (level != null) 'level': level,
    });
  }

  ConditionLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? level,
  }) {
    return ConditionLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      level: level ?? this.level,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConditionLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  /// 설정 키 (Primary Key)
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ShortcutsTable shortcuts = $ShortcutsTable(this);
  late final $TimerSessionsTable timerSessions = $TimerSessionsTable(this);
  late final $ConditionLogsTable conditionLogs = $ConditionLogsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    shortcuts,
    timerSessions,
    conditionLogs,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shortcuts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timer_sessions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String color,
      required int sortOrder,
      Value<bool> isVisible,
      Value<String?> memo,
      Value<String?> goalTitle,
      Value<double?> goalTargetHours,
      Value<int?> goalDeadline,
      Value<bool> goalIsActive,
      Value<bool> autoTimerOn,
      required int createdAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> color,
      Value<int> sortOrder,
      Value<bool> isVisible,
      Value<String?> memo,
      Value<String?> goalTitle,
      Value<double?> goalTargetHours,
      Value<int?> goalDeadline,
      Value<bool> goalIsActive,
      Value<bool> autoTimerOn,
      Value<int> createdAt,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShortcutsTable, List<Shortcut>>
  _shortcutsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shortcuts,
    aliasName: $_aliasNameGenerator(db.categories.id, db.shortcuts.categoryId),
  );

  $$ShortcutsTableProcessedTableManager get shortcutsRefs {
    final manager = $$ShortcutsTableTableManager(
      $_db,
      $_db.shortcuts,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shortcutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimerSessionsTable, List<TimerSession>>
  _timerSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timerSessions,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.timerSessions.categoryId,
    ),
  );

  $$TimerSessionsTableProcessedTableManager get timerSessionsRefs {
    final manager = $$TimerSessionsTableTableManager(
      $_db,
      $_db.timerSessions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timerSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalTitle => $composableBuilder(
    column: $table.goalTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalTargetHours => $composableBuilder(
    column: $table.goalTargetHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalDeadline => $composableBuilder(
    column: $table.goalDeadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalIsActive => $composableBuilder(
    column: $table.goalIsActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoTimerOn => $composableBuilder(
    column: $table.autoTimerOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shortcutsRefs(
    Expression<bool> Function($$ShortcutsTableFilterComposer f) f,
  ) {
    final $$ShortcutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortcuts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortcutsTableFilterComposer(
            $db: $db,
            $table: $db.shortcuts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timerSessionsRefs(
    Expression<bool> Function($$TimerSessionsTableFilterComposer f) f,
  ) {
    final $$TimerSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerSessions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerSessionsTableFilterComposer(
            $db: $db,
            $table: $db.timerSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalTitle => $composableBuilder(
    column: $table.goalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalTargetHours => $composableBuilder(
    column: $table.goalTargetHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalDeadline => $composableBuilder(
    column: $table.goalDeadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalIsActive => $composableBuilder(
    column: $table.goalIsActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoTimerOn => $composableBuilder(
    column: $table.autoTimerOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get goalTitle =>
      $composableBuilder(column: $table.goalTitle, builder: (column) => column);

  GeneratedColumn<double> get goalTargetHours => $composableBuilder(
    column: $table.goalTargetHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalDeadline => $composableBuilder(
    column: $table.goalDeadline,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get goalIsActive => $composableBuilder(
    column: $table.goalIsActive,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoTimerOn => $composableBuilder(
    column: $table.autoTimerOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> shortcutsRefs<T extends Object>(
    Expression<T> Function($$ShortcutsTableAnnotationComposer a) f,
  ) {
    final $$ShortcutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortcuts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortcutsTableAnnotationComposer(
            $db: $db,
            $table: $db.shortcuts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timerSessionsRefs<T extends Object>(
    Expression<T> Function($$TimerSessionsTableAnnotationComposer a) f,
  ) {
    final $$TimerSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timerSessions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimerSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.timerSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool shortcutsRefs, bool timerSessionsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> goalTitle = const Value.absent(),
                Value<double?> goalTargetHours = const Value.absent(),
                Value<int?> goalDeadline = const Value.absent(),
                Value<bool> goalIsActive = const Value.absent(),
                Value<bool> autoTimerOn = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                isVisible: isVisible,
                memo: memo,
                goalTitle: goalTitle,
                goalTargetHours: goalTargetHours,
                goalDeadline: goalDeadline,
                goalIsActive: goalIsActive,
                autoTimerOn: autoTimerOn,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String color,
                required int sortOrder,
                Value<bool> isVisible = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> goalTitle = const Value.absent(),
                Value<double?> goalTargetHours = const Value.absent(),
                Value<int?> goalDeadline = const Value.absent(),
                Value<bool> goalIsActive = const Value.absent(),
                Value<bool> autoTimerOn = const Value.absent(),
                required int createdAt,
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                isVisible: isVisible,
                memo: memo,
                goalTitle: goalTitle,
                goalTargetHours: goalTargetHours,
                goalDeadline: goalDeadline,
                goalIsActive: goalIsActive,
                autoTimerOn: autoTimerOn,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({shortcutsRefs = false, timerSessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (shortcutsRefs) db.shortcuts,
                    if (timerSessionsRefs) db.timerSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (shortcutsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Shortcut
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._shortcutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).shortcutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timerSessionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          TimerSession
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._timerSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).timerSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool shortcutsRefs, bool timerSessionsRefs})
    >;
typedef $$ShortcutsTableCreateCompanionBuilder =
    ShortcutsCompanion Function({
      Value<int> id,
      required int categoryId,
      required String name,
      required String target,
      required String type,
      required int sortOrder,
      Value<bool> autoStart,
    });
typedef $$ShortcutsTableUpdateCompanionBuilder =
    ShortcutsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> name,
      Value<String> target,
      Value<String> type,
      Value<int> sortOrder,
      Value<bool> autoStart,
    });

final class $$ShortcutsTableReferences
    extends BaseReferences<_$AppDatabase, $ShortcutsTable, Shortcut> {
  $$ShortcutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.shortcuts.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShortcutsTableFilterComposer
    extends Composer<_$AppDatabase, $ShortcutsTable> {
  $$ShortcutsTableFilterComposer({
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

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoStart => $composableBuilder(
    column: $table.autoStart,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortcutsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShortcutsTable> {
  $$ShortcutsTableOrderingComposer({
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

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoStart => $composableBuilder(
    column: $table.autoStart,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortcutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShortcutsTable> {
  $$ShortcutsTableAnnotationComposer({
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

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get autoStart =>
      $composableBuilder(column: $table.autoStart, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortcutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShortcutsTable,
          Shortcut,
          $$ShortcutsTableFilterComposer,
          $$ShortcutsTableOrderingComposer,
          $$ShortcutsTableAnnotationComposer,
          $$ShortcutsTableCreateCompanionBuilder,
          $$ShortcutsTableUpdateCompanionBuilder,
          (Shortcut, $$ShortcutsTableReferences),
          Shortcut,
          PrefetchHooks Function({bool categoryId})
        > {
  $$ShortcutsTableTableManager(_$AppDatabase db, $ShortcutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShortcutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShortcutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShortcutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> autoStart = const Value.absent(),
              }) => ShortcutsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                target: target,
                type: type,
                sortOrder: sortOrder,
                autoStart: autoStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String name,
                required String target,
                required String type,
                required int sortOrder,
                Value<bool> autoStart = const Value.absent(),
              }) => ShortcutsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                target: target,
                type: type,
                sortOrder: sortOrder,
                autoStart: autoStart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShortcutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$ShortcutsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$ShortcutsTableReferences
                                    ._categoryIdTable(db)
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

typedef $$ShortcutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShortcutsTable,
      Shortcut,
      $$ShortcutsTableFilterComposer,
      $$ShortcutsTableOrderingComposer,
      $$ShortcutsTableAnnotationComposer,
      $$ShortcutsTableCreateCompanionBuilder,
      $$ShortcutsTableUpdateCompanionBuilder,
      (Shortcut, $$ShortcutsTableReferences),
      Shortcut,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$TimerSessionsTableCreateCompanionBuilder =
    TimerSessionsCompanion Function({
      Value<int> id,
      required int categoryId,
      required int startedAt,
      Value<int?> endedAt,
      Value<int?> durationSec,
      required String mode,
      Value<bool> isFocus,
      Value<String?> memo,
    });
typedef $$TimerSessionsTableUpdateCompanionBuilder =
    TimerSessionsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<int?> durationSec,
      Value<String> mode,
      Value<bool> isFocus,
      Value<String?> memo,
    });

final class $$TimerSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $TimerSessionsTable, TimerSession> {
  $$TimerSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.timerSessions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimerSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TimerSessionsTable> {
  $$TimerSessionsTableFilterComposer({
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

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFocus => $composableBuilder(
    column: $table.isFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerSessionsTable> {
  $$TimerSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFocus => $composableBuilder(
    column: $table.isFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerSessionsTable> {
  $$TimerSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<bool> get isFocus =>
      $composableBuilder(column: $table.isFocus, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimerSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerSessionsTable,
          TimerSession,
          $$TimerSessionsTableFilterComposer,
          $$TimerSessionsTableOrderingComposer,
          $$TimerSessionsTableAnnotationComposer,
          $$TimerSessionsTableCreateCompanionBuilder,
          $$TimerSessionsTableUpdateCompanionBuilder,
          (TimerSession, $$TimerSessionsTableReferences),
          TimerSession,
          PrefetchHooks Function({bool categoryId})
        > {
  $$TimerSessionsTableTableManager(_$AppDatabase db, $TimerSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> isFocus = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => TimerSessionsCompanion(
                id: id,
                categoryId: categoryId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSec: durationSec,
                mode: mode,
                isFocus: isFocus,
                memo: memo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                required String mode,
                Value<bool> isFocus = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => TimerSessionsCompanion.insert(
                id: id,
                categoryId: categoryId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSec: durationSec,
                mode: mode,
                isFocus: isFocus,
                memo: memo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimerSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$TimerSessionsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$TimerSessionsTableReferences
                                    ._categoryIdTable(db)
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

typedef $$TimerSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerSessionsTable,
      TimerSession,
      $$TimerSessionsTableFilterComposer,
      $$TimerSessionsTableOrderingComposer,
      $$TimerSessionsTableAnnotationComposer,
      $$TimerSessionsTableCreateCompanionBuilder,
      $$TimerSessionsTableUpdateCompanionBuilder,
      (TimerSession, $$TimerSessionsTableReferences),
      TimerSession,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$ConditionLogsTableCreateCompanionBuilder =
    ConditionLogsCompanion Function({
      Value<int> id,
      required String date,
      required int level,
    });
typedef $$ConditionLogsTableUpdateCompanionBuilder =
    ConditionLogsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<int> level,
    });

class $$ConditionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ConditionLogsTable> {
  $$ConditionLogsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConditionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConditionLogsTable> {
  $$ConditionLogsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConditionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConditionLogsTable> {
  $$ConditionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);
}

class $$ConditionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConditionLogsTable,
          ConditionLog,
          $$ConditionLogsTableFilterComposer,
          $$ConditionLogsTableOrderingComposer,
          $$ConditionLogsTableAnnotationComposer,
          $$ConditionLogsTableCreateCompanionBuilder,
          $$ConditionLogsTableUpdateCompanionBuilder,
          (
            ConditionLog,
            BaseReferences<_$AppDatabase, $ConditionLogsTable, ConditionLog>,
          ),
          ConditionLog,
          PrefetchHooks Function()
        > {
  $$ConditionLogsTableTableManager(_$AppDatabase db, $ConditionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConditionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConditionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConditionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> level = const Value.absent(),
              }) => ConditionLogsCompanion(id: id, date: date, level: level),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required int level,
              }) => ConditionLogsCompanion.insert(
                id: id,
                date: date,
                level: level,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConditionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConditionLogsTable,
      ConditionLog,
      $$ConditionLogsTableFilterComposer,
      $$ConditionLogsTableOrderingComposer,
      $$ConditionLogsTableAnnotationComposer,
      $$ConditionLogsTableCreateCompanionBuilder,
      $$ConditionLogsTableUpdateCompanionBuilder,
      (
        ConditionLog,
        BaseReferences<_$AppDatabase, $ConditionLogsTable, ConditionLog>,
      ),
      ConditionLog,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ShortcutsTableTableManager get shortcuts =>
      $$ShortcutsTableTableManager(_db, _db.shortcuts);
  $$TimerSessionsTableTableManager get timerSessions =>
      $$TimerSessionsTableTableManager(_db, _db.timerSessions);
  $$ConditionLogsTableTableManager get conditionLogs =>
      $$ConditionLogsTableTableManager(_db, _db.conditionLogs);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
