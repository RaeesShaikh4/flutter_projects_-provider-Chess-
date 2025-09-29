class ToDo {
  final int id;
  final String title;
  final bool completed;

  ToDo({required this.id, required this.title, required this.completed});

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
        id: json['id'], title: json['title'], completed: json['completed']);
  }
}
