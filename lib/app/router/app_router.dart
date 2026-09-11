import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/pages/manage_members_page.dart';
import 'package:taskflow/features/projects/presentation/pages/project_details_page.dart';
import 'package:taskflow/features/projects/presentation/pages/project_form_page.dart';
import 'package:taskflow/features/projects/presentation/pages/projects_page.dart';

final appRouter = GoRouter(
  initialLocation: '/projects',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/projects',
    ),
    GoRoute(
      path: '/projects',
      name: 'projects',
      builder: (context, state) => const ProjectsPage(),
      routes: [
        GoRoute(
          path: 'create',
          name: 'create-project',
          builder: (context, state) => const ProjectFormPage(),
        ),
        GoRoute(
          path: ':projectId',
          name: 'project-details',
          builder: (context, state) {
            final projectId = state.pathParameters['projectId']!;
            final project = state.extra as Project?;
            return ProjectDetailsPage(
              projectId: projectId,
              initialProject: project,
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: 'edit-project',
              builder: (context, state) {
                final project = state.extra as Project?;
                return ProjectFormPage(initialProject: project);
              },
            ),
            GoRoute(
              path: 'members',
              name: 'manage-members',
              builder: (context, state) {
                final projectId = state.pathParameters['projectId']!;
                final project = state.extra as Project?;
                return ManageMembersPage(
                  projectId: projectId,
                  initialProject: project,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page introuvable : ${state.uri.toString()}'),
    ),
  ),
);
