/*
  All types of text
*/

import 'package:flutter/material.dart';
import 'colors.dart';

class TextStyles {
  // Font of the app
  static const String _baseFontFamily = 'BloggerSans';

  static const TextStyle _baseStyle = TextStyle(
    fontFamily: _baseFontFamily,
  );

  static final TextStyle mainHeadline = _baseStyle.copyWith(
    fontSize: 46.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final TextStyle subHeadline = _baseStyle.copyWith(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

    static final TextStyle smallHeadline = _baseStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final TextStyle mainText = _baseStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );

  static final TextStyle subText = _baseStyle.copyWith(
    fontSize: 18.0,
    fontWeight: FontWeight.normal,
    color: AppColors.technical,
  );

  static final TextStyle buttonText = _baseStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.background,
  );
}