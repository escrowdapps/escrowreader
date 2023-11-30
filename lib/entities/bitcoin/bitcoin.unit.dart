import 'package:app/DTOs/Response/UTXO.dart';
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
        equals('https://google.com/test-wallet/test'));

    expect(() => Bitcoin.getReplacedUri(customUrl: testUri),
        throwsFormatException);
  });

  test('return error with wrong bitcoin address', () async {
    expect(() async => await Bitcoin.getTransactions(walletId: 'test'),
        throwsFormatException);
  });

  test('return transactions data type objects if address is correct', () async {
    Uri correctURL =
        Uri.parse('https://blockstream.info/testnet/api/address/wallet/utxo');

    List<UtxoDTO> utxList = await Bitcoin.getTransactions(
        walletId:
            'tb1pgt48ls8l645ewngskqphcnad5y994dxkktll7p24eaqhcv7upjnqgx6exp',
        customUrl: correctURL);

    expect(utxList, isNotEmpty);
  });
}
