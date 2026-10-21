import 'package:flutter/material.dart';

import 'routes.dart';

void main() => runApp(const CinemaApp());

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KBTU Cinema Club',
      routes: Routes.appRoutes,
      onGenerateRoute: Routes.onGenerateRoute,
      onUnknownRoute: Routes.onUnknownRoute,
    );
  }
}
