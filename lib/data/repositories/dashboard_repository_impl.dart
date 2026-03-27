import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiClient _api;

  DashboardRepositoryImpl(this._api);

  @override
  Future<DashboardData> getDashboardData({Map<String, dynamic>? filters}) async {
    final response = await _api.get(ApiConstants.dashboard, queryParameters: filters);
    return DashboardDataModel.fromJson(response.data is Map ? response.data : {});
  }
}
