import 'countdown.dart';
import 'genre.dart';

class Screening {
  const Screening({
    required this.title,
    required this.genre,
    required this.when,
    required this.place,
    required this.seats,
    List<String> viewers = const <String>[],
    this.online = false,
    this.note,
    this.favourite = false,
  }) : _viewers = viewers;

  Screening.empty()
    : title = '',
      genre = Genre.drama,
      when = DateTime.now(),
      place = '',
      seats = 30,
      _viewers = const <String>[],
      online = false,
      note = null,
      favourite = false;

  final String title;
  final Genre genre;
  final DateTime when;
  final String place;
  final int seats;
  final bool online;
  final String? note;
  final bool favourite;
  final List<String> _viewers;

  /// Only ever handed out as an unmodifiable copy, so no caller can mutate the
  /// list inside an already-built [Screening].
  List<String> get viewers => List.unmodifiable(_viewers);

  int get count => _viewers.length;

  ({int taken, int free}) get places => (taken: count, free: seats - count);

  bool get isFull => count >= seats;

  bool get isPast => when.isBefore(DateTime.now());

  Countdown get countdown => Countdown.of(when: when, now: DateTime.now());

  bool contains(String name) {
    final needle = name.trim().toLowerCase();
    return _viewers.any((viewer) => viewer.trim().toLowerCase() == needle);
  }

  Screening copyWith({
    String? title,
    Genre? genre,
    DateTime? when,
    String? place,
    int? seats,
    List<String>? viewers,
    bool? online,
    String? note,
    bool clearNote = false,
    bool? favourite,
  }) => Screening(
    title: title ?? this.title,
    genre: genre ?? this.genre,
    when: when ?? this.when,
    place: place ?? this.place,
    seats: seats ?? this.seats,
    viewers: viewers ?? _viewers,
    online: online ?? this.online,
    note: clearNote ? null : note ?? this.note,
    favourite: favourite ?? this.favourite,
  );
}
