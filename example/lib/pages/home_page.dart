import 'package:flutter/material.dart';

import '../views/detect_view.dart';
import '../views/photo_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: switch (currentPageIndex) {
        0 => const DetectView(),
        1 => const PhotoView(),
        int() => throw UnimplementedError(),
      },
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.camera_alt),
            label: '实时检测',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_arrow),
            label: '拍照检测',
          ),
        ],
      )
    );
  }
}
