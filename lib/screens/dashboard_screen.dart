import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  late Future<List<TaskModel>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = _taskService.getTasks();
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    String selectedPriority = 'MEDIUM';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Duration (mins)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'LOW', child: Text('Low')),
                        DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                        DropdownMenuItem(value: 'HIGH', child: Text('High')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedPriority = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;

                    final newTask = TaskModel(
                      title: titleController.text.trim(),
                      description: descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                      estimatedDuration:
                          int.tryParse(durationController.text) ?? 30,
                      priority: selectedPriority,
                    );

                    try {
                      await _taskService.createTask(newTask);
                      if (mounted) {
                        Navigator.pop(context);
                        _loadTasks();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LRA Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tasks found.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showAddTaskDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Task'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(task.priority.isNotEmpty ? task.priority[0] : 'M'),
                  ),
                  title: Text(task.title),
                  subtitle: Text(
                    '${task.estimatedDuration} mins (${task.priority})' +
                        (task.description != null ? ' | ${task.description}' : ''),
                  ),
                  trailing: task.isCompleted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.radio_button_unchecked),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
