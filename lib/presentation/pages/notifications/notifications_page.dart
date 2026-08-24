import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/notification/notification_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/ledger_row.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_content.dart';
import 'widgets/notification_type_style.dart';
import '../../../domain/entities/notification.dart';

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

  /// Groups the already-loaded notifications by recency for rendering.
  /// Purely a display-layer transform — does not affect data loading.
  List<Object> _buildDisplayItems(List<AppNotification> notifications) {
    final items = <Object>[];
    String? lastGroup;
    for (final n in notifications) {
      final createdAt = n.createdAt;
      if (createdAt != null) {
        final group = _groupLabel(createdAt);
        if (group != lastGroup) {
          items.add(group);
          lastGroup = group;
        }
      }
      items.add(n);
    }
    return items;
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Hoje';
    if (diff < 7) return 'Esta semana';
    return 'Anteriores';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: 'Notificações',
            bottomPadding: 16,
            trailing: Row(
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
                        content:
                            const Text('Deseja remover todas as notificações?'),
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
          ),
          Expanded(
            child: ResponsiveContent(
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
                    final displayItems =
                        _buildDisplayItems(state.notifications);
                    return RefreshIndicator(
                      onRefresh: () async =>
                          context.read<NotificationCubit>().loadNotifications(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          if (item is String) {
                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(4, 16, 4, 4),
                              child: Text(
                                item,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }
                          final n = item as AppNotification;
                          final isUnread = !n.isRead;
                          final typeStyle =
                              NotificationTypeMapper.resolve(context, n.type);
                          final canMutate = n.id != null;
                          final keyValue = n.id?.toString() ??
                              '${n.title}_${n.createdAt?.millisecondsSinceEpoch ?? index}_$index';
                          // Fold the message + relative time into a single
                          // subtitle line -- LedgerRow shows one line below
                          // the title, not a stacked message/timestamp block.
                          final subtitleParts = <String>[
                            if (n.message != null) n.message!,
                            if (n.createdAt != null)
                              DateFormatter.relativeTime(n.createdAt!),
                          ];
                          return Dismissible(
                            key: Key('notif_$keyValue'),
                            direction: canMutate
                                ? DismissDirection.endToStart
                                : DismissDirection.none,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: theme.colorScheme.error,
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              if (!canMutate) return;
                              context
                                  .read<NotificationCubit>()
                                  .deleteNotification(n.id!);
                            },
                            child: LedgerRow(
                              title: n.title,
                              subtitle: subtitleParts.isEmpty
                                  ? null
                                  : subtitleParts.join(' • '),
                              leadingIcon: typeStyle.icon,
                              leadingIconColor: typeStyle.color,
                              trailing: isUnread
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: typeStyle.color,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                              onTap: isUnread && canMutate
                                  ? () => context
                                      .read<NotificationCubit>()
                                      .markAsRead(n.id!)
                                  : null,
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
          ),
        ],
      ),
    );
  }
}
