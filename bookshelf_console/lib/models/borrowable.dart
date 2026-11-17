import 'library_item.dart';
import 'loggable.dart';

/// Миксин для выдачи книги на срок.
mixin Borrowable on LibraryItem {
  DateTime? _dueDate;

  /// Выдана ли книга сейчас.
  bool get isBorrowed =>
      _dueDate != null && _dueDate!.isAfter(DateTime.now());

  /// Дата возврата (null если не выдана).
  DateTime? get dueDate => _dueDate;

  /// Выдать книгу на [days] дней.
  void borrow(int days) {
    _dueDate = DateTime.now().add(Duration(days: days));
    if (this is Loggable) {
      (this as Loggable).log(
          'Книга "$title" выдана на $days дней. Вернуть до: '
          '${_dueDate!.toIso8601String().split('T').first}');
    }
  }

  /// Вернуть книгу.
  void giveBack() {
    _dueDate = null;
    if (this is Loggable) {
      (this as Loggable).log('Книга "$title" возвращена.');
    }
  }
}