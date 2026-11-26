import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

import 'book.dart';
import 'reading_status.dart';
import 'library_format_exception.dart';

/// Класс, инкапсулирующий всю работу с файлами каталога.
class LibraryStorage {
  final String directory;

  const LibraryStorage(this.directory);

  String get jsonPath => p.join(directory, 'library.json');
  String get csvPath => p.join(directory, 'library.csv');

  /// Чтение каталога из JSON-файла.
  Future<List<Book>> load() async {
    final file = File(jsonPath);
    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
      return jsonList
          .map((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      final backupFile = File('$jsonPath.bak');
      await file.rename(backupFile.path);
      stderr.writeln('Файл повреждён: ${e.message}');
      stderr.writeln('Повреждённый файл переименован в ${backupFile.path}');
      return [];
    }
  }

  /// Запись каталога в JSON-файл с отступами.
  Future<void> save(List<Book> books) async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final jsonList = books.map((b) => b.toJson()).toList();
    final content = const JsonEncoder.withIndent('  ').convert(jsonList);

    final tempFile = File('$jsonPath.tmp');
    await tempFile.writeAsString(content);
    await tempFile.rename(jsonPath);
  }

  /// Экспорт каталога в CSV.
  Future<void> exportCsv(List<Book> books) async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final buffer = StringBuffer();
    buffer.writeln('title;author;year;pages;genres;status;rating');

    for (final book in books) {
      final title = book.title.contains(';') ? '"${book.title}"' : book.title;
      final author = book.author.contains(';')
          ? '"${book.author}"'
          : book.author;
      final genres = book.genres.join(',');
      final rating = book.rating?.toString() ?? '';

      buffer.writeln(
        '$title;$author;${book.year};${book.pages};$genres;${book.status.name};$rating',
      );
    }

    final file = File(csvPath);
    await file.writeAsString(buffer.toString());
  }

  /// Импорт каталога из CSV.
  Future<List<Book>> importCsv() async {
    final file = File(csvPath);
    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final books = <Book>[];
    var skipped = 0;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = line.split(';');
      if (fields.length != 7) {
        skipped++;
        continue;
      }

      try {
        final title = fields[0].replaceAll('"', '');
        final author = fields[1].replaceAll('"', '');
        final year = int.tryParse(fields[2]) ?? 0;
        final pages = int.tryParse(fields[3]) ?? 0;
        final genres = fields[4].split(',').where((g) => g.isNotEmpty).toSet();
        final status = ReadingStatus.fromName(fields[5]);
        final rating = double.tryParse(fields[6]);

        books.add(
          Book(
            title: title,
            author: author,
            year: year,
            pages: pages,
            genres: genres,
            status: status,
            rating: rating,
          ),
        );
      } catch (e) {
        throw LibraryFormatException('Не удалось разобрать строку: $e', i + 1);
      }
    }

    if (skipped > 0) {
      print('Пропущено строк при импорте: $skipped');
    }

    return books;
  }

  /// Создание резервной копии с меткой времени.
  Future<bool> backup() async {
    final file = File(jsonPath);
    if (!await file.exists()) {
      return false;
    }

    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final backupFile = File(p.join(directory, 'library_$timestamp.json'));

    await file.copy(backupFile.path);
    return true;
  }
}
