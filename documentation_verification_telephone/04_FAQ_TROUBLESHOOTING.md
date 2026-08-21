# FAQ et Dépannage - Vérification de Téléphone

## ❓ Questions Fréquemment Posées (FAQ)

### 1. Combien coûte Firebase Phone Authentication ?

**Réponse** :
- **Gratuit** : Les 10,000 premiers SMS par jour
- **Payant** : Au-delà, environ 0,01 $ par SMS
- **Astuce** : Pour une application de tontine avec croissance normale, vous restez dans le quota gratuit

### 2. Quels pays sont supportés ?

**Réponse** : 
Tous les pays sont supportés ! Firebase Phone Auth fonctionne avec tous les opérateurs téléphoniques dans le monde entier. Le package `intl_phone_field` inclut tous les codes pays (+1 à +998).

**Pays testés et confirmés** :
- 🇸🇳 Sénégal (+221)
- 🇫🇷 France (+33)
- 🇨🇮 Côte d'Ivoire (+225)
- 🇲🇱 Mali (+223)
- 🇧🇫 Burkina Faso (+226)
- 🇺🇸 États-Unis (+1)
- Et 190+ autres pays

### 3. Combien de temps le code OTP est-il valide ?

**Réponse** : 
- **5 minutes** par défaut
- Après expiration, l'utilisateur doit demander un nouveau code
- Le timer visuel dans l'app indique 60 secondes avant de pouvoir renvoyer

### 4. Que se passe-t-il si l'utilisateur n'a pas d'internet ?

**Réponse** :
- L'envoi du SMS nécessite une connexion internet
- Si pas d'internet : erreur "Pas de connexion internet"
- Une fois le SMS reçu, la vérification nécessite aussi internet pour valider auprès de Firebase

### 5. Puis-je tester sans envoyer de vrais SMS ?

**Réponse** : 
Oui ! Utilisez les numéros de test dans Firebase Console :
1. Authentication → Sign-in method → Phone
2. Phone numbers for testing
3. Ajoutez : `+221771234567` avec code `123456`

⚠️ **Important** : Retirez ces numéros avant la mise en production !

### 6. Le code SMS arrive-t-il instantanément ?

**Réponse** :
- **Généralement** : 5-30 secondes
- **Peut varier** selon :
  - L'opérateur téléphonique
  - La congestion du réseau
  - Le pays
- **Conseil** : Afficher "Cela peut prendre jusqu'à 2 minutes"

### 7. Puis-je personnaliser le message SMS ?

**Réponse** :
Non, le message est géré par Firebase et suit ce format :
```
Your verification code is: 123456
```

Vous ne pouvez pas personnaliser le texte.

### 8. Combien de fois un utilisateur peut-il demander un code ?

**Réponse** :
- **Par numéro** : 10 tentatives par jour
- **Par appareil** : 100 tentatives par jour
- Au-delà : erreur `quota-exceeded`

### 9. Que faire si un utilisateur change de numéro ?

**Réponse** :
Vous devez implémenter une fonctionnalité de "Changement de numéro" :
1. Vérifier l'ancien numéro (avec PIN)
2. Vérifier le nouveau numéro (avec OTP)
3. Mettre à jour dans Firestore

### 10. Est-ce que ça fonctionne avec les numéros VoIP (Google Voice, etc.) ?

**Réponse** :
- **Généralement non** : Firebase bloque souvent les numéros VoIP
- **Raison** : Prévention d'abus
- **Alternative** : Utiliser un vrai numéro de téléphone mobile

---

## 🐛 Problèmes Courants et Solutions

### Problème 1 : "invalid-phone-number"

**Symptôme** :
```
❌ Le numéro de téléphone n'est pas valide
```

**Causes possibles** :
1. Format incorrect (doit commencer par +)
2. Code pays manquant
3. Numéro trop court ou trop long

**Solution** :
```dart
// Vérifier le format avant d'envoyer
if (!_phoneVerificationService.isValidPhoneNumber(phoneNumber)) {
  print('Format invalide: $phoneNumber');
  // Le format correct est : +[code pays][numéro]
  // Exemple : +221771234567
}
```

**Vérification** :
- Le numéro doit être au format E.164
- Exemple valide : `+221771234567`
- Exemple invalide : `771234567` ou `+221 77 123 45 67`

---

### Problème 2 : Le SMS n'arrive jamais

**Symptôme** :
L'utilisateur attend mais ne reçoit jamais le SMS.

**Causes possibles** :

#### Cause A : SHA-1 manquant (Android)
**Vérification** :
```bash
cd android
./gradlew signingReport
```

**Solution** :
1. Copier les empreintes SHA-1 et SHA-256
2. Les ajouter dans Firebase Console → Project Settings → Your apps

#### Cause B : APNs non configuré (iOS)
**Vérification** :
Dans Firebase Console → Project Settings → Cloud Messaging → iOS

**Solution** :
1. Télécharger APNs Auth Key depuis Apple Developer
2. L'uploader dans Firebase Console

#### Cause C : Quota dépassé
**Vérification** :
Firebase Console → Authentication → Usage

**Solution** :
- Attendre la réinitialisation quotidienne
- Demander une augmentation de quota
- Utiliser des numéros de test en développement

#### Cause D : Numéro VoIP ou invalide
**Solution** :
Tester avec un vrai numéro de téléphone mobile

---

### Problème 3 : "session-expired"

**Symptôme** :
```
❌ La session a expiré. Demandez un nouveau code
```

**Cause** :
L'utilisateur a attendu plus de 5 minutes avant d'entrer le code.

**Solution** :
```dart
// Afficher un message clair
if (error.code == 'session-expired') {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Session expirée'),
      content: Text('Le code a expiré. Cliquez sur "Renvoyer le code".'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _resendCode();
          },
          child: Text('Renvoyer'),
        ),
      ],
    ),
  );
}
```

---

### Problème 4 : "too-many-requests"

**Symptôme** :
```
❌ Trop de demandes. Attendez quelques minutes
```

**Cause** :
L'utilisateur ou l'appareil a dépassé le quota horaire.

**Solution** :
```dart
// Implémenter un cooldown
DateTime? _lastRequestTime;

Future<void> _sendCode() async {
  if (_lastRequestTime != null) {
    final diff = DateTime.now().difference(_lastRequestTime!);
    if (diff.inSeconds < 60) {
      setState(() => _errorMessage = 
        'Veuillez attendre ${60 - diff.inSeconds} secondes'
      );
      return;
    }
  }
  
  _lastRequestTime = DateTime.now();
  // Continuer avec l'envoi...
}
```

---

### Problème 5 : L'application crash sur Android

**Symptôme** :
L'application se ferme lors de la vérification du téléphone.

**Causes possibles** :

#### Cause A : Permissions manquantes
**Solution** :
Ajouter dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
```

#### Cause B : google-services.json incorrect
**Solution** :
1. Re-télécharger depuis Firebase Console
2. Placer dans `android/app/google-services.json`
3. Rebuild : `flutter clean && flutter build apk`

#### Cause C : Dépendances obsolètes
**Solution** :
```bash
flutter pub upgrade
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

### Problème 6 : "invalid-verification-code" même avec le bon code

**Symptôme** :
L'utilisateur entre le bon code mais reçoit "Code incorrect".

**Causes possibles** :

#### Cause A : Mauvais verificationId
**Vérification** :
```dart
debugPrint('Verification ID: $_verificationId');
debugPrint('SMS Code: $smsCode');
```

**Solution** :
S'assurer que `_verificationId` est bien conservé entre l'envoi et la vérification.

#### Cause B : Code expiré
Le code a plus de 5 minutes.

**Solution** :
Demander un nouveau code.

#### Cause C : Espaces dans le code
**Solution** :
```dart
// Nettoyer le code avant vérification
final cleanCode = smsCode.replaceAll(RegExp(r'\s'), '');
await verifyOtpCode(cleanCode);
```

---

### Problème 7 : Vérification automatique ne fonctionne pas (Android)

**Symptôme** :
Sur Android, l'utilisateur doit toujours entrer le code manuellement.

**Explication** :
La vérification automatique nécessite :
1. Google Play Services à jour
2. Connexion internet stable
3. SMS envoyé rapidement (< 30 secondes)

**Ce n'est pas un bug** :
La vérification automatique est un bonus, pas une garantie. L'utilisateur doit toujours pouvoir entrer le code manuellement.

---

### Problème 8 : Erreur de build sur iOS

**Symptôme** :
```
Error: Undefined symbol: _OBJC_CLASS_$_FIRPhoneAuthProvider
```

**Solution** :
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install
cd ..
flutter clean
flutter run
```

---

## 🔍 Debugging et Logs

### Activer les Logs Détaillés

#### Pour Android
Dans `android/app/build.gradle` :
```gradle
android {
    buildTypes {
        debug {
            debuggable true
        }
    }
}
```

#### Pour iOS
Dans Xcode → Product → Scheme → Edit Scheme → Run → Arguments
Ajouter :
```
-FIRDebugEnabled
```

### Logs à Surveiller

```dart
// Dans PhoneVerificationService
debugPrint('📱 Numéro formaté: $phoneNumber');
debugPrint('🔄 Tentative d\'envoi du code...');
debugPrint('✅ Code envoyé - ID: $verificationId');
debugPrint('❌ Erreur: ${e.code} - ${e.message}');
```

### Tester le Flow Complet

```dart
void testPhoneVerification() async {
  final service = PhoneVerificationService();
  
  print('1️⃣ Test de validation de format...');
  assert(service.isValidPhoneNumber('+221771234567') == true);
  assert(service.isValidPhoneNumber('771234567') == false);
  print('✅ Validation OK');
  
  print('2️⃣ Test de formatage...');
  assert(service.formatPhoneNumber('771234567', '+221') == '+221771234567');
  assert(service.formatPhoneNumber('0771234567', '+221') == '+221771234567');
  print('✅ Formatage OK');
  
  print('3️⃣ Test d\'envoi de code...');
  await service.verifyPhoneNumber(
    phoneNumber: '+221771234567',  // Utiliser un numéro de test
    onCodeSent: (id) => print('✅ Code envoyé: $id'),
    onVerificationCompleted: () => print('✅ Vérification auto'),
    onVerificationFailed: (error) => print('❌ Erreur: $error'),
  );
}
```

---

## 📋 Checklist de Vérification

Avant de déployer en production, vérifiez :

### Configuration Firebase
- [ ] Phone Authentication activé
- [ ] SHA-1/SHA-256 ajoutés (Android - debug ET release)
- [ ] APNs Auth Key uploadé (iOS)
- [ ] App Check configuré (recommandé)
- [ ] Numéros de test retirés
- [ ] Quotas surveillés

### Code
- [ ] `intl_phone_field` installé
- [ ] `PhoneVerificationService` implémenté
- [ ] `PhoneVerificationScreen` créé
- [ ] `InscriptionScreen` modifié
- [ ] Gestion d'erreurs complète
- [ ] Timer de renvoi fonctionnel
- [ ] Validation de format côté client

### Tests
- [ ] Inscription avec numéro valide (Sénégal)
- [ ] Inscription avec numéro international (France, US)
- [ ] Code incorrect (affichage erreur)
- [ ] Code expiré (session-expired)
- [ ] Renvoi de code après 60s
- [ ] Numéro déjà utilisé (erreur appropriée)
- [ ] Pas d'internet (erreur appropriée)
- [ ] Build Android réussi
- [ ] Build iOS réussi

### Permissions
- [ ] `INTERNET` (Android)
- [ ] `RECEIVE_SMS` (Android, optionnel)
- [ ] `READ_SMS` (Android, optionnel)
- [ ] Push Notifications capability (iOS)

---

## 🆘 Support et Ressources

### Documentation Officielle
- [Firebase Phone Auth](https://firebase.google.com/docs/auth/flutter/phone-auth)
- [IntlPhoneField Package](https://pub.dev/packages/intl_phone_field)
- [Firebase Console](https://console.firebase.google.com/)

### Communauté
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Firebase Support](https://firebase.google.com/support)

### Outils de Debug
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools)
- [Android Studio Logcat](https://developer.android.com/studio/debug/logcat)
- [Xcode Console](https://developer.apple.com/documentation/xcode/viewing-debug-information)

---

## 💡 Bonnes Pratiques

### 1. UX/UI
- ✅ Afficher clairement le numéro à vérifier
- ✅ Timer visible pour le renvoi
- ✅ Auto-focus entre les champs OTP
- ✅ Vérification auto quand le dernier chiffre est entré
- ✅ Messages d'erreur clairs et en français

### 2. Performance
- ✅ Pas de requête inutile (vérifier avant d'envoyer)
- ✅ Cache les controllers et focus nodes
- ✅ Dispose correctement les ressources

### 3. Sécurité
- ✅ Jamais de numéros de test en production
- ✅ Valider côté serveur (Firebase le fait)
- ✅ Limiter les tentatives (Firebase le fait)
- ✅ App Check activé

### 4. Monitoring
- ✅ Logger les erreurs importantes
- ✅ Surveiller les quotas Firebase
- ✅ Analyser le taux de réussite
- ✅ Mesurer le temps de vérification

---

## 🎓 Exemples de Cas d'Usage

### Cas 1 : Utilisateur du Sénégal
```
Numéro entré: 77 123 45 67
Code pays: +221 (Sénégal)
Format final: +221771234567
✅ SMS reçu en ~10 secondes
✅ Code vérifié avec succès
```

### Cas 2 : Utilisateur de France
```
Numéro entré: 06 12 34 56 78
Code pays: +33 (France)
Format final: +33612345678
✅ SMS reçu en ~15 secondes
✅ Code vérifié avec succès
```

### Cas 3 : Utilisateur des États-Unis
```
Numéro entré: (555) 123-4567
Code pays: +1 (US)
Format final: +15551234567
✅ SMS reçu en ~20 secondes
✅ Code vérifié avec succès
```

---

## 📞 Contact et Support

Pour toute question ou problème non résolu :

1. Vérifiez d'abord cette documentation
2. Consultez les logs Firebase Console
3. Testez avec un numéro de test
4. Vérifiez votre configuration (checklist ci-dessus)

**Dernière mise à jour** : 2026-08-18
