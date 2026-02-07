import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../network/api_interceptor.dart';
import '../services/cache_service.dart';
import '../services/theme_service.dart';
import '../services/websocket_service.dart';
import '../services/image_compression_service.dart';
import '../services/deep_link_service.dart';
import '../services/app_review_service.dart';
import '../services/changelog_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/order/data/datasources/order_remote_datasource.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/order/domain/usecases/create_order_usecase.dart';
import '../../features/order/domain/usecases/get_orders_usecase.dart';
import '../../features/order/domain/usecases/get_order_details_usecase.dart';
import '../../features/order/domain/usecases/cancel_order_usecase.dart';
import '../../features/order/domain/usecases/rate_courier.dart';
import '../../features/order/presentation/bloc/order_bloc.dart';
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/usecases/get_notifications_usecase.dart';
import '../../features/notification/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/support/data/datasources/support_remote_datasource.dart';
import '../../features/support/data/repositories/support_repository.dart';
import '../../features/support/presentation/bloc/support_bloc.dart';
import '../../features/incoming/data/datasources/incoming_order_remote_datasource.dart';
import '../../features/incoming/data/repositories/incoming_order_repository.dart';
import '../../features/incoming/presentation/bloc/incoming_order_bloc.dart';
import '../../features/wallet/data/datasources/jeko_payment_datasource.dart';
import '../../features/wallet/data/repositories/jeko_payment_repository.dart';
import '../../features/wallet/presentation/bloc/jeko_payment_bloc.dart';
import '../../features/address/data/repositories/address_repository.dart';
import '../../features/address/presentation/bloc/address_bloc.dart';
import '../../features/tracking/presentation/bloc/live_tracking_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Core Services
  getIt.registerSingleton<ThemeService>(
    ThemeService(sharedPreferences),
  );
  getIt.registerSingleton<CacheService>(
    CacheService(sharedPreferences),
  );
  
  // Image Compression Service
  getIt.registerLazySingleton<ImageCompressionService>(
    () => ImageCompressionService(),
  );
  
  // Deep Link Service
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();
  getIt.registerSingleton<DeepLinkService>(deepLinkService);
  
  // App Review Service
  getIt.registerSingleton<AppReviewService>(
    AppReviewService(sharedPreferences),
  );
  
  // Changelog Service
  getIt.registerSingleton<ChangelogService>(
    ChangelogService(sharedPreferences),
  );
  
  // WebSocket Service for real-time tracking
  getIt.registerLazySingleton<WebSocketService>(
    () => WebSocketService(
      baseUrl: AppConstants.wsBaseUrl,
      appKey: AppConstants.wsAppKey,
    ),
  );
  
  // Dio & API Client
  getIt.registerSingleton<Dio>(_createDio());
  getIt.registerSingleton<ApiClient>(ApiClient(getIt<Dio>()));
  
  // Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SupportRemoteDataSource>(
    () => SupportRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<IncomingOrderRemoteDataSource>(
    () => IncomingOrderRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<JekoPaymentRemoteDataSource>(
    () => JekoPaymentRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: getIt<OrderRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: getIt<WalletRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<SupportRepository>(
    () => SupportRepository(getIt<SupportRemoteDataSource>()),
  );
  getIt.registerLazySingleton<IncomingOrderRepository>(
    () => IncomingOrderRepository(getIt<IncomingOrderRemoteDataSource>()),
  );
  getIt.registerLazySingleton<JekoPaymentRepository>(
    () => JekoPaymentRepository(getIt<JekoPaymentRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepository(getIt<ApiClient>()),
  );
  
  // Use Cases - Auth
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  
  // Use Cases - Order
  getIt.registerLazySingleton(() => CreateOrderUseCase(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => GetOrdersUseCase(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => GetOrderDetailsUseCase(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => CancelOrderUseCase(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => RateCourierUseCase(getIt<OrderRepository>()));
  
  // Use Cases - Notification
  getIt.registerLazySingleton(() => GetNotificationsUseCase(getIt<NotificationRepository>()));
  getIt.registerLazySingleton(() => MarkNotificationReadUseCase(getIt<NotificationRepository>()));
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUseCase: getIt<RegisterUseCase>(),
      verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );
  getIt.registerFactory<OrderBloc>(
    () => OrderBloc(
      createOrderUseCase: getIt<CreateOrderUseCase>(),
      getOrdersUseCase: getIt<GetOrdersUseCase>(),
      getOrderDetailsUseCase: getIt<GetOrderDetailsUseCase>(),
      cancelOrderUseCase: getIt<CancelOrderUseCase>(),
      rateCourierUseCase: getIt<RateCourierUseCase>(),
    ),
  );
  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotificationsUseCase: getIt<GetNotificationsUseCase>(),
      markNotificationReadUseCase: getIt<MarkNotificationReadUseCase>(),
    ),
  );
  getIt.registerFactory<WalletBloc>(
    () => WalletBloc(
      walletRepository: getIt<WalletRepository>(),
    ),
  );
  getIt.registerFactory<SupportBloc>(
    () => SupportBloc(getIt<SupportRepository>()),
  );
  getIt.registerFactory<IncomingOrderBloc>(
    () => IncomingOrderBloc(getIt<IncomingOrderRepository>()),
  );
  getIt.registerFactory<JekoPaymentBloc>(
    () => JekoPaymentBloc(getIt<JekoPaymentRepository>()),
  );
  getIt.registerFactory<AddressBloc>(
    () => AddressBloc(getIt<AddressRepository>()),
  );
  getIt.registerFactory<LiveTrackingBloc>(
    () => LiveTrackingBloc(webSocketService: getIt<WebSocketService>()),
  );
}

Dio _createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: '${AppConstants.baseUrl}/',
    connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
    receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  dio.interceptors.add(ApiInterceptor(getIt<SharedPreferences>()));
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));
  
  return dio;
}
