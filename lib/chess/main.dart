import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/welcome_screen.dart';
import 'utils/simple_sound_manager.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatefulWidget {
  const ChessApp({super.key});

  @override
  State<ChessApp> createState() => _ChessAppState();
}

class _ChessAppState extends State<ChessApp> {
  @override
  void initState() {
    super.initState();
    print('DEBUG: ChessApp initState called');
    // Start background music when app launches
    SimpleSoundManager().playBackgroundMusic();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chess Master',
          theme: ThemeData(
            primarySwatch: Colors.brown,
            useMaterial3: true,
          ),
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
