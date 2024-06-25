/*
  MAIN()

  The start point of the app
*/

/*
  TODO list:
  1) Don't invoke 'print' in production code.
     Try using a logging framework.dartavoid_print

  2) Reduse warnings

*/

import 'package:flutter/material.dart';
import '../styles/theme.dart';
import 'Screen.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
   HttpOverrides.global = MyHttpOverrides();
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

