import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/model/local/dashboard_state.dart';

final dashboardViewModel = NotifierProvider<DashboardViewModel, DashboardState>(
  DashboardViewModel.new,
);

class DashboardViewModel extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState();
  }

  void changeScreen(int index) {
    state = state.screenChanged(index);
  }
}
