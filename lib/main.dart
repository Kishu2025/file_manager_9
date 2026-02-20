import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KFileManager(),
    ),
  );
}

class KFileManager extends StatelessWidget {
  const KFileManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KFile Manager',
      debugShowCheckedModeBanner: false,
      theme: NeonTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
