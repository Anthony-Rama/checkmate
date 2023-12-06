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
    bool completedByCurrentUser = false;
    if (data.containsKey('completedBy') && data['completedBy'] is Map) {
      completedByCurrentUser =
          (data['completedBy'] as Map<String, dynamic>)[userId] ?? false;
    }

    return Task(
      id: id,
      description: data['description'] ?? '',
      points: data['points'] ?? 10,
      isCompletedByCurrentUser: completedByCurrentUser,
    );
  }
}
