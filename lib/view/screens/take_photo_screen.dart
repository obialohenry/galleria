import 'package:flutter/material.dart';
import 'package:galleria/config/app_colors.dart';
import 'package:galleria/view/components/app_text.dart';
import 'package:galleria/view/screens/photos/photo_details_screen.dart';

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({super.key});

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: Column(
        children: [
          Expanded(flex: 3, child: Container(color: AppColors.kPrimary)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>PhotoDetailsScreen()));
                  },
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/daenerys.jpeg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 5, color: AppColors.kPrimary),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 45,
                    width: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.kTextSecondary),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.cameraswitch_rounded, color: AppColors.kTextPrimary, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
