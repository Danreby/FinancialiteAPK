import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';
import 'base_offline_repository.dart';

class NotificationRepositoryImpl extends BaseOfflineRepository
    implements NotificationRepository {
  NotificationRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      if (await isOnline) {
        final response = await api.get(ApiConstants.notifications);
        return safeList(response.data)
            .map((j) => NotificationModel.fromJson(j))
            .toList();
      }
    } catch (_) {}
    final database = await db;
    final results = await database.query('notifications',
        orderBy: 'created_at DESC', limit: 50);
    return results.map((r) => NotificationModel.fromDb(r)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      if (await isOnline) {
        final response = await api.get(ApiConstants.notificationsUnreadCount);
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data['unread_count'] as int? ?? data['count'] as int? ?? 0;
        }
        return 0;
      }
    } catch (_) {}
    final database = await db;
    final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0');
    return result.first['count'] as int? ?? 0;
  }

  @override
  Future<void> markAsRead(int id) async {
    if (await isOnline) {
      await api.patch('${ApiConstants.notifications}/$id/read');
    }
    final database = await db;
    await database.update('notifications', {'is_read': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> markAllAsRead() async {
    if (await isOnline) {
      await api.post(ApiConstants.notificationsMarkAllRead);
    }
    final database = await db;
    await database.update('notifications', {'is_read': 1});
  }

  @override
  Future<void> clearAll() async {
    if (await isOnline) {
      await api.delete(ApiConstants.notificationsClearAll);
    }
    final database = await db;
    await database.delete('notifications');
  }

  @override
  Future<void> deleteNotification(int id) async {
    if (await isOnline) {
      await api.delete('${ApiConstants.notifications}/$id');
    }
    final database = await db;
    await database.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }
}
