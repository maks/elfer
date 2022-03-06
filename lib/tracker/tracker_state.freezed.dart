// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'tracker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$TrackerStateTearOff {
  const _$TrackerStateTearOff();

  _TrackerState call(
      {required int stepPage,
      E2Pattern? pattern,
      int? selectedPartIndex,
      int? selectedStepIndex,
      required int editVersion,
      required bool editing}) {
    return _TrackerState(
      stepPage: stepPage,
      pattern: pattern,
      selectedPartIndex: selectedPartIndex,
      selectedStepIndex: selectedStepIndex,
      editVersion: editVersion,
      editing: editing,
    );
  }
}

/// @nodoc
const $TrackerState = _$TrackerStateTearOff();

/// @nodoc
mixin _$TrackerState {
  int get stepPage => throw _privateConstructorUsedError;
  E2Pattern? get pattern => throw _privateConstructorUsedError;
  int? get selectedPartIndex => throw _privateConstructorUsedError;
  int? get selectedStepIndex => throw _privateConstructorUsedError;
  int get editVersion => throw _privateConstructorUsedError;
  bool get editing => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TrackerStateCopyWith<TrackerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackerStateCopyWith<$Res> {
  factory $TrackerStateCopyWith(
          TrackerState value, $Res Function(TrackerState) then) =
      _$TrackerStateCopyWithImpl<$Res>;
  $Res call(
      {int stepPage,
      E2Pattern? pattern,
      int? selectedPartIndex,
      int? selectedStepIndex,
      int editVersion,
      bool editing});
}

/// @nodoc
class _$TrackerStateCopyWithImpl<$Res> implements $TrackerStateCopyWith<$Res> {
  _$TrackerStateCopyWithImpl(this._value, this._then);

  final TrackerState _value;
  // ignore: unused_field
  final $Res Function(TrackerState) _then;

  @override
  $Res call({
    Object? stepPage = freezed,
    Object? pattern = freezed,
    Object? selectedPartIndex = freezed,
    Object? selectedStepIndex = freezed,
    Object? editVersion = freezed,
    Object? editing = freezed,
  }) {
    return _then(_value.copyWith(
      stepPage: stepPage == freezed
          ? _value.stepPage
          : stepPage // ignore: cast_nullable_to_non_nullable
              as int,
      pattern: pattern == freezed
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as E2Pattern?,
      selectedPartIndex: selectedPartIndex == freezed
          ? _value.selectedPartIndex
          : selectedPartIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedStepIndex: selectedStepIndex == freezed
          ? _value.selectedStepIndex
          : selectedStepIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      editVersion: editVersion == freezed
          ? _value.editVersion
          : editVersion // ignore: cast_nullable_to_non_nullable
              as int,
      editing: editing == freezed
          ? _value.editing
          : editing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$TrackerStateCopyWith<$Res>
    implements $TrackerStateCopyWith<$Res> {
  factory _$TrackerStateCopyWith(
          _TrackerState value, $Res Function(_TrackerState) then) =
      __$TrackerStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {int stepPage,
      E2Pattern? pattern,
      int? selectedPartIndex,
      int? selectedStepIndex,
      int editVersion,
      bool editing});
}

/// @nodoc
class __$TrackerStateCopyWithImpl<$Res> extends _$TrackerStateCopyWithImpl<$Res>
    implements _$TrackerStateCopyWith<$Res> {
  __$TrackerStateCopyWithImpl(
      _TrackerState _value, $Res Function(_TrackerState) _then)
      : super(_value, (v) => _then(v as _TrackerState));

  @override
  _TrackerState get _value => super._value as _TrackerState;

  @override
  $Res call({
    Object? stepPage = freezed,
    Object? pattern = freezed,
    Object? selectedPartIndex = freezed,
    Object? selectedStepIndex = freezed,
    Object? editVersion = freezed,
    Object? editing = freezed,
  }) {
    return _then(_TrackerState(
      stepPage: stepPage == freezed
          ? _value.stepPage
          : stepPage // ignore: cast_nullable_to_non_nullable
              as int,
      pattern: pattern == freezed
          ? _value.pattern
          : pattern // ignore: cast_nullable_to_non_nullable
              as E2Pattern?,
      selectedPartIndex: selectedPartIndex == freezed
          ? _value.selectedPartIndex
          : selectedPartIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedStepIndex: selectedStepIndex == freezed
          ? _value.selectedStepIndex
          : selectedStepIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      editVersion: editVersion == freezed
          ? _value.editVersion
          : editVersion // ignore: cast_nullable_to_non_nullable
              as int,
      editing: editing == freezed
          ? _value.editing
          : editing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_TrackerState implements _TrackerState {
  const _$_TrackerState(
      {required this.stepPage,
      this.pattern,
      this.selectedPartIndex,
      this.selectedStepIndex,
      required this.editVersion,
      required this.editing});

  @override
  final int stepPage;
  @override
  final E2Pattern? pattern;
  @override
  final int? selectedPartIndex;
  @override
  final int? selectedStepIndex;
  @override
  final int editVersion;
  @override
  final bool editing;

  @override
  String toString() {
    return 'TrackerState(stepPage: $stepPage, pattern: $pattern, selectedPartIndex: $selectedPartIndex, selectedStepIndex: $selectedStepIndex, editVersion: $editVersion, editing: $editing)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TrackerState &&
            const DeepCollectionEquality().equals(other.stepPage, stepPage) &&
            const DeepCollectionEquality().equals(other.pattern, pattern) &&
            const DeepCollectionEquality()
                .equals(other.selectedPartIndex, selectedPartIndex) &&
            const DeepCollectionEquality()
                .equals(other.selectedStepIndex, selectedStepIndex) &&
            const DeepCollectionEquality()
                .equals(other.editVersion, editVersion) &&
            const DeepCollectionEquality().equals(other.editing, editing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(stepPage),
      const DeepCollectionEquality().hash(pattern),
      const DeepCollectionEquality().hash(selectedPartIndex),
      const DeepCollectionEquality().hash(selectedStepIndex),
      const DeepCollectionEquality().hash(editVersion),
      const DeepCollectionEquality().hash(editing));

  @JsonKey(ignore: true)
  @override
  _$TrackerStateCopyWith<_TrackerState> get copyWith =>
      __$TrackerStateCopyWithImpl<_TrackerState>(this, _$identity);
}

abstract class _TrackerState implements TrackerState {
  const factory _TrackerState(
      {required int stepPage,
      E2Pattern? pattern,
      int? selectedPartIndex,
      int? selectedStepIndex,
      required int editVersion,
      required bool editing}) = _$_TrackerState;

  @override
  int get stepPage;
  @override
  E2Pattern? get pattern;
  @override
  int? get selectedPartIndex;
  @override
  int? get selectedStepIndex;
  @override
  int get editVersion;
  @override
  bool get editing;
  @override
  @JsonKey(ignore: true)
  _$TrackerStateCopyWith<_TrackerState> get copyWith =>
      throw _privateConstructorUsedError;
}
