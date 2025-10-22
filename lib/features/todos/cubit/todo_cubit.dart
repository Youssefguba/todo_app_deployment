import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/todo_repository.dart';
import '../models/todo.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit(this._repository) : super(const TodoState()) {
    _subscribe();
  }

  final TodoRepository _repository;
  StreamSubscription<List<Todo>>? _subscription;

  void _subscribe() {
    emit(state.copyWith(status: TodoStatus.loading));
    _subscription?.cancel();
    _subscription = _repository.watchTodos().listen(
      (todos) {
        emit(
          state.copyWith(
            status: TodoStatus.success,
            todos: todos,
            errorMessage: null,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(
            status: TodoStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> addTodo({required String title, String description = ''}) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();
    if (trimmedTitle.isEmpty) return;
    try {
      await _repository.createTodo(
        title: trimmedTitle,
        description: trimmedDescription,
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateTodo(
    Todo todo, {
    required String title,
    String? description,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = (description ?? todo.description).trim();
    if (trimmedTitle.isEmpty) return;
    try {
      await _repository.updateTodo(
        todo.copyWith(title: trimmedTitle, description: trimmedDescription),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> toggleTodoCompletion(Todo todo) async {
    try {
      await _repository.toggleCompletion(todo);
    } catch (error) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> deleteTodo(Todo todo) async {
    try {
      await _repository.deleteTodo(todo.id);
    } catch (error) {
      emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
