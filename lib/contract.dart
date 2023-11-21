
import 'package:hive_flutter/hive_flutter.dart';


part 'contract.g.dart';


@HiveType(typeId: 2)
class Contract {
  @HiveField(0)
  String name;
  @HiveField(1)
  String id;
  @HiveField(2)
  int days;
  @HiveField(3)
  double scroll;
  @HiveField(4)
  List<dynamic> paragraphs;
  @HiveField(5)
  Map<dynamic, dynamic> walletMap;
  @HiveField(6)
  dynamic uri;

  Contract(this.id, this.name, this.days, this.paragraphs, this.walletMap,
      this.uri, this.scroll);

  @override
  String toString() =>
      'Contract(id: $id, name: $name, days: $days, paragraphs: $paragraphs,  uri: $uri, scroll: $scroll)';
}
