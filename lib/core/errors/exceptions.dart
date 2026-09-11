class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Une erreur serveur est survenue. Veuillez réessayer.', super.code]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentification requise. Veuillez vous connecter.', super.code]);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([super.message = 'Vous n\'êtes pas autorisé à effectuer cette action.', super.code]);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'La ressource demandée est introuvable.', super.code]);
}

class ExportException extends AppException {
  const ExportException([super.message = 'Impossible d\'exporter les données du projet au format JSON.', super.code]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Les données fournies sont invalides.', super.code]);
}
