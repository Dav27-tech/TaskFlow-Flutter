abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur est survenue. Veuillez réessayer.', super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'User is not authenticated.', super.code]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied for this operation.', super.code]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'L’élément demandé est introuvable.', super.code]);
}

class ExportFailure extends Failure {
  const ExportFailure([super.message = 'Unable to export project JSON.', super.code]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'La validation a échoué.', super.code]);
}
