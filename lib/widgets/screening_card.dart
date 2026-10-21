import 'package:flutter/material.dart';

import '../models/screening.dart';
import '../utils/format.dart';

class ScreeningCard extends StatelessWidget {
  const ScreeningCard({
    super.key,
    required this.screening,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final Screening screening;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GenreAvatar(screening: screening),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      screening.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    Text(formatMoment(screening.when), style: text.bodySmall),
                    Text(
                      screening.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                tooltip: screening.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                icon: Icon(
                  screening.favourite ? Icons.star : Icons.star_border,
                  color: screening.favourite
                      ? Theme.of(context).colorScheme.tertiary
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreAvatar extends StatelessWidget {
  const _GenreAvatar({required this.screening});

  final Screening screening;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (taken: _, free: left) = screening.places;
    final accent = screening.genre.color(scheme);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: accent.withValues(alpha: 0.18),
          child: Icon(screening.genre.icon, color: accent),
        ),
        if (screening.isFull || left <= 5)
          Positioned(
            right: -8,
            bottom: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: screening.isFull
                    ? scheme.error
                    : scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  screening.isFull ? 'FULL' : '$left left',
                  style: text.labelSmall?.copyWith(
                    color: screening.isFull
                        ? scheme.onError
                        : scheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
