import 'package:flutter/material.dart';

import '../models/genre.dart';
import '../models/screening.dart';
import '../utils/format.dart';

/// The one value the form route is handed (R26): nothing means "write a new
/// screening", an item means "edit this one". The form answers by popping a
/// [Screening], so the caller decides where the result lands and the form never
/// has to know that a list exists.
class FormArguments {
  const FormArguments({this.screening});

  final Screening? screening;
}

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.arguments});

  final FormArguments arguments;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  static const int _titleMax = 60;
  static const int _noteMax = 200;

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _place = TextEditingController();
  final TextEditingController _seats = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final TextEditingController _day = TextEditingController();
  final TextEditingController _clock = TextEditingController();

  final FocusNode _titleNode = FocusNode();
  final FocusNode _placeNode = FocusNode();
  final FocusNode _seatsNode = FocusNode();
  final FocusNode _noteNode = FocusNode();

  Genre? _genre;
  DateTime? _date;
  TimeOfDay? _time;
  bool _online = false;

  Screening? get _editing => widget.arguments.screening;

  @override
  void initState() {
    super.initState();
    // Screening.empty() owns the defaults a field can carry (R3). Genre, date
    // and clock stay null for a new item: the model has no way to say "not
    // picked yet", so the form holds them nullable and the validators are the
    // ones that refuse an empty choice.
    final editing = _editing;
    final baseline = editing ?? Screening.empty();
    _title.text = baseline.title;
    _place.text = baseline.place;
    _seats.text = baseline.seats.toString();
    _note.text = baseline.note ?? '';
    _online = baseline.online;
    _genre = editing?.genre;
    final date = editing?.when;
    final time = editing == null ? null : TimeOfDay.fromDateTime(editing.when);
    _date = date;
    _time = time;
    _day.text = date == null ? '' : formatDay(date);
    _clock.text = time == null ? '' : clockOf(time.hour, time.minute);
    for (final controller in [_title, _place, _seats, _note]) {
      controller.addListener(_rebuild);
    }
  }

  /// The typed text never rebuilds this screen on its own, and both the
  /// place label and the dirty check read that text, so the controllers have
  /// to ask for a frame.
  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final controller in [_title, _place, _seats, _note]) {
      controller.removeListener(_rebuild);
    }
    _title.dispose();
    _place.dispose();
    _seats.dispose();
    _note.dispose();
    _day.dispose();
    _clock.dispose();
    _titleNode.dispose();
    _placeNode.dispose();
    _seatsNode.dispose();
    _noteNode.dispose();
    super.dispose();
  }

  DateTime _moment(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.length < 3) return 'A title needs at least 3 characters.';
    if (title.length > _titleMax) return 'A title stops at $_titleMax.';
    return null;
  }

  String? _validateGenre(Genre? value) =>
      value == null ? 'Pick a genre.' : null;

  String? _validateDay(String? _) {
    if (_date == null) return 'Pick a date.';
    return null;
  }

  String? _validateClock(String? _) {
    final time = _time;
    if (time == null) return 'Pick a time.';
    final date = _date;
    // Only a new screening has to be in the future: editing an old one is how
    // you fix a typo in a title, not a reason to move it forward a week.
    if (date != null && _editing == null) {
      if (_moment(date, time).isBefore(DateTime.now())) {
        return 'That moment has already passed.';
      }
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final place = value?.trim() ?? '';
    if (place.isEmpty) {
      return _online ? 'Paste the stream link.' : 'Where is it screened?';
    }
    if (_online && !place.contains('://')) return 'A link needs :// in it.';
    return null;
  }

  String? _validateSeats(String? value) {
    final seats = int.tryParse(value?.trim() ?? '');
    if (seats == null) return 'Seats as a whole number.';
    if (seats < 1 || seats > 500) return 'Between 1 and 500 seats.';
    final already = _editing?.count ?? 0;
    if (seats < already) return 'The list already holds $already names.';
    return null;
  }

  String? _validateNote(String? value) => (value?.trim().length ?? 0) > _noteMax
      ? 'Keep the note under $_noteMax characters.'
      : null;

  /// The values on the screen as a screening, or null while genre, date or
  /// time is still missing. [FormState.validate] refuses that state one frame
  /// earlier, so this is the same rule read from the other side — and the
  /// reason no `!` is needed to unpack the three pickers (R6).
  Screening? _compose() => switch ((_genre, _date, _time)) {
    (final Genre genre, final DateTime date, final TimeOfDay time) =>
      (_editing ?? Screening.empty()).copyWith(
        title: _title.text.trim(),
        genre: genre,
        when: _moment(date, time),
        place: _place.text.trim(),
        seats: int.parse(_seats.text.trim()),
        online: _online,
        note: _noteOrNull,
        clearNote: _noteOrNull == null,
      ),
    _ => null,
  };

  String? get _noteOrNull {
    final note = _note.text.trim();
    return note.isEmpty ? null : note;
  }

  Future<void> _save() async {
    // GlobalKey.currentState is null only before its Form has mounted, and this
    // button lives inside that Form — so it exists whenever Save can be tapped.
    if (!_form.currentState!.validate()) return;
    final item = _compose();
    if (item == null) return;
    Navigator.pop(context, item);
  }

  void _dismissKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    // Cancel returns null and the old value stays on the field (R36).
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _day.text = formatDay(picked);
    });
  }

  Future<void> _pickClock() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _clock.text = clockOf(picked.hour, picked.minute);
    });
  }

  Widget _titleField() => TextFormField(
    controller: _title,
    focusNode: _titleNode,
    textInputAction: TextInputAction.next,
    keyboardType: TextInputType.text,
    maxLength: _titleMax,
    onTapOutside: _dismissKeyboard,
    validator: _validateTitle,
    decoration: const InputDecoration(
      labelText: 'Title',
      border: OutlineInputBorder(),
    ),
  );

  Widget _genreField() => DropdownButtonFormField<Genre>(
    value: _genre,
    hint: const Text('Pick a genre'),
    items: [
      for (final genre in Genre.values)
        DropdownMenuItem(
          value: genre,
          child: Row(
            children: [
              Icon(genre.icon, size: 18),
              const SizedBox(width: 10),
              Text(genre.label),
            ],
          ),
        ),
    ],
    onChanged: (genre) => setState(() => _genre = genre),
    validator: _validateGenre,
    decoration: const InputDecoration(
      labelText: 'Genre',
      border: OutlineInputBorder(),
    ),
  );

  Widget _modeTile() => CheckboxListTile(
    value: _online,
    onChanged: (online) => setState(() => _online = online ?? false),
    title: const Text('Streamed, not screened'),
    subtitle: Text(
      _online
          ? 'The place becomes a link people open from home.'
          : 'The place is a room someone walks into.',
    ),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
  );

  Widget _whenRow() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: TextFormField(
          controller: _day,
          readOnly: true,
          onTap: _pickDay,
          validator: _validateDay,
          decoration: const InputDecoration(
            labelText: 'Date',
            hintText: 'Pick a date',
            prefixIcon: Icon(Icons.calendar_month_outlined),
            border: OutlineInputBorder(),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: TextFormField(
          controller: _clock,
          readOnly: true,
          onTap: _pickClock,
          validator: _validateClock,
          decoration: const InputDecoration(
            labelText: 'Time',
            hintText: 'Pick a time',
            prefixIcon: Icon(Icons.schedule),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );

  Widget _placeField() => TextFormField(
    controller: _place,
    focusNode: _placeNode,
    textInputAction: TextInputAction.next,
    keyboardType: _online ? TextInputType.url : TextInputType.text,
    onTapOutside: _dismissKeyboard,
    validator: _validatePlace,
    decoration: InputDecoration(
      labelText: _online ? 'Stream link' : 'Place',
      border: const OutlineInputBorder(),
    ),
  );

  Widget _seatsField() => TextFormField(
    controller: _seats,
    focusNode: _seatsNode,
    textInputAction: TextInputAction.next,
    keyboardType: TextInputType.number,
    onTapOutside: _dismissKeyboard,
    validator: _validateSeats,
    decoration: const InputDecoration(
      labelText: 'Seats',
      border: OutlineInputBorder(),
    ),
  );

  Widget _noteField() => TextFormField(
    controller: _note,
    focusNode: _noteNode,
    textInputAction: TextInputAction.done,
    keyboardType: TextInputType.text,
    maxLines: 3,
    onTapOutside: _dismissKeyboard,
    validator: _validateNote,
    decoration: const InputDecoration(
      labelText: 'Note (optional)',
      alignLabelWithHint: true,
      border: OutlineInputBorder(),
    ),
  );

  Widget _saveButton() => FilledButton.icon(
    onPressed: _save,
    icon: const Icon(Icons.save_outlined),
    label: const Text('Save'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'New screening' : 'Edit screening'),
      ),
      // One scrolling column, no Spacer: the keyboard shrinks the viewport and
      // the focused field scrolls itself into view (R37).
      body: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _titleField(),
            const SizedBox(height: 12),
            _genreField(),
            const SizedBox(height: 12),
            _modeTile(),
            const SizedBox(height: 12),
            _whenRow(),
            const SizedBox(height: 12),
            _placeField(),
            const SizedBox(height: 12),
            _seatsField(),
            const SizedBox(height: 12),
            _noteField(),
            const SizedBox(height: 24),
            _saveButton(),
          ],
        ),
      ),
    );
  }
}
