import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final bool refresh;
  const LoadNotifications({this.refresh = false});
}

class MarkAsRead extends NotificationEvent {
  final String id;
  const MarkAsRead(this.id);
}

class MarkAllAsRead extends NotificationEvent {}
