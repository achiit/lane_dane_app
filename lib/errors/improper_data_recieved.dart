class ImproperDataRecieved implements Exception {
  final String message;
  final String missingData;
  final Object object;
  ImproperDataRecieved({
    this.message = '',
    required this.missingData,
    required this.object,
  });
}
