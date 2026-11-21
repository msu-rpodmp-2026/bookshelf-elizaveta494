import 'book.dart';

/// Аудиокнига.
class AudioBook extends Book {
  final Duration duration;
  final String narrator;

  AudioBook({
    required super.title,
    required super.author,
    super.year,
    super.pages,
    super.genres,
    super.status,
    super.rating,
    required this.duration,
    required this.narrator,
  });

  @override
  double get readingHours => duration.inMinutes / 60;

  @override
  String describe() =>
      '«$title» — аудиокнига, читает $narrator, ${duration.inMinutes} мин.';
}
