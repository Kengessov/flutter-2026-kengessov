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

  /// R20: under this width a column of rows is what a reader can scan; at it
  /// the same cards move to a grid.
  static const double _gridFromWidth = 600;

  /// R20: the widest a cell may become.
  static const double _maxCellWidth = 360;

  /// A card never grows taller than two title lines, the moment and the place:
  /// 2 x 24 + 2 x 16 of text, 16 of inner padding, 8 of card margin.
  static const double _cellHeight = 104;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder, not MediaQuery: what matters is the width this widget was
    // actually given, and that is what the builder reports (R20).
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < _gridFromWidth ? _list() : _grid(),
    );
  }

  Widget _list() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 84),
    itemCount: screenings.length,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: _card,
  );

  Widget _grid() => GridView.builder(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 84),
    // No cross-axis spacing on purpose: the delegate splits the width by
    // ceil(width / (360 + spacing)), so with a spacing the last column is
    // stretched past 360. At zero the cell is width / ceil(width / 360) and
    // stays under the cap, and the card's own 4 dp margin is the gutter.
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: _maxCellWidth,
      mainAxisExtent: _cellHeight,
    ),
    itemCount: screenings.length,
    itemBuilder: _card,
  );

  Widget _card(BuildContext context, int index) {
    final screening = screenings[index];
    return ScreeningCard(
      screening: screening,
      onOpen: () => onOpen(screening),
      onToggleFavourite: () => onToggleFavourite(screening),
    );
  }
}
