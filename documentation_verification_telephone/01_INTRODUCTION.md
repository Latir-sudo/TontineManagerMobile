# Documentation - Vérification de Numéro de Téléphone

## 📱 Introduction

Cette documentation détaille le système de vérification de numéro de téléphone implémenté dans l'application Tontine Manager. Ce système garantit que les utilisateurs fournissent un numéro de téléphone **valide** et **existant** lors de leur inscription.

## 🎯 Objectifs

1. **Validation de l'existence du numéro** : S'assurer que le numéro de téléphone existe réellement et peut recevoir des SMS
2. **Support international** : Accepter et vérifier les numéros de tous les pays
3. **Sécurité** : Prévenir les inscriptions frauduleuses avec de faux numéros
4. **Expérience utilisateur** : Interface claire et intuitive pour la saisie et la vérification

## 🏗️ Architecture Générale

Le système de vérification repose sur trois composants principaux :

### 1. **PhoneVerificationService**
Service responsable de l'interaction avec Firebase Phone Authentication pour envoyer et vérifier les codes OTP.

**Fichier** : `lib/services/phone_verification_service.dart`

### 2. **PhoneVerificationScreen**
Écran où l'utilisateur entre le code à 6 chiffres reçu par SMS.

**Fichier** : `lib/screens/phone_verification_screen.dart`

### 3. **InscriptionScreen (modifié)**
Écran d'inscription mis à jour pour inclure :
- Un champ de numéro international avec sélection de pays
- L'intégration du flux de vérification avant la création du compte

**Fichier** : `lib/screens/inscription_screen.dart`

## 🔄 Flux d'Inscription avec Vérification

```
┌─────────────────────────────────────────────────────────────┐
│                  INSCRIPTION UTILISATEUR                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 1. Saisie des informations                                  │
│    - Nom complet                                            │
│    - Téléphone (avec code pays)                             │
│    - Localité                                               │
│    - Code PIN (4 chiffres)                                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Validation des champs                                    │
│    ✓ Tous les champs requis remplis                        │
│    ✓ Numéro de téléphone au format valide                  │
│    ✓ Code PIN correspond                                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Vérification que le numéro n'existe pas déjà            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Envoi du code de vérification SMS via Firebase          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. ÉCRAN DE VÉRIFICATION OTP                                │
│    - Saisie du code à 6 chiffres                           │
│    - Timer de 60 secondes                                   │
│    - Option de renvoi du code                               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Vérification du code OTP                                 │
│    ✓ Code correct → Continue                                │
│    ✗ Code incorrect → Réessayer                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Création du compte utilisateur                           │
│    - Stockage dans Firestore                                │
│    - Connexion automatique                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. Navigation vers l'écran principal                        │
└─────────────────────────────────────────────────────────────┘
```

## 🌍 Support International

Le système supporte **tous les pays** grâce à :

1. **IntlPhoneField** : Widget qui gère automatiquement :
   - Liste complète de tous les codes pays (+1, +33, +221, etc.)
   - Drapeaux pour identification visuelle
   - Validation automatique selon le format du pays
   - Formatage du numéro au format international

2. **Firebase Phone Auth** : Service qui :
   - Envoie des SMS dans le monde entier
   - Gère les différents opérateurs téléphoniques
   - S'adapte aux particularités régionales

## 📊 Technologies Utilisées

| Technologie | Version | Rôle |
|------------|---------|------|
| `firebase_auth` | ^5.5.4 | Authentification et vérification téléphone |
| `intl_phone_field` | ^3.2.0 | Saisie de numéro international avec drapeaux |
| `cloud_firestore` | ^5.6.8 | Stockage des données utilisateur |

## 📁 Structure des Fichiers

```
tontine_manager/
├── lib/
│   ├── services/
│   │   ├── phone_verification_service.dart    # Service de vérification
│   │   └── auth_service.dart                  # Service d'authentification
│   └── screens/
│       ├── inscription_screen.dart            # Écran d'inscription (modifié)
│       └── phone_verification_screen.dart     # Écran de vérification OTP
└── documentation_verification_telephone/
    ├── 01_INTRODUCTION.md                     # Ce fichier
    ├── 02_CONFIGURATION_FIREBASE.md           # Configuration Firebase
    ├── 03_GUIDE_TECHNIQUE.md                  # Guide technique détaillé
    └── 04_FAQ_TROUBLESHOOTING.md             # FAQ et dépannage
```

## 🚀 Prochaines Étapes

Pour implémenter complètement ce système, consultez :
- **[Configuration Firebase](02_CONFIGURATION_FIREBASE.md)** - Configuration requise dans la console Firebase
- **[Guide Technique](03_GUIDE_TECHNIQUE.md)** - Détails d'implémentation et code
- **[FAQ et Dépannage](04_FAQ_TROUBLESHOOTING.md)** - Solutions aux problèmes courants

---

**Dernière mise à jour** : 2026-08-18
