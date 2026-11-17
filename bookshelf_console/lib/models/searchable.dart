/// Интерфейс для поиска по элементу библиотеки.
abstract interface class Searchable {
  /// Проверяет, содержит ли элемент подстроку [query] (без учёта регистра).
  bool matches(String query);
}