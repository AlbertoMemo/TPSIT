class TodoCard {
  TodoCard({required this.title, required this.todos});
  final String title;
  final List<Todo> todos;
}

class Todo {
  Todo({required this.name, required this.checked});
  final String name;
  bool checked;
}
