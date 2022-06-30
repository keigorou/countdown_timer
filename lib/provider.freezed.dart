// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TrainingMenu _$TrainingMenuFromJson(Map<String, dynamic> json) {
  return _TrainingMenu.fromJson(json);
}

/// @nodoc
mixin _$TrainingMenu {
  int get time => throw _privateConstructorUsedError;
  String get trainingName => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingMenuCopyWith<TrainingMenu> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingMenuCopyWith<$Res> {
  factory $TrainingMenuCopyWith(
          TrainingMenu value, $Res Function(TrainingMenu) then) =
      _$TrainingMenuCopyWithImpl<$Res>;
  $Res call(
      {int time, String trainingName, String imagePath, String description});
}

/// @nodoc
class _$TrainingMenuCopyWithImpl<$Res> implements $TrainingMenuCopyWith<$Res> {
  _$TrainingMenuCopyWithImpl(this._value, this._then);

  final TrainingMenu _value;
  // ignore: unused_field
  final $Res Function(TrainingMenu) _then;

  @override
  $Res call({
    Object? time = freezed,
    Object? trainingName = freezed,
    Object? imagePath = freezed,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      time: time == freezed
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      trainingName: trainingName == freezed
          ? _value.trainingName
          : trainingName // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: imagePath == freezed
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_TrainingMenuCopyWith<$Res>
    implements $TrainingMenuCopyWith<$Res> {
  factory _$$_TrainingMenuCopyWith(
          _$_TrainingMenu value, $Res Function(_$_TrainingMenu) then) =
      __$$_TrainingMenuCopyWithImpl<$Res>;
  @override
  $Res call(
      {int time, String trainingName, String imagePath, String description});
}

/// @nodoc
class __$$_TrainingMenuCopyWithImpl<$Res>
    extends _$TrainingMenuCopyWithImpl<$Res>
    implements _$$_TrainingMenuCopyWith<$Res> {
  __$$_TrainingMenuCopyWithImpl(
      _$_TrainingMenu _value, $Res Function(_$_TrainingMenu) _then)
      : super(_value, (v) => _then(v as _$_TrainingMenu));

  @override
  _$_TrainingMenu get _value => super._value as _$_TrainingMenu;

  @override
  $Res call({
    Object? time = freezed,
    Object? trainingName = freezed,
    Object? imagePath = freezed,
    Object? description = freezed,
  }) {
    return _then(_$_TrainingMenu(
      time: time == freezed
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      trainingName: trainingName == freezed
          ? _value.trainingName
          : trainingName // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: imagePath == freezed
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      description: description == freezed
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TrainingMenu with DiagnosticableTreeMixin implements _TrainingMenu {
  const _$_TrainingMenu(
      {this.time = 30,
      this.trainingName = '',
      this.imagePath = '',
      this.description = ''});

  factory _$_TrainingMenu.fromJson(Map<String, dynamic> json) =>
      _$$_TrainingMenuFromJson(json);

  @override
  @JsonKey()
  final int time;
  @override
  @JsonKey()
  final String trainingName;
  @override
  @JsonKey()
  final String imagePath;
  @override
  @JsonKey()
  final String description;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TrainingMenu(time: $time, trainingName: $trainingName, imagePath: $imagePath, description: $description)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TrainingMenu'))
      ..add(DiagnosticsProperty('time', time))
      ..add(DiagnosticsProperty('trainingName', trainingName))
      ..add(DiagnosticsProperty('imagePath', imagePath))
      ..add(DiagnosticsProperty('description', description));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TrainingMenu &&
            const DeepCollectionEquality().equals(other.time, time) &&
            const DeepCollectionEquality()
                .equals(other.trainingName, trainingName) &&
            const DeepCollectionEquality().equals(other.imagePath, imagePath) &&
            const DeepCollectionEquality()
                .equals(other.description, description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(time),
      const DeepCollectionEquality().hash(trainingName),
      const DeepCollectionEquality().hash(imagePath),
      const DeepCollectionEquality().hash(description));

  @JsonKey(ignore: true)
  @override
  _$$_TrainingMenuCopyWith<_$_TrainingMenu> get copyWith =>
      __$$_TrainingMenuCopyWithImpl<_$_TrainingMenu>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TrainingMenuToJson(this);
  }
}

abstract class _TrainingMenu implements TrainingMenu {
  const factory _TrainingMenu(
      {final int time,
      final String trainingName,
      final String imagePath,
      final String description}) = _$_TrainingMenu;

  factory _TrainingMenu.fromJson(Map<String, dynamic> json) =
      _$_TrainingMenu.fromJson;

  @override
  int get time => throw _privateConstructorUsedError;
  @override
  String get trainingName => throw _privateConstructorUsedError;
  @override
  String get imagePath => throw _privateConstructorUsedError;
  @override
  String get description => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_TrainingMenuCopyWith<_$_TrainingMenu> get copyWith =>
      throw _privateConstructorUsedError;
}
