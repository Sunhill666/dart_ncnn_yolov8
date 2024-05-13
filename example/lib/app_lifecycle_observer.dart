import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/my_camera_controller.dart';

class _AppLifecycleObserver extends NavigatorObserver
    with WidgetsBindingObserver {
  _AppLifecycleObserver({
    required this.onInactive,
  });

  final VoidCallback onInactive;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}

final appLifecycleObserver = Provider(
  (ref) {
    final observer = _AppLifecycleObserver(
      onInactive: () {
        ref.read(myCameraController).stopImageStream();
      },
    );

    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(
      () => WidgetsBinding.instance.removeObserver(observer),
    );

    return observer;
  },
);
