import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/ncnn_yolo_controller.dart';
import '../utils/logger.dart';
import 'picture_view.dart';

class PhotoView extends HookConsumerWidget {
  const PhotoView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Photo View",
          ),
          FloatingActionButton(
              onPressed: () async {
                try {
                  final image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
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
                  if (compressed == null) return;
                  await ref
                      .read(ncnnYoloController.notifier)
                      .detectFromImageFile(XFile(compressed.path));

                  if (!context.mounted) return;
                  // If the picture was taken, display it on a new screen.
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DisplayPictureScreen(),
                    ),
                  );
                } catch (e) {
                  logger.e(e);
                }
              },
              child: const Icon(Icons.camera)),
        ],
      ),
    );
  }
}
