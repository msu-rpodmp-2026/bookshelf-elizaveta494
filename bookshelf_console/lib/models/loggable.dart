/// Миксин для логирования с отметкой времени.
mixin Loggable {
  /// Выводит сообщение с текущей датой и временем.
  void log(String message) {
    final now = DateTime.now();
    final formatted =
        '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}'
        ':${now.minute.toString().padLeft(2, '0')}';
    print('[$formatted] $message');
  }
}
