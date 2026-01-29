import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  accepted,
  pickingUp,
  inTransit,
  delivered,
  cancelled,
}

class Order extends Equatable {
  final String id;  // UUID depuis l'API
  final String trackingNumber;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String? pickupContactName;
  final String? pickupContactPhone;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String recipientName;
  final String recipientPhone;
  final String? packageDescription;
  final String? packageSize;
  final double distance;
  final double price;
  final OrderStatus status;
  final String? cancelReason;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final Courier? courier;
  final int? courierRating;
  final String? courierReview;
  final int? clientRating;
  final String? clientReview;

  const Order({
    required this.id,
    required this.trackingNumber,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.pickupContactName,
    this.pickupContactPhone,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.recipientName,
    required this.recipientPhone,
    this.packageDescription,
    this.packageSize,
    required this.distance,
    required this.price,
    required this.status,
    this.cancelReason,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.createdAt,
    this.courier,
    this.courierRating,
    this.courierReview,
    this.clientRating,
    this.clientReview,
  });

  @override
  List<Object?> get props => [
        id,
        trackingNumber,
        pickupAddress,
        deliveryAddress,
        status,
        price,
        createdAt,
      ];

  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.accepted;
  
  bool get isActive => status != OrderStatus.delivered && status != OrderStatus.cancelled;

  bool get canRate => status == OrderStatus.delivered && courierRating == null;

  bool get hasRatedCourier => courierRating != null;

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.accepted:
        return 'Acceptée';
      case OrderStatus.pickingUp:
        return 'Récupération';
      case OrderStatus.inTransit:
        return 'En cours';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }
}

class Courier extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? avatar;
  final double? rating;
  final String? vehicleType;
  final String? vehiclePlate;
  final double? currentLatitude;
  final double? currentLongitude;

  const Courier({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.rating,
    this.vehicleType,
    this.vehiclePlate,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  List<Object?> get props => [id, name, phone];
}
