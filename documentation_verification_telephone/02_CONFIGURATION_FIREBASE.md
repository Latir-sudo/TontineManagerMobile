# Configuration Firebase pour la Vérification de Téléphone

## 🔐 Activation de Firebase Phone Authentication

### Étape 1 : Accéder à la Console Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet **Tontine Manager**
3. Dans le menu latéral, cliquez sur **Authentication**

### Étape 2 : Activer Phone Authentication

1. Cliquez sur l'onglet **Sign-in method**
2. Dans la liste des fournisseurs, trouvez **Phone**
3. Cliquez sur **Phone** puis sur **Enable** (Activer)
4. Cliquez sur **Save** (Enregistrer)

![Firebase Phone Auth](https://i.imgur.com/placeholder-phone-auth.png)

---

## 📱 Configuration Android

### 1. Vérifier le SHA-1/SHA-256

Firebase nécessite les empreintes SHA de votre application Android pour des raisons de sécurité.

#### Obtenir les empreintes SHA :

```bash
# Pour debug keystore
cd android
./gradlew signingReport

# OU via keytool
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Ajouter les empreintes dans Firebase :

1. Dans la Console Firebase, allez dans **Project Settings** (⚙️ en haut à gauche)
2. Sous **Your apps**, sélectionnez votre application Android
3. Cliquez sur **Add fingerprint**
4. Collez votre empreinte SHA-1
5. Ajoutez aussi l'empreinte SHA-256 si disponible

### 2. Mettre à jour `android/app/build.gradle`

Assurez-vous que les dépendances Firebase sont bien présentes :

```gradle
dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.0.0')
    implementation 'com.google.firebase:firebase-auth'
}
```

### 3. Configuration AndroidManifest.xml

Ajoutez les permissions nécessaires dans `android/app/src/main/AndroidManifest.xml` :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions requises -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_SMS"/>
    <uses-permission android:name="android.permission.READ_SMS"/>
    
    <application>
        <!-- Votre configuration existante -->
    </application>
</manifest>
```

⚠️ **Note** : `RECEIVE_SMS` et `READ_SMS` sont optionnels mais améliorent l'expérience utilisateur car Android peut détecter automatiquement le SMS de vérification.

---

## 🍎 Configuration iOS

### 1. Activer les notifications push

Firebase Phone Auth sur iOS nécessite les notifications push (même silencieuses).

#### Dans Xcode :

1. Ouvrez `ios/Runner.xcworkspace` dans Xcode
2. Sélectionnez le projet **Runner** dans le navigateur
3. Allez dans l'onglet **Signing & Capabilities**
4. Cliquez sur **+ Capability**
5. Ajoutez **Push Notifications**

### 2. Télécharger le fichier APNs Auth Key

#### Dans Apple Developer Portal :

1. Allez sur [Apple Developer](https://developer.apple.com/)
2. Accédez à **Certificates, Identifiers & Profiles**
3. Cliquez sur **Keys** → **+ Create a new key**
4. Donnez un nom (ex: "Firebase Phone Auth")
5. Cochez **Apple Push Notifications service (APNs)**
6. Cliquez sur **Continue** puis **Register**
7. **Téléchargez le fichier .p8** (IMPORTANT : vous ne pourrez le télécharger qu'une seule fois)

#### Uploader dans Firebase :

1. Dans Firebase Console, allez dans **Project Settings**
2. Onglet **Cloud Messaging**
3. Sous **iOS app configuration** :
   - Cliquez sur **Upload** dans la section **APNs Authentication Key**
   - Uploadez votre fichier `.p8`
   - Entrez le **Key ID** (trouvé sur Apple Developer)
   - Entrez le **Team ID** (trouvé dans Apple Developer → Membership)

### 3. Configuration Info.plist

Aucune configuration spéciale n'est requise, Firebase gère automatiquement la configuration.

---

## 🔥 Télécharger les Fichiers de Configuration Mis à Jour

### Pour Android

1. Dans Firebase Console → **Project Settings**
2. Sous **Your apps**, sélectionnez votre app Android
3. Cliquez sur **google-services.json** pour le télécharger
4. Remplacez le fichier dans `android/app/google-services.json`

### Pour iOS

1. Dans Firebase Console → **Project Settings**
2. Sous **Your apps**, sélectionnez votre app iOS
3. Cliquez sur **GoogleService-Info.plist** pour le télécharger
4. Remplacez le fichier dans `ios/Runner/GoogleService-Info.plist`

---

## 🧪 Configuration des Numéros de Test (Optionnel)

Pour tester sans envoyer de vrais SMS (pratique en développement) :

### Ajouter des Numéros de Test :

1. Firebase Console → **Authentication** → **Sign-in method**
2. Sous **Phone**, cliquez sur **Phone numbers for testing**
3. Ajoutez un numéro et un code de vérification :
   - **Numéro** : `+221771234567`
   - **Code** : `123456`
4. Cliquez sur **Add**

Maintenant, en utilisant ce numéro, Firebase renverra toujours le code `123456` sans envoyer de SMS réel.

⚠️ **ATTENTION** : Retirez ces numéros de test en production !

---

## 🌐 Quota et Limites

### Quotas par Défaut

Firebase Phone Auth a des limites gratuites :

| Limite | Valeur |
|--------|--------|
| SMS par jour | 10,000 (gratuit) |
| SMS par projet par heure | 5,000 |
| Tentatives par numéro par jour | 10 |
| Tentatives par appareil par jour | 100 |

### Augmenter les Quotas

Si vous dépassez ces limites :
1. Allez dans **Authentication** → **Settings** → **Quotas**
2. Cliquez sur **Manage quotas**
3. Contactez le support Firebase pour une augmentation

---

## 🔒 Configuration de sécurité (App Check)

Pour éviter les abus, configurez App Check :

### 1. Activer App Check

```bash
flutter pub add firebase_app_check
```

### 2. Configurer dans le code

Dans `lib/main.dart`, après `Firebase.initializeApp()` :

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Activer App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  
  runApp(const TontineManagerApp());
}
```

### 3. Configurer dans Firebase Console

1. Allez dans **App Check**
2. Cliquez sur **Get started**
3. Enregistrez vos applications Android et iOS
4. Activez l'application pour Phone Auth

---

## ✅ Vérification de la Configuration

### Commande de Test

```bash
# Installer les dépendances
flutter pub get

# Tester sur Android
flutter run -d android

# Tester sur iOS
flutter run -d ios
```

### Checklist

- [ ] Firebase Phone Authentication activé
- [ ] SHA-1/SHA-256 ajoutés (Android)
- [ ] APNs Auth Key uploadé (iOS)
- [ ] Fichiers `google-services.json` et `GoogleService-Info.plist` à jour
- [ ] Numéros de test configurés (dev uniquement)
- [ ] App Check configuré (recommandé)
- [ ] Test d'inscription réussi

---

## 🚨 Points Importants

1. **Coûts** : Les 10,000 premiers SMS par jour sont gratuits, au-delà c'est payant
2. **Numéros de test** : À retirer en production pour éviter les failles de sécurité
3. **SHA fingerprints** : Différentes entre debug et release, pensez à ajouter les deux
4. **APNs Key** : Fichier .p8 téléchargeable qu'une seule fois, conservez-le précieusement
5. **Quotas** : Surveillez votre utilisation pour éviter les coupures

---

**Prochaine étape** : [Guide Technique](03_GUIDE_TECHNIQUE.md)
