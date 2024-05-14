import 'package:dart_ncnn_yolov8/dart_ncnn_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../main.dart';
import '../providers/my_camera_controller.dart';
import '../providers/ncnn_yolo_controller.dart';

// A screen that allows users to take a picture using a given camera.
class CameraPage extends HookConsumerWidget {
  const CameraPage({
    super.key,
  });

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
          builder: (_) {
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
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
      ),
    );
  }
}
