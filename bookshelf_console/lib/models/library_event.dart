import 'book.dart';

/// Запечатанный класс для событий библиотеки.
/// Наследники могут быть только внутри этого файла.
sealed class LibraryEvent {
  final Book book;
  const LibraryEvent(this.book);
}

/// Событие добавления книги.
class BookAdded extends LibraryEvent {
  const BookAdded(super.book);
}

/// Событие удаления книги.
class BookRemoved extends LibraryEvent {
  const BookRemoved(super.book);
}

/// Событие оценки книги.
class BookRated extends LibraryEvent {
  final double rating;
  const BookRated(super.book, this.rating);
}

/// Форматированное сообщение о событии (switch-выражение без default).
String describeEvent(LibraryEvent event) => switch (event) {
  BookAdded(:final book) => 'Добавлена книга: «${book.title}»',
  BookRemoved(:final book) => 'Удалена книга: «${book.title}»',
  BookRated(:final book, :final rating) =>
    'Книга «${book.title}» оценена на $rating',
};
