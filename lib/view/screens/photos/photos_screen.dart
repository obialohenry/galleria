import 'package:flutter/material.dart';
import 'package:galleria/config/app_colors.dart';
import 'package:galleria/view/components/app_text.dart';
import 'package:galleria/view/screens/photos/photo_details_screen.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final List<String> _photos = ["assets/images/daenerys.jpeg", "assets/images/justice-league.jpg"];
  String photo(int index) {
    if ((index + 1) % 2 != 0) {
      return _photos[0];
    } else {
      return _photos[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
            childAspectRatio: 0.5
            ),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding:const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          itemCount: 20,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> PhotoDetailsScreen()));
              },
              child: Container(
                height: 250,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: AssetImage(photo(index)), fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
