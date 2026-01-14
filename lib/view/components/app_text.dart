import 'package:flutter/material.dart';
import 'package:galleria/config/app_colors.dart';
import 'package:galleria/config/app_strings.dart';

class AppText extends StatelessWidget {
  ///Creates a clickable text widget.
  const AppText({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textStyle,
    this.textAlign,
    this.onTap,
  });
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        textAlign: textAlign,
        style:
            textStyle ??
            TextStyle(
              fontFamily: AppStrings.inter,
              fontSize: fontSize ?? 18,
              fontWeight: fontWeight ?? FontWeight.w400,
              color: color ?? AppColors.kTextPrimary,
            ),
      ),
    );
  }
}
