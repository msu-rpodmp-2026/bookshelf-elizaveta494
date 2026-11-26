import 'dart:io';
import 'dart:convert';

import 'package:bookshelf_console/models/reading_status.dart';
import 'package:bookshelf_console/models/book.dart';
import 'package:bookshelf_console/models/paper_book.dart';
import 'package:bookshelf_console/models/ebook.dart';
import 'package:bookshelf_console/models/audiobook.dart';
import 'package:bookshelf_console/models/library.dart';
import 'package:bookshelf_console/models/library_event.dart';
import 'package:bookshelf_console/models/library_storage.dart';
import 'package:bookshelf_console/models/library_format_exception.dart';

// Исключение: поток ввода закрыт (EOF) — операцию надо отменить.
class InputClosedException implements Exception {}

// Безопасное чтение строки: null (EOF) превращается в исключение.
String readLineOrThrow() {
  final input = stdin.readLineSync(encoding: utf8);
  if (input == null) throw InputClosedException();
  return input;
}

// Надёжный ввод непустой строки
String readNonEmpty(String prompt, String fieldName) {
  while (true) {
    stdout.write(prompt);
    final input = readLineOrThrow().trim();
    if (input.isNotEmpty) return input;
    print(
      '$fieldName не может быть пустым. Введите ещё раз или нажмите Ctrl+Z для отмены.',
    );
  }
}

// Каталог книг
final Library<Book> library = Library<Book>();
final storage = LibraryStorage('data');

// Инициализация каталога из файла
Future<void> initLibrary() async {
  try {
    final books = await storage.load();
    if (books.isEmpty) {
      print('Файл каталога не найден — создан новый пустой каталог.');
      // Добавляем книги по умолчанию
      library.add(
        Book(
          title: 'Преступление и наказание',
          author: 'Фёдор Достоевский',
          year: 1866,
          pages: 672,
          genres: {'роман', 'классика'},
          status: ReadingStatus.finished,
          rating: 5.0,
        ),
      );
      library.add(
        Book(
          title: 'Война и мир',
          author: 'Лев Толстой',
          year: 1869,
          pages: 1225,
          genres: {'роман', 'классика'},
          status: ReadingStatus.finished,
          rating: 4.5,
        ),
      );
      library.add(
        Book(
          title: 'Мастер и Маргарита',
          author: 'Михаил Булгаков',
          year: 1967,
          pages: 480,
          genres: {'роман', 'фантастика'},
          status: ReadingStatus.reading,
        ),
      );
      library.add(
        Book(
          title: '1984',
          author: 'Джордж Оруэлл',
          year: 1949,
          pages: 320,
          genres: {'антиутопия'},
          status: ReadingStatus.finished,
        ),
      );
      library.add(
        Book(
          title: 'Гарри Поттер и философский камень',
          author: 'Джоан Роулинг',
          year: 1997,
          pages: 432,
          genres: {'фэнтези'},
          status: ReadingStatus.finished,
        ),
      );
      library.add(
        PaperBook(
          title: 'Дюна',
          author: 'Фрэнк Герберт',
          year: 1965,
          pages: 688,
          genres: {'фантастика'},
          status: ReadingStatus.planned,
          shelf: 'B3',
        ),
      );
      library.add(
        EBook(
          title: 'Марсианин',
          author: 'Энди Вейер',
          year: 2011,
          pages: 384,
          genres: {'фантастика'},
          status: ReadingStatus.finished,
          format: 'epub',
          sizeMb: 2.5,
        ),
      );
      library.add(
        AudioBook(
          title: 'Основы Dart',
          author: 'С. А. Чернышев',
          year: 2024,
          pages: 521,
          genres: {'учебник'},
          status: ReadingStatus.planned,
          duration: const Duration(hours: 10, minutes: 30),
          narrator: 'Иван Петров',
        ),
      );
      await storage.save(library.items);
      print('Каталог инициализирован с книгами по умолчанию.');
    } else {
      for (final book in books) {
        library.add(book);
      }
      print('Каталог загружен из файла. Книг: ${library.count}');
    }
  } on PathNotFoundException {
    print('Файл каталога не найден — создан новый пустой каталог.');
  } on FormatException catch (e) {
    print('Файл повреждён: ${e.message}');
  } on FileSystemException catch (e) {
    print('Ошибка файловой системы: ${e.message} код(${e.osError?.errorCode})');
    rethrow;
  } finally {
    print('Загрузка завершена.');
  }
}

// Сохранение каталога
Future<void> saveLibrary() async {
  try {
    await storage.save(library.items);
    print('Каталог сохранён. Записей: ${library.count}');
  } on FileSystemException catch (e) {
    print('Ошибка при сохранении: ${e.message}');
  }
}

// Вывод каталога
void printAll(Library<Book> lib, {String emptyMessage = 'Ничего не найдено.'}) {
  final books = lib.items;
  if (books.isEmpty) {
    print(emptyMessage);
    return;
  }
  for (int i = 0; i < books.length; i++) {
    final book = books[i];
    final mark = book.status == ReadingStatus.finished
        ? '[✓]'
        : book.status == ReadingStatus.reading
        ? '[~]'
        : '[ ]';
    print('${i + 1}. $mark ${book.describe()}');
  }
}

// Надёжный ввод числа
int askInt(String prompt, {int min = 0, int? max}) {
  int? value;
  do {
    stdout.write('$prompt: ');
    final input = readLineOrThrow();
    value = int.tryParse(input);
    if (value == null || value < min || (max != null && value > max)) {
      print('Некорректное значение.');
      if (max == null) {
        print('Ожидается целое число не меньше $min.');
      } else {
        print('Ожидается целое число от $min до $max.');
      }
      value = null;
    }
  } while (value == null);
  return value;
}

// Статистика
void printStatistics(Library<Book> lib) {
  final books = lib.items;
  if (books.isEmpty) {
    print('Каталог пуст.');
    return;
  }

  final total = books.length;
  final readCount = books
      .where((b) => b.status == ReadingStatus.finished)
      .length;
  final totalPages = books.fold<int>(0, (sum, book) => sum + book.pages);
  final avgPages = totalPages / total;

  final oldest = books.reduce((a, b) => a.year < b.year ? a : b);
  final newest = books.reduce((a, b) => a.year > b.year ? a : b);
  final largest = books.reduce((a, b) => a.pages > b.pages ? a : b);

  final genres = books.expand((b) => b.genres).toSet();
  final genreCount = lib.countByGenre();

  final readPercent = (readCount / total * 100).toStringAsFixed(1);

  print('');
  print('=== Статистика каталога ===');
  print('Всего книг: $total, прочитано: $readCount ($readPercent%)');
  print(
    'Суммарно страниц: $totalPages, в среднем: ${avgPages.toStringAsFixed(1)}',
  );
  print('Самая старая: ${oldest.title} (${oldest.year})');
  print('Самая новая: ${newest.title} (${newest.year})');
  print('Самая объёмная: ${largest.title} (${largest.pages} стр.)');
  print('Жанры: ${genres.join(', ')}');
  print('Книг по жанрам:');
  genreCount.forEach((genre, count) {
    print('  $genre: $count');
  });
}

// Демонстрация ООП
void demonstrateOOP() {
  print('');
  print('=== Демонстрация ООП ===');

  final book1 = Book(title: 'Тест', author: 'Автор', year: 2020);
  final book2 = Book(title: 'Тест', author: 'Автор', year: 2020);
  print('book1 == book2: ${book1 == book2}');
  print('hashCode book1: ${book1.hashCode}, book2: ${book2.hashCode}');

  final set = <Book>{book1, book2};
  print('Размер множества с двумя одинаковыми книгами: ${set.length}');

  final books = library.items.toList();
  books.sort();
  print('');
  print('Каталог после сортировки по названию:');
  for (final book in books) {
    print('  - ${book.title}');
  }

  final copy = book1.copyWith(year: 2021);
  print('');
  print('Оригинал: ${book1.year}, копия: ${copy.year}');

  book1.vote(4.0);
  book1.vote(5.0);
  print('Средняя оценка: ${book1.averageRating}');

  final paperBook = PaperBook(
    title: 'Тестовая книга',
    author: 'Тест',
    shelf: 'A1',
  );
  paperBook.borrow(14);
  print('Выдана: ${paperBook.isBorrowed}');
  paperBook.giveBack();
  print('После возврата: ${paperBook.isBorrowed}');

  print('');
  print('JSON: ${book1.toJson()}');

  final event = BookAdded(book1);
  final message = describeEvent(event);
  print('Событие: $message');
}

// Главное меню
void printMenu() {
  print('');
  print('=== BookShelf (ООП + Файлы) ===');
  print('1. Показать весь каталог');
  print('2. Поиск по названию/автору/жанру');
  print('3. Фильтр по статусу');
  print('4. Сортировка по названию');
  print('5. Статистика каталога');
  print('6. Добавить книгу');
  print('7. Удалить книгу');
  print('8. Демонстрация ООП');
  print('9. Экспорт в CSV');
  print('10. Импорт из CSV');
  print('11. Резервная копия');
  print('0. Выход');
}

Future<void> main() async {
  await initLibrary();
  var running = true;

  while (running) {
    try {
      printMenu();
      stdout.write('> ');
      final command = readLineOrThrow().trim();

      switch (command) {
        case '1':
          printAll(library);
          break;
        case '2':
          stdout.write('Введите запрос: ');
          final query = readLineOrThrow().trim();
          final results = library.search(query).toList();
          print('');
          print('Результаты поиска:');
          if (results.isEmpty) {
            print('Ничего не найдено.');
          } else {
            for (int i = 0; i < results.length; i++) {
              final book = results[i];
              print('${i + 1}. ${book.describe()}');
            }
          }
          break;
        case '3':
          print('Статусы: 1-Запланирована, 2-Читаю, 3-Прочитана, 4-Брошена');
          stdout.write('Выберите статус: ');
          final choice = readLineOrThrow().trim();
          final statusMap = {
            '1': ReadingStatus.planned,
            '2': ReadingStatus.reading,
            '3': ReadingStatus.finished,
            '4': ReadingStatus.abandoned,
          };
          final status = statusMap[choice];
          if (status == null) {
            print('Неверный выбор.');
          } else {
            final filtered = library.where((b) => b.status == status).toList();
            print('');
            print('Книги со статусом "${status.label}":');
            if (filtered.isEmpty) {
              print('  Ничего не найдено.');
            } else {
              for (final book in filtered) {
                print('  - ${book.describe()}');
              }
            }
          }
          break;
        case '4':
          final sorted = library.items.toList()..sort();
          print('');
          print('Отсортированный каталог:');
          for (final book in sorted) {
            print('  - ${book.title}');
          }
          break;
        case '5':
          printStatistics(library);
          break;
        case '6':
          final title = readNonEmpty('Название: ', 'Название');
          final author = readNonEmpty('Автор: ', 'Автор');
          final year = askInt('Год издания', min: 1000, max: 2026);
          final pages = askInt('Количество страниц', min: 1);
          stdout.write('Жанры (через запятую): ');
          final genresInput = readLineOrThrow().trim();
          final genres = genresInput
              .split(',')
              .map((g) => g.trim())
              .where((g) => g.isNotEmpty)
              .toSet();
          library.add(
            Book(
              title: title,
              author: author,
              year: year,
              pages: pages,
              genres: genres,
            ),
          );
          print('Книга добавлена.');
          await saveLibrary();
          break;
        case '7':
          printAll(library);
          if (library.count == 0) break;
          final number = askInt(
            'Введите номер книги для удаления',
            min: 1,
            max: library.count,
          );
          final book = library.items[number - 1];
          stdout.write('Удалить "${book.title}"? (да/нет): ');
          final confirm = readLineOrThrow().trim().toLowerCase();
          if (confirm == 'да' || confirm == 'д') {
            library.remove(book);
            print('Книга удалена.');
            await saveLibrary();
          } else {
            print('Удаление отменено.');
          }
          break;
        case '8':
          demonstrateOOP();
          break;
        case '9':
          await storage.exportCsv(library.items);
          print('Каталог экспортирован в ${storage.csvPath}');
          break;
        case '10':
          try {
            final importedBooks = await storage.importCsv();
            for (final book in importedBooks) {
              library.add(book);
            }
            print('Импортировано книг: ${importedBooks.length}');
            await saveLibrary();
          } on LibraryFormatException catch (e) {
            print(e);
          }
          break;
        case '11':
          final success = await storage.backup();
          if (success) {
            print('Резервная копия создана.');
          } else {
            print('Файл каталога не найден — резервная копия не создана.');
          }
          break;
        case '0':
          running = false;
          await saveLibrary();
          print('Работа завершена. Сохранено записей: ${library.count}');
          break;
        default:
          print('Неизвестная команда. Повторите ввод.');
      }
    } on InputClosedException {
      print('\nВвод закрыт. Текущая операция отменена. Завершение работы.');
      running = false;
    }
  }
}
