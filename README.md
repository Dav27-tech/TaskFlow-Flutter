# TaskFlow - Projects Module

TaskFlow est une application mobile collaborative de gestion de projets et de tâches développée avec **Flutter**, **Riverpod**, **Firebase Authentication**, **Cloud Firestore** et structurée selon les principes de la **Clean Architecture** et du **Repository Pattern**.

---

## 🏛️ Architecture du Projet

Le module `projects` respecte scrupuleusement la séparation des responsabilités en trois couches étanches :

```
lib/
├── app/
│   ├── app.dart                    # Racine de l'application (MaterialApp.router + ProviderScope)
│   ├── router/
│   │   └── app_router.dart         # Configuration des routes GoRouter
│   └── theme/
│       └── app_theme.dart          # Thème moderne TaskFlow (Light/Dark, palette violette)
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Tokens de couleur (Primary #6C5CE7, Accents, Badges)
│   │   └── app_constants.dart      # Noms de collections Firestore, statuts, rôles
│   ├── errors/
│   │   ├── exceptions.dart         # Exceptions personnalisées (Server, Auth, Permission, etc.)
│   │   └── failures.dart           # Objets Failure pour la couche Domain
│   ├── services/
│   │   └── share_service.dart      # Écriture temporaire et partage de fichiers JSON
│   ├── utils/
│   │   └── invitation_code_generator.dart # Générateur de codes TFMA-XXXX-XXXX
│   └── widgets/
│       ├── custom_button.dart      # Bouton stylé réutilisable
│       ├── custom_text_field.dart  # Champ de saisie personnalisé avec validation
│       ├── loading_indicator.dart  # Indicateur de chargement centré
│       ├── error_view.dart         # Vue d'erreur avec bouton de retry
│       └── confirm_dialog.dart     # Dialogue modal de confirmation d'action
│
└── features/
    ├── tasks/                      # Entités et modèles de tâches (support export & métriques)
    │   ├── data/models/task_model.dart
    │   └── domain/entities/task.dart
    │
    └── projects/
        ├── data/
        │   ├── datasources/
        │   │   └── project_remote_datasource.dart # Firestore CRUD + WriteBatch atomique
        │   ├── models/
        │   │   ├── project_model.dart             # Mappage Firestore & JSON
        │   │   └── project_member_model.dart      # Mappage sous-collection members
        │   └── repositories/
        │       └── project_repository_impl.dart   # Implémentation du contrat Repository
        │
        ├── domain/
        │   ├── entities/
        │   │   ├── project.dart                   # Entité Projet métier & progression
        │   │   └── project_member.dart            # Entité Membre de projet & rôles
        │   ├── repositories/
        │   │   └── project_repository.dart        # Contrat d'interface du Repository
        │   └── usecases/
        │       ├── get_projects.dart              # Flux des projets de l'utilisateur
        │       ├── get_project.dart               # Détails d'un projet
        │       ├── create_project.dart            # Création atomique avec Owner automatique
        │       ├── update_project.dart            # Modification (Owner uniquement)
        │       ├── delete_project.dart            # Suppression (Owner uniquement)
        │       ├── get_project_members.dart       # Flux des membres du projet
        │       ├── remove_member.dart             # Suppression d'un membre par l'Owner
        │       ├── leave_project.dart             # Quitter le projet (Member uniquement)
        │       ├── regenerate_invitation_code.dart# Régénération du code (Owner uniquement)
        │       └── export_project_json.dart       # Exportation et partage JSON 2 espaces
        │
        └── presentation/
            ├── pages/
            │   ├── projects_page.dart             # Liste des projets + empty state + FAB
            │   ├── project_details_page.dart      # Résumé, métriques, onglets Tasks & Members
            │   ├── project_form_page.dart         # Formulaire de création / édition
            │   └── manage_members_page.dart       # Gestion du code d'invitation et des membres
            ├── providers/
            │   └── project_provider.dart          # Riverpod providers et ActionController
            └── widgets/
                ├── project_card.dart              # Carte de projet avec badge rôle & barre
                ├── project_summary.dart           # En-tête des détails avec KPIs
                ├── project_menu.dart              # Menu contextuel filtré par permissions
                └── member_tile.dart               # Tuile de membre avec avatar & options
```

---

## 🔒 Modèle de Données Firestore

### Collection Principale : `projects/{projectId}`
```json
{
  "name": "Refonte Application Mobile",
  "description": "Développement de la v2 sous Flutter",
  "ownerId": "usr_owner_abc123",
  "invitationCode": "TFMA-7X3K-QP2L",
  "status": "active",
  "memberIds": ["usr_owner_abc123", "usr_member_def456"],
  "createdAt": "2026-09-08T20:00:00.000Z",
  "updatedAt": "2026-09-08T20:00:00.000Z"
}
```

### Sous-Collection : `projects/{projectId}/members/{userId}`
```json
{
  "userId": "usr_owner_abc123",
  "role": "owner",
  "joinedAt": "2026-09-08T20:00:00.000Z",
  "displayName": "Alice Dupont",
  "email": "alice@taskflow.dev"
}
```

### Atomicité de la Création (`WriteBatch`)
Lorsqu'un utilisateur crée un projet :
1. L'identifiant `currentUser.uid` est automatiquement affecté à `ownerId`.
2. Le document `projects/{projectId}` et le document `projects/{projectId}/members/{currentUser.uid}` avec `role: "owner"` sont rédigés et validés **de façon atomique** au sein d'une seule transaction `WriteBatch`.
3. Le rôle OWNER ne peut jamais être sélectionné manuellement dans l'interface.

---

## 🛡️ Matrice des Permissions (Owner vs Member)

| Fonctionnalité | OWNER | MEMBER |
| :--- | :---: | :---: |
| Voir la liste des projets | ✅ | ✅ |
| Consulter les détails du projet | ✅ | ✅ |
| Voir les tâches et membres | ✅ | ✅ |
| Modifier le projet (Nom, Description, Statut) | ✅ | ❌ |
| Supprimer le projet | ✅ | ❌ |
| Afficher & Copier le code d'invitation | ✅ | ✅ |
| Régénérer le code d'invitation | ✅ | ❌ |
| Supprimer un membre | ✅ | ❌ |
| Quitter le projet (*Leave Project*) | ❌ *(Suppression projet requise)* | ✅ |
| Exporter les tâches au format JSON | ✅ | ✅ |

---

## 📦 Format d'Export JSON des Tâches

L'export génère un fichier `project_tasks.json` formaté avec **2 espaces d'indentation** :

```json
{
  "project": {
    "id": "proj_123",
    "name": "TaskFlow Mobile",
    "description": "Application collaborative",
    "ownerId": "usr_owner_abc123"
  },
  "exportedAt": "2026-09-08T20:15:30.000Z",
  "tasks": [
    {
      "id": "task_01",
      "title": "Implémentation Clean Architecture",
      "description": "Couches domain, data et presentation",
      "status": "completed",
      "priority": "high",
      "dueDate": "2026-09-15T00:00:00.000Z",
      "assignedTo": "usr_owner_abc123"
    }
  ]
}
```

Le fichier est écrit dans le dossier temporaire de l'appareil via `path_provider` et partagé via la boîte de dialogue système native avec `share_plus`.

---

## 🛡️ Firestore Security Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isProjectMember(projectId) {
      return isAuthenticated() && (
        exists(/databases/$(database)/documents/projects/$(projectId)/members/$(request.auth.uid)) ||
        (resource.data.memberIds != null && request.auth.uid in resource.data.memberIds)
      );
    }

    function isProjectOwner(projectId) {
      return isAuthenticated() && (
        get(/databases/$(database)/documents/projects/$(projectId)).data.ownerId == request.auth.uid ||
        resource.data.ownerId == request.auth.uid
      );
    }

    match /projects/{projectId} {
      allow create: if isAuthenticated() && request.resource.data.ownerId == request.auth.uid;
      allow read: if isAuthenticated() && (isProjectMember(projectId) || resource.data.ownerId == request.auth.uid);
      allow update, delete: if isAuthenticated() && isProjectOwner(projectId);

      match /members/{userId} {
        allow read: if isAuthenticated() && (isProjectMember(projectId) || isProjectOwner(projectId));
        allow create: if isAuthenticated() && (isProjectOwner(projectId) || request.auth.uid == userId);
        allow update: if isAuthenticated() && isProjectOwner(projectId);
        allow delete: if isAuthenticated() && (isProjectOwner(projectId) || request.auth.uid == userId);
      }

      match /tasks/{taskId} {
        allow read, create, update: if isAuthenticated() && isProjectMember(projectId);
        allow delete: if isAuthenticated() && (isProjectOwner(projectId) || isProjectMember(projectId));
      }
    }

    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 Tests Automatisés

Le projet contient une suite complète de tests unitaires et widgets :

### Tests Unitaires (10+)
1. `invitation_code_generator_test.dart` : Génération au format `TFMA-XXXX-XXXX`, entropie et validation regex.
2. `project_model_test.dart` : Mappage `fromFirestore` et calcul de progression.
3. `project_model_test.dart` : Sérialisation `toFirestore`.
4. `create_project_test.dart` : Exécution du cas d'utilisation de création.
5. `owner_rule_test.dart` : Vérification `ownerId == currentUserId`.
6. `owner_rule_test.dart` : Rôle initial `role == 'owner'`.
7. `get_projects_test.dart` : Récupération du flux de projets filtré par utilisateur.
8. `remove_member_test.dart` : Suppression d'un membre par l'Owner et interdictions.
9. `leave_project_test.dart` : Départ d'un membre et blocage pour l'Owner.
10. `regenerate_invitation_code_test.dart` : Régénération du code réservée à l'Owner.
11. `export_project_json_test.dart` : Génération du JSON 2 espaces avec projet et tâches.
12. `project_remote_datasource_test.dart` : Transaction atomique `WriteBatch` dans Firestore.

### Tests Widget (5+)
1. `projects_page_test.dart` : Rendu de la liste des projets avec `ProjectCard` et Empty State.
2. `project_details_page_test.dart` : Rendu des détails, des indicateurs de progression et des onglets.
3. `project_permissions_widget_test.dart` : Présence des options *Edit*, *Manage Members*, *Delete* pour l'Owner.
4. `project_permissions_widget_test.dart` : Absence des options d'administration pour un Member.
5. `project_permissions_widget_test.dart` : Présence du bouton *Leave Project* pour un Member et absence pour l'Owner.

---

## 🚀 Commandes Flutter

```powershell
# 1. Récupération des dépendances
flutter pub get

# 2. Analyse statique du code (Lint)
flutter analyze

# 3. Exécution de tous les tests
flutter test

# 4. Lancement de l'application
flutter run
```

---

## 🌿 Procédure Git (Branche & Pull Request)

```powershell
# 1. Créer et basculer sur la branche feature/projects
git checkout -b feature/projects

# 2. Ajouter tous les fichiers modifiés et créés
git add .

# 3. Créer un commit sémantique
git commit -m "feat(projects): complete projects module implementation with clean architecture and riverpod"

# 4. Pousser la branche vers le dépôt distant
git push -u origin feature/projects

# 5. Créer la Pull Request vers la branche principale (main ou develop)
# Titre: [Feature] Module Projects complet (Clean Architecture, Riverpod, Firebase)
# Description: Implémentation complète du module Projects, gestion des membres, invitation codes, permissions Owner/Member, export JSON et tests unitaires/widgets.
```
