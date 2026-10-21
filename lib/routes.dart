import 'package:flutter/material.dart';

import 'models/screening.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/home_shell.dart';

/// Every route name and every route builder lives here, so no '/' literal
/// appears anywhere else in the project (R25).
class Routes {
  static const String home = '/';
  static const String detail = '/detail';
  static const String form = '/form';

  /// The home route is built here like every other one, so the theme mode is
  /// handed down from the app rather than read from somewhere global (R11).
  static Map<String, WidgetBuilder> appRoutes(
    ValueNotifier<ThemeMode> themeMode,
  ) => {home: (context) => HomeShell(themeMode: themeMode)};

  static Route<Object?> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    return switch (settings.name) {
      Routes.detail when arguments is DetailArguments =>
        MaterialPageRoute<Object?>(
          builder: (context) => DetailScreen(arguments: arguments),
          settings: settings,
        ),
      // Typed as Route<Screening> so the caller can await pushNamed<Screening>:
      // the form hands its result back through pop instead of writing into the
      // list itself (R26, R27).
      Routes.form when arguments is FormArguments =>
        MaterialPageRoute<Screening>(
          builder: (context) => FormScreen(arguments: arguments),
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
