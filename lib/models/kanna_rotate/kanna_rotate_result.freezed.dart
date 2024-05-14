// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kanna_rotate_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$KannaRotateResult {
  Uint8List? get pixels => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  PixelChannel get pixelChannel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $KannaRotateResultCopyWith<KannaRotateResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KannaRotateResultCopyWith<$Res> {
  factory $KannaRotateResultCopyWith(
          KannaRotateResult value, $Res Function(KannaRotateResult) then) =
      _$KannaRotateResultCopyWithImpl<$Res, KannaRotateResult>;
  @useResult
  $Res call(
      {Uint8List? pixels, int width, int height, PixelChannel pixelChannel});
}

/// @nodoc
class _$KannaRotateResultCopyWithImpl<$Res, $Val extends KannaRotateResult>
    implements $KannaRotateResultCopyWith<$Res> {
  _$KannaRotateResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pixels = freezed,
    Object? width = null,
    Object? height = null,
    Object? pixelChannel = null,
  }) {
    return _then(_value.copyWith(
      pixels: freezed == pixels
          ? _value.pixels
          : pixels // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      pixelChannel: null == pixelChannel
          ? _value.pixelChannel
          : pixelChannel // ignore: cast_nullable_to_non_nullable
              as PixelChannel,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KannaRotateResultImplCopyWith<$Res>
    implements $KannaRotateResultCopyWith<$Res> {
  factory _$$KannaRotateResultImplCopyWith(_$KannaRotateResultImpl value,
          $Res Function(_$KannaRotateResultImpl) then) =
      __$$KannaRotateResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Uint8List? pixels, int width, int height, PixelChannel pixelChannel});
}

/// @nodoc
class __$$KannaRotateResultImplCopyWithImpl<$Res>
    extends _$KannaRotateResultCopyWithImpl<$Res, _$KannaRotateResultImpl>
    implements _$$KannaRotateResultImplCopyWith<$Res> {
  __$$KannaRotateResultImplCopyWithImpl(_$KannaRotateResultImpl _value,
      $Res Function(_$KannaRotateResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pixels = freezed,
    Object? width = null,
    Object? height = null,
    Object? pixelChannel = null,
  }) {
    return _then(_$KannaRotateResultImpl(
      pixels: freezed == pixels
          ? _value.pixels
          : pixels // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      pixelChannel: null == pixelChannel
          ? _value.pixelChannel
          : pixelChannel // ignore: cast_nullable_to_non_nullable
              as PixelChannel,
    ));
  }
}

/// @nodoc

class _$KannaRotateResultImpl
    with DiagnosticableTreeMixin
    implements _KannaRotateResult {
  const _$KannaRotateResultImpl(
      {this.pixels,
      this.width = 0,
      this.height = 0,
      this.pixelChannel = PixelChannel.c1});

  @override
  final Uint8List? pixels;
  @override
  @JsonKey()
  final int width;
  @override
  @JsonKey()
  final int height;
  @override
  @JsonKey()
  final PixelChannel pixelChannel;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'KannaRotateResult(pixels: $pixels, width: $width, height: $height, pixelChannel: $pixelChannel)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'KannaRotateResult'))
      ..add(DiagnosticsProperty('pixels', pixels))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('pixelChannel', pixelChannel));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KannaRotateResultImpl &&
            const DeepCollectionEquality().equals(other.pixels, pixels) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.pixelChannel, pixelChannel) ||
                other.pixelChannel == pixelChannel));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(pixels), width, height, pixelChannel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KannaRotateResultImplCopyWith<_$KannaRotateResultImpl> get copyWith =>
      __$$KannaRotateResultImplCopyWithImpl<_$KannaRotateResultImpl>(
          this, _$identity);
}

abstract class _KannaRotateResult implements KannaRotateResult {
  const factory _KannaRotateResult(
      {final Uint8List? pixels,
      final int width,
      final int height,
      final PixelChannel pixelChannel}) = _$KannaRotateResultImpl;

  @override
  Uint8List? get pixels;
  @override
  int get width;
  @override
  int get height;
  @override
  PixelChannel get pixelChannel;
  @override
  @JsonKey(ignore: true)
  _$$KannaRotateResultImplCopyWith<_$KannaRotateResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
