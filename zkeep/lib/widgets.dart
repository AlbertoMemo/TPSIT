import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model.dart';
import 'notifier.dart';

class TodoCardWidget extends StatelessWidget {
  const TodoCardWidget({required this.card, super.key});

  final TodoCard card;

  Future<void> _displayAddTodoDialog(
      BuildContext context, TodoListNotifier notifier) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('add todo item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'type here ...'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                notifier.addTodoToCard(card, controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TodoListNotifier notifier = context.watch<TodoListNotifier>();

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => notifier.deleteCard(card),
                ),
              ],
            ),
            const Divider(),
            ...card.todos.map((todo) => TodoItem(todo: todo, card: card)),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: () => _displayAddTodoDialog(context, notifier),
                child: const Text('add todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  const TodoItem({required this.todo, required this.card, super.key});

  final Todo todo;
  final TodoCard card;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black45,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TodoListNotifier notifier = context.watch<TodoListNotifier>();

    return ListTile(
      onTap: () {
        notifier.changeTodo(todo);
      },
      onLongPress: () {
        notifier.deleteTodo(card, todo);
      },
      leading: CircleAvatar(child: Text(todo.name[0])),
      title: Text(todo.name, style: _getTextStyle(todo.checked)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
