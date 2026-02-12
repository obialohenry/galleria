import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/screens.dart';
import 'package:galleria/src/view_model.dart';

class DashboardScreen extends ConsumerWidget {
  DashboardScreen({super.key});

  final List<Widget> _screens = [TakePhotoScreen(), PhotosScreen()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardProvider = ref.watch(dashboardViewModel);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: _screens[dashboardProvider.index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: dashboardProvider.index,
        backgroundColor: AppColors.kBackgroundPrimary,
        selectedItemColor: AppColors.kPrimary,
        unselectedItemColor: AppColors.kTextSecondary,
        onTap: (value) => ref.read(dashboardViewModel.notifier).changeScreen(value),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera), label: AppStrings.takeAPhoto),
          BottomNavigationBarItem(icon: Icon(Icons.photo_album), label: AppStrings.photos),
        ],
      ),
    );
  }
}
