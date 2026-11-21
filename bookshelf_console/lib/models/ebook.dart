import 'book.dart';

/// Электронная книга.
class EBook extends Book {
  final String format;
  final double sizeMb;

  EBook({
    required super.title,
    required super.author,
    super.year,
    super.pages,
    super.genres,
    super.status,
    super.rating,
    this.format = 'epub',
    this.sizeMb = 1.0,
  });

  @override
  String describe() =>
      '«$title» — электронная книга, формат $format, $sizeMb МБ';
}
