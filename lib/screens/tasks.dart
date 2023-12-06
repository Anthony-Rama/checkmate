class Task {
  String id;
  String description;
  int points;
  bool isCompletedByCurrentUser;

  Task({
    required this.id,
    required this.description,
    this.points = 10,
    this.isCompletedByCurrentUser = false,
  });

  factory Task.fromFirestore(
      Map<String, dynamic> data, String id, String? userId) {
    return Task(
      id: id,
      description: data['description'] ?? '',
      points: data['points'] ?? 10,
      isCompletedByCurrentUser:
          (data['completedBy'] as Map<String, dynamic>?)?.containsKey(userId) ??
              false,
    );
  }
}
