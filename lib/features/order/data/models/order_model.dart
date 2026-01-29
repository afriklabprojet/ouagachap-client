import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.trackingNumber,
    required super.pickupAddress,
    required super.pickupLatitude,
    required super.pickupLongitude,
    super.pickupContactName,
    super.pickupContactPhone,
    required super.deliveryAddress,
    required super.deliveryLatitude,
    required super.deliveryLongitude,
    required super.recipientName,
    required super.recipientPhone,
    super.packageDescription,
    super.packageSize,
    required super.distance,
    required super.price,
    required super.status,
    super.cancelReason,
    super.acceptedAt,
    super.pickedUpAt,
    super.deliveredAt,
    super.cancelledAt,
    required super.createdAt,
    super.courier,
    super.courierRating,
    super.courierReview,
    super.clientRating,
    super.clientReview,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      // L'API renvoie un UUID string pour l'id
      id: json['id'].toString(),
      // L'API utilise order_number au lieu de tracking_number
      trackingNumber: json['order_number'] as String? ?? json['tracking_number'] as String? ?? '',
      pickupAddress: json['pickup_address'] as String? ?? '',
      pickupLatitude: _parseDouble(json['pickup_latitude']),
      pickupLongitude: _parseDouble(json['pickup_longitude']),
      pickupContactName: json['pickup_contact_name'] as String?,
      pickupContactPhone: json['pickup_contact_phone'] as String?,
      // L'API utilise dropoff_* au lieu de delivery_*
      deliveryAddress: json['dropoff_address'] as String? ?? json['delivery_address'] as String? ?? '',
      deliveryLatitude: _parseDouble(json['dropoff_latitude'] ?? json['delivery_latitude']),
      deliveryLongitude: _parseDouble(json['dropoff_longitude'] ?? json['delivery_longitude']),
      // L'API utilise dropoff_contact_* au lieu de recipient_*
      recipientName: json['dropoff_contact_name'] as String? ?? json['recipient_name'] as String? ?? '',
      recipientPhone: json['dropoff_contact_phone'] as String? ?? json['recipient_phone'] as String? ?? '',
      packageDescription: json['package_description'] as String?,
      packageSize: json['package_size'] as String?,
      // L'API utilise distance_km au lieu de distance
      distance: _parseDouble(json['distance_km'] ?? json['distance']),
      // L'API utilise total_price au lieu de price
      price: _parseDouble(json['total_price'] ?? json['price']),
      status: _parseStatus(json['status'] as String?),
      // L'API utilise cancellation_reason au lieu de cancel_reason
      cancelReason: json['cancellation_reason'] as String? ?? json['cancel_reason'] as String?,
      // L'API utilise assigned_at au lieu de accepted_at
      acceptedAt: _parseDateTime(json['assigned_at'] ?? json['accepted_at']),
      pickedUpAt: _parseDateTime(json['picked_up_at']),
      deliveredAt: _parseDateTime(json['delivered_at']),
      cancelledAt: _parseDateTime(json['cancelled_at']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      courier: json['courier'] != null
          ? CourierModel.fromJson(json['courier'] as Map<String, dynamic>)
          : null,
      courierRating: json['courier_rating'] as int?,
      courierReview: json['courier_review'] as String?,
      clientRating: json['client_rating'] as int?,
      clientReview: json['client_review'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_number': trackingNumber,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_contact_name': pickupContactName,
      'pickup_contact_phone': pickupContactPhone,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'package_description': packageDescription,
      'package_size': packageSize,
      'distance': distance,
      'price': price,
      'status': status.name,
      'cancel_reason': cancelReason,
      'accepted_at': acceptedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'assigned':
      case 'accepted':
        return OrderStatus.accepted;
      case 'picked_up':
      case 'pickingup':
      case 'picking_up':
        return OrderStatus.pickingUp;
      case 'in_transit':
      case 'intransit':
        return OrderStatus.inTransit;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class CourierModel extends Courier {
  const CourierModel({
    required super.id,
    required super.name,
    required super.phone,
    super.avatar,
    super.rating,
    super.vehicleType,
    super.vehiclePlate,
    super.currentLatitude,
    super.currentLongitude,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) {
    return CourierModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
      // L'API utilise average_rating au lieu de rating
      rating: _parseDouble(json['average_rating'] ?? json['rating']),
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      currentLatitude: _parseDouble(json['current_latitude']),
      currentLongitude: _parseDouble(json['current_longitude']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
