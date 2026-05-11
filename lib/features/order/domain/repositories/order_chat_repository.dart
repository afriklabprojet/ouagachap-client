import '../../data/models/order_chat_model.dart';

abstract class OrderChatRepositoryInterface {
  Future<OrderChat> getOrderChat(String orderUuid);
  Future<List<OrderChatMessage>> getMessages(String orderUuid, {int page = 1});
  Future<OrderChatMessage> sendMessage(String orderUuid, String message);
  Future<OrderChatMessage> sendImage(String orderUuid, String imagePath);
  Future<void> markAsRead(String orderUuid);
}
