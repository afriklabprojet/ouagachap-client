import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) {
        final pName = p is AuthAuthenticated ? p.user.name : null;
        final cName = c is AuthAuthenticated ? c.user.name : null;
        return pName != cName;
      },
      builder: (context, state) {
        final userName = state is AuthAuthenticated
            ? state.user.name
            : 'Client';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.hello},',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                BlocBuilder<NotificationBloc, NotificationState>(
                  buildWhen: (p, c) {
                    final pCount = p is NotificationLoaded ? p.unreadCount : 0;
                    final cCount = c is NotificationLoaded ? c.unreadCount : 0;
                    return pCount != cCount;
                  },
                  builder: (context, notifState) {
                    int unreadCount = 0;
                    if (notifState is NotificationLoaded) {
                      unreadCount = notifState.unreadCount;
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            onPressed: () => context.go(
                              '${Routes.profile}/${Routes.notifications}',
                            ),
                            icon: const Icon(Icons.notifications_outlined),
                            style: IconButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => context.go(Routes.profile),
                    icon: const Icon(Icons.person_outline),
                    style: IconButton.styleFrom(foregroundColor: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
