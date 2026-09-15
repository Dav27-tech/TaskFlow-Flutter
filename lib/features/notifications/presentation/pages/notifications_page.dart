import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationItem> _items = [
    _NotificationItem(
      id: '1',
      title: 'Nouvelle tâche assignée',
      message:
          'Vous avez été assigné à une nouvelle tâche dans le projet « Marketing ».',
      timeLabel: 'Il y a 2 minutes',
      group: 'Aujourd’hui',
      icon: Icons.person_add_alt_1_rounded,
      iconBackground: AppColors.secondaryLight,
      iconColor: AppColors.secondary,
      isRead: false,
    ),
    _NotificationItem(
      id: '2',
      title: 'Tâche mise à jour',
      message:
          'Le statut de « Concevoir le prototype » a été modifié par votre équipe.',
      timeLabel: 'Il y a 25 minutes',
      group: 'Aujourd’hui',
      icon: Icons.edit_rounded,
      iconBackground: AppColors.primaryContainer,
      iconColor: AppColors.primary,
      isRead: false,
    ),
    _NotificationItem(
      id: '3',
      title: 'Validation terminée',
      message:
          'La tâche « Présentation client » est maintenant marquée comme terminée.',
      timeLabel: 'Il y a 1 heure',
      group: 'Aujourd’hui',
      icon: Icons.check_rounded,
      iconBackground: AppColors.primaryContainer,
      iconColor: AppColors.success,
      isRead: true,
    ),
    _NotificationItem(
      id: '4',
      title: 'Projet mis à jour',
      message: 'Une nouvelle note a été ajoutée dans le projet « App mobile ».',
      timeLabel: 'Il y a 3 heures',
      group: 'Hier',
      icon: Icons.folder_rounded,
      iconBackground: AppColors.primaryContainer,
      iconColor: AppColors.info,
      isRead: true,
    ),
    _NotificationItem(
      id: '5',
      title: 'Invitation reçue',
      message: 'Vous avez été invité à rejoindre le projet « Planification ».',
      timeLabel: 'Hier, 18:40',
      group: 'Hier',
      icon: Icons.group_add_rounded,
      iconBackground: AppColors.secondaryLight,
      iconColor: AppColors.secondary,
      isRead: true,
    ),
  ];

  String _selectedFilter = 'tout';

  List<_NotificationItem> get _visibleItems {
    switch (_selectedFilter) {
      case 'non_lus':
        return _items.where((item) => !item.isRead).toList();
      case 'lus':
        return _items.where((item) => item.isRead).toList();
      case 'tout':
      default:
        return _items;
    }
  }

  int get _unreadCount => _items.where((item) => !item.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (final item in _items) {
        item.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _visibleItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textPrimary,
                    tooltip: 'Retour',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ) ??
                          const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  if (_unreadCount > 0)
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: const Text('Tout marquer comme lu'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FilterChip(
                    label: 'Tout',
                    count: _items.length,
                    isSelected: _selectedFilter == 'tout',
                    onSelected: () => setState(() => _selectedFilter = 'tout'),
                  ),
                  _FilterChip(
                    label: 'Non lus',
                    count: _unreadCount,
                    isSelected: _selectedFilter == 'non_lus',
                    onSelected: () =>
                        setState(() => _selectedFilter = 'non_lus'),
                  ),
                  _FilterChip(
                    label: 'Lus',
                    count: _items.where((item) => item.isRead).length,
                    isSelected: _selectedFilter == 'lus',
                    onSelected: () => setState(() => _selectedFilter = 'lus'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: visibleItems.isEmpty
                    ? const _EmptyNotificationsState()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: visibleItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          final showGroupHeading =
                              index == 0 ||
                              visibleItems[index - 1].group != item.group;

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
                                    item.group,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              _NotificationCard(item: item),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return Container(
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
              color: item.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 24),
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
                        item.timeLabel,
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
    );
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

class _NotificationItem {
  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.group,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.isRead,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final String group;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  bool isRead;
}
