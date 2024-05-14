// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'yolo_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$YoloResult {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;
  int get label => throw _privateConstructorUsedError;
  double get prob => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $YoloResultCopyWith<YoloResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YoloResultCopyWith<$Res> {
  factory $YoloResultCopyWith(
          YoloResult value, $Res Function(YoloResult) then) =
      _$YoloResultCopyWithImpl<$Res, YoloResult>;
  @useResult
  $Res call(
      {double x,
      double y,
      double width,
      double height,
      int label,
      double prob});
}

/// @nodoc
class _$YoloResultCopyWithImpl<$Res, $Val extends YoloResult>
    implements $YoloResultCopyWith<$Res> {
  _$YoloResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? label = null,
    Object? prob = null,
  }) {
    return _then(_value.copyWith(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as int,
      prob: null == prob
          ? _value.prob
          : prob // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YoloResultImplCopyWith<$Res>
    implements $YoloResultCopyWith<$Res> {
  factory _$$YoloResultImplCopyWith(
          _$YoloResultImpl value, $Res Function(_$YoloResultImpl) then) =
      __$$YoloResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double x,
      double y,
      double width,
      double height,
      int label,
      double prob});
}

/// @nodoc
class __$$YoloResultImplCopyWithImpl<$Res>
    extends _$YoloResultCopyWithImpl<$Res, _$YoloResultImpl>
    implements _$$YoloResultImplCopyWith<$Res> {
  __$$YoloResultImplCopyWithImpl(
      _$YoloResultImpl _value, $Res Function(_$YoloResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? label = null,
    Object? prob = null,
  }) {
    return _then(_$YoloResultImpl(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as int,
      prob: null == prob
          ? _value.prob
          : prob // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$YoloResultImpl with DiagnosticableTreeMixin implements _YoloResult {
  const _$YoloResultImpl(
      {this.x = 0,
      this.y = 0,
      this.width = 0,
      this.height = 0,
      this.label = 0,
      this.prob = 0});

  @override
  @JsonKey()
  final double x;
  @override
  @JsonKey()
  final double y;
  @override
  @JsonKey()
  final double width;
  @override
  @JsonKey()
  final double height;
  @override
  @JsonKey()
  final int label;
  @override
  @JsonKey()
  final double prob;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'YoloResult(x: $x, y: $y, width: $width, height: $height, label: $label, prob: $prob)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'YoloResult'))
      ..add(DiagnosticsProperty('x', x))
      ..add(DiagnosticsProperty('y', y))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('label', label))
      ..add(DiagnosticsProperty('prob', prob));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YoloResultImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.prob, prob) || other.prob == prob));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, x, y, width, height, label, prob);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YoloResultImplCopyWith<_$YoloResultImpl> get copyWith =>
      __$$YoloResultImplCopyWithImpl<_$YoloResultImpl>(this, _$identity);
}

abstract class _YoloResult implements YoloResult {
  const factory _YoloResult(
      {final double x,
      final double y,
      final double width,
      final double height,
      final int label,
      final double prob}) = _$YoloResultImpl;

  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;
  @override
  int get label;
  @override
  double get prob;
  @override
  @JsonKey(ignore: true)
  _$$YoloResultImplCopyWith<_$YoloResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
