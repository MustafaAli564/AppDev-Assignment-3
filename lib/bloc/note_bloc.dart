import 'package:flutter_bloc/flutter_bloc.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(NoteState()) {
    on<AddNote>((event, emit) {
      final updatedNotes = [...state.notes, event.note];
      emit(state.copyWith(notes: updatedNotes));
    });

    on<DeleteNote>((event, emit) {
      final updatedNotes = state.notes.where((note) => note.id != event.id).toList();
      emit(state.copyWith(notes: updatedNotes));
    });

    on<UpdateNote>((event, emit) {
      final updatedNotes = state.notes.map((note) {
        return note.id == event.note.id ? event.note : note;
      }).toList();
      emit(state.copyWith(notes: updatedNotes));
    });

    on<FilterNotes>((event, emit) {
      emit(state.copyWith(filterType: event.type));
    });
  }
}
