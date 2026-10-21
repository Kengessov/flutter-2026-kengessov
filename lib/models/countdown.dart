sealed class Countdown {
  const Countdown();

  static const Duration screeningLength = Duration(hours: 2);

  static Countdown of({required DateTime when, required DateTime now}) {
    final until = when.difference(now);
    if (!until.isNegative) return Upcoming(until);
    final since = now.difference(when);
    if (since > screeningLength) return const Ended();
    return Started(since);
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.until);

  final Duration until;
}

final class Started extends Countdown {
  const Started(this.since);

  final Duration since;
}

final class Ended extends Countdown {
  const Ended();
}
