import '../model/note.dart';

abstract class NoteEvent {}

class AddNote extends NoteEvent {
  final Note note;

  AddNote(this.note);
}

class DeleteNote extends NoteEvent {
  final String id;

  DeleteNote(this.id);
}

class UpdateNote extends NoteEvent {
  final Note note;

  UpdateNote(this.note);
}

class FilterNotes extends NoteEvent {
  final String? type;

  FilterNotes(this.type);
}