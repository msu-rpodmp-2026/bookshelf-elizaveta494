/// Интерфейс для экспорта элемента в JSON.
abstract interface class Exportable {
  /// Преобразует объект в словарь для сериализации.
  Map<String, dynamic> toJson();
}