import 'dart:io';

///
/// Класс книги
/// реализует базовые операции с книгой
/// чтение
/// добавление чекпоинтов и тд
///
class Book {
  final String path;

  late File file;

  List<String>? _lines;
  int? length;

  Book(this.path) {
    file = File(path);
  }

  /// читает все строки из книги,
  /// если уже хоть раз прочтены,
  /// возвращает их
  Future<List<String>> readLines() async {
    if (_lines != null) {
      return _lines as List<String>;
    }

    _lines = await file.readAsLines();
    length = _lines?.length;

    return _lines as List<String>;
  }
}
