import 'package:flutter/material.dart';
import '../domain/dashboard_models.dart';

class DashboardMockData {
  static const todo = 12;
  static const inProgress = 5;
  static const completed = 18;

  static const focusTasks = <FocusTask>[
    FocusTask(
      name: 'Mise à jour du design system',
      project: 'Refonte du site',
      projectColor: Color(0xFF6C5CE7),
      priority: Priority.high,
      due: "Aujourd'hui",
      urgent: true,
    ),
    FocusTask(
      name: 'Intégration API paiement',
      project: 'Application mobile',
      projectColor: Color(0xFF16B981),
      priority: Priority.medium,
      due: 'Demain',
    ),
    FocusTask(
      name: 'Revue du parcours utilisateur',
      project: 'Refonte du site',
      projectColor: Color(0xFF6C5CE7),
      priority: Priority.high,
      due: 'Dans 2 jours',
    ),
  ];

  static const projects = <ProjectItem>[
    ProjectItem(
      name: 'Refonte du site',
      gradient: [Color(0xFF6C5CE7), Color(0xFF009FC2)],
      progress: .75,
      tasks: 12,
      members: 4,
    ),
    ProjectItem(
      name: 'Application mobile',
      gradient: [Color(0xFF16B981), Color(0xFF009FC2)],
      progress: .60,
      tasks: 8,
      members: 3,
    ),
    ProjectItem(
      name: 'Site vitrine',
      gradient: [Color(0xFFEF476F), Color(0xFFFF8F6C)],
      progress: .40,
      tasks: 6,
      members: 2,
    ),
  ];

  static const importantTasks = <ImportantTask>[
    ImportantTask(
      name: 'Préparer la présentation projet',
      project: 'Site vitrine',
      projectColor: Color(0xFFEF476F),
      priority: Priority.high,
      due: "Aujourd'hui",
    ),
    ImportantTask(
      name: 'Corriger les bugs critiques',
      project: 'Application mobile',
      projectColor: Color(0xFF16B981),
      priority: Priority.medium,
      due: 'Demain',
    ),
    ImportantTask(
      name: 'Relecture et validation du contenu',
      project: 'Refonte du site',
      projectColor: Color(0xFF6C5CE7),
      priority: Priority.low,
      due: 'Dans 3 jours',
    ),
  ];
}
