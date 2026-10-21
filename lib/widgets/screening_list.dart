import 'package:flutter/material.dart';

import '../models/screening.dart';
import 'screening_card.dart';

/// The card list, shared by the screenings tab and the favourites tab so the
/// grid decision has exactly one home.
class ScreeningList extends StatelessWidget {
  const ScreeningList({
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 84),
      itemCount: screenings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final screening = screenings[index];
        return ScreeningCard(
          screening: screening,
          onOpen: () => onOpen(screening),
          onToggleFavourite: () => onToggleFavourite(screening),
        );
      },
    );
  }
}
