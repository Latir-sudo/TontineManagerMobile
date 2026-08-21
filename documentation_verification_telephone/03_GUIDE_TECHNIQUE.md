# Guide Technique - Vérification de Téléphone

## 📋 Table des Matières

1. [Architecture du Service](#architecture-du-service)
2. [Flux de Données](#flux-de-données)
3. [Code Détaillé](#code-détaillé)
4. [Gestion des Erreurs](#gestion-des-erreurs)
5. [Cas Particuliers](#cas-particuliers)

---

## 🏗️ Architecture du Service

### PhoneVerificationService

Le service principal qui encapsule toute la logique de vérification.

#### Responsabilités

- ✅ Envoyer le code de vérification SMS
- ✅ Vérifier le code OTP entré par l'utilisateur
- ✅ Gérer les cas de renvoi de code
- ✅ Valider le format des numéros
- ✅ Gérer les erreurs Firebase

#### Variables d'État Internes

```dart
String? _verificationId;    // ID de session de vérification
int? _resendToken;          // Token pour renvoyer un code
```

---

## 🔄 Flux de Données Détaillé

### 1. Envoi du Code de Vérification

```
┌──────────────────────────────────────────────────────────────┐
│ INSCRIPTION SCREEN                                           │
│ - L'utilisateur entre son numéro : +221 77 123 45 67       │
│ - Validation du format avec IntlPhoneField                  │
│ - Vérification que le numéro n'existe pas dans Firestore   │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ PHONE VERIFICATION SERVICE                                   │
│ Method: verifyPhoneNumber()                                  │
│ - Formate le numéro au format E.164 : +221771234567        │
│ - Appelle Firebase Auth verifyPhoneNumber()                 │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ FIREBASE PHONE AUTH                                          │
│ - Envoie une requête au backend Firebase                    │
│ - Firebase génère un code à 6 chiffres                      │
│ - Firebase envoie un SMS via les opérateurs télécom        │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ CALLBACKS                                                    │
│                                                              │
│ ✅ codeSent(verificationId, resendToken)                    │
│    → Navigation vers PhoneVerificationScreen                │
│                                                              │
│ ✅ verificationCompleted(credential)                        │
│    → (Android uniquement) Vérification auto, skip OTP      │
│                                                              │
│ ❌ verificationFailed(exception)                            │
│    → Afficher l'erreur à l'utilisateur                     │
└──────────────────────────────────────────────────────────────┘
```

### 2. Vérification du Code OTP

```
┌──────────────────────────────────────────────────────────────┐
│ PHONE VERIFICATION SCREEN                                    │
│ - Affiche 6 champs pour les chiffres                        │
│ - L'utilisateur entre : 1 2 3 4 5 6                        │
│ - Focus automatique d'un champ à l'autre                    │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ PHONE VERIFICATION SERVICE                                   │
│ Method: verifyOtpCode("123456")                             │
│ - Crée un PhoneAuthCredential avec verificationId + code   │
│ - Tente signInWithCredential()                              │
│ - Si succès : déconnecte immédiatement                      │
│ - Retourne le credential si valide                          │
└──────────────────────────────────────────────────────────────┘
                          ▼
┌──────────────────────────────────────────────────────────────┐
│ RÉSULTAT                                                     │
│                                                              │
│ ✅ Code correct                                              │
│    → Retour à InscriptionScreen                            │
│    → Création du compte dans Firestore                      │
│    → Connexion de l'utilisateur                             │
│    → Navigation vers MainNavigationScreen                   │
│                                                              │
│ ❌ Code incorrect                                            │
│    → Afficher erreur                                        │
│    → Effacer les champs                                     │
│    → L'utilisateur peut réessayer                           │
└──────────────────────────────────────────────────────────────┘
```

---

## 💻 Code Détaillé

### 1. PhoneVerificationService - Méthode principale

```dart
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
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('✅ Vérification automatique réussie');
        onVerificationCompleted();
      },

      // Appelé en cas d'échec
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('❌ Échec: ${e.code} - ${e.message}');
        final errorMessage = _mapFirebaseError(e.code);
        onVerificationFailed(errorMessage);
      },

      // Appelé quand le SMS est envoyé
      codeSent: (String verificationId, int? resendToken) {
        debugPrint('📨 Code envoyé - ID: $verificationId');
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId);
      },

      // Timeout de récupération auto
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('⏱️ Timeout de récupération automatique');
        _verificationId = verificationId;
      },

      // Token pour renvoyer
      forceResendingToken: _resendToken,
    );
  } catch (e) {
    debugPrint('❌ Erreur lors de la vérification: $e');
    onVerificationFailed('Une erreur est survenue.');
  }
}
```

### 2. Vérification du Code OTP

```dart
Future<PhoneVerificationResult> verifyOtpCode(String smsCode) async {
  try {
    if (_verificationId == null) {
      return PhoneVerificationResult.failure(
        'Aucune vérification en cours.'
      );
    }

    // Créer le credential
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    // Vérifier le credential
    try {
      await _auth.signInWithCredential(credential);
      // Code correct ! On déconnecte car on veut juste vérifier
      await _auth.signOut();

      return PhoneVerificationResult.success(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return PhoneVerificationResult.failure('Code incorrect.');
      } else if (e.code == 'session-expired') {
        return PhoneVerificationResult.failure('Le code a expiré.');
      }
      return PhoneVerificationResult.failure(_mapFirebaseError(e.code));
    }
  } catch (e) {
    debugPrint('❌ Erreur: $e');
    return PhoneVerificationResult.failure('Une erreur est survenue.');
  }
}
```

### 3. InscriptionScreen - Intégration du Champ International

```dart
IntlPhoneField(
  controller: _telephoneController,
  decoration: InputDecoration(
    hintText: 'Numéro de téléphone',
    filled: true,
    fillColor: AppColors.lightGrey,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  languageCode: 'fr',
  initialCountryCode: 'SN',  // Sénégal par défaut
  onChanged: (phone) {
    setState(() {
      _completePhoneNumber = phone.completeNumber;  // Ex: +221771234567
      _isPhoneValid = phone.isValidNumber();
      _errorMessage = null;
    });
  },
  invalidNumberMessage: 'Numéro invalide',
),
```

### 4. PhoneVerificationScreen - Champs OTP

```dart
// Génère 6 champs de saisie pour le code OTP
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: List.generate(6, (index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          // Focus sur le champ suivant
          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          // Focus sur le champ précédent si effacement
          else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          
          // Auto-vérification si tous les champs remplis
          if (index == 5 && value.length == 1) {
            _verifyCode();
          }
        },
      ),
    );
  }),
),
```

---

## 🚨 Gestion des Erreurs

### Codes d'Erreur Firebase Courants

| Code Firebase | Signification | Message Utilisateur |
|--------------|---------------|---------------------|
| `invalid-phone-number` | Format de numéro invalide | "Le numéro de téléphone n'est pas valide" |
| `invalid-verification-code` | Code OTP incorrect | "Le code de vérification est incorrect" |
| `session-expired` | La session a expiré (>5min) | "La session a expiré. Demandez un nouveau code" |
| `quota-exceeded` | Trop de SMS envoyés | "Trop de tentatives. Réessayez plus tard" |
| `network-request-failed` | Pas d'internet | "Pas de connexion internet" |
| `too-many-requests` | Trop de requêtes | "Trop de demandes. Attendez quelques minutes" |

### Implémentation du Mapping

```dart
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
    default:
      return 'Une erreur est survenue. Réessayez';
  }
}
```

---

## 🎯 Cas Particuliers

### 1. Vérification Automatique (Android)

Sur Android, Firebase peut détecter automatiquement le SMS et remplir le code.

**Callback** :
```dart
verificationCompleted: (PhoneAuthCredential credential) async {
  debugPrint('✅ Vérification automatique réussie');
  // Pas besoin de l'écran OTP, on passe directement à l'inscription
  onVerificationCompleted();
}
```

### 2. Renvoi du Code

L'utilisateur peut demander un nouveau code après 60 secondes.

**Implémentation** :
```dart
Future<void> _resendCode() async {
  if (!_canResend || _isResending) return;

  setState(() => _isResending = true);

  await _verificationService.resendCode(
    phoneNumber: widget.phoneNumber,
    onCodeSent: (verificationId) {
      // Redémarrer le timer
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un nouveau code a été envoyé'),
          backgroundColor: Colors.green,
        ),
      );
    },
    onVerificationCompleted: () {
      widget.onVerificationComplete(true);
    },
    onVerificationFailed: (error) {
      setState(() => _errorMessage = error);
    },
  );
}
```

### 3. Timer de Renvoi

Empêche l'utilisateur de renvoyer trop rapidement.

```dart
void _startTimer() {
  _remainingSeconds = 60;
  _canResend = false;
  _timer?.cancel();

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }
    setState(() {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else {
        _canResend = true;
        timer.cancel();
      }
    });
  });
}
```

### 4. Validation de Numéro

Avant d'envoyer le code, on valide le format :

```dart
bool isValidPhoneNumber(String phoneNumber) {
  // Format E.164 : + suivi de 1-15 chiffres
  final regex = RegExp(r'^\+[1-9]\d{1,14}$');
  return regex.hasMatch(phoneNumber);
}
```

### 5. Formatage de Numéro

Conversion automatique au format international :

```dart
String formatPhoneNumber(String phoneNumber, String countryCode) {
  // Retirer espaces et caractères spéciaux
  phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

  // Si commence par +, retourner tel quel
  if (phoneNumber.startsWith('+')) {
    return phoneNumber;
  }

  // Si commence par 0, le retirer
  if (phoneNumber.startsWith('0')) {
    phoneNumber = phoneNumber.substring(1);
  }

  // Ajouter le code pays
  return '$countryCode$phoneNumber';
}
```

**Exemples** :
- `771234567` + `+221` → `+221771234567`
- `0771234567` + `+221` → `+221771234567`
- `+221771234567` → `+221771234567` (déjà formaté)

---

## 🧪 Tests Recommandés

### 1. Tests Unitaires (Service)

```dart
void main() {
  group('PhoneVerificationService', () {
    test('Format de numéro valide', () {
      final service = PhoneVerificationService();
      expect(service.isValidPhoneNumber('+221771234567'), true);
      expect(service.isValidPhoneNumber('771234567'), false);
      expect(service.isValidPhoneNumber('+221 77 123 45 67'), false);
    });

    test('Formatage de numéro', () {
      final service = PhoneVerificationService();
      expect(
        service.formatPhoneNumber('771234567', '+221'),
        '+221771234567'
      );
      expect(
        service.formatPhoneNumber('0771234567', '+221'),
        '+221771234567'
      );
    });
  });
}
```

### 2. Tests d'Intégration

1. **Inscription avec numéro valide** :
   - Entrer toutes les informations
   - Vérifier que le SMS est envoyé
   - Entrer le bon code
   - Vérifier la création du compte

2. **Code incorrect** :
   - Entrer un mauvais code
   - Vérifier l'affichage de l'erreur
   - Vérifier que les champs sont effacés

3. **Renvoi de code** :
   - Attendre 60 secondes
   - Cliquer sur "Renvoyer"
   - Vérifier la réception d'un nouveau SMS

4. **Numéro déjà utilisé** :
   - Tenter l'inscription avec un numéro existant
   - Vérifier l'affichage de l'erreur appropriée

---

## 📊 Métriques et Monitoring

### Logs Importants

Le service log automatiquement :

- ✅ `✅ Vérification automatique réussie` - Android auto-verify
- 📨 `📨 Code envoyé - verificationId: xxx` - SMS envoyé
- ❌ `❌ Échec de vérification: code - message` - Erreur
- ⏱️ `⏱️ Timeout de récupération automatique` - Timeout

### Métriques à Surveiller

1. **Taux de réussite de vérification** : 
   - `(Codes corrects / Codes envoyés) * 100`
   - Objectif : > 90%

2. **Temps moyen de vérification** :
   - Du clic "S'inscrire" à la validation
   - Objectif : < 2 minutes

3. **Taux d'abandon** :
   - Utilisateurs qui quittent l'écran OTP
   - Objectif : < 10%

4. **Utilisations de renvoi** :
   - Combien de fois le code est renvoyé
   - Objectif : < 20% des inscriptions

---

## 🔐 Sécurité

### Bonnes Pratiques Implémentées

1. ✅ **Validation côté client ET serveur** (Firebase)
2. ✅ **Limitation des tentatives** (Firebase quota)
3. ✅ **Expiration du code** (5 minutes)
4. ✅ **Pas de stockage du code** (géré par Firebase)
5. ✅ **Numéros de test uniquement en dev**
6. ✅ **App Check** pour éviter les abus (recommandé)

### Points d'Attention

⚠️ **Ne jamais** :
- Stocker le code OTP dans Firestore
- Afficher le code dans les logs en production
- Permettre des tentatives illimitées
- Laisser des numéros de test en production

---

**Prochaine étape** : [FAQ et Dépannage](04_FAQ_TROUBLESHOOTING.md)
