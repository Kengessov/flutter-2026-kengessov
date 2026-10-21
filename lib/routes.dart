import 'package:flutter/material.dart';

import 'screens/detail_screen.dart';
import 'screens/home_shell.dart';

/// Every route name and every route builder lives here, so no '/' literal
/// appears anywhere else in the project (R25).
class Routes {
  static const String home = '/';
  static const String detail = '/detail';

  static final Map<String, WidgetBuilder> appRoutes = <String, WidgetBuilder>{
    home: (context) => const HomeShell(),
  };

  static Route<Object?> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    return switch (settings.name) {
      Routes.detail when arguments is DetailArguments =>
        MaterialPageRoute<Object?>(
          builder: (context) => DetailScreen(arguments: arguments),
          settings: settings,
        ),
      _ => onUnknownRoute(settings),
    };
  }

  static Route<Object?> onUnknownRoute(RouteSettings settings) =>
      MaterialPageRoute<Object?>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: Center(child: Text('No screen for "${settings.name}".')),
        ),
        settings: settings,
      );
}
