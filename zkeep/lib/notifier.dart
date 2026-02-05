import 'package:flutter/widgets.dart';
import 'model.dart';

class TodoListNotifier with ChangeNotifier {
  final _cards = <TodoCard>[];

  int get length => _cards.length;

  void addCard(String title) {
    _cards.add(TodoCard(title: title, todos: []));
    notifyListeners();
  }

  void addTodoToCard(TodoCard card, String name) {
    card.todos.add(Todo(name: name, checked: false));
    notifyListeners();
  }

  void changeTodo(Todo todo) {
    todo.checked = !todo.checked;
    notifyListeners();
  }

  void deleteTodo(TodoCard card, Todo todo) {
    card.todos.remove(todo);
    notifyListeners();
  }

  void deleteCard(TodoCard card) {
    _cards.remove(card);
    notifyListeners();
  }

  TodoCard getCard(int i) => _cards[i];
}
