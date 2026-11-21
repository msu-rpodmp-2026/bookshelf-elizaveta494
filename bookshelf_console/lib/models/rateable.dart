/// Миксин для накопления оценок.
mixin Rateable {
  double _totalRating = 0;
  int _voteCount = 0;

  /// Среднее значение оценок.
  double get averageRating => _voteCount == 0 ? 0.0 : _totalRating / _voteCount;

  /// Число голосов.
  int get voteCount => _voteCount;

  /// Добавить оценку (0–5).
  void vote(double rating) {
    if (rating < 0 || rating > 5) {
      throw ArgumentError('Оценка должна быть от 0 до 5');
    }
    _totalRating += rating;
    _voteCount++;
  }
}
