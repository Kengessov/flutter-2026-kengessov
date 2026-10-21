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

/// The screen values a dirty check compares, text included. "Dirty" means
/// "different from what the form opened with", not "a key was pressed": a
/// screening whose date was picked and then put back is clean again (R30).
typedef FormSnapshot = ({
  String title,
  Genre? genre,
  DateTime? date,
  TimeOfDay? time,
  String place,
  String seats,
  bool online,
  String note,
});

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.arguments});

  final FormArguments arguments;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  static const int _titleMax = 60;
  static const int _noteMax = 200;

  /// Set on the `Form` instead, this mode validates every field after the
  /// first character typed anywhere; set per field it waits for that one
  /// field, so an empty form stays quiet (R33).
  static const AutovalidateMode _auto = AutovalidateMode.onUserInteraction;

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
  bool _saving = false;

  late final FormSnapshot _opened;

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
    _opened = _current;
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

  FormSnapshot get _current => (
    title: _title.text,
    genre: _genre,
    date: _date,
    time: _time,
    place: _place.text,
    seats: _seats.text,
    online: _online,
    note: _note.text,
  );

  bool get _dirty => _current != _opened;

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
    // The button is only redrawn on the next frame, so two quick taps can both
    // get here before the first one is painted away; the flag stops the second
    // from starting a second save (R17).
    if (_saving) return;
    // An unmounted Form has no state to validate, and there is nothing to save
    // either, so the null case simply ends here.
    final form = _form.currentState;
    if (form == null || !form.validate()) return;
    final item = _compose();
    if (item == null) return;
    // The save is a simulated second of work, so the button has to show it and
    // go inert while it runs (R17).
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    // If the form vanished during that second, popping now would throw.
    if (!mounted) return;
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
    autovalidateMode: _auto,
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
    autovalidateMode: _auto,
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
          autovalidateMode: _auto,
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
          autovalidateMode: _auto,
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
    autovalidateMode: _auto,
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
    autovalidateMode: _auto,
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
    autovalidateMode: _auto,
    validator: _validateNote,
    decoration: const InputDecoration(
      labelText: 'Note (optional)',
      alignLabelWithHint: true,
      border: OutlineInputBorder(),
    ),
  );

  Widget _saveButton() => FilledButton.icon(
    onPressed: _saving ? null : _save,
    icon: _saving
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.save_outlined),
    label: Text(_saving ? 'Saving…' : 'Save'),
  );

  Future<void> _askDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Nothing you typed here leaves the screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    // PopScope only refuses gestures and the arrow; Navigator.pop from inside
    // is the one way out while canPop is false, which is what an accepted
    // discard needs (R30). Save does the same thing with a result attached.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // One comparison decides every way out — the AppBar arrow, the Android
      // back gesture, the system back button — and Save, which pops straight
      // through it, never asks (R30).
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _askDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editing == null ? 'New screening' : 'Edit screening'),
        ),
        // One scrolling column, no Spacer: the keyboard shrinks the viewport and
        // the focused field scrolls itself into view (R37).
        body: Form(
          key: _form,
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
      ),
    );
  }
}
