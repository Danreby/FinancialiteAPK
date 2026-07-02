import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/connectivity/connectivity_cubit.dart';
import '../blocs/notification/notification_cubit.dart';
import '../widgets/connectivity_banner.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/bills')) return 2;
    if (location.startsWith('/faturas')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/bills');
        break;
      case 3:
        context.go('/faturas');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityCubit>().state;
    final selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);
    final appColors = theme.appColors;

    return Scaffold(
      body: Column(
        children: [
          ConnectivityBanner(isOnline: isOnline),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: appColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.nav),
              boxShadow: [
                BoxShadow(
                  color: appColors.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Início',
                  isSelected: selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                  lift: true,
                ),
                _NavItem(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Transações',
                  isSelected: selectedIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Contas',
                  isSelected: selectedIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
                _NavItem(
                  icon: Icons.credit_card_rounded,
                  label: 'Faturas',
                  isSelected: selectedIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    return _NavItem(
                      icon: Icons.menu_rounded,
                      label: 'Mais',
                      isSelected: selectedIndex == 4,
                      onTap: () => _onItemTapped(4),
                      badgeCount:
                          state is NotificationLoaded ? state.unreadCount : 0,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A tab whose selected state morphs into a filled capsule behind the icon,
/// with the label fading in -- the nav "speaks" on selection instead of
/// just recoloring an icon.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool lift;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.lift = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    final onCapsule = appColors.background;
    final unselected = appColors.onSurfaceVariant;

    final capsule = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: isSelected ? 14 : 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? appColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? onCapsule : unselected,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: isSelected
                ? Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: onCapsule,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        offset: lift && isSelected ? const Offset(0, -0.08) : Offset.zero,
        child: capsule,
      ),
    );
  }
}
