class InvalidInputError implements Exception {
  String message;
  String input;
  InvalidInputError({
    required this.message,
    required this.input,
  });
}
