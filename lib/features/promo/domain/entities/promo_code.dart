import 'package:equatable/equatable.dart';

class PromoCode extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final String type; // 'percentage', 'fixed', 'free_delivery'
  final double value;
  final double minOrderAmount;
  final double? maxDiscount;
  final String? expiresAt;
  final bool firstOrderOnly;

  const PromoCode({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.minOrderAmount,
    this.maxDiscount,
    this.expiresAt,
    this.firstOrderOnly = false,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'].toString(),
      code: json['code'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      maxDiscount: json['max_discount'] != null
          ? (json['max_discount'] as num).toDouble()
          : null,
      expiresAt: json['expires_at'] as String?,
      firstOrderOnly: json['first_order_only'] as bool? ?? false,
    );
  }

  String get discountLabel {
    switch (type) {
      case 'percentage':
        return '${value.toInt()}%';
      case 'fixed':
        return '${value.toInt()} FCFA';
      case 'free_delivery':
        return 'Livraison gratuite';
      default:
        return '${value.toInt()}';
    }
  }

  @override
  List<Object?> get props => [id, code, type, value];
}
