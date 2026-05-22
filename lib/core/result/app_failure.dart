enum AppFailureType {
  timeout,
  network,
  server,
  unauthorized,
  invalidData,
  unknown,
}

class AppFailure {
  final AppFailureType type;
  final String message;
  final int? statusCode;

  const AppFailure._({
    required this.type,
    required this.message,
    this.statusCode,
  });

  const AppFailure.timeout()
      : this._(
          type: AppFailureType.timeout,
          message: 'Ket noi qua cham. Hay thu lai.',
        );

  const AppFailure.network()
      : this._(
          type: AppFailureType.network,
          message: 'Khong co ket noi mang. Kiem tra internet va thu lai.',
        );

  const AppFailure.server([int? statusCode])
      : this._(
          type: AppFailureType.server,
          message: 'May chu dang gap loi. Hay thu lai sau.',
          statusCode: statusCode,
        );

  const AppFailure.unauthorized()
      : this._(
          type: AppFailureType.unauthorized,
          message: 'Phien dang nhap khong hop le.',
        );

  const AppFailure.invalidData()
      : this._(
          type: AppFailureType.invalidData,
          message: 'Du lieu quan ca phe khong hop le.',
        );

  const AppFailure.unknown()
      : this._(
          type: AppFailureType.unknown,
          message: 'Da co loi xay ra. Hay thu lai.',
        );

  String get userMessage => message;
}
