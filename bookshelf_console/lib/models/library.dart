import 'library_item.dart';
import 'searchable.dart';
import 'book.dart';

/// Обобщённый класс библиотеки (одиночка).
class Library<T extends LibraryItem> {
  /// Приватное статическое поле для хранения единственного экземпляра.
  static Library<Book>? _instance;

  /// Фабричный конструктор — возвращает единственный экземпляр.
  factory Library() {
    _instance ??= Library._internal();
    return _instance as Library<T>;
  }

  /// Приватный именованный конструктор.
  Library._internal();

  final List<T> _items = [];

  /// Неизменяемое представление списка.
  List<T> get items => List.unmodifiable(_items);

  /// Количество элементов.
  int get count => _items.length;

  /// Добавить элемент (с защитой от дубликатов).
  void add(T item) {
    if (!_items.contains(item)) {
      _items.add(item);
    }
  }

  /// Удалить элемент.
  bool remove(T item) => _items.remove(item);

  /// Найти по точному совпадению названия (без учёта регистра).
  T? findByTitle(String title) {
    for (final item in _items) {
      if (item.title.toLowerCase() == title.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  /// Поиск по подстроке.
  Iterable<T> search(String query) {
    return _items.where((item) {
      if (item is Searchable) {
        final searchable = item as Searchable;
        return searchable.matches(query);
      }
      return item.title.toLowerCase().contains(query.toLowerCase());
    });
  }

  /// Фильтрация по предикату.
  Iterable<T> where(bool Function(T) test) => _items.where(test);

  /// Подсчёт книг по жанрам (работает только для Book).
  Map<String, int> countByGenre() {
    final result = <String, int>{};
    for (final item in _items) {
      if (item is Book) {
        for (final genre in item.genres) {
          result[genre] = (result[genre] ?? 0) + 1;
        }
      }
    }
    return result;
  }

  /// Оператор + для объединения двух библиотек (пункт 3 повышенной сложности).
  Library<T> operator +(Library<T> other) {
    final merged = Library<T>();
    for (final item in _items) {
      merged.add(item);
    }
    for (final item in other._items) {
      merged.add(item);
    }
    return merged;
  }

  /// Очистка (для тестов).
  void clear() => _items.clear();
}
