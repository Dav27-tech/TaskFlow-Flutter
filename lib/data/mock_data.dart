import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/project.dart';
import '../models/task.dart';

class MockData {
  MockData._();

  static const members = <Member>[
    Member(id: 'm1', name: 'Sarah Johnson', initials: 'SJ', avatarColorValue: 0xFFEDE9FE),
    Member(id: 'm2', name: 'Michael Brown', initials: 'MB', avatarColorValue: 0xFFDCEAFE),
    Member(id: 'm3', name: 'Emma Wilson', initials: 'EW', avatarColorValue: 0xFFE9D5FF),
    Member(id: 'm4', name: 'James Miller', initials: 'JM', avatarColorValue: 0xFFDCFCE7),
    Member(id: 'm5', name: 'David Amani', initials: 'DA', avatarColorValue: 0xFFFFE4E6),
  ];

  static const projects = <Project>[
    Project(id: 'p1', name: 'Website Redesign', dotColor: Color(0xFF2563EB), memberIds: ['m1', 'm2', 'm5']),
    Project(id: 'p2', name: 'Mobile App', dotColor: Color(0xFF16A34A), memberIds: ['m2', 'm3', 'm4']),
    Project(id: 'p3', name: 'Marketing Site', dotColor: Color(0xFF9333EA), memberIds: ['m3', 'm4']),
  ];

  static List<Task> initialTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 't1',
        title: 'Design system update',
        description:
            'Update the existing design system to improve consistency, accessibility and maintainability across the application. This includes updating colors, typography, components and spacing guidelines.',
        projectId: 'p1',
        memberId: 'm2',
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        deadline: DateTime(now.year, now.month, now.day),
        createdAt: now.subtract(const Duration(days: 4, hours: 2)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't2',
        title: 'API integration',
        description: 'Connect the mobile app to the new backend endpoints and handle error states.',
        projectId: 'p2',
        memberId: 'm3',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        deadline: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 3)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't3',
        title: 'User flow review',
        description: 'Review the onboarding flow with the design team and collect feedback.',
        projectId: 'p1',
        memberId: 'm1',
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        deadline: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't4',
        title: 'Fix critical bugs',
        description: 'Triage and resolve the crash reports coming from the latest beta build.',
        projectId: 'p2',
        memberId: 'm4',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        deadline: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 1)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't5',
        title: 'Prepare project presentation',
        description: 'Put together slides summarizing progress for the stakeholder review.',
        projectId: 'p3',
        memberId: 'm3',
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        deadline: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 1)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't6',
        title: 'Setup analytics',
        description: 'Add event tracking for the key user actions in the mobile app.',
        projectId: 'p2',
        memberId: 'm4',
        priority: TaskPriority.low,
        status: TaskStatus.todo,
        deadline: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(hours: 20)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't7',
        title: 'Content review',
        description: 'Proofread and validate all the marketing copy before launch.',
        projectId: 'p1',
        memberId: 'm1',
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        deadline: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 6)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't8',
        title: 'Marketing pages design',
        description: 'Design the landing pages for the upcoming product launch.',
        projectId: 'p3',
        memberId: 'm4',
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        deadline: now.subtract(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 8)),
        createdBy: 'David Amani',
      ),
      Task(
        id: 't9',
        title: 'Database optimization',
        description: 'Add indexes and optimize the slow queries flagged in the last audit.',
        projectId: 'p2',
        memberId: 'm2',
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        deadline: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(hours: 5)),
        createdBy: 'David Amani',
      ),
    ];
  }
}
