import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/taskflow_bottom_navigation.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/pages/task_details_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/projects/presentation/pages/project_form_page.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/projects/presentation/pages/manage_members_page.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    // ============================================================
    // AUTHENTIFICATION
    // ============================================================
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: '/projects/create',
      builder: (context, state) => const ProjectFormPage(),
    ),

    GoRoute(
      path: '/tasks/create',
      builder: (context, state) => TaskFormPage(
        initialProjectId: state.uri.queryParameters['projectId'],
      ),
    ),

    GoRoute(
      path: '/tasks/:projectId/:taskId/edit',
      builder: (context, state) => TaskFormPage(
        initialProjectId: state.pathParameters['projectId'],
        initialTask: state.extra as Task?,
      ),
    ),

    GoRoute(
      path: '/projects/:id/edit',
      builder: (context, state) =>
          ProjectFormPage(initialProject: state.extra as Project?),
    ),

    GoRoute(
      path: '/projects/:id/members',
      builder: (context, state) => ManageMembersPage(
        projectId: state.pathParameters['id']!,
        initialProject: state.extra as Project?,
      ),
    ),

    GoRoute(
      path: '/projects/:id',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        final project = state.extra as Project?;

        return ProjectDetailsPage(
          projectId: projectId,
          initialProject: project,
        );
      },
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),

    // ============================================================
    // APPLICATION PRINCIPALE
    // ============================================================
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },

      branches: [
        // ========================================================
        // ACCUEIL / DASHBOARD
        // ========================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),

        // ========================================================
        // TÂCHES
        // ========================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksPage(),
              routes: [
                GoRoute(
                  path: ':projectId/:taskId',
                  builder: (context, state) => TaskDetailsPage(
                    projectId: state.pathParameters['projectId']!,
                    taskId: state.pathParameters['taskId']!,
                    initialTask: state.extra as Task?,
                  ),
                ),
              ],
            ),
          ],
        ),

        // ========================================================
        // PROJETS
        // ========================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              builder: (context, state) => const ProjectsPage(),
            ),
          ],
        ),

        // ========================================================
        // PROFIL
        // ========================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: TaskFlowBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
