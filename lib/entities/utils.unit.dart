import 'package:app/entities/utils.dart';
import 'package:test/test.dart';

void main() {
  test('Utils.timestampToDate', () {
    String datetime = Utils.timestampToDate(1700592163411);

    expect(datetime, equals('21.11.23 22:42:43'));
  });

  test('Utils.getDateFromTimestamp', () {
    int timestamp = 1700594826584;

    expect(Utils.getDateFromTimestamp(timestamp, 'dd.MM.yy HH:mm:ss'),
        equals('21.11.23 23:27:06'));
    expect(Utils.getDateFromTimestamp(timestamp, 'dd'), equals('21'));
    expect(Utils.getDateFromTimestamp(timestamp, 'MM'), equals('11'));
    expect(Utils.getDateFromTimestamp(timestamp, 'yyyy'), equals('2023'));
  });
}
