import 'package:flutter/material.dart';

/// Carte de commande améliorée avec animations
class OrderCard extends StatelessWidget {
  final String orderNumber;
  final String status;
  final String date;
  final String? pickupAddress;
  final String? deliveryAddress;
  final String? amount;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final Color? statusColor;
  
  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.date,
    this.pickupAddress,
    this.deliveryAddress,
    this.amount,
    this.onTap,
    this.onTrack,
    this.statusColor,
  });
  
  Color _getStatusColor() {
    if (statusColor != null) return statusColor!;
    
    switch (status.toLowerCase()) {
      case 'pending':
      case 'en attente':
        return Colors.orange;
      case 'accepted':
      case 'acceptée':
        return Colors.blue;
      case 'in_progress':
      case 'en cours':
        return Colors.indigo;
      case 'completed':
      case 'terminée':
        return Colors.green;
      case 'cancelled':
      case 'annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _StatusChip(
                    status: status,
                    color: _getStatusColor(),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Addresses
              if (pickupAddress != null)
                _AddressRow(
                  icon: Icons.circle,
                  iconColor: Colors.green,
                  address: pickupAddress!,
                  label: 'Départ',
                ),
              
              if (pickupAddress != null && deliveryAddress != null)
                _ConnectionLine(),
              
              if (deliveryAddress != null)
                _AddressRow(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  address: deliveryAddress!,
                  label: 'Arrivée',
                ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (amount != null)
                    Text(
                      amount!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
              
              // Track button
              if (onTrack != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.location_searching, size: 18),
                    label: const Text('Suivre la livraison'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  
  const _StatusChip({
    required this.status,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String address;
  final String label;
  
  const _AddressRow({
    required this.icon,
    required this.iconColor,
    required this.address,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 2, bottom: 2),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 24,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

/// Carte de portefeuille avec solde animé
class WalletCard extends StatelessWidget {
  final double balance;
  final String currency;
  final VoidCallback? onTopUp;
  final VoidCallback? onHistory;
  final List<Color>? gradientColors;
  
  const WalletCard({
    super.key,
    required this.balance,
    this.currency = 'FCFA',
    this.onTopUp,
    this.onHistory,
    this.gradientColors,
  });
  
  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [
      Theme.of(context).primaryColor,
      Theme.of(context).primaryColor.withOpacity(0.7),
    ];
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mon Solde',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: balance),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  '${value.toStringAsFixed(0)} $currency',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _WalletButton(
                    icon: Icons.add_circle_outline,
                    label: 'Recharger',
                    onTap: onTopUp,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WalletButton(
                    icon: Icons.history,
                    label: 'Historique',
                    onTap: onHistory,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  
  const _WalletButton({
    required this.icon,
    required this.label,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de coursier avec info de position
class CourierCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double? rating;
  final String? phone;
  final String? vehicleInfo;
  final String? distance;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  
  const CourierCard({
    super.key,
    required this.name,
    this.photoUrl,
    this.rating,
    this.phone,
    this.vehicleInfo,
    this.distance,
    this.onCall,
    this.onMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Photo
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: photoUrl != null 
                      ? NetworkImage(photoUrl!) 
                      : null,
                  child: photoUrl == null 
                      ? Icon(Icons.person, size: 30, color: Colors.grey.shade400)
                      : null,
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                      if (vehicleInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          vehicleInfo!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      distance!,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (onCall != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Appeler'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (onCall != null && onMessage != null)
                  const SizedBox(width: 12),
                if (onMessage != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
