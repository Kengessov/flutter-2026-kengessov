import 'genre.dart';
import 'screening.dart';

/// The name the defence types into the profile tab, so that "You" highlighting
/// and "You are on N lists" work right away.
const String youName = 'Nurkhan Kengessov';

/// [total] always matches the number written next to the screening in the table:
/// one slot goes to [youName] when [withYou] is set, the rest are generated.
List<String> _viewers(int total, {bool withYou = false}) => [
  if (withYou) youName,
  ...List.generate(
    total - (withYou ? 1 : 0),
    (index) => 'Student ${index + 1}',
  ),
];

List<Screening> seedScreenings() {
  final now = DateTime.now();
  return List.unmodifiable([
    Screening(
      title:
          'Oppenheimer: Three-Hour IMAX Screening Plus Panel Discussion', // 60 characters
      genre: Genre.drama,
      when: now.add(const Duration(hours: 6)),
      place: 'Аудитория 301',
      seats: 60,
      viewers: _viewers(18, withYou: true),
      note: 'Ведущий вечера: Аяз, обсуждение после показа.',
      favourite: true,
    ),
    Screening(
      title: 'Parasite',
      genre: Genre.drama,
      when: now.add(const Duration(days: 1)),
      place: 'Актовый зал',
      seats: 25,
      viewers: _viewers(25),
      note: 'Все места заняты, лист ожидания не ведём.',
      favourite: true,
    ),
    Screening(
      title: 'Inception',
      genre: Genre.sciFi,
      when: now.subtract(const Duration(days: 3)),
      place: 'Аудитория 214',
      seats: 40,
      viewers: _viewers(11, withYou: true),
      note: 'Показ прошёл, обсуждение осталось в чате клуба.',
    ),
    Screening(
      title: 'Your Name',
      genre: Genre.animation,
      when: now.add(const Duration(days: 2)),
      place: 'https://meet.example.com/your-name',
      seats: 100,
      viewers: _viewers(34),
      online: true,
      note: 'Ссылка открывается за 10 минут до начала.',
      favourite: true,
    ),
    Screening(
      title: 'Joker',
      genre: Genre.drama,
      when: now.add(const Duration(days: 4)),
      place: 'Аудитория 301',
      seats: 30,
      viewers: _viewers(7),
    ),
    Screening(
      title: 'Mad Max: Fury Road',
      genre: Genre.action,
      when: now.add(const Duration(hours: 12)),
      place: 'Библиотека, 3 этаж',
      seats: 45,
      viewers: _viewers(41),
      note: 'Осталось несколько мест, приходите заранее.',
    ),
    Screening(
      title: 'The Shining',
      genre: Genre.horror,
      when: now.add(const Duration(days: 8)),
      place: 'Аудитория 214',
      seats: 35,
      viewers: _viewers(2),
      note: 'Показ в темноте, свет в зале не включаем.',
    ),
    Screening(
      title: 'The Hangover',
      genre: Genre.comedy,
      when: now.add(const Duration(days: 5)),
      place: 'Актовый зал',
      seats: 50,
      viewers: _viewers(22),
      note: 'Возьмите с собой что-нибудь sharing.',
    ),
    Screening(
      title: 'Interstellar',
      genre: Genre.sciFi,
      when: now.add(const Duration(days: 9)),
      place: 'Аудитория 301',
      seats: 80,
      viewers: _viewers(63, withYou: true),
      note: 'Долгий полёт, перерыв на 10 минут в середине.',
      favourite: true,
    ),
    Screening(
      title: 'Spirited Away',
      genre: Genre.animation,
      when: now.add(const Duration(days: 11)),
      place: 'https://meet.example.com/spirited-away',
      seats: 40,
      viewers: _viewers(9),
      online: true,
      note: 'Онлайн-показ для тех, кто живёт далеко от кампуса.',
    ),
    Screening(
      title: 'Get Out',
      genre: Genre.horror,
      when: now.subtract(const Duration(minutes: 40)),
      place: 'IT-коворкинг KBTU',
      seats: 28,
      viewers: _viewers(14),
      note: 'Сеанс уже начался, войти ещё можно.',
    ),
    Screening(
      title: 'Blade Runner 2049',
      genre: Genre.sciFi,
      when: now.add(const Duration(days: 20)),
      place: 'Актовый зал',
      seats: 36,
      viewers: _viewers(36),
      note: 'Зал заполнен, но места у стены ещё есть.',
      favourite: true,
    ),
  ]);
}
