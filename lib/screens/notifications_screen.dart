import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NotificationType { paiement, rappel, nouveauMembre, retard }

class NotificationItem {
  final String title;
  final String description;
  final String tontineName;
  final String timeAgo;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.title,
    required this.description,
    required this.tontineName,
    required this.timeAgo,
    required this.type,
    this.isRead = true,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      const NotificationItem(
        title: 'Paiement validé',
        description: 'Votre cotisation de 5 000 FCFA a été validée',
        tontineName: 'Tontine Famille',
        timeAgo: '2h',
        type: NotificationType.paiement,
        isRead: false,
      ),
      const NotificationItem(
        title: 'Rappel de cotisation',
        description: 'Votre cotisation arrive à échéance dans 3 jours',
        tontineName: 'Épargne Quartier',
        timeAgo: '5h',
        type: NotificationType.rappel,
        isRead: false,
      ),
      const NotificationItem(
        title: 'Nouveau membre',
        description: 'Khadija Sow a rejoint votre tontine',
        tontineName: 'Tontine Famille',
        timeAgo: '1j',
        type: NotificationType.nouveauMembre,
      ),
      const NotificationItem(
        title: 'Cotisation en retard',
        description: 'Votre cotisation de Mai est en retard',
        tontineName: 'Épargne Quartier',
        timeAgo: '1j',
        type: NotificationType.retard,
      ),
    ];
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationItem(
                title: n.title,
                description: n.description,
                tontineName: n.tontineName,
                timeAgo: n.timeAgo,
                type: n.type,
                isRead: true,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _unreadCount > 0 ? _markAllAsRead : null,
            child: Text(
              'Tout marquer comme lu',
              style: TextStyle(
                color: _unreadCount > 0 ? AppColors.primaryDark : AppColors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_unreadCount > 0) _buildUnreadBanner(),
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildNotificationCard(_notifications[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$_unreadCount notification${_unreadCount > 1 ? 's' : ''} non lue${_unreadCount > 1 ? 's' : ''}',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous êtes à jour !',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final config = _getNotificationConfig(notification.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.white : config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: !notification.isRead
            ? Border.all(color: config.iconColor.withValues(alpha: 0.2), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: config.iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, color: config.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    Text(
                      notification.timeAgo,
                      style: const TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: const TextStyle(fontSize: 15, color: AppColors.grey, height: 1.3),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.tontineName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark.withValues(alpha: 0.7),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
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

  _NotificationConfig _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.paiement:
        return _NotificationConfig(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFE8F5E9),
        );
      case NotificationType.rappel:
        return _NotificationConfig(
          icon: Icons.access_time,
          iconColor: const Color(0xFFFF9800),
          backgroundColor: const Color(0xFFFFF3E0),
        );
      case NotificationType.nouveauMembre:
        return _NotificationConfig(
          icon: Icons.person_add_outlined,
          iconColor: const Color(0xFF7C4DFF),
          backgroundColor: const Color(0xFFF3E5F5),
        );
      case NotificationType.retard:
        return _NotificationConfig(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFF44336),
          backgroundColor: const Color(0xFFFFEBEE),
        );
    }
  }
}

class _NotificationConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _NotificationConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
