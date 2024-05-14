import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../pages/camera_page.dart';
import '../providers/my_camera_controller.dart';

class DetectView extends HookConsumerWidget {
  const DetectView({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Detect View",
          ),
          FloatingActionButton(
            onPressed: () {
              ref.read(myCameraController).startImageStream();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                    const CameraPage(),
                ),
              );
            },
            child: const Icon(Icons.camera)
          ),
        ],
      ),
    );
  }
}
