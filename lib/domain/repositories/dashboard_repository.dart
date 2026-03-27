import '../entities/dashboard.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData({Map<String, dynamic>? filters});
}
