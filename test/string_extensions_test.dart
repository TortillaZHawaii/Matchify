import 'package:flutter_test/flutter_test.dart';
import 'package:matchify/features/utils/string_extensions.dart';

void main() {
  group(
    'String extensions',
    () {
      test('capitilize doesn\'t change empty string', () {
        const string = '';
        expect(string.capitalize(), '');
      });

      test('capitilize changes first letter to uppercase', () {
        const string = 'abc def';
        expect(string.capitalize(), 'Abc def');
      });

      test('capitilize changes every letter to lowercase apart from first', () {
        const string = 'ABC DEF';
        expect(string.capitalize(), 'Abc def');
      });

      test('capitalize doesn\'t change digits', () {
        const string = '123';
        expect(string.capitalize(), '123');
      });
    },
  );
}
