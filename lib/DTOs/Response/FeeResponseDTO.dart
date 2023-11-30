class FeeResponseDTO {
  final int fee;

  FeeResponseDTO({required this.fee});

  factory FeeResponseDTO.fromJSON(Map<String, dynamic> parsedJSON) {
    // TODO: divide by 1000
    return FeeResponseDTO(fee: (parsedJSON['low_fee_per_kb'] / 1024).ceil());
  }
}
