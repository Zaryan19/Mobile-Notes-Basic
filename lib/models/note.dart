import 'package:hive/hive.dart';

/// Note model representing an entry in Hive database.
class Note {
  final String id;
  final String content;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.content,
    required this.updatedAt,
  });

  /// Derive title from the first non-empty line of content.
  String get title {
    if (content.trim().isEmpty) return 'UNTITLED NOTE';
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return 'UNTITLED NOTE';
  }

  /// Derive snippet from subsequent lines or content following the title.
  String get snippet {
    if (content.trim().isEmpty) return 'Empty note...';
    final lines = content.split('\n');
    bool foundTitle = false;
    final snippetLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (!foundTitle) {
        if (trimmed.isNotEmpty) {
          foundTitle = true;
        }
      } else {
        if (trimmed.isNotEmpty) {
          snippetLines.add(trimmed);
        }
      }
    }

    if (snippetLines.isEmpty) {
      // If there are no additional lines, return remainder of the title or hint
      return 'No additional content';
    }
    return snippetLines.join(' ');
  }

  /// Character count of the note content.
  int get charCount => content.length;

  /// Word count of the note content.
  int get wordCount {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// Formatted last modified date & time (e.g., "Nov 9, 2026, 14:27").
  static String formatTimestamp(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month $day, $year, $hour:$minute';
  }

  String get formattedUpdatedAt => formatTimestamp(updatedAt);

  Note copyWith({
    String? id,
    String? content,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Manual Hive TypeAdapter for Note model.
/// Guarantees zero code-gen dependencies, zero build_runner requirement,
/// and maximum reliability.
class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      id: fields[0] as String,
      content: fields[1] as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeByte(3);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.content);
    writer.writeByte(2);
    writer.write(obj.updatedAt.millisecondsSinceEpoch);
  }
}

