import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/notification/notification_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../../core/utils/date_formatter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
            child: const Text('Marcar tudo como lido'),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) return const AppLoadingIndicator();
          if (state is NotificationError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<NotificationCubit>().loadNotifications(),
            );
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.notifications_none,
                title: 'Sem notificações',
                subtitle: 'Você ainda não tem notificações',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<NotificationCubit>().loadNotifications(),
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final n = state.notifications[index];
                  final isUnread = !n.isRead;
                  return Dismissible(
                    key: Key('notif_${n.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: theme.colorScheme.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => context.read<NotificationCubit>().deleteNotification(n.id!),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isUnread
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          _notifIcon(n.type),
                          color: isUnread ? theme.colorScheme.primary : theme.colorScheme.outline,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        n.title,
                        style: TextStyle(fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (n.message != null)
                            Text(n.message!, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (n.createdAt != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              DateFormatter.relativeTime(n.createdAt!),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ],
                      ),
                      onTap: isUnread ? () => context.read<NotificationCubit>().markAsRead(n.id!) : null,
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'bill_due':
        return Icons.receipt;
      case 'budget_exceeded':
        return Icons.warning;
      case 'income_received':
        return Icons.trending_up;
      case 'savings_goal':
        return Icons.savings;
      default:
        return Icons.notifications;
    }
  }
}
