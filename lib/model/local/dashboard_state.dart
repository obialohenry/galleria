
class DashboardState {
  final int index;

  DashboardState({this.index = 0});

  DashboardState screenChanged(int index) {
    return DashboardState(index: index);
  }
}
