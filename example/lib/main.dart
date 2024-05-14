import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_lifecycle_observer.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: "NCNN Camera",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: "NCNN Camera"),
      navigatorObservers: [
        ref.watch(appLifecycleObserver),
      ],
    );
  }
}
