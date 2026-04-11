import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../domain/entities/notification.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../core/utils/error_message.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;
  bool _permissionRequested = false;

  NotificationCubit(this._repository) : super(const NotificationInitial());

  Future<void> _requestPermissionIfNeeded() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> loadNotifications() async {
    _requestPermissionIfNeeded();
    emit(const NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      int unreadCount = 0;
      try {
        unreadCount = await _repository.getUnreadCount();
      } catch (_) {}
      emit(NotificationLoaded(
          notifications: notifications, unreadCount: unreadCount));
    } catch (e) {
      emit(NotificationError(extractErrorMessage(e)));
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updated = current.notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        emit(NotificationLoaded(
          notifications: updated,
          unreadCount: current.unreadCount > 0 ? current.unreadCount - 1 : 0,
        ));
      }
    } catch (e) {
      emit(NotificationError(extractErrorMessage(e)));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updated =
            current.notifications.map((n) => n.copyWith(isRead: true)).toList();
        emit(NotificationLoaded(notifications: updated, unreadCount: 0));
      }
    } catch (e) {
      emit(NotificationError(extractErrorMessage(e)));
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final removed = current.notifications.firstWhere((n) => n.id == id);
        emit(NotificationLoaded(
          notifications:
              current.notifications.where((n) => n.id != id).toList(),
          unreadCount:
              !removed.isRead ? current.unreadCount - 1 : current.unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(extractErrorMessage(e)));
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
      emit(const NotificationLoaded(notifications: [], unreadCount: 0));
    } catch (e) {
      emit(NotificationError(extractErrorMessage(e)));
    }
  }
}
