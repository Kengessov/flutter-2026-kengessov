import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/profile.dart';
import '../models/screening.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import 'form_screen.dart';

/// Everything the detail is handed through the route (R26): the item, the
/// profile it is shown against, and the callbacks that keep the list in the
/// shell. The screen never edits the master list itself.
class DetailArguments {
  const DetailArguments({
    required this.screening,
    required this.profile,
    required this.onBook,
    required this.onCancel,
    required this.onReplace,
    required this.onDelete,
    required this.onGoToProfile,
  });

  final Screening screening;
  final Profile profile;
  final Screening Function(Screening) onBook;
  final Screening Function(Screening) onCancel;

  /// Puts an edited item into the master list and gives the same object back.
  /// Book and cancel are built by the shell, so they need only the old item;
  /// an edit arrives already built from the form, so it goes in as a pair.
  final Screening Function(Screening before, Screening after) onReplace;
  final void Function(Screening) onDelete;
  final VoidCallback onGoToProfile;
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.arguments});

  final DetailArguments arguments;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Timer? _ticker;

  /// A local mirror of the one item this screen shows. The shell still owns the
  /// list; route arguments are a snapshot, so the screen keeps its own copy of
  /// the value it just changed to keep the tab label and the buttons honest.
  late Screening _screening = widget.arguments.screening;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  bool get _joined => _screening.contains(widget.arguments.profile.name);

  Future<bool> _confirm({
    required String title,
    required String question,
    required String action,
  }) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return agreed ?? false;
  }

  Future<void> _book() async {
    if (!widget.arguments.profile.hasName) {
      _askForName();
      return;
    }
    final (taken: _, free: left) = _screening.places;
    final agreed = await _confirm(
      title: 'Book a seat?',
      question:
          '${widget.arguments.profile.name} takes one of $left free seats in '
          '"${_screening.title}".',
      action: 'Book',
    );
    if (!agreed || !mounted) return;
    final next = widget.arguments.onBook(_screening);
    setState(() => _screening = next);
  }

  void _cancel() {
    final next = widget.arguments.onCancel(_screening);
    setState(() => _screening = next);
  }

  void _askForName() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Type your name in the profile first.'),
        action: SnackBarAction(
          label: 'Open profile',
          onPressed: widget.arguments.onGoToProfile,
        ),
      ),
    );
  }

  /// The form hands back a finished screening, so both copies of it have to
  /// move: the shell puts it into the master list and this screen swaps its own
  /// mirror, or the header, the tab label and the buttons keep showing the
  /// values the form just replaced.
  Future<void> _edit() async {
    final next = await Navigator.of(context).pushNamed<Screening>(
      Routes.form,
      arguments: FormArguments(screening: _screening),
    );
    if (next == null || !mounted) return;
    final saved = widget.arguments.onReplace(_screening, next);
    setState(() => _screening = saved);
  }

  Future<void> _delete() async {
    final agreed = await _confirm(
      title: 'Delete screening?',
      question: '"${_screening.title}" leaves the list for good.',
      action: 'Delete',
    );
    if (!agreed || !mounted) return;
    widget.arguments.onDelete(_screening);
    Navigator.of(context).pop();
  }

  Widget _corner({
    required String label,
    required IconData icon,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor ?? theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 2.2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/club_poster.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.scrim.withValues(alpha: 0.10),
                  scheme.scrim.withValues(alpha: 0.70),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _corner(
              label: _screening.genre.label,
              icon: _screening.genre.icon,
              iconColor: _screening.genre.color(scheme),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _corner(
              label: _countdown(_screening.countdown),
              icon: Icons.schedule,
            ),
          ),
        ],
      ),
    );
  }

  String _countdown(Countdown countdown) => switch (countdown) {
    Upcoming(:final Duration until) => 'In ${formatSpan(until)}',
    Started(:final Duration since) => 'Started ${formatSpan(since)} ago',
    Ended() => 'Finished',
  };

  Widget _fact({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _about() {
    final (taken: taken, free: free) = _screening.places;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _fact(
          icon: Icons.schedule,
          label: 'Starts',
          value: formatMoment(_screening.when),
        ),
        _fact(
          icon: _screening.online ? Icons.link : Icons.place,
          label: _screening.online ? 'Stream' : 'Place',
          value: _screening.place,
        ),
        _fact(
          icon: Icons.event_seat,
          label: 'Seats',
          value: '$taken taken · $free free of ${_screening.seats}',
        ),
        if (_screening.note case final String note)
          _fact(icon: Icons.sticky_note_2_outlined, label: 'Note', value: note),
      ],
    );
  }

  Widget _viewers() {
    final names = _screening.viewers;
    if (names.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody on the list yet.',
      );
    }
    final theme = Theme.of(context);
    final you = widget.arguments.profile.name;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        final isYou =
            you.isNotEmpty &&
            name.trim().toLowerCase() == you.trim().toLowerCase();
        return ListTile(
          leading: Icon(
            isYou ? Icons.star : Icons.person_outline,
            color: isYou ? theme.colorScheme.tertiary : null,
          ),
          title: Text(
            name,
            style: isYou
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodyLarge,
          ),
          trailing: isYou
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      'You',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _primaryAction() {
    if (_joined) {
      return OutlinedButton.icon(
        onPressed: _cancel,
        icon: const Icon(Icons.close),
        label: const Text('Cancel booking'),
      );
    }
    return FilledButton.icon(
      onPressed: _screening.canBook ? _book : null,
      icon: const Icon(Icons.confirmation_number_outlined),
      label: Text(_screening.isFull ? 'Sold out' : 'Book a seat'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _screening.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Screening actions',
            onSelected: (choice) {
              switch (choice) {
                case 'edit':
                  _edit();
                case 'delete':
                  _delete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      const Tab(text: 'About'),
                      Tab(text: 'Viewers (${_screening.count})'),
                    ],
                  ),
                  Expanded(child: TabBarView(children: [_about(), _viewers()])),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(width: double.infinity, child: _primaryAction()),
            ),
          ),
        ],
      ),
    );
  }
}
