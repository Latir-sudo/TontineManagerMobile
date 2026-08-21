# Obtenir les empreintes SHA-1 et SHA-256 de l'application

## Debug (développement)

### Commande

```bash
keytool -list -v -keystore C:\Users\HP\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Informations par défaut du keystore debug

| Champ       | Valeur          |
|-------------|-----------------|
| Chemin      | `C:\Users\HP\.android\debug.keystore` |
| Alias       | `androiddebugkey` |
| Mot de passe| `android`       |

---

## Production (publication)

### 1. Créer un keystore de production (une seule fois)

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Conservez ce fichier en lieu sûr. Ne le versionnez jamais dans git.

### 2. Obtenir l'empreinte du keystore de production

```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
```

Entrez le mot de passe défini lors de la création.

### 3. Si vous utilisez la signature Google Play (App Signing)

L'empreinte de production réelle est gérée par Google. Pour la trouver :

1. Ouvrez la **Google Play Console**
2. Sélectionnez votre application
3. Allez dans **Configuration** > **Intégrité de l'application**
4. Onglet **Signature de l'application**
5. Copiez l'empreinte **SHA-256** affichée

---

## Utilisation des empreintes

### Firebase

1. Ouvrez la **Firebase Console**
2. Allez dans **Paramètres du projet** (icône engrenage)
3. Section **Vos applications** > sélectionnez l'app Android
4. Cliquez **Ajouter une empreinte**
5. Collez l'empreinte SHA-1 ou SHA-256

### Play Integrity (reCAPTCHA / vérification téléphone)

Pour activer Play Integrity avec Firebase Phone Auth, ajoutez l'empreinte **SHA-256** dans Firebase Console (voir ci-dessus).

---

## Rediriger la sortie dans un fichier (si la console tronque)

```bash
keytool -list -v -keystore C:\Users\HP\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android > sha_output.txt
```

Le fichier `sha_output.txt` contiendra les lignes :

```
SHA1:   XX:XX:XX:XX:...
SHA256: XX:XX:XX:XX:...
```
