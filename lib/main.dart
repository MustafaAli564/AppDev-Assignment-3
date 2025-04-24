import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'bloc/note_bloc.dart';
import 'bloc/note_event.dart';
import 'bloc/note_state.dart';
import 'model/note.dart';
import 'cards/noteCard.dart';

void main() {
  runApp(BlocProvider(create: (_) => NoteBloc(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NoteIt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const NoteHomePage(),
    );
  }
}

class NoteHomePage extends StatelessWidget {
  const NoteHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NoteIt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [_buildFilterDropdown(context)],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state.filteredNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    state.filterType == null
                        ? 'No notes yet!'
                        : 'No ${state.filterType} notes',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  if (state.filterType != null && state.notes.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        context.read<NoteBloc>().add(FilterNotes(null));
                      },
                      child: const Text('Clear filter'),
                    )
                  else
                    Text(
                      'Tap the + button to add a new note',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemCount: state.filteredNotes.length,
              itemBuilder: (_, index) {
                final note = state.filteredNotes[index];
                return GestureDetector(
                  onTap: () {
                    showNoteDetailBottomSheet(context, note);
                  },
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Itemcard(
                      title: note.title,
                      content: note.content,
                      type: note.type,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddNotePage(note: note),
                          ),
                        );
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Delete this note?'),
                                content: const Text('Are you sure?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<NoteBloc>().add(
                                        DeleteNote(note.id),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNotePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: state.filterType,
            hint: const Text('Filter'),
            icon: const Icon(Icons.arrow_drop_down),
            underline: Container(),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('All')),
              ...['Personal', 'Work', 'Study'].map((type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
            ],
            onChanged: (value) {
              context.read<NoteBloc>().add(FilterNotes(value));
            },
          ),
        );
      },
    );
  }
}

class AddNotePage extends StatefulWidget {
  final Note? note;
  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late String selectedType;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');
    selectedType = widget.note?.type ?? 'Personal';
  }

  void saveNote() {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    final note =
        widget.note?.copyWith(
          title: titleController.text,
          content: contentController.text,
          type: selectedType,
        ) ??
        Note(
          id: const Uuid().v4(),
          title: titleController.text,
          content: contentController.text,
          type: selectedType,
        );

    final event = widget.note == null ? AddNote(note) : UpdateNote(note);

    context.read<NoteBloc>().add(event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                expands: true,
                scrollPhysics: ClampingScrollPhysics(), 
                scrollPadding: EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                  items:
                      ['Personal', 'Work', 'Study']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveNote,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: _getCategoryColor(selectedType),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                widget.note == null ? 'Save Note' : 'Update Note',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showNoteDetailBottomSheet(BuildContext context, Note note) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(note.type),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      note.type,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(note.content, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    },
  );
}

Color _getCategoryColor(String type) {
  switch (type) {
    case 'Personal':
      return Colors.lightBlue.shade100;
    case 'Work':
      return Colors.yellow.shade100;
    case 'Study':
      return Colors.pink.shade100;
    default:
      return Colors.white;
  }
}
