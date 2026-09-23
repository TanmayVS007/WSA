/// Base class for all application exceptions
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection unavailable', super.code]);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

class DeviceException extends AppException {
  const DeviceException(super.message, [super.code]);
}

class LocationException extends AppException {
  const LocationException(super.message, [super.code]);
}

class PermissionException extends AppException {
  const PermissionException(super.message, [super.code]);
}

class EmergencyStateException extends AppException {
  const EmergencyStateException(super.message, [super.code]);
}
