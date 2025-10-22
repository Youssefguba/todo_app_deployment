import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_constants.dart';
import '../features/todos/view/todo_page.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
    );

    return MaterialApp(
      title: AppConstants.appName,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: baseTheme.appBarTheme.copyWith(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: baseTheme.floatingActionButtonTheme.copyWith(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        ),
        checkboxTheme: baseTheme.checkboxTheme.copyWith(
          fillColor: MaterialStateProperty.all(AppColors.primary),
        ),
      ),
      home: const TodoPage(),
    );
  }
}
