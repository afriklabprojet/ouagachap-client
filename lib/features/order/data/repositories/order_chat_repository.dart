import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/repositories/order_chat_repository.dart';
import '../models/order_chat_model.dart';

class OrderChatRepository implements OrderChatRepositoryInterface {
  final ApiClient _apiClient;

  OrderChatRepository(this._apiClient);

  /// Récupérer le chat complet d'une commande (infos + messages)
  @override
  Future<OrderChat> getOrderChat(String orderUuid) async {
    final response = await _apiClient.get('orders/$orderUuid/chat');
    final data = response.data;

    if (data['success'] == true) {
      return OrderChat.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Erreur lors du chargement du chat');
  }

  /// Récupérer uniquement les messages (paginés)
  @override
  Future<List<OrderChatMessage>> getMessages(
    String orderUuid, {
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      'orders/$orderUuid/chat/messages',
      queryParameters: {'page': page},
    );
    final data = response.data;

    if (data['success'] == true) {
      final messagesJson = data['data']['messages'] ?? data['data'] ?? [];
      return (messagesJson as List)
          .map((m) => OrderChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Envoyer un message texte
  @override
  Future<OrderChatMessage> sendMessage(String orderUuid, String message) async {
    final response = await _apiClient.post(
      'orders/$orderUuid/chat/messages',
      data: {'message': message},
    );
    final data = response.data;

    if (data['success'] == true) {
      return OrderChatMessage.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Erreur lors de l\'envoi du message');
  }

  /// Envoyer une image
  @override
  Future<OrderChatMessage> sendImage(String orderUuid, String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });

    final response = await _apiClient.post(
      'orders/$orderUuid/chat/messages',
      data: formData,
    );
    final data = response.data;

    if (data['success'] == true) {
      return OrderChatMessage.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Erreur lors de l\'envoi de l\'image');
  }

  /// Marquer les messages comme lus
  @override
  Future<void> markAsRead(String orderUuid) async {
    await _apiClient.post('orders/$orderUuid/chat/read');
  }
}
