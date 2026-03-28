import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/projections_repository.dart';

class ProjectionsRepositoryImpl implements ProjectionsRepository {
  final ApiClient _api;

  ProjectionsRepositoryImpl(this._api);

  @override
  Future<Map<String, dynamic>> getProjections() async {
    final response = await _api.get(ApiConstants.projections);
    return response.data is Map ? Map<String, dynamic>.from(response.data) : {};
  }
}
