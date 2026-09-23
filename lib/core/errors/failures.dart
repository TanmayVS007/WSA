/// Clean domain failure models for functional error handling
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again later.', super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

class DeviceFailure extends Failure {
  const DeviceFailure(super.message, [super.code]);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message, [super.code]);
}

class EmergencyFailure extends Failure {
  const EmergencyFailure(super.message, [super.code]);
}
