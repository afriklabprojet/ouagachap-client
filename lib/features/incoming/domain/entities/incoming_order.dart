import 'package:equatable/equatable.dart';

/// Entité représentant un colis entrant (que l'utilisateur va RECEVOIR)
class IncomingOrder extends Equatable {
  final String id;
  final String orderNumber;
  final String status;
  final String statusLabel;
  
  // Expéditeur
  final String senderName;
  final String senderPhone;
  
  // Adresse de livraison
  final String dropoffAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  
  // Colis
  final String? packageDescription;
  final String packageSize;
  
  // Coursier (si assigné)
  final IncomingOrderCourier? courier;
  
  // Prix
  final double totalPrice;
  
  // Confirmation
  final String? confirmationCode;
  final bool recipientConfirmed;
  
  // Dates
  final DateTime createdAt;
  final DateTime? deliveredAt;

  const IncomingOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.senderName,
    required this.senderPhone,
    required this.dropoffAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    this.packageDescription,
    required this.packageSize,
    this.courier,
    required this.totalPrice,
    this.confirmationCode,
    required this.recipientConfirmed,
    required this.createdAt,
    this.deliveredAt,
  });

  factory IncomingOrder.fromJson(Map<String, dynamic> json) {
    return IncomingOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      statusLabel: json['status_label'] ?? _getStatusLabel(json['status'] as String),
      senderName: json['pickup_contact_name'] as String? ?? 'Expéditeur',
      senderPhone: json['pickup_contact_phone'] as String? ?? '',
      dropoffAddress: json['dropoff_address'] as String,
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      packageDescription: json['package_description'] as String?,
      packageSize: json['package_size'] as String? ?? 'small',
      courier: json['courier'] != null 
          ? IncomingOrderCourier.fromJson(json['courier'] as Map<String, dynamic>)
          : null,
      totalPrice: (json['total_price'] as num).toDouble(),
      confirmationCode: json['recipient_confirmation_code'] as String?,
      recipientConfirmed: json['recipient_confirmed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
    );
  }

  static String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Coursier en route vers expéditeur';
      case 'picked_up':
        return 'En cours de livraison';
      case 'delivered':
        return 'Livré';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  bool get isInTransit => status == 'accepted' || status == 'picked_up';
  bool get isDelivered => status == 'delivered';
  bool get isPending => status == 'pending';
  bool get canTrack => isInTransit;

  @override
  List<Object?> get props => [
    id, orderNumber, status, senderName, dropoffAddress, 
    courier, totalPrice, recipientConfirmed, createdAt,
  ];
}

class IncomingOrderCourier extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? vehicleType;
  final double? latitude;
  final double? longitude;

  const IncomingOrderCourier({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleType,
    this.latitude,
    this.longitude,
  });

  factory IncomingOrderCourier.fromJson(Map<String, dynamic> json) {
    return IncomingOrderCourier(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Coursier',
      phone: json['phone'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String?,
      latitude: json['current_latitude'] != null 
          ? (json['current_latitude'] as num).toDouble()
          : null,
      longitude: json['current_longitude'] != null 
          ? (json['current_longitude'] as num).toDouble()
          : null,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;

  @override
  List<Object?> get props => [id, name, phone, vehicleType, latitude, longitude];
}

class IncomingOrderStats extends Equatable {
  final int pending;
  final int inTransit;
  final int delivered;
  final int total;

  const IncomingOrderStats({
    required this.pending,
    required this.inTransit,
    required this.delivered,
    required this.total,
  });

  factory IncomingOrderStats.fromJson(Map<String, dynamic> json) {
    return IncomingOrderStats(
      pending: json['pending'] as int? ?? 0,
      inTransit: json['in_transit'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [pending, inTransit, delivered, total];
}
