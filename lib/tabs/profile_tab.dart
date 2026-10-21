import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/screening.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.screenings,
  });

  final Profile profile;
  final List<Screening> screenings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lists = screenings.fold<int>(
      0,
      (total, screening) =>
          screening.contains(profile.name) ? total + 1 : total,
    );
    final initial = profile.hasName
        ? profile.name.characters.first.toUpperCase()
        : '?';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
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
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.checklist),
            title: Text('You are on $lists ${lists == 1 ? 'list' : 'lists'}'),
            subtitle: Text('Out of ${screenings.length} screenings.'),
          ),
        ),
      ],
    );
  }
}
