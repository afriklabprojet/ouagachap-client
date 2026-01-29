import '../entities/order.dart';

abstract class OrderRepository {
  /// Créer une nouvelle commande
  Future<Order> createOrder({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? pickupContactName,
    String? pickupContactPhone,
    required String deliveryAddress,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required String recipientName,
    required String recipientPhone,
    String? packageDescription,
    String? packageSize,
  });

  /// Récupérer les commandes de l'utilisateur
  Future<List<Order>> getOrders({
    int page = 1,
    int perPage = 10,
    OrderStatus? status,
  });

  /// Récupérer les détails d'une commande
  Future<Order> getOrderDetails(String orderId);

  /// Annuler une commande
  Future<void> cancelOrder(String orderId, {String? reason});

  /// Calculer le prix estimé
  Future<double> calculatePrice({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
  });

  /// Noter le coursier après livraison
  Future<Order> rateCourier({
    required String orderId,
    required int rating,
    String? review,
    List<String>? tags,
  });

  /// Suivre une commande en temps réel
  Stream<Order> trackOrder(String orderId);
}
