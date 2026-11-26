/// Исключение при разборе некорректной строки CSV.
class LibraryFormatException implements Exception {
  final String message;
  final int line;

  LibraryFormatException(this.message, this.line);

  @override
  String toString() => 'Ошибка в строке $line: $message';
}
