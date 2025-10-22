import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_app_v2/app_colors.dart';
import 'package:todo_app_v2/app_constants.dart';

import '../cubit/todo_cubit.dart';
import '../cubit/todo_state.dart';
import '../models/todo.dart';
import 'widgets/todo_form_dialog.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();

  static Future<void> _showCreateDialog(BuildContext context) async {
    final result = await showDialog<TodoFormResult>(
      context: context,
      builder: (context) => const TodoFormDialog(),
    );
    if (result == null) return;
    await context.read<TodoCubit>().addTodo(
      title: result.title,
      description: result.description,
    );
  }
}

class _TodoPageState extends State<TodoPage> {

  bool throwError = false;

  @override
  Widget build(BuildContext context) {
    if (throwError) {
      // Since the error widget is only used during a build, in this contrived example,
      // we purposely throw an exception in a build function.
      return Builder(
        builder: (BuildContext context) {
          throw Exception('oh no, an error');
        },
      );
    } else {
      return BlocListener<TodoCubit, TodoState>(
        listenWhen: (previous, current) =>
        previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        child: Scaffold(
          appBar: AppBar(title: const Text(AppConstants.appName)),
          body: const _TodoBody(),
          floatingActionButton: FloatingActionButton(
            // onPressed: () => _showCreateDialog(context),
            onPressed: () {
              setState(() {
                throwError = true;
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      );
    }
  }
}

class _TodoBody extends StatelessWidget {
  const _TodoBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        switch (state.status) {
          case TodoStatus.initial:
          case TodoStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case TodoStatus.failure:
            if (state.todos.isEmpty) {
              return _EmptyState(
                message: state.errorMessage ?? 'Failed to load todos.',
              );
            }
            return _TodoList(todos: state.todos);
          case TodoStatus.success:
            if (state.todos.isEmpty) {
              return const _EmptyState(
                message: 'No todos yet. Tap + to add one.',
              );
            }
            return _TodoList(todos: state.todos);
        }
      },
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _TodoListTile(todo: todo);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: todos.length,
    );
  }
}

class _TodoListTile extends StatelessWidget {
  const _TodoListTile({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      color: AppColors.surface,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) =>
              context.read<TodoCubit>().toggleTodoCompletion(todo),
        ),
        title: Text(
          todo.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: todo.description.isEmpty
            ? null
            : Text(
                todo.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
        onTap: () => context.read<TodoCubit>().toggleTodoCompletion(todo),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(context, todo),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                context.read<TodoCubit>().deleteTodo(todo);
                FirebaseAnalytics.instance.logEvent(
                  name: 'delete_todo',
                  parameters: {
                    'user_id': 12,
                    'date': DateTime.now().toUtc().toString(),
                  },
                );
              },
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showEditDialog(BuildContext context, Todo todo) async {
    final result = await showDialog<TodoFormResult>(
      context: context,
      builder: (context) => TodoFormDialog(
        dialogTitle: 'Edit Todo',
        initialTitle: todo.title,
        initialDescription: todo.description,
      ),
    );
    if (result == null) return;
    await context.read<TodoCubit>().updateTodo(
      todo,
      title: result.title,
      description: result.description,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist_rtl,
              size: 48,
              color: AppColors.secondary.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
