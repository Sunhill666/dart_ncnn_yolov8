// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detect_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DetectResult {
  List<YoloResult> get result => throw _privateConstructorUsedError;
  KannaRotateResult? get image => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DetectResultCopyWith<DetectResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectResultCopyWith<$Res> {
  factory $DetectResultCopyWith(
          DetectResult value, $Res Function(DetectResult) then) =
      _$DetectResultCopyWithImpl<$Res, DetectResult>;
  @useResult
  $Res call({List<YoloResult> result, KannaRotateResult? image});

  $KannaRotateResultCopyWith<$Res>? get image;
}

/// @nodoc
class _$DetectResultCopyWithImpl<$Res, $Val extends DetectResult>
    implements $DetectResultCopyWith<$Res> {
  _$DetectResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
    Object? image = freezed,
  }) {
    return _then(_value.copyWith(
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as List<YoloResult>,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as KannaRotateResult?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $KannaRotateResultCopyWith<$Res>? get image {
    if (_value.image == null) {
      return null;
    }

    return $KannaRotateResultCopyWith<$Res>(_value.image!, (value) {
      return _then(_value.copyWith(image: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DetectResultImplCopyWith<$Res>
    implements $DetectResultCopyWith<$Res> {
  factory _$$DetectResultImplCopyWith(
          _$DetectResultImpl value, $Res Function(_$DetectResultImpl) then) =
      __$$DetectResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<YoloResult> result, KannaRotateResult? image});

  @override
  $KannaRotateResultCopyWith<$Res>? get image;
}

/// @nodoc
class __$$DetectResultImplCopyWithImpl<$Res>
    extends _$DetectResultCopyWithImpl<$Res, _$DetectResultImpl>
    implements _$$DetectResultImplCopyWith<$Res> {
  __$$DetectResultImplCopyWithImpl(
      _$DetectResultImpl _value, $Res Function(_$DetectResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
    Object? image = freezed,
  }) {
    return _then(_$DetectResultImpl(
      result: null == result
          ? _value._result
          : result // ignore: cast_nullable_to_non_nullable
              as List<YoloResult>,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as KannaRotateResult?,
    ));
  }
}

/// @nodoc

class _$DetectResultImpl with DiagnosticableTreeMixin implements _DetectResult {
  const _$DetectResultImpl(
      {final List<YoloResult> result = const <YoloResult>[], this.image})
      : _result = result;

  final List<YoloResult> _result;
  @override
  @JsonKey()
  List<YoloResult> get result {
    if (_result is EqualUnmodifiableListView) return _result;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_result);
  }

  @override
  final KannaRotateResult? image;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DetectResult(result: $result, image: $image)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DetectResult'))
      ..add(DiagnosticsProperty('result', result))
      ..add(DiagnosticsProperty('image', image));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectResultImpl &&
            const DeepCollectionEquality().equals(other._result, _result) &&
            (identical(other.image, image) || other.image == image));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_result), image);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectResultImplCopyWith<_$DetectResultImpl> get copyWith =>
      __$$DetectResultImplCopyWithImpl<_$DetectResultImpl>(this, _$identity);
}

abstract class _DetectResult implements DetectResult {
  const factory _DetectResult(
      {final List<YoloResult> result,
      final KannaRotateResult? image}) = _$DetectResultImpl;

  @override
  List<YoloResult> get result;
  @override
  KannaRotateResult? get image;
  @override
  @JsonKey(ignore: true)
  _$$DetectResultImplCopyWith<_$DetectResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
