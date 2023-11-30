import 'package:test/test.dart';
import 'package:app/entities/bitcoin/bitcoin.dart';

void main() {
  test('getReplacedUri', () {
    expect(Bitcoin.getReplacedUri(walletId: 'test').toString(),
        equals('https://blockstream.info/api/address/test/utxo'));

    Uri testUri = Uri(scheme: 'https', host: 'google.com', path: 'wallet/test');

    expect(
        Bitcoin.getReplacedUri(customUrl: testUri, walletId: 'test-wallet')
            .toString(),
        equals('https://google.com/api/address/test-wallet/utxo'));

    expect(() => Bitcoin.getReplacedUri(customUrl: testUri),
        throwsFormatException);
  });
}
