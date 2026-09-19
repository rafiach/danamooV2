import 'package:danamoo/core/constants/constant.dart';
import 'package:danamoo/features/quick_add/view/quick_add_view.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
void quickAddMain() {
  runApp(const QuickAddApp());
}

class QuickAddApp extends StatelessWidget {
  const QuickAddApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Constant.limeAccent,
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const QuickAddScreen(),
    );
  }
}
