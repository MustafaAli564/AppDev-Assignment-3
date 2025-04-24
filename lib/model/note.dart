class Note {
  final String id;
  final String title;
  final String content;
  final String type;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
  });

  Note copyWith({String? title, String? content, String? type}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
    );
  }
}
