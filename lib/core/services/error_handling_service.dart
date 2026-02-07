import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'analytics_service.dart';

/// Types d'erreurs de l'application
enum ErrorType {
  network,
  server,
  authentication,
  validation,
  notFound,
  permission,
  timeout,
  unknown,
}

/// Classe représentant une erreur de l'application
class AppError implements Exception {
  final String message;
  final String? userMessage;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final String? errorCode;
  final Map<String, dynamic>? context;

  const AppError({
    required this.message,
    this.userMessage,
    required this.type,
    this.originalError,
    this.stackTrace,
    this.errorCode,
    this.context,
  });

  /// Message à afficher à l'utilisateur
  String get displayMessage => userMessage ?? _getDefaultMessage();

  String _getDefaultMessage() {
    switch (type) {
      case ErrorType.network:
        return 'Problème de connexion. Vérifiez votre connexion internet.';
      case ErrorType.server:
        return 'Une erreur serveur s\'est produite. Veuillez réessayer.';
      case ErrorType.authentication:
        return 'Session expirée. Veuillez vous reconnecter.';
      case ErrorType.validation:
        return 'Les données saisies sont invalides.';
      case ErrorType.notFound:
        return 'La ressource demandée n\'existe pas.';
      case ErrorType.permission:
        return 'Vous n\'avez pas les permissions nécessaires.';
      case ErrorType.timeout:
        return 'La requête a pris trop de temps. Veuillez réessayer.';
      case ErrorType.unknown:
        return 'Une erreur inattendue s\'est produite.';
    }
  }

  /// Vérifie si l'erreur peut être réessayée
  bool get canRetry {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.server:
        return true;
      default:
        return false;
    }
  }

  @override
  String toString() => 'AppError[$type]: $message';
}

/// Service central de gestion des erreurs
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final _errorStreamController = StreamController<AppError>.broadcast();
  Stream<AppError> get errorStream => _errorStreamController.stream;

  /// Convertit une exception en AppError
  AppError handleException(dynamic error, [StackTrace? stackTrace]) {
    AppError appError;

    if (error is AppError) {
      appError = error;
    } else if (error is DioException) {
      appError = _handleDioError(error, stackTrace);
    } else if (error is SocketException) {
      appError = AppError(
        message: error.message,
        type: ErrorType.network,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is TimeoutException) {
      appError = AppError(
        message: error.message ?? 'Request timeout',
        type: ErrorType.timeout,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else if (error is FormatException) {
      appError = AppError(
        message: error.message,
        type: ErrorType.validation,
        originalError: error,
        stackTrace: stackTrace,
      );
    } else {
      appError = AppError(
        message: error.toString(),
        type: ErrorType.unknown,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Log l'erreur
    _logError(appError);

    // Envoie l'erreur dans le stream
    _errorStreamController.add(appError);

    return appError;
  }

  /// Gère les erreurs Dio (HTTP)
  AppError _handleDioError(DioException error, StackTrace? stackTrace) {
    ErrorType type;
    String message = error.message ?? 'HTTP Error';
    String? userMessage;
    String? errorCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        type = ErrorType.timeout;
        break;

      case DioExceptionType.connectionError:
        type = ErrorType.network;
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Essaie d'extraire le message d'erreur du serveur
        if (responseData is Map<String, dynamic>) {
          userMessage = responseData['message'] as String?;
          errorCode = responseData['error_code'] as String?;
        }

        switch (statusCode) {
          case 400:
            type = ErrorType.validation;
            break;
          case 401:
            type = ErrorType.authentication;
            userMessage = 'Session expirée. Veuillez vous reconnecter.';
            break;
          case 403:
            type = ErrorType.permission;
            break;
          case 404:
            type = ErrorType.notFound;
            break;
          case 422:
            type = ErrorType.validation;
            // Extrait les erreurs de validation Laravel
            if (responseData is Map<String, dynamic>) {
              final errors = responseData['errors'] as Map<String, dynamic>?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  userMessage = firstError.first.toString();
                }
              }
            }
            break;
          case 429:
            type = ErrorType.server;
            userMessage = 'Trop de requêtes. Veuillez patienter un moment.';
            break;
          case 500:
          case 502:
          case 503:
          case 504:
            type = ErrorType.server;
            break;
          default:
            type = ErrorType.unknown;
        }
        message = 'HTTP $statusCode: ${error.response?.statusMessage}';
        break;

      case DioExceptionType.cancel:
        type = ErrorType.unknown;
        message = 'Request cancelled';
        break;

      case DioExceptionType.badCertificate:
        type = ErrorType.network;
        userMessage = 'Certificat de sécurité invalide.';
        break;

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          type = ErrorType.network;
        } else {
          type = ErrorType.unknown;
        }
    }

    return AppError(
      message: message,
      userMessage: userMessage,
      type: type,
      originalError: error,
      stackTrace: stackTrace,
      errorCode: errorCode,
      context: {
        'url': error.requestOptions.uri.toString(),
        'method': error.requestOptions.method,
        'statusCode': error.response?.statusCode,
      },
    );
  }

  /// Log l'erreur pour debugging et analytics
  void _logError(AppError error) {
    // Log en console (debug)
    debugPrint('═══════════════════════════════════════');
    debugPrint('ERROR: ${error.type}');
    debugPrint('Message: ${error.message}');
    if (error.context != null) {
      debugPrint('Context: ${error.context}');
    }
    if (error.stackTrace != null && kDebugMode) {
      debugPrint('Stack: ${error.stackTrace}');
    }
    debugPrint('═══════════════════════════════════════');

    // Envoie à Firebase Analytics
    analyticsService.logAppError(
      errorType: error.type.name,
      errorMessage: error.message,
    );
  }

  /// Ferme le stream controller
  void dispose() {
    _errorStreamController.close();
  }
}

/// Instance globale du service d'erreurs
final errorService = ErrorHandlingService();

/// Widget pour afficher les erreurs avec option de retry
class ErrorDisplay extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool showDetails;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: _getErrorColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              error.displayMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (showDetails && kDebugMode) ...[
              const SizedBox(height: 8),
              Text(
                error.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
            if (error.canRetry && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.authentication:
        return Icons.lock_outline_rounded;
      case ErrorType.validation:
        return Icons.error_outline_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      case ErrorType.permission:
        return Icons.block_rounded;
      case ErrorType.timeout:
        return Icons.timer_off_rounded;
      case ErrorType.unknown:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getErrorColor(BuildContext context) {
    switch (error.type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return Colors.orange;
      case ErrorType.server:
        return Theme.of(context).colorScheme.error;
      case ErrorType.authentication:
      case ErrorType.permission:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.notFound:
        return Colors.grey;
      case ErrorType.unknown:
        return Theme.of(context).colorScheme.error;
    }
  }
}

/// Snackbar pour afficher une erreur
void showErrorSnackBar(BuildContext context, AppError error, {VoidCallback? onRetry}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.displayMessage),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      action: error.canRetry && onRetry != null
          ? SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
      duration: const Duration(seconds: 4),
    ),
  );
}

/// Dialog pour les erreurs critiques
Future<bool?> showErrorDialog(
  BuildContext context,
  AppError error, {
  VoidCallback? onRetry,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: Icon(
        error.type == ErrorType.authentication
            ? Icons.lock_outline
            : Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        size: 48,
      ),
      title: Text(_getErrorTitle(error.type)),
      content: Text(error.displayMessage),
      actions: [
        if (error.type != ErrorType.authentication)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Fermer'),
          ),
        if (error.canRetry && onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              onRetry();
            },
            child: const Text('Réessayer'),
          ),
        if (error.type == ErrorType.authentication)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              // Navigation vers login
              // GoRouter.of(context).go('/login');
            },
            child: const Text('Se reconnecter'),
          ),
      ],
    ),
  );
}

String _getErrorTitle(ErrorType type) {
  switch (type) {
    case ErrorType.network:
      return 'Connexion impossible';
    case ErrorType.server:
      return 'Erreur serveur';
    case ErrorType.authentication:
      return 'Session expirée';
    case ErrorType.validation:
      return 'Données invalides';
    case ErrorType.notFound:
      return 'Non trouvé';
    case ErrorType.permission:
      return 'Accès refusé';
    case ErrorType.timeout:
      return 'Délai dépassé';
    case ErrorType.unknown:
      return 'Erreur';
  }
}

/// Extension Result pour gérer les erreurs de manière fonctionnelle
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppError error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T> s => s.data,
        Failure<T> _ => null,
      };

  AppError? get errorOrNull => switch (this) {
        Success<T> _ => null,
        Failure<T> f => f.error,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) =>
      switch (this) {
        Success<T> s => success(s.data),
        Failure<T> f => failure(f.error),
      };

  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T> s => Result.success(transform(s.data)),
        Failure<T> f => Result.failure(f.error),
      };
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

/// Helper pour exécuter du code avec gestion d'erreur
Future<Result<T>> runCatching<T>(Future<T> Function() action) async {
  try {
    final result = await action();
    return Result.success(result);
  } catch (e, stackTrace) {
    final error = errorService.handleException(e, stackTrace);
    return Result.failure(error);
  }
}
