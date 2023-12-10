class UtxoDTO {
  final String txid;
  final int vout;
  final int value;

  UtxoDTO({required this.txid, required this.vout, required this.value});

  static UtxoDTO fromJSON(Map<String, dynamic> parsedJSON) {
    return UtxoDTO(
        txid: parsedJSON['txid'].toString(),
        vout: parsedJSON['vout'],
        value: parsedJSON['value']);
  }

  @override
  String toString() {
    return '[UtxDTO]: {txId: $txid, vout: $vout, value: $value';
  }
}
