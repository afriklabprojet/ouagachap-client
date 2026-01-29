import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded || event.refresh) {
      emit(NotificationLoading());
    }

    try {
      final notifications = await getNotificationsUseCase.call();
      // Calculate unread count locally for now or add a usecase for it
      final unreadCount = notifications.where((n) => !n.isRead).length; 
      
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      try {
        await markNotificationReadUseCase.call(event.id);
        
        // Optimistic update
        final updatedList = currentState.notifications.map((n) {
          if (n.id == event.id) {
             // Return a copy marked as read - since entities are immutable we'd normally use copyWith
             // For simplicity here, assuming we reload or have copyWith
             // Ideally Entity should have copyWith
             return n; // TODO: Implement copyWith on entity or immutable update
          }
          return n;
        }).toList();
        
        // Refresh list from server to be sure
        add(const LoadNotifications());
      } catch (e) {
        // Handle error silently or show snackbar via BlocListener
      }
    }
  }
}
