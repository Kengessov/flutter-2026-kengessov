const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatMoment(DateTime at) =>
    '${at.day} ${_months[at.month - 1]}, ${_padded(at.hour)}:${_padded(at.minute)}';

String _padded(int value) => value.toString().padLeft(2, '0');
