/*
  MAIN()

  The start point of the app
*/

/*
  TODO list:
  1) Don't invoke 'print' in production code.
     Try using a logging framework.dartavoid_print

  2) Don't use 'BuildContext's across async gaps.
     Try rewriting the code to not use the 'BuildContext', or guard the use with a 'mounted' check.dartuse_build_context_synchronously

*/

import 'package:flutter/material.dart';
import '../styles/theme.dart';
import 'Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  
      title: 'Exchange',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.background),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const Screen(),
    );
  }
}

