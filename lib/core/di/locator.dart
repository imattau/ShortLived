class Locator {
  Locator._();
  static final Locator I = Locator._();

  final Map<Type, dynamic> _store = {};

  void put<T>(T value) => _store[T] = value;
  T get<T>() => _store[T] as T;
}

