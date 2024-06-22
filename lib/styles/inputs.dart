/*
  All types of input fields
*/

import 'package:flutter/material.dart';
import 'colors.dart';
import 'texts.dart';

class InputStyles {
  static InputDecoration defaultInputDecoration({
    required String hintText,
    required EdgeInsetsGeometry contentPadding,
    required BorderRadius borderRadius,
    required double borderWidth,
    required Color borderColor,
    required Color fillColor,
    required TextStyle hintStyle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      contentPadding: contentPadding,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: borderColor.withOpacity(0.7),
          width: borderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
    );
  }
}

class DefaultTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final EdgeInsetsGeometry padding;
  final void Function(String)? onChanged;

  const DefaultTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.onChanged, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: onChanged ?? (_) {}, 
        style: TextStyles.mainText, 
        decoration: InputStyles.defaultInputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: BorderRadius.circular(8),
          borderWidth: 2,
          borderColor: AppColors.primary,
          fillColor: AppColors.background,
          hintStyle: TextStyles.mainText,
        ),
      ),
    );
  }
}
