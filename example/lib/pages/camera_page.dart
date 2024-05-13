import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dart_ncnn_yolov8/dart_ncnn_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../providers/my_camera_controller.dart';
import '../providers/ncnn_yolo_controller.dart';
import '../utils/logger.dart';

// A screen that allows users to take a picture using a given camera.
class CameraPage extends HookConsumerWidget {
  const CameraPage({
    super.key,
    required this.detection,
  });

  final bool detection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewImage = ref.watch(NcnnYoloController.previewImage);

    void showBackDialog() {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('离开'),
            content: const Text(
              '要离开吗？',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('不'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('离开'),
                onPressed: () {
                  ref.read(myCameraController).stopImageStream();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showBackDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showBackDialog();
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Builder(
          builder: (context) {
            if (previewImage == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: previewImage.width.toDouble(),
                    height: previewImage.height.toDouble(),
                    child: CustomPaint(
                      painter: YoloResultPainter(
                        image: previewImage,
                        results: ref.watch(ncnnYoloController),
                        labels: cocoLabels,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: detection
            ? FloatingActionButton(
                onPressed: () async {
                  try {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.camera);

                    if (image == null) return;
                    await ref.read(ncnnYoloController.notifier).initialize();

                    final dir = (await getTemporaryDirectory()).path;
                    final compressedFile = '$dir/ncnn_yolo_flutter_example.jpg';
                    final compressed =
                        await FlutterImageCompress.compressAndGetFile(
                      image.path,
                      compressedFile,
                      quality: 100,
                    );
                    if (compressed == null) {
                      return;
                    }
                    await ref
                        .read(ncnnYoloController.notifier)
                        .detectFromImageFile(XFile(compressed.path));

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          imagePath: image.path,
                        ),
                      ),
                    );
                  } catch (e) {
                    logger.e(e);
                  }
                },
                child: const Icon(Icons.camera_alt),
              )
            : null,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
