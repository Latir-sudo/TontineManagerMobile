import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/app_notification.dart';
import '../services/session_service.dart';
import '../services/tontine_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TontineService _tontineService = TontineService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = SessionService.currentAppUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final query = await _firestore
          .collection('notifications')
          .where('userUid', isEqualTo: user.uid)
          .get();

      final notifs = query.docs
          .map((doc) => AppNotification.fromMap(doc.data()))
          .toList();
      notifs.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _markAllAsRead() async {
    final user = SessionService.currentAppUser;
    if (user == null) return;

    setState(() {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        userUid: n.userUid,
        title: n.title,
        description: n.description,
        tontineNom: n.tontineNom,
        type: n.type,
        isRead: true,
        date: n.date,
      )).toList();
    });

    try {
      final query = await _firestore
          .collection('notifications')
          .where('userUid', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}min';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}j';
    } else {
      return '${(diff.inDays / 7).floor()}sem';
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

  Future<void> _accepterInvitation(AppNotification notification) async {
    final user = SessionService.currentAppUser;
    if (user == null) return;
    await _tontineService.accepterInvitation(
        notification.id, notification.tontineId, user.uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation acceptée'),
        backgroundColor: Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _loadNotifications();
  }

  Future<void> _refuserInvitation(AppNotification notification) async {
    await _tontineService.refuserInvitation(notification.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invitation refusée'),
        backgroundColor: Color(0xFFF57C00),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _loadNotifications();
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final config = _getNotificationConfig(notification.type);
    final isInvitationPending =
        notification.type == 'invitation' && notification.statut.isEmpty;

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
                      _formatTimeAgo(notification.date),
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
                      notification.tontineNom,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark.withValues(alpha: 0.7),
                      ),
                    ),
                    if (!notification.isRead && !isInvitationPending)
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
                if (isInvitationPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _refuserInvitation(notification),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935),
                            side: const BorderSide(color: Color(0xFFE53935)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Refuser',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _accepterInvitation(notification),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27AE60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Accepter',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
                if (notification.type == 'invitation' && notification.statut.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: notification.statut == 'acceptee'
                          ? const Color(0xFF27AE60).withValues(alpha: 0.1)
                          : const Color(0xFFF57C00).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notification.statut == 'acceptee' ? 'Acceptée' : 'Refusée',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: notification.statut == 'acceptee'
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFF57C00),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _NotificationConfig _getNotificationConfig(String type) {
    switch (type) {
      case 'paiement':
        return _NotificationConfig(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFE8F5E9),
        );
      case 'rappel':
        return _NotificationConfig(
          icon: Icons.access_time,
          iconColor: const Color(0xFFFF9800),
          backgroundColor: const Color(0xFFFFF3E0),
        );
      case 'nouveau_membre':
        return _NotificationConfig(
          icon: Icons.person_add_outlined,
          iconColor: const Color(0xFF7C4DFF),
          backgroundColor: const Color(0xFFF3E5F5),
        );
      case 'invitation':
        return _NotificationConfig(
          icon: Icons.mail_outlined,
          iconColor: const Color(0xFF1E88E5),
          backgroundColor: const Color(0xFFE3F2FD),
        );
      case 'retard':
        return _NotificationConfig(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFF44336),
          backgroundColor: const Color(0xFFFFEBEE),
        );
      default:
        return _NotificationConfig(
          icon: Icons.notifications_outlined,
          iconColor: AppColors.primaryDark,
          backgroundColor: AppColors.lightGrey,
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
