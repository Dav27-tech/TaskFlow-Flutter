# Correction de l'accès aux détails du projet et Diagnostic Firestore

Ce plan vise à résoudre le blocage lors de l'ouverture d'un projet et à améliorer la visibilité sur les erreurs de permissions Firestore.

## User Review Required

> [!IMPORTANT]
> **Règles Firestore** : Assurez-vous d'avoir publié les règles imbriquées (avec les sous-collections `members` et `tasks`) dans votre console Firebase. Sans cela, les détails du projet ne pourront pas charger les statistiques des tâches et des membres.

## Proposed Changes

### [Navigation & Performance]

#### [MODIFY] [app_router.dart](file:///C:/Users/LENOVO/StudioProjects/task_flow/lib/app/router/app_router.dart)
- Mettre à jour la route `/projects/:id` pour passer l'objet `Project` (s'il existe dans `state.extra`) à la page `ProjectDetailsPage`.
- Cela permet d'afficher les informations instantanément pendant que les données fraîches sont récupérées en arrière-plan.

### [Diagnostic & Robustesse]

#### [MODIFY] [project_remote_datasource.dart](file:///C:/Users/LENOVO/StudioProjects/task_flow/lib/features/projects/data/datasources/project_remote_datasource.dart)
- Ajouter des blocs try-catch individuels dans `getProject` pour identifier si c'est la lecture des Tâches ou des Membres qui échoue à cause des permissions.
- Ajouter des logs explicites (`print`) pour le débogage en mode développement.

## Verification Plan

### Manual Verification
- Cliquer sur un projet dans la liste.
- Vérifier que la transition est fluide (utilisation du `initialProject`).
- Si une erreur survient, vérifier les logs de la console (Stdout) pour voir quel composant Firestore a échoué.
