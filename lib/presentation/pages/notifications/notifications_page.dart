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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificações',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          context.read<NotificationCubit>().markAllAsRead(),
                      child: Text(
                        'Ler tudo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Limpar notificações'),
                            content: const Text(
                                'Deseja remover todas as notificações?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Limpar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          context.read<NotificationCubit>().clearAll();
                        }
                      },
                      child: Text(
                        'Limpar tudo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 5);
                }
                if (state is NotificationError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<NotificationCubit>().loadNotifications(),
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
                    onRefresh: () async =>
                        context.read<NotificationCubit>().loadNotifications(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final n = state.notifications[index];
                        final isUnread = !n.isRead;
                        final typeColor = _notifColor(n.type);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Dismissible(
                              key: Key('notif_${n.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: theme.colorScheme.error,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) => context
                                  .read<NotificationCubit>()
                                  .deleteNotification(n.id!),
                              child: GestureDetector(
                                onTap: isUnread
                                    ? () => context
                                        .read<NotificationCubit>()
                                        .markAsRead(n.id!)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isUnread
                                        ? Color.alphaBlend(
                                            theme.colorScheme.primary
                                                .withValues(alpha: 0.03),
                                            theme.colorScheme.surface,
                                          )
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color:
                                              typeColor.withValues(alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(_notifIcon(n.type),
                                            color: typeColor, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              n.title,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontWeight: isUnread
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                            if (n.message != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                n.message!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                            if (n.createdAt != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormatter.relativeTime(
                                                    n.createdAt!),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color:
                                                      theme.colorScheme.outline,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isUnread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _notifColor(String type) {
    switch (type) {
      case 'bill_due':
        return Theme.of(context).colorScheme.primary;
      case 'budget_exceeded':
        return Colors.amber;
      case 'income_received':
        return const Color(0xFF10B981);
      case 'savings_goal':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
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
