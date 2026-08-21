# DOCUMENT DES FONCTIONNALITES - TontineManager Mobile

## Informations generales du projet

| Element | Description |
|---------|------------|
| **Nom du projet** | TontineManager Mobile |
| **Type** | Application mobile |
| **Technologie** | Flutter (Dart) |
| **Backend** | Firebase (Firestore + Firebase Authentication) |
| **Plateforme cible** | Android / iOS |
| **Contexte** | Gestion de tontines au Senegal |

---

## 1. MODULE AUTHENTIFICATION

### 1.1 Inscription (Creation de compte)

**Description** : Permet a un nouvel utilisateur de creer un compte sur l'application.

**Champs du formulaire** :
| Champ | Type | Obligatoire | Exemple |
|-------|------|-------------|---------|
| Nom complet | Texte | Oui | Amadou Diop |
| Telephone | Numerique | Oui | 77 123 45 67 |
| Localite | Liste deroulante | Oui | Dakar, Thies, Saint-Louis, Ziguinchor, Kaolack, Tambacounda, Rufisque, Touba |
| Code PIN | 4 chiffres | Oui | **** |
| Confirmer le code PIN | 4 chiffres | Oui | **** |

**Regles de gestion** :
- Le code PIN doit faire exactement 4 chiffres
- La confirmation du PIN doit correspondre au PIN saisi
- Le numero de telephone doit etre unique (un seul compte par numero)
- A la creation, un compte Firebase anonyme est cree automatiquement
- Les donnees utilisateur sont stockees dans la collection Firestore `users`
- Apres inscription reussie, l'utilisateur est connecte automatiquement

---

### 1.2 Connexion (par code PIN uniquement)

**Description** : Ecran de connexion rapide par saisie du code PIN a 4 chiffres.

**Elements d'interface** :
- Logo de l'application
- Message d'accueil "Bon retour !"
- 4 indicateurs circulaires animes pour le PIN
- Clavier numerique personnalise (0-9 + suppression)
- Lien "Code oublie ?" (fonctionnalite prevue)
- Lien vers l'inscription

**Regles de gestion** :
- La validation est automatique des que le 4eme chiffre est saisi
- Recherche dans Firestore d'un utilisateur avec le PIN correspondant
- Retour haptique (vibration) a chaque touche
- Affichage d'un indicateur de chargement pendant la verification
- En cas d'erreur, le PIN est reinitialise

---

### 1.3 Connexion complete (Telephone + PIN)

**Description** : Connexion en deux etapes avec verification du telephone puis du code PIN.

**Etape 1** : Saisie du numero de telephone (format +221 7X XXX XX XX)
**Etape 2** : Saisie du code PIN via clavier personnalise

**Regles de gestion** :
- Etape 1 : Verifie que le champ telephone n'est pas vide
- Etape 2 : Recherche l'utilisateur par telephone, puis verifie le PIN
- Messages d'erreur specifiques :
  - "Aucun compte trouve avec ce numero"
  - "Code PIN incorrect"
- Possibilite de revenir a l'etape 1 ("Changer de numero")

---

### 1.4 Deconnexion

**Description** : Permet a l'utilisateur de se deconnecter de l'application.

**Regles de gestion** :
- Disponible depuis le menu lateral (drawer) et depuis le profil
- Dialogue de confirmation : "Etes-vous sur de vouloir vous deconnecter ?"
- Supprime la session locale et deconnecte Firebase
- Redirige vers l'ecran de connexion

---

### 1.5 Gestion de session

**Description** : Verification automatique de la session au lancement de l'application.

**Regles de gestion** :
- Au demarrage, verifie si un utilisateur Firebase est connecte
- Tente de charger les donnees utilisateur depuis Firestore (timeout 5 secondes)
- Si session valide : acces direct a l'application
- Si session invalide ou timeout : redirection vers l'ecran de connexion

---

## 2. MODULE NAVIGATION

### 2.1 Barre de navigation principale

**Description** : Navigation par onglets en bas de l'ecran.

| Onglet | Icone | Ecran |
|--------|-------|-------|
| Accueil | Maison | Page d'accueil avec resume |
| Mes tontines | Portefeuille | Liste des tontines de l'utilisateur |
| Disponibles | Explorer | Tontines disponibles a rejoindre |
| Profil | Personne | Profil utilisateur |

### 2.2 Menu lateral (Drawer)

**Elements affiches** :
- En-tete : Avatar, nom, telephone, badge "Compte verifie"
- Menu : Profil, Notifications (avec badge du nombre non lues), Preferences
- Bouton de deconnexion

---

## 3. MODULE ACCUEIL (Tableau de bord)

### 3.1 Page d'accueil

**Description** : Vue d'ensemble des activites de l'utilisateur.

**Donnees affichees en temps reel** :
- Salutation personnalisee : "Bonjour, [nom]"
- **Total cotise** : Somme totale de toutes les cotisations de l'utilisateur (en FCFA)
- **Mes tontines** : Nombre de tontines dont l'utilisateur est membre
- **Notifications non lues** : Indicateur visuel (point rouge) sur l'icone cloche
- **Liste des tontines** : Cartes avec nom, montant, nombre de membres, frequence

### 3.2 Actions rapides

| Action | Description | Navigation |
|--------|-------------|-----------|
| Creer tontine | Acces rapide a la creation | Ecran de creation |
| Historique Cotisations | Voir tous les paiements | Ecran historique |
| Explorez | Decouvrir les tontines | Ecran tontines disponibles |
| Mes tours | Voir les prochains tours | Fenetre modale |

### 3.3 Fenetre "Mes tours"

**Informations affichees** :
- **Prochaine cotisation** : Nom de la tontine, frequence, montant a payer
- **Tour a recevoir** : Montant calcule (montant cotisation x nombre de membres)

---

## 4. MODULE GESTION DES TONTINES

### 4.1 Creation d'une tontine

**Description** : Permet a un utilisateur de creer une nouvelle tontine dont il sera l'administrateur.

**Champs du formulaire** :
| Champ | Type | Obligatoire | Valeur par defaut |
|-------|------|-------------|-------------------|
| Nom de la tontine | Texte | Oui | - |
| Categorie | Liste deroulante | Non | Epargne |
| Localite | Liste deroulante | Non | Dakar |
| Montant de cotisation | Numerique (FCFA) | Non | 5000 |
| Frequence | Liste deroulante | Oui | - |
| Nombre max de membres | Numerique | Non | 20 |
| Telephone de versement | Telephone | Oui | - |

**Categories disponibles** : Epargne, Solidarite, Investissement, Famille

**Frequences disponibles** : Hebdomadaire, Mensuel, Bimensuel

**Localites** : Dakar, Thies, Saint-Louis, Ziguinchor, Kaolack

**Regles de gestion** :
- Le createur devient automatiquement l'administrateur
- Le createur est ajoute comme premier membre
- La date de debut est la date de creation
- La tontine est active par defaut
- Timeout de 15 secondes pour la creation (gestion reseau)

---

### 4.2 Detail d'une tontine

**Description** : Vue complete des informations et statistiques d'une tontine.

**Informations affichees** :
- Nom et description de la tontine
- Statut : Badge "Active" ou "Inactive"
- **Progression** : Indicateur circulaire et barre lineaire (cotisations payees / nombre de membres)
- **Grille d'informations** : Date de debut, Frequence, Places (occupees/maximum)
- **Barre de progression des membres** : Visuelle avec places restantes
- **Informations complementaires** : Localite, Administrateur, Montant cotisation
- **Liens** : Suivi des cotisations par tour, Historique des cotisations

**Actions selon le role** :

| Role | Actions disponibles |
|------|-------------------|
| Administrateur | Ajouter membre, Gerer les demandes, Voir les membres, Acceder aux parametres |
| Membre | Voir les membres, Cotiser |
| Non-membre | Rejoindre la tontine (envoyer une demande) |

**Regles de gestion** :
- La demande d'adhesion cree une notification pour l'administrateur
- Si l'utilisateur est deja membre, un message l'informe
- Le bouton "Rejoindre" n'apparait que pour les non-membres

---

### 4.3 Parametres de la tontine (Admin)

**Description** : Modification des parametres de la tontine par l'administrateur.

**Champ modifiable** :
- Telephone de versement

**Regles de gestion** :
- Accessible uniquement par l'administrateur
- Le telephone ne doit pas etre vide

---

### 4.4 Mes tontines

**Description** : Liste de toutes les tontines dont l'utilisateur est membre.

**Statistiques en en-tete** :
- Nombre de tontines actives
- Nombre total de tontines
- Nombre de tontines terminees

**Sections** :
- **Actives** : Tontines en cours
- **Terminees** : Tontines finies

**Informations par carte** :
- Nom, description, statut (badge colore)
- Nombre de membres / maximum
- Frequence, montant (FCFA), localite
- Icone parametres (si admin)

**Donnees en temps reel** : Ecoute Firestore pour mise a jour instantanee

---

### 4.5 Tontines disponibles (Explorer)

**Description** : Permet de decouvrir et rejoindre des tontines publiques.

**Fonctionnalites** :
- **Recherche textuelle** : Par nom, description ou localite (delai de 300ms)
- **Filtres** : "Toutes", "Dakar", "Thies", "Saint-Louis"
- **Barre de progression** : Affiche le remplissage de la tontine

**Regles de gestion** :
- Affiche uniquement les tontines actives ou l'utilisateur n'est PAS membre
- Si la tontine est complete (membres >= max) : badge "Complet", bouton desactive
- Code couleur progression : Rouge si pleine, orange si >= 75%, corail sinon

**Informations par carte** :
- Nom, description, montant (FCFA), frequence
- Localite, date de debut
- Barre de progression des places
- Bouton "Voir les details"

---

## 5. MODULE GESTION DES MEMBRES

### 5.1 Liste des membres

**Description** : Affiche tous les membres d'une tontine.

**Informations par membre** :
- Avatar (couleur generee a partir du nom)
- Nom complet
- Numero de telephone
- Badge "Admin" si administrateur

**Fonctionnalites** :
- **Recherche** : Filtrer par nom ou telephone
- **Fiche membre** (fenetre modale) : Avatar, nom, badge admin, telephone, localite
- **Actions de contact** : Boutons "Appeler" et "Message"

**Actions administrateur** :
- Retirer un membre (avec dialogue de confirmation)
- L'administrateur ne peut pas etre retire
- L'administrateur est toujours affiche en premier dans la liste

---

### 5.2 Ajouter un membre (Admin)

**Description** : Permet a l'administrateur d'inviter des utilisateurs a rejoindre la tontine.

**Fonctionnalites** :
- Recherche d'utilisateurs par nom ou telephone (delai 300ms)
- Affichage : initiales, nom, telephone, localite
- Charge jusqu'a 50 utilisateurs

**Regles de gestion** :
- Verification si l'utilisateur est deja membre avant invitation
- Si deja membre : message d'avertissement orange
- Dialogue de confirmation : "Inviter [nom] a rejoindre la tontine ?"
- Envoi d'une notification de type "invitation" au destinataire

---

### 5.3 Demandes d'adhesion (Admin)

**Description** : Gestion des demandes d'adhesion par l'administrateur.

**Informations par demande** :
- Avatar (initiales), nom, telephone, localite, date de la demande

**Actions** :
| Action | Effet |
|--------|-------|
| Accepter | Ajoute l'utilisateur aux membres + notification "Demande acceptee" |
| Refuser | Met a jour le statut + notification "Demande refusee" |

**Regles de gestion** :
- Affiche uniquement les demandes en attente (statut = 'en_attente')
- Verification de doublon avant acceptation
- Notification envoyee au demandeur dans les deux cas

---

## 6. MODULE COTISATIONS / PAIEMENTS

### 6.1 Paiement d'une cotisation

**Description** : Interface de paiement pour cotiser a une tontine.

**Informations affichees** :
- Montant a payer (FCFA)
- Nom de la tontine
- Periode concernee

**Moyens de paiement disponibles** :
| Moyen | Type |
|-------|------|
| Wave | Paiement mobile |
| Orange Money | Paiement mobile |

**Formulaire** :
- Numero de telephone pour le paiement
- Message informatif : "Vous recevrez une notification pour confirmer le paiement"

**Regles de gestion** :
- Selection d'un seul moyen de paiement (boutons radio)
- Bouton "Payer" lance le traitement
- Confirmation : "Paiement en cours de traitement..."

---

### 6.2 Suivi des cotisations par tour

**Description** : Vue detaillee des cotisations organisees par tour de tontine.

**En-tete** :
- Nombre total de tours
- Frequence de la tontine
- Progression globale (indicateur circulaire avec pourcentage)

**Selecteur de tour** : Liste horizontale defilable ("Tour 1", "Tour 2"... avec label "En cours")

**Contenu par tour** :
- Numero du tour, periode (date debut - date fin), statut
- Barre de progression (payees / total)
- **Section "Ont cotise"** (vert) : Liste des membres ayant paye
- **Section "En attente"** (orange) : Liste des membres n'ayant pas encore paye

**Calcul des tours** :
| Frequence | Duree d'un tour |
|-----------|----------------|
| Hebdomadaire | 7 jours |
| Bimensuel | 15 jours |
| Mensuel | 30 jours |

**Regles de gestion** :
- Les tours sont calcules automatiquement depuis la date de debut
- Les cotisations sont assignees aux tours selon leur date
- Le tour le plus recent est affiche en premier
- Les noms des membres sont resolus par lots depuis Firestore (cache)

---

### 6.3 Historique des cotisations

**Description** : Historique complet de toutes les cotisations de l'utilisateur.

**Resume en en-tete** :
- Total des cotisations (FCFA)
- Nombre de paiements reussis

**Filtres** :
| Filtre | Description |
|--------|------------|
| Tous | Toutes les cotisations |
| Reussis | Statut = 'payee' |
| Echoue | Statut = 'echouee' |

**Informations par cotisation** :
- Icone de statut (coche verte / croix rouge)
- Nom de la tontine
- Nom de l'utilisateur
- Montant (FCFA)
- Badge de statut
- Date et heure
- ID de transaction (8 premiers caracteres)

---

## 7. MODULE NOTIFICATIONS

### 7.1 Centre de notifications

**Description** : Gestion centralisee de toutes les notifications de l'utilisateur.

**Informations affichees** :
- Banniere avec nombre de notifications non lues
- Cartes de notification avec icone et couleur selon le type
- Temps relatif (Xmin, Xh, Xj, Xsem)

**Types de notifications** :
| Type | Icone | Couleur | Declencheur |
|------|-------|---------|-------------|
| Paiement | Coche | Vert | Cotisation enregistree |
| Rappel | Horloge | Orange | Rappel de cotisation |
| Nouveau membre | Personne+ | Violet | Demande d'adhesion recue |
| Invitation | Courrier | Bleu | Invitation a rejoindre une tontine |
| Retard | Erreur | Rouge | Cotisation en retard |

**Actions** :
- **Marquer tout comme lu** : Met a jour toutes les notifications en lot
- **Accepter une invitation** : Ajoute l'utilisateur a la tontine + marque comme acceptee
- **Refuser une invitation** : Marque la notification comme refusee

**Regles de gestion** :
- Les invitations en attente affichent les boutons Accepter/Refuser
- Les invitations traitees affichent un badge "Acceptee" ou "Refusee"
- Compteur de notifications non lues visible dans le drawer et sur l'accueil

---

## 8. MODULE PROFIL UTILISATEUR

### 8.1 Page de profil

**Description** : Affichage et gestion des informations personnelles.

**Informations affichees** :
- Avatar (premiere lettre du nom)
- Nom complet
- Numero de telephone
- Localite

**Sections de parametres** (prevues) :
| Section | Description | Statut |
|---------|-------------|--------|
| Notifications | Gerer les preferences de notification | A implementer |
| Securite | Code PIN et connexion | A implementer |
| Aide & Support | FAQ et contact | A implementer |

**Action** : Bouton de deconnexion

---

## 9. MODELE DE DONNEES

### 9.1 Utilisateur (AppUser)

| Attribut | Type | Description |
|----------|------|-------------|
| uid | String | Identifiant unique Firebase |
| nom | String | Nom complet |
| telephone | String | Numero de telephone |
| localite | String | Ville/Localite |
| pin | String | Code PIN (4 chiffres) |
| createdAt | DateTime | Date de creation du compte |

### 9.2 Tontine

| Attribut | Type | Description |
|----------|------|-------------|
| id | String | Identifiant unique |
| nom | String | Nom de la tontine |
| description | String | Categorie/Description |
| montantCotisation | Entier | Montant par cotisation (FCFA) |
| frequence | String | Hebdomadaire/Mensuel/Bimensuel |
| localite | String | Ville |
| adminUid | String | UID de l'administrateur |
| adminNom | String | Nom de l'administrateur |
| maxMembres | Entier | Nombre maximum de membres |
| membresUids | Liste | UIDs de tous les membres |
| dateDebut | DateTime | Date de debut |
| createdAt | DateTime | Date de creation |
| isActive | Booleen | Statut actif (par defaut: vrai) |
| telephoneVersement | String | Telephone pour les versements |

### 9.3 Cotisation

| Attribut | Type | Description |
|----------|------|-------------|
| id | String | Identifiant unique |
| tontineId | String | Tontine associee |
| tontineNom | String | Nom de la tontine |
| userUid | String | UID du payeur |
| userNom | String | Nom du payeur |
| montant | Entier | Montant paye (FCFA) |
| date | DateTime | Date du paiement |
| statut | String | payee / en_attente / en_retard |

### 9.4 Notification

| Attribut | Type | Description |
|----------|------|-------------|
| id | String | Identifiant unique |
| userUid | String | UID du destinataire |
| title | String | Titre |
| description | String | Contenu |
| tontineNom | String | Tontine concernee |
| type | String | paiement/rappel/nouveau_membre/invitation/retard |
| isRead | Booleen | Statut de lecture |
| date | DateTime | Date de creation |
| tontineId | String | ID tontine (pour invitations) |
| statut | String | vide/acceptee/refusee |

### 9.5 Demande d'adhesion

| Attribut | Type | Description |
|----------|------|-------------|
| id | String | Identifiant unique |
| tontineId | String | Tontine cible |
| userUid | String | UID du demandeur |
| userNom | String | Nom du demandeur |
| userTelephone | String | Telephone du demandeur |
| userLocalite | String | Localite du demandeur |
| date | DateTime | Date de la demande |
| statut | String | en_attente/acceptee/refusee |

---

## 10. ARCHITECTURE TECHNIQUE

### 10.1 Services

| Service | Responsabilite |
|---------|---------------|
| AuthService | Inscription, connexion, deconnexion, recherche utilisateur |
| SessionService | Gestion de la session locale (singleton) |
| TontineService | CRUD tontines, membres, cotisations, demandes, invitations, notifications |

### 10.2 Collections Firestore

| Collection | Contenu |
|-----------|---------|
| users | Profils utilisateurs |
| tontines | Groupes de tontine |
| cotisations | Enregistrements de paiements |
| demandes | Demandes d'adhesion |
| notifications | Notifications utilisateur |

### 10.3 Technologies utilisees

| Technologie | Usage |
|-------------|-------|
| Flutter | Framework de developpement mobile |
| Dart | Langage de programmation |
| Firebase Auth | Authentification (anonyme) |
| Cloud Firestore | Base de donnees NoSQL temps reel |
| Material Design | Composants d'interface |

---

## 11. FLUX METIER PRINCIPAUX

### 11.1 Flux : Rejoindre une tontine

```
Utilisateur consulte les tontines disponibles
    |
    v
Clique sur "Voir les details"
    |
    v
Clique sur "REJOINDRE"
    |
    v
Demande d'adhesion creee (statut: en_attente)
    |
    v
Notification envoyee a l'administrateur
    |
    v
L'administrateur voit la demande dans "Demandes d'adhesion"
    |
    +---> Accepter : Utilisateur ajoute aux membres + notification envoyee
    |
    +---> Refuser : Statut mis a jour + notification envoyee
```

### 11.2 Flux : Inviter un membre (administrateur)

```
Administrateur va dans "Ajouter membre"
    |
    v
Recherche un utilisateur par nom ou telephone
    |
    v
Clique sur "Inviter"
    |
    v
Notification d'invitation envoyee a l'utilisateur cible
    |
    v
L'utilisateur voit l'invitation dans ses notifications
    |
    +---> Accepter : Ajoute aux membres de la tontine
    |
    +---> Refuser : Notification marquee comme refusee
```

### 11.3 Flux : Cotiser a une tontine

```
Membre accede au detail de la tontine
    |
    v
Clique sur "COTISER"
    |
    v
Choisit le moyen de paiement (Wave ou Orange Money)
    |
    v
Saisit le numero de telephone
    |
    v
Clique sur "Payer"
    |
    v
Paiement en cours de traitement
```

### 11.4 Flux : Creer une tontine

```
Utilisateur clique sur "Creer tontine"
    |
    v
Remplit le formulaire (nom, categorie, montant, frequence, etc.)
    |
    v
Clique sur "Creer la tontine"
    |
    v
Tontine creee dans Firestore
    |
    v
Utilisateur = administrateur + premier membre
    |
    v
Retour a l'ecran precedent
```

---

## 12. FONCTIONNALITES PREVUES (Non encore implementees)

| Fonctionnalite | Statut |
|---------------|--------|
| Recuperation de code PIN oublie | Prevue |
| Preferences de notifications | Prevue |
| Modification du code PIN | Prevue |
| Aide et support (FAQ) | Prevue |
| Integration complete du paiement mobile (Wave/OM) | Partielle |

---

## 13. RESUME DES FONCTIONNALITES PAR ROLE

### Utilisateur standard (Membre)

- Creer un compte / Se connecter / Se deconnecter
- Voir son tableau de bord (accueil)
- Creer une tontine
- Rejoindre une tontine existante
- Consulter les tontines disponibles
- Cotiser a une tontine
- Voir l'historique de ses cotisations
- Voir le suivi des cotisations par tour
- Recevoir et gerer les notifications
- Accepter / Refuser les invitations
- Consulter son profil
- Rechercher des tontines

### Administrateur (Createur de la tontine)

Toutes les fonctionnalites du membre, plus :
- Gerer les parametres de la tontine
- Ajouter des membres par invitation
- Accepter / Refuser les demandes d'adhesion
- Retirer un membre de la tontine
- Voir la liste des demandes en attente

---

*Document genere le 06/08/2026 - TontineManager Mobile*
