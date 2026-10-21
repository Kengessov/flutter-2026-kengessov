import 'package:flutter/material.dart';

import '../models/genre.dart';
import '../models/screening.dart';
import '../widgets/empty_state.dart';
import '../widgets/screening_card.dart';

class ScreeningsTab extends StatefulWidget {
  const ScreeningsTab({
    super.key,
    required this.screenings,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Screening> screenings;
  final ValueChanged<Screening> onOpen;
  final ValueChanged<Screening> onToggleFavourite;

  @override
  State<ScreeningsTab> createState() => _ScreeningsTabState();
}

class _ScreeningsTabState extends State<ScreeningsTab> {
  final TextEditingController _search = TextEditingController();
  Genre? _genre;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _search.text.isNotEmpty || _genre != null || _showPast;

  List<Screening> _visible() {
    final query = _search.text.trim().toLowerCase();
    // toList() gives a fresh list, so the sort below never reorders the list the
    // shell owns (R7).
    final shown = widget.screenings.where((screening) {
      final matchesQuery =
          query.isEmpty || screening.title.toLowerCase().contains(query);
      final matchesGenre = _genre == null || screening.genre == _genre;
      final matchesPast = _showPast || !screening.isPast;
      return matchesQuery && matchesGenre && matchesPast;
    }).toList();
    return shown..sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.when.compareTo(b.when);
    });
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _genre = null;
      _showPast = false;
    });
  }

  Widget _genreChip(Genre? genre) {
    return ChoiceChip(
      label: Text(genre?.label ?? 'All'),
      avatar: genre == null ? null : Icon(genre.icon),
      selected: _genre == genre,
      onSelected: (_) => setState(() => _genre = genre),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search a film',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _genreChip(null),
              for (final genre in Genre.values) ...[
                const SizedBox(width: 6),
                _genreChip(genre),
              ],
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Past'),
                avatar: const Icon(Icons.history),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: _hasFilters
                      ? Icons.filter_alt_off
                      : Icons.local_movies_outlined,
                  message: _hasFilters
                      ? 'Nothing matches those filters'
                      : 'No screenings yet',
                  action: _hasFilters
                      ? (label: 'Clear filters', onPress: _clearFilters)
                      : null,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 84),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final screening = items[index];
                    return ScreeningCard(
                      screening: screening,
                      onOpen: () => widget.onOpen(screening),
                      onToggleFavourite: () =>
                          widget.onToggleFavourite(screening),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
