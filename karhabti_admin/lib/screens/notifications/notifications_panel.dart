// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { info, warning, error, success }

class NotificationsPanel extends StatefulWidget {
  final Function? onClose;

  const NotificationsPanel({super.key, this.onClose});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  final List<Notification> _notifications = [
    Notification(
      id: '1',
      title: 'Stock faible',
      message:
          'Le stock de plaquettes de frein est en dessous du seuil minimum (5 pièces)',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.warning,
    ),
    Notification(
      id: '2',
      title: 'Nouveau client',
      message: 'Mehdi Ben Ali vient de s\'inscrire sur l\'application',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.info,
    ),
    Notification(
      id: '3',
      title: 'Panne détectée',
      message: 'Alerte de panne de batterie détectée pour le véhicule TUN 1234',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.error,
    ),
    Notification(
      id: '4',
      title: 'Maintenance effectuée',
      message: 'La maintenance de la Peugeot 208 (TUN 5678) a été complétée',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.success,
    ),
    Notification(
      id: '5',
      title: 'Demande de devis',
      message: 'Nouvelle demande de devis pour une vidange Peugeot 3008',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      type: NotificationType.info,
    ),
    Notification(
      id: '6',
      title: 'Mise à jour système',
      message: 'La mise à jour du système est programmée pour demain à 03:00',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.info,
      isRead: true,
    ),
  ];

  bool _showOnlyUnread = false;

  List<Notification> get _filteredNotifications {
    if (_showOnlyUnread) {
      return _notifications.where((notif) => !notif.isRead).toList();
    }
    return _notifications;
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((notif) => notif.id == id);
      notification.isRead = true;
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((notif) => notif.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Container(
        width: 350,
        height: 500,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(child: _buildNotificationsList()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (widget.onClose != null) {
                widget.onClose!();
              }
            },
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final unreadCount = _notifications.where((notif) => !notif.isRead).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Non lues ($unreadCount)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _showOnlyUnread,
                onChanged: (value) {
                  setState(() {
                    _showOnlyUnread = value;
                  });
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
            ],
          ),
          TextButton(
            onPressed: unreadCount > 0 ? _markAllAsRead : null,
            child: Text(
              'Tout marquer comme lu',
              style: TextStyle(
                fontSize: 13,
                color:
                    unreadCount > 0
                        ? AppTheme.primaryColor
                        : AppTheme.greyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 50,
              color: AppTheme.greyColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune notification',
              style: TextStyle(fontSize: 16, color: AppTheme.greyColor),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredNotifications.length,
      separatorBuilder:
          (context, index) =>
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Notification notification) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: _getNotificationColor(
          notification.type,
        ).withOpacity(0.2),
        child: Icon(
          _getNotificationIcon(notification.type),
          color: _getNotificationColor(notification.type),
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              notification.title,
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            _formatTime(notification.time),
            style: TextStyle(fontSize: 12, color: AppTheme.greyColor),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.message,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.darkColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!notification.isRead)
                TextButton(
                  onPressed: () => _markAsRead(notification.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Marquer comme lu'),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
                onPressed: () => _removeNotification(notification.id),
              ),
            ],
          ),
        ],
      ),
      tileColor:
          notification.isRead
              ? Colors.white
              : AppTheme.lightGreyColor.withOpacity(0.1),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Center(
        child: TextButton(
          onPressed: () {},
          child: const Text('Voir toutes les notifications'),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return AppTheme.primaryColor;
      case NotificationType.warning:
        return AppTheme.warningColor;
      case NotificationType.error:
        return AppTheme.dangerColor;
      case NotificationType.success:
        return AppTheme.successColor;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
