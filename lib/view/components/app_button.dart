import 'package:flutter/widgets.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/view/components/app_text.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key,required this.text,this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.kPrimary,
        ),
        child: AppText(
          text: text,
          color: AppColors.kPrimaryPressed,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
