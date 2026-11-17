import 'book.dart';
import 'borrowable.dart';
import 'loggable.dart';

/// Печатная книга — с местом на полке и возможностью выдачи.
class PaperBook extends Book with Borrowable, Loggable {
  final String shelf;

  PaperBook({
    required super.title,
    required super.author,
    super.year,
    super.pages,
    super.genres,
    super.status,
    super.rating,
    this.shelf = 'A1',
  });

  @override
  String describe() =>
      '«$title» — печатная книга, полка $shelf, '
      '$author, $year г., $pages стр.';
}