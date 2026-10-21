import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/screening.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.screenings,
    required this.onSave,
  });

  final Profile profile;
  final List<Screening> screenings;
  final ValueChanged<Profile> onSave;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  /// A group code is a programme, a speciality, an intake and a stream, like
  /// `BSc-CS-24-1`.
  static final RegExp _groupCode = RegExp(
    r'^[A-Za-z]{2,6}-[A-Za-z]{2,6}-\d{2}-\d{1,2}$',
  );

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  // R38: the fields start from the model the shell owns, not from a copy of it.
  late final TextEditingController _name = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _group = TextEditingController(
    text: widget.profile.group,
  );

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  /// The shell can replace the profile without this tab, which is what Reset
  /// data does, so a model that changed has to be written back into the
  /// fields. Only a change of the model counts: an edit that has not been
  /// submitted yet must survive an unrelated rebuild of the shell.
  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  void _save() {
    final form = _form.currentState;
    if (form == null || !form.validate()) return;
    widget.onSave(Profile(name: _name.text.trim(), group: _group.text.trim()));
  }

  String? _validateGroup(String? value) {
    final group = value?.trim() ?? '';
    // An empty group is what a profile starts with, so only a typed one is
    // held against the pattern.
    if (group.isEmpty) return null;
    if (!_groupCode.hasMatch(group)) return 'A group looks like BSc-CS-24-1.';
    return null;
  }

  void _dismissKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  Widget _header(BuildContext context, Profile profile) {
    final theme = Theme.of(context);
    final initial = profile.hasName
        ? profile.name.characters.first.toUpperCase()
        : '?';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.hasName ? profile.name : 'No name yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    profile.group.isEmpty ? 'No group' : profile.group,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fields() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The name has no validator on purpose: an empty profile is a state
            // the app itself creates (Reset data), and a booking screen is where
            // a missing name is asked for. Writing into this field from
            // didUpdateWidget counts as an interaction, so a required-name rule
            // would shout after every reset.
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onTapOutside: _dismissKeyboard,
              onFieldSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _group,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.done,
              onTapOutside: _dismissKeyboard,
              validator: _validateGroup,
              onFieldSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'Group',
                hintText: 'BSc-CS-24-1',
                helperText: 'Optional',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _lists(BuildContext context, List<Screening> screenings) {
    final theme = Theme.of(context);
    // R38: counted from the list on every build, so booking or deleting a
    // screening is reflected without this tab being told anything.
    final lists = screenings.fold<int>(
      0,
      (total, screening) =>
          screening.contains(widget.profile.name) ? total + 1 : total,
    );
    return Card(
      child: ListTile(
        leading: const Icon(Icons.checklist),
        title: Text('You are on $lists ${lists == 1 ? 'list' : 'lists'}'),
        subtitle: Text(
          'Out of ${screenings.length} screenings.',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(context, widget.profile),
        const SizedBox(height: 12),
        _fields(),
        const SizedBox(height: 12),
        _lists(context, widget.screenings),
      ],
    );
  }
}
