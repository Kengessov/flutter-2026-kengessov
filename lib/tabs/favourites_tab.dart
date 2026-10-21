import 'package:flutter/material.dart';

import '../models/screening.dart';
import '../widgets/empty_state.dart';
import '../widgets/screening_list.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.screenings,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Screening> screenings;
  final ValueChanged<Screening> onOpen;
  final ValueChanged<Screening> onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final loved = screenings.where((screening) => screening.favourite).toList()
      ..sort((left, right) => left.when.compareTo(right.when));
    if (loved.isEmpty) {
      return const EmptyState(
        icon: Icons.star_border,
        message: 'No favourites yet.\nTap the star on a card.',
      );
    }
    return ScreeningList(
      screenings: loved,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
