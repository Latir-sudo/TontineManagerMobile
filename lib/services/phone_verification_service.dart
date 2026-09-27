import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service pour gérer la vérification des numéros de téléphone via Firebase
/// Supporte tous les formats internationaux de numéros
class PhoneVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  /// Envoie un code de vérification SMS au numéro de téléphone
  ///
  /// [phoneNumber] doit être au format international (ex: +221771234567)
  /// [onCodeSent] appelé quand le code est envoyé avec succès
  /// [onVerificationCompleted] appelé si la vérification se fait automatiquement (Android uniquement)
  /// [onVerificationFailed] appelé en cas d'erreur
  /// [timeout] durée d'attente avant timeout (défaut: 60 secondes)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function() onVerificationCompleted,
    required Function(String error) onVerificationFailed,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,

        // Vérification automatique (Android uniquement)
        // Appelé si Firebase détecte automatiquement le SMS
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Vérification automatique réussie');
          onVerificationCompleted();
        },

        // Appelé en cas d'échec de vérification
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Échec de vérification: ${e.code} - ${e.message}');
          final errorMessage = _mapFirebaseError(e.code);
          onVerificationFailed(errorMessage);
        },

        // Appelé quand le code est envoyé avec succès
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('📨 Code envoyé - verificationId: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },

        // Appelé après le timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ Timeout de récupération automatique');
          _verificationId = verificationId;
        },

        // Token pour renvoyer le code
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification: $e');
      onVerificationFailed('Une erreur est survenue. Vérifiez votre connexion.');
    }
  }

  /// Vérifie le code OTP entré par l'utilisateur
  ///
  /// [smsCode] le code à 6 chiffres reçu par SMS
  /// Retourne [PhoneVerificationResult] avec le statut et le credential si succès
  Future<PhoneVerificationResult> verifyOtpCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        return PhoneVerificationResult.failure(
          'Aucune vérification en cours. Veuillez redemander un code.'
        );
      }

      // Créer le credential avec le code
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Vérifier le credential (sans se connecter pour l'instant)
      // On va juste vérifier que le code est correct
      try {
        await _auth.signInWithCredential(credential);
        // Si on arrive ici, le code est correct
        // On déconnecte immédiatement car on veut juste vérifier
        await _auth.signOut();

        return PhoneVerificationResult.success(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-verification-code') {
          return PhoneVerificationResult.failure('Code incorrect. Veuillez réessayer.');
        } else if (e.code == 'session-expired') {
          return PhoneVerificationResult.failure('Le code a expiré. Demandez un nouveau code.');
        }
        return PhoneVerificationResult.failure(_mapFirebaseError(e.code));
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du code: $e');
      return PhoneVerificationResult.failure(
        'Une erreur est survenue. Réessayez.'
      );
    }
  }

  /// Renvoie un nouveau code de vérification
  Future<void> resendCode({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function() onVerificationCompleted,
    required Function(String error) onVerificationFailed,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
    );
  }

  /// Valide le format du numéro de téléphone
  ///
  /// Vérifie que le numéro:
  /// - Commence par +
  /// - Contient un code pays valide
  /// - A une longueur appropriée
  bool isValidPhoneNumber(String phoneNumber) {
    // Le numéro doit commencer par + suivi de chiffres
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Formate un numéro de téléphone au format international
  ///
  /// Exemple: "771234567" avec countryCode "+221" -> "+221771234567"
  String formatPhoneNumber(String phoneNumber, String countryCode) {
    // Retirer tous les espaces et caractères spéciaux
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Si le numéro commence déjà par +, le retourner tel quel
    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }

    // Si le numéro commence par 0, le retirer
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Ajouter le code pays
    return '$countryCode$phoneNumber';
  }

  /// Nettoie l'état de vérification actuel
  void reset() {
    _verificationId = null;
    _resendToken = null;
  }

  /// Mappe les codes d'erreur Firebase vers des messages en français
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Le numéro de téléphone n\'est pas valide';
      case 'invalid-verification-code':
        return 'Le code de vérification est incorrect';
      case 'session-expired':
        return 'La session a expiré. Demandez un nouveau code';
      case 'quota-exceeded':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'network-request-failed':
        return 'Pas de connexion internet';
      case 'too-many-requests':
        return 'Trop de demandes. Attendez quelques minutes';
      case 'missing-phone-number':
        return 'Aucun numéro de téléphone fourni';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      default:
        return 'Une erreur est survenue. Réessayez';
    }
  }
}

/// Résultat de la vérification du code OTP
class PhoneVerificationResult {
  final bool isSuccess;
  final PhoneAuthCredential? credential;
  final String? error;

  PhoneVerificationResult._({
    required this.isSuccess,
    this.credential,
    this.error,
  });

  factory PhoneVerificationResult.success(PhoneAuthCredential credential) {
    return PhoneVerificationResult._(
      isSuccess: true,
      credential: credential,
    );
  }

  factory PhoneVerificationResult.failure(String error) {
    return PhoneVerificationResult._(
      isSuccess: false,
      error: error,
    );
  }
}
