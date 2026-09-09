class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final String priority;
  final int estimatedDuration; 
  final bool isCompleted;
  final DateTime? dueDate;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    this.priority = 'MEDIUM',
    this.estimatedDuration = 30,
    this.isCompleted = false,
    this.dueDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'] ?? 'MEDIUM',
      estimatedDuration: json['estimated_duration'] ?? 30,
      isCompleted: json['is_completed'] ?? false,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null && description!.isNotEmpty) 'description': description,
      'priority': priority,
      'estimated_duration': estimatedDuration,
      'is_completed': isCompleted,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String().split('T')[0],
    };
  }
}
