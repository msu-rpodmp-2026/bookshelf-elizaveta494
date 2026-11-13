import 'dart:io';
import 'dart:convert';

// Функция для чтения строки с клавиатуры в кодировке UTF-8
String? readLine() => stdin.readLineSync(encoding: utf8);

// Задание 1: Тип для книги и каталог
typedef Book = Map<String, Object?>;

final List<Book> library = [
  {
    'title': 'Преступление и наказание',
    'author': 'Фёдор Достоевский',
    'year': 1866,
    'pages': 672,
    'genre': 'роман',
    'read': true,
  },
  {
    'title': 'Война и мир',
    'author': 'Лев Толстой',
    'year': 1869,
    'pages': 1225,
    'genre': 'роман',
    'read': true,
  },
  {
    'title': 'Мастер и Маргарита',
    'author': 'Михаил Булгаков',
    'year': 1967,
    'pages': 480,
    'genre': 'роман',
    'read': false,
  },
  {
    'title': '1984',
    'author': 'Джордж Оруэлл',
    'year': 1949,
    'pages': 320,
    'genre': 'антиутопия',
    'read': true,
  },
  {
    'title': 'Гарри Поттер и философский камень',
    'author': 'Джоан Роулинг',
    'year': 1997,
    'pages': 432,
    'genre': 'фэнтези',
    'read': true,
  },
  {
    'title': 'Дюна',
    'author': 'Фрэнк Герберт',
    'year': 1965,
    'pages': 688,
    'genre': 'фантастика',
    'read': false,
  },
  {
    'title': 'Марсианин',
    'author': 'Энди Вейер',
    'year': 2011,
    'pages': 384,
    'genre': 'фантастика',
    'read': true,
  },
  {
    'title': 'Основы Dart',
    'author': 'С. А. Чернышев',
    'year': 2024,
    'pages': 521,
    'genre': 'учебник',
    'read': false,
  },
];

// Задание 3: Функции вывода и поиска

// Вывод каталога с нумерацией и отметкой о прочтении
void printAll(List<Book> books, {String emptyMessage = 'Ничего не найдено.'}) {
  if (books.isEmpty) {
    print(emptyMessage);
    return;
  }
  for (int i = 0; i < books.length; i++) {
    final book = books[i];
    final readMark = book['read'] == true ? '[✓]' : '[ ]';
    final title = book['title'];
    final author = book['author'];
    final year = book['year'];
    final pages = book['pages'];
    final genre = book['genre'];
    print('${i + 1}. $readMark $title — $author ($year, $pages стр., $genre)');
  }
}

// Поиск по подстроке в указанном поле, без учёта регистра
List<Book> searchByField(List<Book> books, String field, String query) {
  return books.where((book) {
    final value = book[field]?.toString().toLowerCase() ?? '';
    return value.contains(query.toLowerCase());
  }).toList();
}

// Фильтрация по признаку прочтения
List<Book> filterByRead(List<Book> books, bool isRead) {
  return books.where((book) => book['read'] == isRead).toList();
}

// Сортировка; направление задаётся именованным параметром
// Функция не изменяет исходный список
List<Book> sortBy(List<Book> books, String field, {bool descending = false}) {
  final copy = [...books];
  copy.sort((a, b) {
    final aVal = a[field];
    final bVal = b[field];
    int comparison;
    if (aVal is Comparable && bVal is Comparable) {
      comparison = aVal.compareTo(bVal);
    } else {
      comparison = aVal.toString().compareTo(bVal.toString());
    }
    return descending ? -comparison : comparison;
  });
  return copy;
}

// Задание 4: Статистика с методами Iterable
void printStatistics(List<Book> books) {
  if (books.isEmpty) {
    print('Каталог пуст.');
    return;
  }

  final total = books.length;
  final readCount = books.where((b) => b['read'] == true).length;
  final totalPages = books.fold<int>(
    0,
    (sum, book) => sum + (book['pages'] as int),
  );
  final avgPages = totalPages / total;

  final oldest = books.reduce(
    (a, b) => (a['year'] as int) < (b['year'] as int) ? a : b,
  );
  final newest = books.reduce(
    (a, b) => (a['year'] as int) > (b['year'] as int) ? a : b,
  );
  final largest = books.reduce(
    (a, b) => (a['pages'] as int) > (b['pages'] as int) ? a : b,
  );

  final genres = books.map((b) => b['genre'] as String).toSet();
  final genreCount = <String, int>{};
  for (final book in books) {
    final genre = book['genre'] as String;
    genreCount[genre] = (genreCount[genre] ?? 0) + 1;
  }

  final readPercent = (readCount / total * 100).toStringAsFixed(1);

  print('');
  print('=== Статистика каталога ===');
  print('Всего книг: $total, прочитано: $readCount ($readPercent%)');
  print(
    'Суммарно страниц: $totalPages, в среднем: ${avgPages.toStringAsFixed(1)}',
  );
  print('Самая старая: ${oldest['title']} (${oldest['year']})');
  print('Самая новая: ${newest['title']} (${newest['year']})');
  print('Самая объёмная: ${largest['title']} (${largest['pages']} стр.)');
  print('Жанры: ${genres.join(', ')}');
  print('Книг по жанрам:');
  genreCount.forEach((genre, count) {
    print('  $genre: $count');
  });
}

// Задание 5: Надёжный ввод числа
int askInt(String prompt, {int min = 0, int? max}) {
  int? value;
  do {
    stdout.write('$prompt: ');
    value = int.tryParse(readLine() ?? '');
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

// Добавление книги
void addBook() {
  print('');
  print('=== Добавление книги ===');
  stdout.write('Название: ');
  final title = readLine()?.trim() ?? '';
  stdout.write('Автор: ');
  final author = readLine()?.trim() ?? '';
  final year = askInt('Год издания', min: 1000, max: 2026);
  final pages = askInt('Количество страниц', min: 1);
  stdout.write('Жанр: ');
  final genre = readLine()?.trim() ?? '';
  stdout.write('Прочитана (да/нет): ');
  final readInput = readLine()?.trim().toLowerCase() ?? '';
  final isRead =
      readInput == 'да' ||
      readInput == 'д' ||
      readInput == 'yes' ||
      readInput == 'y';

  library.add({
    'title': title,
    'author': author,
    'year': year,
    'pages': pages,
    'genre': genre,
    'read': isRead,
  });
  print('Книга добавлена.');
}

// Удаление книги по номеру
void removeBook() {
  print('');
  print('=== Удаление книги ===');
  printAll(library);
  if (library.isEmpty) return;

  final number = askInt(
    'Введите номер книги для удаления',
    min: 1,
    max: library.length,
  );
  final book = library[number - 1];
  stdout.write('Удалить "${book['title']}"? (да/нет): ');
  final confirm = readLine()?.trim().toLowerCase() ?? '';
  if (confirm == 'да' || confirm == 'д' || confirm == 'yes' || confirm == 'y') {
    library.removeAt(number - 1);
    print('Книга удалена.');
  } else {
    print('Удаление отменено.');
  }
}

// Задание 6: Функции высшего порядка

typedef BookPredicate = bool Function(Book book);

List<Book> filter(List<Book> books, BookPredicate test) {
  return books.where(test).toList();
}

// Замыкание-счётчик
Function makeCounter() {
  int count = 0;
  return () {
    count++;
    return count;
  };
}

// Демонстрация функций высшего порядка
void demonstrateHigherOrderFunctions() {
  print('');
  print('=== Демонстрация функций высшего порядка ===');

  // 1. Толстые книги (более 500 страниц)
  final thickBooks = filter(library, (book) => (book['pages'] as int) > 500);
  print('');
  print('Толстые книги (более 500 страниц):');
  printAll(thickBooks, emptyMessage: 'Не найдено.');

  // 2. Книги нового века (после 2000 года)
  final modernBooks = filter(library, (book) => (book['year'] as int) > 2000);
  print('');
  print('Книги нового века (после 2000 года):');
  printAll(modernBooks, emptyMessage: 'Не найдено.');

  // 3. Непрочитанные книги выбранного жанра
  stdout.write('');
  stdout.write('Введите жанр для поиска непрочитанных книг: ');
  final genre = readLine()?.trim().toLowerCase() ?? '';
  final unreadByGenre = filter(
    library,
    (book) =>
        (book['genre'] as String).toLowerCase() == genre &&
        book['read'] == false,
  );
  print('');
  print('Непрочитанные книги жанра "$genre":');
  printAll(unreadByGenre, emptyMessage: 'Не найдено.');
}

// Главное меню
void printMenu() {
  print('');
  print('=== BookShelf ===');
  print('1. Показать весь каталог');
  print('2. Поиск по автору');
  print('3. Поиск по названию');
  print('4. Фильтр по жанру');
  print('5. Фильтр по признаку "прочитана"');
  print('6. Сортировка');
  print('7. Статистика каталога');
  print('8. Добавить книгу');
  print('9. Удалить книгу');
  print('10. Демонстрация функций высшего порядка');
  print('0. Выход');
}

void main() {
  final commandCounter = makeCounter();
  var running = true;

  while (running) {
    printMenu();
    stdout.write('> ');
    final command = readLine()?.trim();

    switch (command) {
      case '1':
        printAll(library);
        commandCounter();
        break;
      case '2':
        stdout.write('Введите имя автора: ');
        final query = readLine()?.trim() ?? '';
        final results = searchByField(library, 'author', query);
        print('');
        print('Результаты поиска:');
        printAll(results, emptyMessage: 'Книги не найдены.');
        commandCounter();
        break;
      case '3':
        stdout.write('Введите название: ');
        final query = readLine()?.trim() ?? '';
        final results = searchByField(library, 'title', query);
        print('');
        print('Результаты поиска:');
        printAll(results, emptyMessage: 'Книги не найдены.');
        commandCounter();
        break;
      case '4':
        stdout.write('Введите жанр: ');
        final genre = readLine()?.trim().toLowerCase() ?? '';
        final results = library
            .where((b) => (b['genre'] as String).toLowerCase() == genre)
            .toList();
        print('');
        print('Книги жанра "$genre":');
        printAll(results, emptyMessage: 'Книги не найдены.');
        commandCounter();
        break;
      case '5':
        stdout.write('Показать прочитанные (да) или непрочитанные (нет)? ');
        final input = readLine()?.trim().toLowerCase() ?? '';
        final isRead = input == 'да' || input == 'д';
        final results = filterByRead(library, isRead);
        print('');
        if (isRead) {
          print('Прочитанные книги:');
        } else {
          print('Непрочитанные книги:');
        }
        printAll(results, emptyMessage: 'Книги не найдены.');
        commandCounter();
        break;
      case '6':
        print('Сортировка по:');
        print('1 - название');
        print('2 - автор');
        print('3 - год');
        print('4 - объём');
        stdout.write('Выберите поле: ');
        final fieldChoice = readLine()?.trim();
        final fieldMap = {
          '1': 'title',
          '2': 'author',
          '3': 'year',
          '4': 'pages',
        };
        final field = fieldMap[fieldChoice] ?? 'title';
        stdout.write('По убыванию? (да/нет): ');
        final descInput = readLine()?.trim().toLowerCase() ?? '';
        final descending = descInput == 'да' || descInput == 'д';
        final sorted = sortBy(library, field, descending: descending);
        print('');
        print('Отсортированный каталог:');
        printAll(sorted);
        commandCounter();
        break;
      case '7':
        printStatistics(library);
        commandCounter();
        break;
      case '8':
        addBook();
        commandCounter();
        break;
      case '9':
        removeBook();
        commandCounter();
        break;
      case '10':
        demonstrateHigherOrderFunctions();
        commandCounter();
        break;
      case '0':
        running = false;
        final count = commandCounter();
        print('Работа завершена. Выполнено команд: $count');
        break;
      default:
        print('Неизвестная команда. Повторите ввод.');
    }
  }
}
