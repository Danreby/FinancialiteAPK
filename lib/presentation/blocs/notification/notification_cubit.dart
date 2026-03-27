import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/notification.dart';
import '../../../domain/repositories/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(const NotificationInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      int unreadCount = 0;
      try { unreadCount = await _repository.getUnreadCount(); } catch (_) {}
      emit(NotificationLoaded(notifications: notifications, unreadCount: unreadCount));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updated = current.notifications.map((n) {
          if (n.id == id) {
            return AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              userId: n.userId,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        emit(NotificationLoaded(
          notifications: updated,
          unreadCount: current.unreadCount > 0 ? current.unreadCount - 1 : 0,
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updated = current.notifications.map((n) {
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            isRead: true,
            userId: n.userId,
            createdAt: n.createdAt,
          );
        }).toList();
        emit(NotificationLoaded(notifications: updated, unreadCount: 0));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final removed = current.notifications.firstWhere((n) => n.id == id);
        emit(NotificationLoaded(
          notifications: current.notifications.where((n) => n.id != id).toList(),
          unreadCount: !removed.isRead ? current.unreadCount - 1 : current.unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
