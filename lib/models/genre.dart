import 'package:flutter/material.dart';

enum Genre {
  action('Action', Icons.bolt),
  comedy('Comedy', Icons.emoji_emotions),
  drama('Drama', Icons.theater_comedy),
  horror('Horror', Icons.bedtime),
  sciFi('Sci-Fi', Icons.rocket_launch),
  animation('Animation', Icons.animation);

  const Genre(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    Genre.action => scheme.error,
    Genre.comedy => scheme.tertiary,
    Genre.drama => scheme.secondary,
    Genre.horror => scheme.primary,
    Genre.sciFi => scheme.tertiaryContainer,
    Genre.animation => scheme.secondaryContainer,
  };
}
