import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';

/// Page de profil public du coursier
class CourierProfilePage extends StatefulWidget {
  final int courierId;
  final String? courierName;
  final String? courierPhoto;

  const CourierProfilePage({
    super.key,
    required this.courierId,
    this.courierName,
    this.courierPhoto,
  });

  @override
  State<CourierProfilePage> createState() => _CourierProfilePageState();
}

class _CourierProfilePageState extends State<CourierProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response =
          await getIt<ApiClient>().get('couriers/${widget.courierId}/profile');
      final data = response.data;
      if (data['success'] == true) {
        setState(() {
          _profile = data['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Erreur';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger le profil';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.courierName ?? 'Profil coursier',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _loadProfile();
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _buildProfile(),
    );
  }

  Widget _buildProfile() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = _profile!;
    final avatarUrl = profile['avatar_url'] as String?;
    final name = profile['name'] as String? ?? '';
    final rating = (profile['average_rating'] as num?)?.toDouble() ?? 0;
    final totalRatings = profile['total_ratings'] as int? ?? 0;
    final totalOrders = profile['total_orders'] as int? ?? 0;
    final vehicleType = profile['vehicle_type'] as String?;
    final vehiclePlate = profile['vehicle_plate'] as String?;
    final vehicleModel = profile['vehicle_model'] as String?;
    final memberSince = profile['member_since'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Icon(Icons.person, size: 60, color: AppColors.primary.withValues(alpha: 0.5))
                : null,
          ),
          const SizedBox(height: 16),

          // Nom
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (i) {
                final starValue = i + 1;
                if (rating >= starValue) {
                  return const Icon(Icons.star, color: Colors.amber, size: 24);
                } else if (rating >= starValue - 0.5) {
                  return const Icon(Icons.star_half, color: Colors.amber, size: 24);
                } else {
                  return Icon(Icons.star_border, color: Colors.grey[300], size: 24);
                }
              }),
              const SizedBox(width: 8),
              Text(
                '${rating.toStringAsFixed(1)} ($totalRatings avis)',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              _buildStatCard(
                Icons.delivery_dining,
                '$totalOrders',
                'Livraisons',
                AppColors.primary,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                Icons.star,
                rating.toStringAsFixed(1),
                'Note moyenne',
                Colors.amber,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                Icons.calendar_today,
                memberSince ?? '-',
                'Membre depuis',
                AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Véhicule
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.two_wheeler, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Véhicule',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (vehicleType != null)
                  _buildInfoRow('Type', vehicleType),
                if (vehicleModel != null)
                  _buildInfoRow('Modèle', vehicleModel),
                if (vehiclePlate != null)
                  _buildInfoRow('Plaque', vehiclePlate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
