class BreakActivity {
  final String id;
  final String text;
  final String emoji;
  final String category;

  BreakActivity({
    required this.id,
    required this.text,
    required this.emoji,
    required this.category,
  });

  factory BreakActivity.fromJson(Map<String, dynamic> json) {
    return BreakActivity(
      id: json['id'] as String,
      text: json['text'] as String,
      emoji: json['emoji'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'emoji': emoji,
      'category': category,
    };
  }
}
