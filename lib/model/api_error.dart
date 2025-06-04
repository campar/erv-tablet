class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic> details;
  final String localizationKey;

  ApiError({
    required this.code,
    required this.message,
    required this.details,
    required this.localizationKey,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'],
      details: Map<String, dynamic>.from(json['details']),
      localizationKey: json['localizationKey'],
    );
  }
}