import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'session_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationService.showLocalNotification(
    title: message.notification?.title ?? 'Tontine Manager',
    body: message.notification?.body ?? '',
    payload: jsonEncode(message.data),
  );
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tontine_rappels',
    'Rappels de paiement',
    description: 'Notifications de rappel pour les paiements de tontine',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Demander la permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notifications: permission refusée');
      return;
    }

    // Configurer les notifications locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer le canal Android
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    // Handler pour les messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handler pour les messages en premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Sauvegarder le token FCM
    await _saveToken();

    // Écouter les rafraîchissements de token
    _messaging.onTokenRefresh.listen((token) => _saveTokenToFirestore(token));
  }

  Future<void> _saveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde token FCM: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = SessionService.currentAppUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    showLocalNotification(
      title: notification.title ?? 'Tontine Manager',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tontine_rappels',
      'Rappels de paiement',
      channelDescription: 'Notifications de rappel pour les paiements de tontine',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Envoie un rappel de paiement à un membre via notification Firestore
  /// (le Cloud Function enverra la notification push via FCM)
  Future<void> envoyerRappelPaiement({
    required String membreUid,
    required String tontineNom,
    required int montant,
    required String frequence,
  }) async {
    final doc = FirebaseFirestore.instance.collection('notifications').doc();
    await doc.set({
      'id': doc.id,
      'userUid': membreUid,
      'title': 'Rappel de paiement',
      'description':
          'N\'oubliez pas votre cotisation de $montant FCFA pour la tontine $tontineNom. Échéance: $frequence',
      'tontineNom': tontineNom,
      'type': 'rappel',
      'isRead': false,
      'date': FieldValue.serverTimestamp(),
      'tontineId': '',
      'statut': '',
    });
  }

  /// Planifie une notification locale de rappel
  Future<void> planifierRappelLocal({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tontine_rappels',
      'Rappels de paiement',
      channelDescription: 'Notifications de rappel pour les paiements de tontine',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      scheduledDate.millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Vérifie les tontines de l'utilisateur et envoie des rappels si nécessaire
  Future<void> verifierEtEnvoyerRappels() async {
    final user = SessionService.currentAppUser;
    if (user == null) return;

    try {
      final tontinesQuery = await FirebaseFirestore.instance
          .collection('tontines')
          .where('membresUids', arrayContains: user.uid)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in tontinesQuery.docs) {
        final data = doc.data();
        final frequence = data['frequence'] as String? ?? '';
        final montant = data['montantCotisation'] as int? ?? 0;
        final nom = data['nom'] as String? ?? '';

        // Vérifier si l'utilisateur a déjà payé pour cette période
        final dejaPayeCettePeriode = await _aPayeCettePeriode(
          user.uid,
          doc.id,
          frequence,
        );

        if (!dejaPayeCettePeriode) {
          await showLocalNotification(
            title: 'Rappel: $nom',
            body: 'Votre cotisation de $montant FCFA est due. N\'oubliez pas de payer !',
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur vérification rappels: $e');
    }
  }

  Future<bool> _aPayeCettePeriode(
    String userUid,
    String tontineId,
    String frequence,
  ) async {
    final now = DateTime.now();
    DateTime debutPeriode;

    switch (frequence.toLowerCase()) {
      case 'journalière':
      case 'journaliere':
        debutPeriode = DateTime(now.year, now.month, now.day);
        break;
      case 'hebdomadaire':
        debutPeriode = now.subtract(Duration(days: now.weekday - 1));
        debutPeriode = DateTime(debutPeriode.year, debutPeriode.month, debutPeriode.day);
        break;
      case 'mensuelle':
        debutPeriode = DateTime(now.year, now.month, 1);
        break;
      default:
        debutPeriode = DateTime(now.year, now.month, 1);
    }

    final query = await FirebaseFirestore.instance
        .collection('cotisations')
        .where('tontineId', isEqualTo: tontineId)
        .where('userUid', isEqualTo: userUid)
        .where('statut', isEqualTo: 'payee')
        .get();

    for (final doc in query.docs) {
      final dateValue = doc.data()['date'];
      DateTime? cotisationDate;
      if (dateValue is Timestamp) {
        cotisationDate = dateValue.toDate();
      }
      if (cotisationDate != null && cotisationDate.isAfter(debutPeriode)) {
        return true;
      }
    }

    return false;
  }
}
