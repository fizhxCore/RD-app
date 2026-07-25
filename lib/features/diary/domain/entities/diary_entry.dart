/// Representasi diary entry di domain layer.
/// `content` di sini SELALU plaintext (sudah didekripsi) — enkripsi
/// hanya terjadi di data layer, domain tidak perlu tahu soal itu.
class DiaryEntry {
  const DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String content;
  final String category;
  final String? mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    String? mood,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
