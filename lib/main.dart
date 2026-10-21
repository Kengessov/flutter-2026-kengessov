import 'package:flutter/material.dart';

import 'routes.dart';

void main() => runApp(const CinemaApp());

class CinemaApp extends StatefulWidget {
  const CinemaApp({super.key});

  @override
  State<CinemaApp> createState() => _CinemaAppState();
}

class _CinemaAppState extends State<CinemaApp> {
  /// R22 asks for a seed and forbids a literal color in the same breath, and
  /// `fromSeed` will not run without one. This is the one color the app does
  /// not invent: it is the primary of the palette the framework itself ships
  /// with, so the seed stays a role rather than a number typed into the source.
  static final Color _seed = ColorScheme.light().primary;

  // R11: the mode lives above MaterialApp because MaterialApp is the widget
  // that has to rebuild when it changes. It is a listenable rather than a
  // plain value because a route captures its arguments once, when it is
  // pushed: a value handed through `routes` would stay frozen in the profile
  // tab, while the notifier it was given keeps reporting the truth.
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  ThemeData _theme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
  );

  @override
  Widget build(BuildContext context) {
    // No setState anywhere: writing the notifier is the whole signal, and this
    // widget builds MaterialApp again with the new mode inside it.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'KBTU Cinema Club',
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: mode,
        routes: Routes.appRoutes(_themeMode),
        onGenerateRoute: Routes.onGenerateRoute,
        onUnknownRoute: Routes.onUnknownRoute,
      ),
    );
  }
}
