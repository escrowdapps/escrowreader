import 'package:test/test.dart';

import 'package:app/entities/book.dart';

void main() {
  test('Book', () async {
    Book book = Book('./assets/test.txt');
    await book.readLines();

    expect(await book.readLines(), hasLength(3));
    expect(book.length, 3);
  });
}
