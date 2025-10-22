import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:todo_app_v2/app_constants.dart';
import '../models/todo.dart';

class TodoRepository {
  TodoRepository({FirebaseFirestore? firestore})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection(
        AppConstants.todosCollection,
      );

  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<Todo>> watchTodos() {
    return _collection.orderBy('updatedAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => Todo.fromMap(doc.id, doc.data()))
          .toList(growable: false);
    });
  }

  Future<Todo> createTodo({
    required String title,
    String description = '',
  }) async {
    final docRef = _collection.doc();
    final todo = Todo(
      id: docRef.id,
      title: title,
      description: description,
      updatedAt: DateTime.now(),
    );
    await docRef.set(todo.toMap());
    return todo;
  }

  Future<void> updateTodo(Todo todo) {
    return _collection
        .doc(todo.id)
        .update(todo.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteTodo(String id) {
    return _collection.doc(id).delete();
  }

  Future<void> toggleCompletion(Todo todo) {
    return updateTodo(
      todo.copyWith(isCompleted: !todo.isCompleted, updatedAt: DateTime.now()),
    );
  }
}
