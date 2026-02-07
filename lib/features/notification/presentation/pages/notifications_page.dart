import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.profile),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const AnimatedLoadingWidget(
              message: 'Chargement des notifications...',
            );
          }
          
          if (state is NotificationError) {
            return AnimatedErrorWidget(
              title: 'Erreur',
              subtitle: state.message,
              retryText: 'Réessayer',
              onRetry: () => context.read<NotificationBloc>().add(const LoadNotifications(refresh: true)),
            );
          }
          
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const AnimatedEmptyWidget(
                title: 'Aucune notification',
                subtitle: 'Vous êtes à jour !',
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const LoadNotifications(refresh: true));
              },
              child: ListView.separated(
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return SlideInWidget(
                    delay: Duration(milliseconds: 50 * index),
                    beginOffset: const Offset(0.2, 0),
                    child: _buildNotificationTile(notification),
                  );
                },
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationTile(notification) {
    return ListTile(
      tileColor: notification.isRead ? Colors.transparent : AppColors.primaryLight.withAlpha(25),
      leading: ScaleInWidget(
        child: CircleAvatar(
          backgroundColor: _getIconColor(notification.type),
          child: Icon(_getIcon(notification.type), color: Colors.white, size: 20),
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            _formatDate(notification.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
      trailing: notification.isRead 
          ? null 
          : Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationBloc>().add(MarkAsRead(notification.id));
        }
      },
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'order_status':
      case 'order':
        return Icons.local_shipping;
      case 'promo':
        return Icons.card_giftcard;
      case 'payment':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'order_status':
      case 'order':
        return Colors.blue;
      case 'promo':
        return Colors.purple;
      case 'payment':
        return Colors.green;
      case 'wallet':
        return Colors.orange;
      case 'system':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    // Simple formatter, you might want to use intl package
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
