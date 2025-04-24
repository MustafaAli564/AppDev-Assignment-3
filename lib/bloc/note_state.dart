import '../model/note.dart';

class NoteState {
  final List<Note> notes;
  final String? filterType;

  NoteState({this.notes = const [], this.filterType});

  NoteState copyWith({List<Note>? notes, String? filterType}) {
    return NoteState(
      notes: notes ?? this.notes,
      filterType: filterType ?? this.filterType,
    );
  }

  List<Note> get filteredNotes {
    if (filterType == null || filterType!.isEmpty) return notes;
    return notes.where((note) => note.type == filterType).toList();
  }
}