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

/// Coarse span for the countdown: nobody reads seconds on a poster, but the
/// difference between "in 3 d" and "in 4 h" is the whole point.
String formatSpan(Duration span) => switch (span.inDays) {
  > 0 => '${span.inDays} d ${span.inHours % 24} h',
  0 when span.inHours > 0 =>
    '${span.inHours} h ${_padded(span.inMinutes % 60)} min',
  _ => '${span.inMinutes} min',
};
