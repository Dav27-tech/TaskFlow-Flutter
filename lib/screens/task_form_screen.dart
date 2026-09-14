import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../theme/app_colors.dart';
import '../widgets/deadline_field.dart';
import '../widgets/validated_dropdown.dart';
import '../widgets/validated_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  /// null => Create Task, non-null => Edit Task (pre-filled, per the mockup).
  final Task? existingTask;
  const TaskFormScreen({super.key, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  final _titleFieldKey = GlobalKey<ValidatedTextFieldState>();
  final _descFieldKey = GlobalKey<ValidatedTextFieldState>();

  String? _projectId;
  String? _memberId;
  TaskPriority? _priority;
  TaskStatus? _status;
  DateTime? _deadline;

  bool _submitted = false; // becomes true once the user tries to submit
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _projectId = t?.projectId;
    _memberId = t?.memberId;
    _priority = t?.priority;
    _status = t?.status;
    _deadline = t?.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String? _validateTitle(String v) {
    if (v.trim().isEmpty) return 'Task title is required';
    if (v.trim().length < 3) return 'Title must contain at least 3 characters';
    return null;
  }

  String? _validateDescription(String v) {
    if (v.trim().isEmpty) return null; // description is optional per the mockup
    if (v.trim().length < 10) return 'Description must contain at least 10 characters';
    return null;
  }

  bool get _isDeadlineInPast {
    if (_deadline == null) return false;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return _deadline!.isBefore(start);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);

    final titleOk = _titleFieldKey.currentState?.validateNow() ?? false;
    final descOk = _descFieldKey.currentState?.validateNow() ?? true;
    final projectOk = _projectId != null;
    final memberOk = _memberId != null;
    final priorityOk = _priority != null;
    final statusOk = _status != null;
    final deadlineOk = _deadline != null && !_isDeadlineInPast;

    final allOk = titleOk && descOk && projectOk && memberOk && priorityOk && statusOk && deadlineOk;
    if (!allOk) return;

    setState(() => _submitting = true);
    try {
      if (widget.isEditing) {
        final updated = widget.existingTask!.copyWith(
          title: _titleController.text,
          description: _descController.text,
          projectId: _projectId,
          memberId: _memberId,
          priority: _priority,
          status: _status,
          deadline: _deadline,
        );
        await TaskService.instance.updateTask(updated);
      } else {
        await TaskService.instance.createTask(
          title: _titleController.text,
          description: _descController.text,
          projectId: _projectId!,
          memberId: _memberId!,
          priority: _priority!,
          status: _status!,
          deadline: _deadline!,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectOptions = MockData.projects
        .map((p) => DropdownOption(
              value: p.id,
              label: p.name,
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: p.dotColor, shape: BoxShape.circle),
              ),
            ))
        .toList();

    final memberOptions = MockData.members
        .map((m) => DropdownOption(
              value: m.id,
              label: m.name,
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: Color(m.avatarColorValue),
                child: Text(m.initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ))
        .toList();

    final priorityOptions = TaskPriority.values
        .map((p) => DropdownOption(
              value: p,
              label: p.label,
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: p.fg, shape: BoxShape.circle),
              ),
            ))
        .toList();

    final statusOptions = TaskStatus.values
        .map((s) => DropdownOption(
              value: s,
              label: s.label,
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: s.fg, shape: BoxShape.circle),
              ),
            ))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isEditing ? 'Edit Task' : 'Create Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValidatedTextField(
                key: _titleFieldKey,
                label: 'Task Title',
                hint: 'Enter task title',
                controller: _titleController,
                validator: _validateTitle,
              ),
              const SizedBox(height: 16),
              ValidatedTextField(
                key: _descFieldKey,
                label: 'Description',
                hint: 'Enter task description',
                controller: _descController,
                validator: _validateDescription,
                required: false,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ValidatedDropdown<String>(
                label: 'Project',
                hint: 'Select a project',
                value: _projectId,
                options: projectOptions,
                showError: _submitted,
                onChanged: (v) => setState(() => _projectId = v),
              ),
              const SizedBox(height: 16),
              ValidatedDropdown<String>(
                label: 'Assigned Member',
                hint: 'Select a member',
                value: _memberId,
                options: memberOptions,
                showError: _submitted,
                onChanged: (v) => setState(() => _memberId = v),
              ),
              const SizedBox(height: 16),
              ValidatedDropdown<TaskPriority>(
                label: 'Priority',
                hint: 'Select priority',
                value: _priority,
                options: priorityOptions,
                showError: _submitted,
                onChanged: (v) => setState(() => _priority = v),
              ),
              const SizedBox(height: 16),
              ValidatedDropdown<TaskStatus>(
                label: 'Status',
                hint: 'Select status',
                value: _status,
                options: statusOptions,
                showError: _submitted,
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 16),
              DeadlineField(
                value: _deadline,
                showError: _submitted,
                onChanged: (v) => setState(() => _deadline = v),
              ),
              if (_submitted && _isDeadlineInPast) ...[
                const SizedBox(height: 4),
                const Text(
                  'The deadline cannot be in the past',
                  style: TextStyle(color: AppColors.fieldErrorBorder, fontSize: 12),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _submitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Text(widget.isEditing ? 'Saving...' : 'Creating task...'),
                          ],
                        )
                      : Text(
                          widget.isEditing ? 'Save Changes' : 'Create Task',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Text('*', style: TextStyle(color: AppColors.fieldErrorBorder)),
                  SizedBox(width: 4),
                  Text('= Required field', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
