import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lottie_animations.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/animations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(Routes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon profil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(Routes.home),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              final user = state.user;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Phone
                          Text(
                            _formatPhone(user.phone),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (user.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.email!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Edit button
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.go('${Routes.profile}/${Routes.editProfile}'),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Modifier'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menu items
                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'Historique des commandes',
                      onTap: () => context.go(Routes.ordersHistory),
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Mes adresses',
                      onTap: () => context.go('${Routes.profile}/${Routes.addresses}'),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () => context.go('${Routes.profile}/${Routes.notifications}'),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Aide & Support',
                      onTap: () => context.go('${Routes.profile}/${Routes.support}'),
                    ),
                    _buildThemeToggle(),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'À propos',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'OUAGA CHAP',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2024 OUAGA CHAP',
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                                'Application de livraison rapide à Ouagadougou'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: const Text('Déconnexion'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Version
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return const AnimatedLoadingWidget(
              message: 'Chargement du profil...',
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final themeService = getIt<ThemeService>();
    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListenableBuilder(
          listenable: themeService,
          builder: (context, _) {
            return ListTile(
              leading: Icon(
                themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
              ),
              title: const Text('Thème sombre'),
              trailing: Switch(
                value: themeService.isDarkMode,
                onChanged: (_) => themeService.toggleTheme(),
                activeColor: AppColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Déconnexion',
      message: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      confirmText: 'Déconnexion',
      cancelText: 'Annuler',
      isDestructive: true,
    );
    
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }

  String _formatPhone(String phone) {
    if (phone.startsWith('+226') && phone.length == 12) {
      final local = phone.substring(4);
      return '+226 ${local.substring(0, 2)} ${local.substring(2, 4)} ${local.substring(4, 6)} ${local.substring(6)}';
    }
    return phone;
  }
}
