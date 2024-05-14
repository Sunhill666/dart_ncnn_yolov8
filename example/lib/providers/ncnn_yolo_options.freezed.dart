// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ncnn_yolo_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NcnnYoloOptions {
  bool get autoDispose => throw _privateConstructorUsedError;
  double get probThreshold => throw _privateConstructorUsedError;
  double get nmsThreshold => throw _privateConstructorUsedError;
  int get targetSize => throw _privateConstructorUsedError;
  int get numClass => throw _privateConstructorUsedError;
  bool get useGPU => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NcnnYoloOptionsCopyWith<NcnnYoloOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NcnnYoloOptionsCopyWith<$Res> {
  factory $NcnnYoloOptionsCopyWith(
          NcnnYoloOptions value, $Res Function(NcnnYoloOptions) then) =
      _$NcnnYoloOptionsCopyWithImpl<$Res, NcnnYoloOptions>;
  @useResult
  $Res call(
      {bool autoDispose,
      double probThreshold,
      double nmsThreshold,
      int targetSize,
      int numClass,
      bool useGPU});
}

/// @nodoc
class _$NcnnYoloOptionsCopyWithImpl<$Res, $Val extends NcnnYoloOptions>
    implements $NcnnYoloOptionsCopyWith<$Res> {
  _$NcnnYoloOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoDispose = null,
    Object? probThreshold = null,
    Object? nmsThreshold = null,
    Object? targetSize = null,
    Object? numClass = null,
    Object? useGPU = null,
  }) {
    return _then(_value.copyWith(
      autoDispose: null == autoDispose
          ? _value.autoDispose
          : autoDispose // ignore: cast_nullable_to_non_nullable
              as bool,
      probThreshold: null == probThreshold
          ? _value.probThreshold
          : probThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      nmsThreshold: null == nmsThreshold
          ? _value.nmsThreshold
          : nmsThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      targetSize: null == targetSize
          ? _value.targetSize
          : targetSize // ignore: cast_nullable_to_non_nullable
              as int,
      numClass: null == numClass
          ? _value.numClass
          : numClass // ignore: cast_nullable_to_non_nullable
              as int,
      useGPU: null == useGPU
          ? _value.useGPU
          : useGPU // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NcnnYoloOptionsImplCopyWith<$Res>
    implements $NcnnYoloOptionsCopyWith<$Res> {
  factory _$$NcnnYoloOptionsImplCopyWith(_$NcnnYoloOptionsImpl value,
          $Res Function(_$NcnnYoloOptionsImpl) then) =
      __$$NcnnYoloOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool autoDispose,
      double probThreshold,
      double nmsThreshold,
      int targetSize,
      int numClass,
      bool useGPU});
}

/// @nodoc
class __$$NcnnYoloOptionsImplCopyWithImpl<$Res>
    extends _$NcnnYoloOptionsCopyWithImpl<$Res, _$NcnnYoloOptionsImpl>
    implements _$$NcnnYoloOptionsImplCopyWith<$Res> {
  __$$NcnnYoloOptionsImplCopyWithImpl(
      _$NcnnYoloOptionsImpl _value, $Res Function(_$NcnnYoloOptionsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoDispose = null,
    Object? probThreshold = null,
    Object? nmsThreshold = null,
    Object? targetSize = null,
    Object? numClass = null,
    Object? useGPU = null,
  }) {
    return _then(_$NcnnYoloOptionsImpl(
      autoDispose: null == autoDispose
          ? _value.autoDispose
          : autoDispose // ignore: cast_nullable_to_non_nullable
              as bool,
      probThreshold: null == probThreshold
          ? _value.probThreshold
          : probThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      nmsThreshold: null == nmsThreshold
          ? _value.nmsThreshold
          : nmsThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      targetSize: null == targetSize
          ? _value.targetSize
          : targetSize // ignore: cast_nullable_to_non_nullable
              as int,
      numClass: null == numClass
          ? _value.numClass
          : numClass // ignore: cast_nullable_to_non_nullable
              as int,
      useGPU: null == useGPU
          ? _value.useGPU
          : useGPU // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NcnnYoloOptionsImpl
    with DiagnosticableTreeMixin
    implements _NcnnYoloOptions {
  const _$NcnnYoloOptionsImpl(
      {this.autoDispose = true,
      this.probThreshold = yoloProbThresholdDefault,
      this.nmsThreshold = yoloNmsThresholdDefault,
      this.targetSize = yoloTargetSizeDefault,
      this.numClass = yoloNumClassDefault,
      this.useGPU = yoloUseGPUDefault});

  @override
  @JsonKey()
  final bool autoDispose;
  @override
  @JsonKey()
  final double probThreshold;
  @override
  @JsonKey()
  final double nmsThreshold;
  @override
  @JsonKey()
  final int targetSize;
  @override
  @JsonKey()
  final int numClass;
  @override
  @JsonKey()
  final bool useGPU;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NcnnYoloOptions(autoDispose: $autoDispose, probThreshold: $probThreshold, nmsThreshold: $nmsThreshold, targetSize: $targetSize, numClass: $numClass, useGPU: $useGPU)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NcnnYoloOptions'))
      ..add(DiagnosticsProperty('autoDispose', autoDispose))
      ..add(DiagnosticsProperty('probThreshold', probThreshold))
      ..add(DiagnosticsProperty('nmsThreshold', nmsThreshold))
      ..add(DiagnosticsProperty('targetSize', targetSize))
      ..add(DiagnosticsProperty('numClass', numClass))
      ..add(DiagnosticsProperty('useGPU', useGPU));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NcnnYoloOptionsImpl &&
            (identical(other.autoDispose, autoDispose) ||
                other.autoDispose == autoDispose) &&
            (identical(other.probThreshold, probThreshold) ||
                other.probThreshold == probThreshold) &&
            (identical(other.nmsThreshold, nmsThreshold) ||
                other.nmsThreshold == nmsThreshold) &&
            (identical(other.targetSize, targetSize) ||
                other.targetSize == targetSize) &&
            (identical(other.numClass, numClass) ||
                other.numClass == numClass) &&
            (identical(other.useGPU, useGPU) || other.useGPU == useGPU));
  }

  @override
  int get hashCode => Object.hash(runtimeType, autoDispose, probThreshold,
      nmsThreshold, targetSize, numClass, useGPU);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NcnnYoloOptionsImplCopyWith<_$NcnnYoloOptionsImpl> get copyWith =>
      __$$NcnnYoloOptionsImplCopyWithImpl<_$NcnnYoloOptionsImpl>(
          this, _$identity);
}

abstract class _NcnnYoloOptions implements NcnnYoloOptions {
  const factory _NcnnYoloOptions(
      {final bool autoDispose,
      final double probThreshold,
      final double nmsThreshold,
      final int targetSize,
      final int numClass,
      final bool useGPU}) = _$NcnnYoloOptionsImpl;

  @override
  bool get autoDispose;
  @override
  double get probThreshold;
  @override
  double get nmsThreshold;
  @override
  int get targetSize;
  @override
  int get numClass;
  @override
  bool get useGPU;
  @override
  @JsonKey(ignore: true)
  _$$NcnnYoloOptionsImplCopyWith<_$NcnnYoloOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
