/*
  All types of buttons
*/

import 'package:flutter/material.dart';
import 'colors.dart';
import 'texts.dart'; 

class ButtonStyles {
  static ButtonStyle styleFromColor(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      minimumSize: const Size(88, 60),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      textStyle: TextStyles.buttonText,
    );
  }
}

class DefaultButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const DefaultButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        style: ButtonStyles.styleFromColor(color),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyles.buttonText, 
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MainButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        style: ButtonStyles.styleFromColor(AppColors.primary),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyles.buttonText, 
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class SubButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SubButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        style: ButtonStyles.styleFromColor(AppColors.technical),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyles.buttonText, 
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/* 

USAGE EXAMPLES:

1) DefaultButton with custom color:
child: DefaultButton(
        text: 'Do action',
        color: AppColors.technical,
        onPressed: myAction,
      ),

2) MainButton with primary color:
child: MainButton(
        text: 'Main action',
        onPressed: myAction,
      ),

3) SubButton with secondary color:
child: SubButton(
        text: 'Sub action',
        onPressed: myAction,
      ),

*/
