import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

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
          title: Text(context.l10n.profile),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) {
            if (p is AuthAuthenticated && c is AuthAuthenticated) {
              return p.user != c.user;
            }
            return p.runtimeType != c.runtimeType;
          },
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
                            color: Colors.black.withValues(alpha: 0.05),
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
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: user.avatar != null && user.avatar!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: user.avatar!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
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
                          // Badge vérification
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                user.isPhoneVerified
                                    ? Icons.verified
                                    : Icons.warning_amber_rounded,
                                size: 16,
                                color: user.isPhoneVerified
                                    ? AppColors.success
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.isPhoneVerified
                                    ? 'Numéro vérifié'
                                    : 'Numéro non vérifié',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: user.isPhoneVerified
                                      ? AppColors.success
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Edit button
                          OutlinedButton.icon(
                            onPressed: () => context.go(
                              '${Routes.profile}/${Routes.editProfile}',
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(context.l10n.translate('edit')),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menu items
                    _buildMenuItem(
                      icon: Icons.history,
                      title: context.l10n.orderHistory,
                      onTap: () => context.go(Routes.ordersHistory),
                    ),
                    if (!user.isPhoneVerified)
                      _buildMenuItem(
                        icon: Icons.phone_android,
                        title: 'Vérifier mon numéro',
                        onTap: () => context.go(
                          '${Routes.profile}/${Routes.phoneVerification}',
                        ),
                        color: Colors.orange,
                      ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: context.l10n.myAddresses,
                      onTap: () =>
                          context.go('${Routes.profile}/${Routes.addresses}'),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: context.l10n.notifications,
                      onTap: () => context.go(
                        '${Routes.profile}/${Routes.notifications}',
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: context.l10n.helpSupport,
                      onTap: () =>
                          context.go('${Routes.profile}/${Routes.support}'),
                    ),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: context.l10n.settings,
                      onTap: () => context.go(
                        '${Routes.profile}/${Routes.settings}',
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: context.l10n.about,
                      onTap: () async {
                        final packageInfo = await _packageInfoFuture;
                        if (!context.mounted) return;
                        final year = DateTime.now().year;
                        showAboutDialog(
                          context: context,
                          applicationName: 'OUAGA CHAP',
                          applicationVersion:
                              '${packageInfo.version} (${packageInfo.buildNumber})',
                          applicationLegalese: '© $year OUAGA CHAP',
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Application de livraison rapide à Ouagadougou',
                            ),
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
                        label: Text(context.l10n.logout),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Version
                    FutureBuilder<PackageInfo>(
                      future: _packageInfoFuture,
                      builder: (context, snapshot) {
                        final version = snapshot.data?.version ?? '...';
                        return Text(
                          'Version $version',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return const ProfileSkeleton();
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? AppColors.primary;
    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color != null ? color.withValues(alpha: 0.3) : Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: itemColor),
          title: Text(title, style: TextStyle(color: color != null ? itemColor : null)),
          trailing: Icon(Icons.chevron_right, color: color ?? Colors.grey),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.l10n.logout,
      message: context.l10n.logoutConfirm,
      confirmText: context.l10n.logout,
      cancelText: context.l10n.cancel,
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
