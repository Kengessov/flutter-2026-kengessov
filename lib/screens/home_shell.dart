import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/screening.dart';
import '../models/seed.dart';
import '../routes.dart';
import '../screens/form_screen.dart';
import '../tabs/favourites_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/screenings_tab.dart';
import 'detail_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const int _profileTab = 2;

  int _tab = 0;
  List<Screening> _screenings = seedScreenings();
  Profile _profile = Profile(name: youName, group: '');

  /// Items have no ids, so the shell finds the old one by object identity.
  /// A stale `before` — already replaced or deleted — would rewrite nothing
  /// and still hand the caller a shiny new screening, so the edit would look
  /// saved while the list quietly kept the old one.
  Screening _replace(Screening before, Screening after) {
    final index = _screenings.indexOf(before);
    assert(
      index != -1,
      'The shell no longer holds "${before.title}", nothing was saved.',
    );
    setState(() {
      _screenings = [..._screenings]..[index] = after;
    });
    return after;
  }

  Screening _book(Screening screening) => _replace(
    screening,
    screening.copyWith(viewers: [...screening.viewers, _profile.name.trim()]),
  );

  Screening _cancel(Screening screening) => _replace(
    screening,
    screening.copyWith(
      viewers: screening.viewers
          .where(
            (name) =>
                name.trim().toLowerCase() != _profile.name.trim().toLowerCase(),
          )
          .toList(),
    ),
  );

  Screening _toggleFavourite(Screening screening) =>
      _replace(screening, screening.copyWith(favourite: !screening.favourite));

  void _delete(Screening screening) {
    setState(() {
      _screenings = _screenings.where((item) => item != screening).toList();
    });
  }

  /// The form answers with a finished screening or with nothing at all:
  /// backing out returns null, the list stays exactly as it was and no
  /// exception crosses the await (R27).
  Future<void> _newScreening() async {
    final created = await Navigator.of(
      context,
    ).pushNamed<Screening>(Routes.form, arguments: const FormArguments());
    if (created == null || !mounted) return;
    setState(() => _screenings = [..._screenings, created]);
  }

  void _openDetail(Screening screening) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArguments(
        screening: screening,
        profile: _profile,
        onBook: _book,
        onCancel: _cancel,
        onReplace: _replace,
        onDelete: _delete,
        onGoToProfile: _goToProfile,
      ),
    );
  }

  // R28: a pushed screen never switches tabs itself, it asks the shell, which
  // both moves the bar and drops the screen covering it.
  void _goToProfile() {
    final navigator = Navigator.of(context);
    setState(() => _tab = _profileTab);
    if (navigator.canPop()) navigator.pop();
  }

  Future<void> _showAbout() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.local_movies),
        title: const Text('KBTU Cinema Club'),
        content: const Text(
          'Lab 1: a screenings list, a detail screen, a form and a profile. '
          'Everything lives in memory and starts from twelve seed items.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'The twelve seed screenings come back and the profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) return;
    setState(() {
      _screenings = seedScreenings();
      _profile = Profile.empty();
    });
  }

  Widget _drawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'KBTU Cinema Club',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset data'),
              subtitle: const Text('Back to the twelve seed screenings'),
              onTap: () {
                Navigator.pop(context);
                _resetData();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KBTU Cinema Club')),
      drawer: _drawer(),
      body: IndexedStack(
        index: _tab,
        children: [
          ScreeningsTab(
            screenings: _screenings,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            screenings: _screenings,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          ProfileTab(profile: _profile, screenings: _screenings),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newScreening,
        tooltip: 'New screening',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_movies_outlined),
            selectedIcon: Icon(Icons.local_movies),
            label: 'Screenings',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
