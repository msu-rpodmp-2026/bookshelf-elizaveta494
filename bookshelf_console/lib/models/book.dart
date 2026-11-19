import 'library_item.dart';
import 'reading_status.dart';
import 'searchable.dart';
import 'exportable.dart';
import 'rateable.dart';
import 'loggable.dart';

/// Класс книги — центральный элемент модели BookShelf.
class Book extends LibraryItem
    with Rateable, Loggable
    implements Searchable, Exportable, Comparable<Book> {
  @override
  final String title;
  final String author;
  final int year;
  final int pages;
  final Set<String> genres;
  ReadingStatus status;
  double? _rating;

  /// Конструктор с именованными параметрами.
  /// title и author — обязательные, остальные — со значениями по умолчанию.
  Book({
    required this.title,
    required this.author,
    this.year = 2024,
    this.pages = 100,
    Set<String>? genres,
    this.status = ReadingStatus.planned,
    double? rating,
  }) : genres = genres ?? {} {
    if (rating != null) {
      this.rating = rating;
    }
  }

  /// Фабричный конструктор из JSON (задание повышенной сложности №4).
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      author: json['author'] as String,
      year: json['year'] as int? ?? 2024,
      pages: json['pages'] as int? ?? 100,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      status: ReadingStatus.fromName(json['status'] as String? ?? 'planned'),
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  // ===== Геттеры =====

  /// Краткое название (обрезка до 30 символов).
  String get shortTitle =>
      title.length > 30 ? '${title.substring(0, 27)}...' : title;

  /// Время чтения в часах (50 стр/час).
  double get readingHours => pages / 50;

  /// Возраст издания в годах.
  int get age => DateTime.now().year - year;

  /// Есть ли оценка.
  bool get isRated => _rating != null;

  double? get rating => _rating;

  /// Сеттер rating с проверкой диапазона 0–5.
  set rating(double? value) {
    if (value != null && (value < 0 || value > 5)) {
      throw ArgumentError('Оценка должна быть в диапазоне 0–5');
    }
    _rating = value;
  }

  // ===== Реализация интерфейсов =====

  @override
  bool matches(String query) {
    final lower = query.toLowerCase();
    if (title.toLowerCase().contains(lower)) return true;
    if (author.toLowerCase().contains(lower)) return true;
    return genres.any((g) => g.toLowerCase().contains(lower));
  }

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'author': author,
        'year': year,
        'pages': pages,
        'genres': genres.toList(),
        'status': status.name,
        'rating': _rating,
      };

  @override
  String describe() =>
      '«$title» — $author, $year г., $pages стр., ${genres.join(', ')}';

  // ===== Специальные методы (Задание 6) =====

  @override
  String toString() => 'Book($title, $author, $year)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          author == other.author &&
          year == other.year;

  @override
  int get hashCode => Object.hash(title, author, year);

  @override
  int compareTo(Book other) => title.compareTo(other.title);

  /// Копия книги с изменёнными полями.
  Book copyWith({
    String? title,
    String? author,
    int? year,
    int? pages,
    Set<String>? genres,
    ReadingStatus? status,
    double? rating,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      rating: rating ?? _rating,
    );
  }
}