import 'package:flutter/material.dart';

import '../../features/order/domain/entities/order.dart';
import '../theme/app_colors.dart';

/// Mapping centralisé des statuts de commande vers couleurs et icônes.
///
/// Source unique de vérité — remplace les 4+ copies identiques
/// dispersées dans les pages order_details, order_tracking,
/// orders_history et active_order_card.
class OrderStatusMapper {
  OrderStatusMapper._();

  static Color getColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
        return AppColors.info;
      case OrderStatus.pickingUp:
        return AppColors.secondary;
      case OrderStatus.inTransit:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  static IconData getIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.pickingUp:
        return Icons.inventory;
      case OrderStatus.inTransit:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// Mapping des statuts de réclamation (String) vers couleurs.
class ComplaintStatusMapper {
  ComplaintStatusMapper._();

  static Color getColor(String status) {
    return switch (status) {
      'open' => Colors.red,
      'in_progress' => Colors.orange,
      'resolved' => Colors.green,
      'closed' => Colors.grey,
      _ => Colors.grey,
    };
  }
}
