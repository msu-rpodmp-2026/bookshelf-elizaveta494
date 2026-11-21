/// Абстрактный класс — базовый для всех элементов библиотеки.
abstract class LibraryItem {
  /// Название элемента (абстрактный геттер).
  String get title;

  /// Краткое описание элемента (абстрактный метод).
  String describe();

  /// Вывод карточки элемента.
  void printCard() {
    print('=== $title ===');
    print(describe());
  }
}
