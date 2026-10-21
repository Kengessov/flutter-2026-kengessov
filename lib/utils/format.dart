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

/// "18 Oct" — the date half, for the field whose time lives in its own picker.
String formatDay(DateTime at) => '${at.day} ${_months[at.month - 1]}';

/// "19:30" from the two numbers a time picker hands back.
String clockOf(int hour, int minute) => '${_padded(hour)}:${_padded(minute)}';

String formatMoment(DateTime at) =>
    '${formatDay(at)}, ${clockOf(at.hour, at.minute)}';

String _padded(int value) => value.toString().padLeft(2, '0');

/// Coarse span for the countdown: nobody reads seconds on a poster, but the
/// difference between "in 3 d" and "in 4 h" is the whole point.
String formatSpan(Duration span) => switch (span.inDays) {
  > 0 => '${span.inDays} d ${span.inHours % 24} h',
  0 when span.inHours > 0 =>
    '${span.inHours} h ${_padded(span.inMinutes % 60)} min',
  _ => '${span.inMinutes} min',
};
