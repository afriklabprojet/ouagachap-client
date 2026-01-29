import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Types d'erreurs API possibles
enum ApiErrorType {
  network,
  server,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  unknown,
}

/// Classe encapsulant les erreurs API
class ApiError implements Exception {
  final String message;
  final String? details;
  final ApiErrorType type;
  final int? statusCode;
  final dynamic originalError;

  const ApiError({
    required this.message,
    this.details,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  /// Crée une erreur à partir d'une DioException
  factory ApiError.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: 'Délai d\'attente dépassé',
          details: 'La connexion a pris trop de temps. Vérifiez votre connexion internet.',
          type: ApiErrorType.timeout,
          originalError: e,
        );
        
      case DioExceptionType.connectionError:
        return ApiError(
          message: 'Erreur de connexion',
          details: 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
          type: ApiErrorType.network,
          originalError: e,
        );
        
      case DioExceptionType.cancel:
        return ApiError(
          message: 'Requête annulée',
          type: ApiErrorType.unknown,
          originalError: e,
        );
        
      case DioExceptionType.badResponse:
        return _handleStatusCode(e);
        
      case DioExceptionType.badCertificate:
        return ApiError(
          message: 'Erreur de certificat',
          details: 'Le certificat du serveur n\'est pas valide.',
          type: ApiErrorType.server,
          originalError: e,
        );
        
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return ApiError(
            message: 'Pas de connexion internet',
            details: 'Vérifiez votre connexion réseau.',
            type: ApiErrorType.network,
            originalError: e,
          );
        }
        return ApiError(
          message: 'Une erreur est survenue',
          details: e.message,
          type: ApiErrorType.unknown,
          originalError: e,
        );
    }
  }

  static ApiError _handleStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    
    // Extraire le message d'erreur de la réponse API
    String? serverMessage;
    if (responseData is Map) {
      serverMessage = responseData['message'] as String? 
          ?? responseData['error'] as String?;
    }
    
    switch (statusCode) {
      case 400:
        return ApiError(
          message: 'Requête invalide',
          details: serverMessage ?? 'Les données envoyées sont incorrectes.',
          type: ApiErrorType.validation,
          statusCode: statusCode,
          originalError: e,
        );
        
      case 401:
        return ApiError(
          message: 'Session expirée',
          details: 'Veuillez vous reconnecter.',
          type: ApiErrorType.unauthorized,
          statusCode: statusCode,
          originalError: e,
        );
        
      case 403:
        return ApiError(
          message: 'Accès refusé',
          details: serverMessage ?? 'Vous n\'avez pas les droits nécessaires.',
          type: ApiErrorType.forbidden,
          statusCode: statusCode,
          originalError: e,
        );
        
      case 404:
        return ApiError(
          message: 'Ressource introuvable',
          details: serverMessage ?? 'La ressource demandée n\'existe pas.',
          type: ApiErrorType.notFound,
          statusCode: statusCode,
          originalError: e,
        );
        
      case 422:
        return ApiError(
          message: 'Données invalides',
          details: serverMessage ?? 'Vérifiez les informations saisies.',
          type: ApiErrorType.validation,
          statusCode: statusCode,
          originalError: e,
        );
        
      case 429:
        return ApiError(
          message: 'Trop de requêtes',
          details: 'Veuillez patienter quelques instants.',
          type: ApiErrorType.server,
          statusCode: statusCode,
          originalError: e,
        );
        
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiError(
          message: 'Erreur serveur',
          details: 'Le service est temporairement indisponible. Réessayez plus tard.',
          type: ApiErrorType.server,
          statusCode: statusCode,
          originalError: e,
        );
        
      default:
        return ApiError(
          message: serverMessage ?? 'Une erreur est survenue',
          details: 'Code erreur: $statusCode',
          type: ApiErrorType.unknown,
          statusCode: statusCode,
          originalError: e,
        );
    }
  }

  /// Icône correspondant au type d'erreur
  IconData get icon {
    switch (type) {
      case ApiErrorType.network:
        return Icons.wifi_off_outlined;
      case ApiErrorType.server:
        return Icons.cloud_off_outlined;
      case ApiErrorType.timeout:
        return Icons.hourglass_empty;
      case ApiErrorType.unauthorized:
        return Icons.lock_outline;
      case ApiErrorType.forbidden:
        return Icons.block_outlined;
      case ApiErrorType.notFound:
        return Icons.search_off_outlined;
      case ApiErrorType.validation:
        return Icons.warning_amber_outlined;
      case ApiErrorType.unknown:
        return Icons.error_outline;
    }
  }

  /// Indique si l'erreur peut être résolue en réessayant
  bool get isRetryable {
    return type == ApiErrorType.network 
        || type == ApiErrorType.timeout 
        || type == ApiErrorType.server;
  }

  /// Indique si l'utilisateur doit se reconnecter
  bool get requiresReauth => type == ApiErrorType.unauthorized;

  @override
  String toString() => message;
}

/// Extension pour convertir facilement les DioException en ApiError
extension DioExceptionExtension on DioException {
  ApiError toApiError() => ApiError.fromDioException(this);
}
