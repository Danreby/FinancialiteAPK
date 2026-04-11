import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/storage_constants.dart';

class PushNotificationService {
  static const _channelId = 'financialite_notifications';
  static const _channelName = 'Notificações';
  static const _channelDesc = 'Notificações do Financialite';
  static const _lastSeenIdKey = 'push_last_seen_notification_id';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static Dio? _dio;

  static Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String type = 'info',
  }) async {
    if (!_initialized) await init();

    final color = switch (type) {
      'error' => 0xFFEF4444,
      'warning' => 0xFFF59E0B,
      'success' => 0xFF10B981,
      _ => 0xFF3B82F6,
    };

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        color: Color(color),
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
      ),
    );

    await _plugin.show(
        id: id, title: title, body: body, notificationDetails: details);
  }

  static Future<void> checkForNewNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      final token = await storage.read(key: StorageConstants.accessToken);
      if (token == null || token.isEmpty) {
        _dio = null;
        return;
      }

      final lastSeenId = prefs.getInt(_lastSeenIdKey) ?? 0;

      _dio ??= Dio(BaseOptions(
        baseUrl: ApiConstants.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      _dio!.options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio!.get(ApiConstants.notifications);
      final rawData = response.data;
      final List items;
      if (rawData is Map && rawData.containsKey('data')) {
        items = rawData['data'] as List? ?? [];
      } else if (rawData is List) {
        items = rawData;
      } else {
        return;
      }

      if (!_initialized) await init();

      int maxId = lastSeenId;
      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final id = map['id'] as int? ?? 0;
        final isRead = map['is_read'] == true || map['is_read'] == 1;
        if (id <= lastSeenId || isRead) continue;

        await show(
          id: id,
          title: map['title'] as String? ?? 'Financialite',
          body: map['message'] as String? ?? '',
          type: map['type'] as String? ?? 'info',
        );

        if (id > maxId) maxId = id;
      }

      if (maxId > lastSeenId) {
        await prefs.setInt(_lastSeenIdKey, maxId);
      }
    } catch (e) {
      debugPrint('[PushNotificationService] poll error: $e');
    }
  }
}
