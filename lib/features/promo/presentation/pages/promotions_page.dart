import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final promotions = [
      _Promotion(
        title: '-20% sur votre première commande',
        description: 'Bénéficiez de 20% de réduction sur votre première livraison avec OUAGA CHAP',
        code: 'BIENVENUE20',
        discount: '20%',
        minAmount: 500,
        expiresAt: '28 Février 2026',
        gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
        icon: Icons.card_giftcard,
      ),
      _Promotion(
        title: 'Livraison gratuite le weekend',
        description: 'Les samedis et dimanches, profitez de la livraison offerte pour toute commande',
        code: 'WEEKEND',
        discount: '100%',
        minAmount: 1000,
        expiresAt: '31 Mars 2026',
        gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
        icon: Icons.celebration,
      ),
      _Promotion(
        title: 'Parrainage - 500 FCFA offerts',
        description: 'Invitez un ami et recevez chacun 500 FCFA de crédit sur votre wallet',
        code: 'PARRAIN500',
        discount: '500 FCFA',
        minAmount: 0,
        expiresAt: 'Sans limite',
        gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
        icon: Icons.people,
      ),
      _Promotion(
        title: 'Happy Hour - 15% off',
        description: 'De 14h à 16h, profitez de 15% de réduction sur toutes vos livraisons',
        code: 'HAPPYHOUR',
        discount: '15%',
        minAmount: 300,
        expiresAt: '30 Juin 2026',
        gradient: const [Color(0xFFfc4a1a), Color(0xFFf7b733)],
        icon: Icons.access_time,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Promotions',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return _buildPromoCard(context, promo);
        },
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context, _Promotion promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: promo.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(promo.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          promo.discount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(Icons.shopping_bag_outlined, 'Min: ${promo.minAmount} FCFA'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.calendar_today_outlined, promo.expiresAt),
                  ],
                ),
                const SizedBox(height: 16),
                // Code promo
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: promo.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text('Code ${promo.code} copié !'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              promo.code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.copy, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Copier',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _Promotion {
  final String title;
  final String description;
  final String code;
  final String discount;
  final int minAmount;
  final String expiresAt;
  final List<Color> gradient;
  final IconData icon;

  const _Promotion({
    required this.title,
    required this.description,
    required this.code,
    required this.discount,
    required this.minAmount,
    required this.expiresAt,
    required this.gradient,
    required this.icon,
  });
}
