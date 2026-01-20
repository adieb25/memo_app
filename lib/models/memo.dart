class Memo {
  final int? id;
  final String title;
  final String content;
  final bool isPinned;
  final bool isLocked;

  Memo({
    this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.isLocked = false,
  });

  // Konversi dari Object ke Map (untuk Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isPinned': isPinned ? 1 : 0, // SQLite pakai 1/0 bukan true/false
      'isLocked': isLocked ? 1 : 0,
    };
  }

  // Konversi dari Map (Database) ke Object
  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isPinned: map['isPinned'] == 1,
      isLocked: map['isLocked'] == 1,
    );
  }

  // Helper untuk menduplikasi objek (fitur edit/copy)
  Memo copy({
    int? id,
    String? title,
    String? content,
    bool? isPinned,
    bool? isLocked,
  }) {
    return Memo(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}