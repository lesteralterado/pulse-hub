import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/meeting_providers.dart';

class CreateMeetingPage extends ConsumerStatefulWidget {
  const CreateMeetingPage({super.key});

  @override
  ConsumerState<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends ConsumerState<CreateMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime get _scheduledStart =>
      DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute);

  DateTime get _scheduledEnd =>
      DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_scheduledEnd.isAfter(_scheduledStart)) {
      setState(() => _errorMessage = 'End time must be after the start time.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref.read(meetingRepositoryProvider).createMeeting(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledStart: _scheduledStart,
          scheduledEnd: _scheduledEnd,
        );
    if (!mounted) return;

    result.when(
      success: (_) {
        ref.invalidate(meetingsProvider);
        Navigator.of(context).pop();
      },
      failure: (error) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = describeError(error);
        });
      },
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule a meeting'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _titleController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                trailing: Text(_formatDate(_date)),
                onTap: _isSubmitting ? null : _pickDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start time'),
                trailing: Text(_formatTime(_startTime)),
                onTap: _isSubmitting ? null : _pickStartTime,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End time'),
                trailing: Text(_formatTime(_endTime)),
                onTap: _isSubmitting ? null : _pickEndTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
