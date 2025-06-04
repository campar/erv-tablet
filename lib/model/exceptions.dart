class ServiceUnavailableException implements Exception {
  final String message;

  const ServiceUnavailableException(this.message);

  @override
  String toString() => message;
}

class ServiceClientError implements Exception {
  final String message;

  const ServiceClientError(this.message);

  @override
  String toString() => message;
}

class ServiceUserError implements Exception {
  final String message;

  const ServiceUserError(this.message);

  @override
  String toString() => message;
}

class ServiceServerError implements Exception {
  final String message;

  const ServiceServerError(this.message);

  @override
  String toString() => message;
}

class ServiceUnexpectedResponseError implements Exception {
  final String message;

  const ServiceUnexpectedResponseError(this.message);

  @override
  String toString() => message;
}