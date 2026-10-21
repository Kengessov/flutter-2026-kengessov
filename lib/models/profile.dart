class Profile {
  const Profile({this.name = '', this.group = ''});

  Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  bool get hasName => name.isNotEmpty;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
