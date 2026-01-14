import 'package:flutter/material.dart';
import 'package:galleria/config/app_colors.dart';
import 'package:galleria/view/screens/photos/photos_screen.dart';
import 'package:galleria/view/screens/take_photo_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> _screens = [TakePhotoScreen(), PhotosScreen()];
  int _currentIndex = 0;
  void changeScreen(int index) {
    _currentIndex = index;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.kBackgroundPrimary,
        selectedItemColor: AppColors.kPrimary,
        unselectedItemColor: AppColors.kTextSecondary,
        onTap: (value) => changeScreen(value),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera), label: "Take a Photo"),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: "Photos"),
        ],
      ),
    );
  }
}
