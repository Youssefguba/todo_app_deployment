import 'package:equatable/equatable.dart';

import '../models/todo.dart';

enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  const TodoState({
    this.status = TodoStatus.initial,
    this.todos = const <Todo>[],
    this.errorMessage,
  });

  final TodoStatus status;
  final List<Todo> todos;
  final String? errorMessage;

  TodoState copyWith({
    TodoStatus? status,
    List<Todo>? todos,
    String? errorMessage,
  }) {
    return TodoState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, todos, errorMessage];
}
