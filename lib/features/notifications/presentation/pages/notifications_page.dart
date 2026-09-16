import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _selectedFilter = 'tout';

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return notificationsAsync.when(
      data: (items) {
        final visibleItems = switch (_selectedFilter) {
          'non_lus' => items.where((item) => !item.isRead).toList(),
          'lus' => items.where((item) => item.isRead).toList(),
          _ => items,
        };

        final unreadCount = items.where((item) => !item.isRead).length;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation Top Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 24, 0),
                  child: IconButton(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textPrimary,
                    tooltip: 'Retour',
                  ),
                ),

                // Header with Title and Action
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        SizedBox.square(
                          dimension: 52,
                          child: FilledButton(
                            onPressed: () => ref
                                .read(
                                  notificationActionControllerProvider.notifier,
                                )
                                .markAllAsRead(),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Icon(Icons.done_all_rounded, size: 30),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FilterChip(
                        label: 'Tout',
                        count: items.length,
                        isSelected: _selectedFilter == 'tout',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'tout'),
                      ),
                      _FilterChip(
                        label: 'Non lus',
                        count: unreadCount,
                        isSelected: _selectedFilter == 'non_lus',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'non_lus'),
                      ),
                      _FilterChip(
                        label: 'Lus',
                        count: items.where((item) => item.isRead).length,
                        isSelected: _selectedFilter == 'lus',
                        onSelected: () =>
                            setState(() => _selectedFilter = 'lus'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: visibleItems.isEmpty
                      ? const _EmptyNotificationsState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: visibleItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = visibleItems[index];
                            final showGroupHeading =
                                index == 0 ||
                                _groupLabel(
                                      visibleItems[index - 1].createdAt,
                                    ) !=
                                    _groupLabel(item.createdAt);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showGroupHeading)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      _groupLabel(item.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                _NotificationCard(
                                  item: item,
                                  onTap: () async {
                                    if (!item.isRead && item.id.isNotEmpty) {
                                      await ref
                                          .read(
                                            notificationActionControllerProvider
                                                .notifier,
                                          )
                                          .markAsRead(notificationId: item.id);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Impossible de charger les notifications.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  String _groupLabel(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) return 'Aujourd’hui';
    if (diff.inDays == 1) return 'Hier';
    return 'Plus ancien';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
      side: const BorderSide(color: AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;
    final iconData = _iconForType(item.type);
    final iconBackground = _colorForType(item.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 7, left: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _timeAgo(item.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'task_assigned':
        return Icons.person_add_alt_1_rounded;
      case 'task_status':
        return Icons.check_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'task_assigned':
        return AppColors.primaryContainer;
      case 'task_status':
        return AppColors.primaryContainer;
      default:
        return AppColors.primaryLight.withValues(alpha: 0.35);
    }
  }

  String _timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return 'À l’instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    return 'Il y a ${difference.inDays} j';
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous n’avez pas encore de nouvelles notifications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
