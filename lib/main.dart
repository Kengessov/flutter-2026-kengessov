import 'package:flutter/material.dart';

import 'models/screening.dart';
import 'models/seed.dart';
import 'tabs/screenings_tab.dart';

void main() => runApp(const CinemaApp());

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(title: 'KBTU Cinema Club', home: const ScreeningsDemo());
}

/// Temporary home for the list: the shell with three tabs takes ownership of the
/// screenings in the next step.
class ScreeningsDemo extends StatefulWidget {
  const ScreeningsDemo({super.key});

  @override
  State<ScreeningsDemo> createState() => _ScreeningsDemoState();
}

class _ScreeningsDemoState extends State<ScreeningsDemo> {
  List<Screening> _screenings = seedScreenings();

  void _toggleFavourite(Screening screening) {
    final next = [
      for (final item in _screenings)
        if (item == screening)
          item.copyWith(favourite: !item.favourite)
        else
          item,
    ];
    setState(() => _screenings = next);
  }

  // The card is already tappable; the detail screen is built in the next step, so
  // this only proves the tap reaches the owner of the list.
  void _open(Screening screening) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(screening.title)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('KBTU Cinema Club')),
    body: ScreeningsTab(
      screenings: _screenings,
      onOpen: _open,
      onToggleFavourite: _toggleFavourite,
    ),
  );
}
