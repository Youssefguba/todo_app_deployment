import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/app_env.dart';
import 'features/todos/cubit/todo_cubit.dart';
import 'features/todos/data/todo_repository.dart';
import 'firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> runMainApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment before running the app
  EnvironmentConfig.init(EnvironmentType.production);

  /// www.facebook.com -> account, history, subscriptions -> DB Production
  /// www.stg.facebook.com -> x , x , x, logout, can't login, data, not found, login, create accounts, no history, no subscriptions
  /// Migration - Production -> Staging
  /// 12 PM -> 6 PM
  /// What's Happened? How can avoid this again?
  /// Don't point fingers == Blame Fingers

  // https://7b9f87a15d2d901dc6bf8b10bd029c64@o4510211814588416.ingest.us.sentry.io/4510211820355584
  await Firebase.initializeApp(
    name: 'main',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Set the ErrorWidget's builder before the app is started.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // If we're in debug mode, use the normal error widget which shows the error
    // message:
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    // In release builds, show a yellow-on-blue message instead:
    return ReleaseModeErrorWidget(details: details);
  };


  final todoRepository = TodoRepository();

  // Environment Variables
  final key = String.fromEnvironment('sentry_key');
  final name = String.fromEnvironment('MY_NAME');

  await SentryFlutter.init(
    (options) {
      options.dsn = EnvironmentConfig.sentryKey;
      options.sendDefaultPii = true;
      options.enableLogs = true;
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: 
    RepositoryProvider.value(
      value: todoRepository,
      child: BlocProvider(
        create: (_) => TodoCubit(todoRepository),
        child: const TodoApp(),
      ),
    ),
  )),
  );
}

class ReleaseModeErrorWidget extends StatelessWidget {
  const ReleaseModeErrorWidget({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.add), ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error!\n${details.exception}',
            style: const TextStyle(color: Colors.yellow),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}