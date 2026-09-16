# TaskFlow

> Application mobile collaborative de gestion de projets et de tâches, développée avec Flutter, Dart et Firebase.

TaskFlow permet aux utilisateurs de créer des projets, collaborer avec des membres, gérer des tâches, suivre leur progression et recevoir des notifications liées à leur activité.

---

## ✨ Fonctionnalités

### Authentification

- Inscription avec e-mail et mot de passe
- Connexion
- Déconnexion
- Vérification de l'utilisateur connecté
- Protection des écrans privés

### Projets

- Création d'un projet
- Modification d'un projet par son propriétaire
- Suppression d'un projet par son propriétaire
- Consultation des projets de l'utilisateur
- Ajout et retrait de membres
- Gestion des permissions

### Tâches

- Création, modification et suppression
- Attribution à un membre du projet
- Priorité : basse, moyenne, haute
- Statut : À faire, En cours, Terminé
- Date d'échéance
- Recherche et filtrage

### Dashboard

- Résumé des tâches
- Progression
- Tâches urgentes
- Tâches récentes
- Projets récents
- Accès rapide
- Notifications

### Notifications

- Tâche attribuée
- Tâche modifiée
- Tâche terminée
- Membre ajouté à un projet
- Membre retiré d'un projet

### Profil

- Consultation des informations du compte
- Déconnexion

### Export

- Export des tâches au format JSON local

---

# 🏗️ Architecture du projet

TaskFlow suit une **Clean Architecture organisée par fonctionnalités**. Chaque feature regroupe son accès aux données, ses règles métier et sa présentation, tandis que `app/` et `core/` contiennent les éléments transverses.

## Principe général

```text
┌──────────────────────────────────────────────┐
│                PRESENTATION                  │
│ Pages • Widgets • Riverpod Providers        │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                   DOMAIN                     │
│ Entities • Repositories • Use Cases         │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                    DATA                      │
│ Models • Data Sources • Repository Impl.    │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│              SERVICES EXTERNES              │
│ Firebase Auth • Cloud Firestore • Share     │
└──────────────────────────────────────────────┘
```

## Flux des données

```text
Page / Widget
 ↓
Riverpod Provider ou Notifier
 ↓
Use Case (si nécessaire)
 ↓
Repository
 ↓
Data Source
 ↓
Firebase Auth / Cloud Firestore / Service partagé
```

Les features `dashboard` et `profile` utilisent principalement des providers pour leurs lectures. Les features `auth`, `projects`, `tasks` et `notifications` suivent le découpage data/domain/presentation. La couche `domain` ne dépend pas de Flutter, Firebase ou Riverpod.

---

# 📂 Structure du projet

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── app_shell.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── services/
│   ├── utils/
│   └── widgets/
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── pages/
    │       ├── providers/
    │       └── widgets/
    │
    ├── dashboard/
    │   └── presentation/
      │       └── pages/
    │
    ├── tasks/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── pages/
    │       ├── providers/
    │       └── widgets/
    │
    ├── projects/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── pages/
    │       ├── providers/
    │       └── widgets/
    │
    ├── notifications/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
      │   │   └── entities/
    │   └── presentation/
    │       ├── pages/
      │       └── providers/
    │
    ├── profile/
    │   └── presentation/
    │       ├── pages/
      │       └── providers/
```

---

# 📁 Rôle des dossiers

## `app/`

Contient la configuration générale de l'application.

### `app.dart`

Configure `MaterialApp.router`, le thème, la localisation et le système de navigation.

### `router/`

Contient la configuration de GoRouter, les routes publiques et les routes protégées.

---

## `core/`

Contient les éléments réellement partagés entre plusieurs fonctionnalités.

### `constants/`

Constantes globales, noms de collections Firestore et autres valeurs communes.

### `errors/`

Exceptions, erreurs Firebase, erreurs réseau et erreurs de validation.

### `services/`

Services techniques partagés comme le partage de fichiers et l'export JSON.

### `utils/`

Helpers, formatage, validation et fonctions utilitaires.

### `widgets/`

Widgets génériques réellement réutilisés dans plusieurs fonctionnalités.

---

## `features/`

Chaque fonctionnalité possède ses propres couches `data`, `domain` et `presentation`.

### `data/`

Responsable de l'accès aux données.

Contient :

- Models
- Data Sources
- Repository Implementations

### `domain/`

Contient les règles métier.

Contient :

- Entities
- Repository Interfaces
- Use Cases

### `presentation/`

Contient l'interface utilisateur.

Contient :

- Pages
- Widgets
- Providers
- Notifiers

### Dépendances entre features

Les providers peuvent composer plusieurs features lorsque le dashboard ou les formulaires ont besoin de données croisées. Par exemple, le dashboard combine les projets et les tâches, et le formulaire de tâche lit les membres du projet avant d'autoriser une attribution. Les accès Firebase restent encapsulés dans les data sources.

---

# 🔥 Technologies utilisées

| Technologie             | Utilisation                        |
| ----------------------- | ---------------------------------- |
| Flutter                 | Interface mobile                   |
| Dart                    | Langage                            |
| Firebase Authentication | Authentification                   |
| Cloud Firestore         | Base de données et synchronisation |
| Riverpod                | Gestion d'état                     |
| GoRouter                | Navigation                         |
| Clean Architecture      | Organisation du code               |
| JSON                    | Export local                       |

---

# 🗃️ Modèle de données Firestore

Les principales collections sont :

```text
users
projects
tasks
notifications
```

## `users`

```text
users/{userId}
```

Champs principaux :

```text
id
name
email
createdAt
```

## `projects`

```text
projects/{projectId}
```

Champs principaux :

```text
id
name
description
ownerId
memberIds
createdAt
updatedAt
```

Le créateur est automatiquement ajouté dans `memberIds` et devient `ownerId`.

## `tasks`

```text
tasks/{taskId}
```

Champs principaux :

```text
id
projectId
title
description
createdBy
assignedTo
status
priority
dueDate
createdAt
updatedAt
```

### Statuts

```text
todo
inProgress
done
```

### Priorités

```text
low
medium
high
```

## `notifications`

```text
notifications/{notificationId}
```

Champs principaux :

```text
id
userId
title
message
type
projectId
taskId
isRead
createdAt
```

Types :

```text
task_assigned
task_updated
task_completed
project_member_added
project_member_removed
```

---

# 👥 Rôles et permissions

TaskFlow utilise deux rôles.

## Owner

Le propriétaire du projet peut :

- modifier le projet ;
- supprimer le projet ;
- ajouter des membres ;
- retirer des membres ;
- gérer les permissions du projet.

## Member

Un membre peut :

- consulter les projets auxquels il appartient ;
- consulter les tâches autorisées ;
- créer des tâches selon les permissions définies ;
- modifier les tâches auxquelles il a accès ;
- modifier les statuts ;
- recevoir des notifications.

Un même utilisateur peut être Owner d'un projet et Member d'un autre.

---

# 🚀 Installation

## Prérequis

Installer :

- Flutter SDK
- Dart SDK
- Android Studio ou Visual Studio Code
- Git
- un appareil Android ou un émulateur
- un projet Firebase

Vérifier Flutter :

```bash
flutter doctor
```

## Cloner le projet

```bash
git clone <URL_DU_DEPOT>
cd task_flow
```

## Installer les dépendances

```bash
flutter pub get
```

---

# 🔥 Configuration de Firebase

## 1. Créer le projet Firebase

Créer un projet dans Firebase Console.

Activer :

- Authentication
- Cloud Firestore

## 2. Activer l'authentification

Dans Firebase :

```text
Authentication
→ Sign-in method
→ Email/Password
→ Enable
```

## 3. Créer Firestore

Dans :

```text
Firestore Database
→ Create database
```

## 4. Configurer FlutterFire

Installer FlutterFire CLI :

```bash
dart pub global activate flutterfire_cli
```

Puis :

```bash
flutterfire configure
```

Cette commande configure notamment :

```text
lib/firebase_options.dart
```

---

# ▶️ Lancer l'application

Afficher les appareils disponibles :

```bash
flutter devices
```

Lancer l'application :

```bash
flutter run
```

Ou sur un appareil précis :

```bash
flutter run -d <device_id>
```

---

# 📖 Comment utiliser l'application

## 1. Créer un compte

Au premier lancement :

1. Ouvrir TaskFlow.
2. Choisir **Créer un compte**.
3. Entrer le nom.
4. Entrer l'adresse e-mail.
5. Entrer le mot de passe.
6. Valider l'inscription.

Le compte est créé dans Firebase Authentication et le profil est enregistré dans Firestore.

## 2. Se connecter

1. Entrer l'adresse e-mail.
2. Entrer le mot de passe.
3. Appuyer sur **Se connecter**.

Après connexion, l'utilisateur arrive sur le Dashboard.

## 3. Utiliser le Dashboard

Le Dashboard permet de consulter rapidement :

- les statistiques des tâches ;
- les tâches urgentes ;
- les tâches récentes ;
- les projets récents ;
- la progression ;
- les notifications.

## 4. Créer un projet

1. Ouvrir **Projets**.
2. Appuyer sur le bouton de création.
3. Entrer le nom.
4. Entrer la description.
5. Valider.

Le créateur devient automatiquement Owner.

## 5. Ajouter des membres

Depuis le projet :

1. Ouvrir les détails du projet.
2. Accéder à la gestion des membres.
3. Sélectionner un utilisateur.
4. Ajouter le membre.

## 6. Créer une tâche

1. Ouvrir **Tâches**.
2. Appuyer sur **Ajouter**.
3. Choisir le projet.
4. Entrer le titre.
5. Ajouter une description.
6. Choisir la priorité.
7. Définir éventuellement une date d'échéance.
8. Assigner un membre si nécessaire.
9. Enregistrer.

## 7. Modifier une tâche

Ouvrir une tâche pour modifier :

- le titre ;
- la description ;
- le statut ;
- la priorité ;
- la date d'échéance ;
- l'utilisateur assigné.

## 8. Utiliser le Kanban

Les tâches sont organisées dans :

```text
À faire → En cours → Terminé
```

Le Kanban permet de suivre visuellement la progression.

## 9. Rechercher et filtrer les tâches

Les tâches peuvent être filtrées par :

- projet ;
- statut ;
- priorité ;
- utilisateur assigné ;
- recherche textuelle.

## 10. Consulter les notifications

L'icône de notification dans l'en-tête ouvre la page des notifications.

L'utilisateur peut consulter ses notifications et marquer les éléments comme lus.

## 11. Consulter le profil

Depuis **Profil**, l'utilisateur peut consulter les informations de son compte et se déconnecter.

## 12. Exporter les tâches

La fonctionnalité d'export génère un fichier JSON contenant les tâches sélectionnées.

---

# 🧭 Navigation principale

TaskFlow utilise quatre sections principales :

```text
Accueil
Tâches
Projets
Profil
```

Une icône dédiée aux notifications est disponible dans l'en-tête.

Les écrans d'authentification sont séparés des écrans protégés de l'application.

---

# 🔔 Système de notifications

Le principe est :

```text
Événement
   ↓
Création de la notification
   ↓
Firestore
   ↓
Synchronisation
   ↓
Affichage à l'utilisateur
```

Les notifications concernent notamment :

- l'assignation d'une tâche ;
- la modification d'une tâche ;
- la fin d'une tâche ;
- l'ajout d'un membre ;
- le retrait d'un membre.

Les notifications internes utilisent Firestore. Les notifications push mobiles peuvent être ajoutées ultérieurement avec Firebase Cloud Messaging.

---

# 📤 Export JSON

L'export sert à obtenir une copie locale des tâches.

Exemple :

```json
[
  {
    "id": "task_001",
    "title": "Préparer la présentation",
    "description": "Finaliser les diapositives",
    "status": "inProgress",
    "priority": "high"
  }
]
```

L'export local ne remplace pas Firestore.

---

# ⚠️ Gestion des erreurs

L'application doit gérer notamment :

- les erreurs de connexion ;
- les erreurs d'authentification ;
- les permissions insuffisantes ;
- les documents inexistants ;
- les erreurs Firestore ;
- les erreurs de validation ;
- les erreurs d'export.

Les erreurs techniques doivent être transformées en messages compréhensibles pour l'utilisateur.

Exemple :

```text
Une erreur est survenue. Veuillez réessayer.
```

---

# 🔐 Sécurité Firebase

Les règles Firestore doivent respecter les permissions de l'application.

Principes :

- un utilisateur doit être authentifié pour accéder aux données protégées ;
- un utilisateur ne peut consulter que les projets auxquels il appartient ;
- seul le Owner peut administrer son projet ;
- les tâches sont accessibles aux membres autorisés ;
- les notifications sont accessibles à leur destinataire ;
- les données utilisateur sont protégées.

Les règles Firestore doivent être testées avant la mise en production.

---

# 🧪 Tests

## Tests unitaires

Tester :

- Entities ;
- Use Cases ;
- validation ;
- Models ;
- Repositories.

## Tests de widgets

Tester :

- Login ;
- Register ;
- Dashboard ;
- Tâches ;
- Navigation ;
- états loading/error/empty.

## Tests d'intégration

Scénario principal :

```text
Créer un compte
      ↓
Se connecter
      ↓
Créer un projet
      ↓
Ajouter un membre
      ↓
Créer une tâche
      ↓
Assigner la tâche
      ↓
Modifier son statut
      ↓
Consulter la notification
      ↓
Exporter les tâches
```

---

# 📏 Bonnes pratiques

- Respecter la Clean Architecture.
- Garder la logique métier dans les Use Cases.
- Ne pas appeler Firebase directement depuis les widgets.
- Utiliser Riverpod pour la gestion d'état.
- Garder les Providers dans leurs fonctionnalités respectives.
- Gérer les états `loading`, `data`, `error` et `empty`.
- Éviter les widgets globaux inutiles.
- Garder une nomenclature cohérente.
- Tester les fonctionnalités importantes.
- Éviter de modifier l'architecture sans nécessité.

---

# 🚧 Évolutions possibles

Plusieurs fonctionnalités pourront être ajoutées dans une version future :

- notifications push avec FCM ;
- commentaires sur les tâches ;
- discussion d'équipe ;
- historique des modifications ;
- pièces jointes ;
- statistiques avancées ;
- calendrier ;
- amélioration du mode hors ligne ;
- intégration de services externes ;
- assistant intelligent pour les tâches.

---

# 👨‍💻 Projet

**TaskFlow — Gestionnaire de tâches collaboratif**

Projet réalisé dans le cadre du groupe :

**Systèmes de Gestion & Productivité**

---
