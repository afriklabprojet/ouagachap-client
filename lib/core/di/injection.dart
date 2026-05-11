import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../network/enhanced_interceptors.dart';
import '../services/cache_service.dart';
import '../services/theme_service.dart';
import '../services/websocket_service.dart';
import '../services/image_compression_service.dart';
import '../services/geocoding_service.dart';
import '../services/realtime_tracking_service.dart';
import '../services/deep_link_service.dart';
import '../services/app_review_service.dart';
import '../services/changelog_service.dart';
import '../services/app_config_service.dart';
import '../services/connectivity_service.dart';
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
import '../../features/order/domain/usecases/calculate_price_usecase.dart';
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
import '../../features/order/data/repositories/order_chat_repository.dart';
import '../../features/order/presentation/bloc/order_chat_bloc.dart';
import '../../features/promo/data/repositories/promo_repository.dart';
import '../../features/promo/presentation/bloc/promo_bloc.dart';
import '../services/order_draft_service.dart';
import '../services/locale_service.dart';
import '../services/secure_token_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Secure token storage (must init before Dio)
  final tokenService = SecureTokenService();
  await tokenService.init();
  getIt.registerSingleton<SecureTokenService>(tokenService);

  // Migrer un ancien token de SharedPreferences vers le stockage sécurisé
  final legacyToken = sharedPreferences.getString('auth_token');
  if (legacyToken != null &&
      legacyToken.isNotEmpty &&
      tokenService.token == null) {
    await tokenService.saveToken(legacyToken);
    await sharedPreferences.remove('auth_token');
  }

  // Core Services
  getIt.registerSingleton<ThemeService>(ThemeService(sharedPreferences));
  getIt.registerSingleton<LocaleService>(LocaleService());
  getIt.registerSingleton<CacheService>(CacheService(sharedPreferences));

  // Image Compression Service
  getIt.registerLazySingleton<ImageCompressionService>(
    () => ImageCompressionService(),
  );

  // Geocoding Service (Nominatim)
  getIt.registerLazySingleton<GeocodingService>(() => GeocodingService());

  // RealTime Tracking Service (HTTP polling)
  getIt.registerLazySingleton<RealTimeTrackingService>(
    () => RealTimeTrackingService(),
  );

  // Deep Link Service — initialisé en lazy pour ne pas bloquer le démarrage.
  // L'initialisation se fait au premier accès (ex: HomePage).
  getIt.registerLazySingleton<DeepLinkService>(() {
    final service = DeepLinkService();
    service.initialize(); // Fire-and-forget : l'écoute démarre en arrière-plan
    return service;
  });

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
      appKey: AppConfig.wsAppKey,
    ),
  );

  // Dio & API Client
  getIt.registerSingleton<Dio>(_createDio());
  getIt.registerSingleton<ApiClient>(ApiClient(getIt<Dio>()));

  // App Config Service (fetches config from backend)
  getIt.registerLazySingleton<AppConfigService>(
    () => AppConfigService(getIt<ApiClient>()),
  );

  // Connectivity Service
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      getIt<SharedPreferences>(),
      getIt<SecureTokenService>(),
    ),
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
    () => OrderRepositoryImpl(remoteDataSource: getIt<OrderRemoteDataSource>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<WalletRepository>(
    () =>
        WalletRepositoryImpl(remoteDataSource: getIt<WalletRemoteDataSource>()),
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
  // PromoRepository et PromoBloc désactivés — feature non intégré dans
  // le flow commande (TODO Sprint 5: intégrer dans create_order_page)
  // getIt.registerLazySingleton<PromoRepository>(
  //   () => PromoRepository(getIt<ApiClient>()),
  // );

  // Use Cases - Auth
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));

  // Use Cases - Order
  getIt.registerLazySingleton(
    () => CreateOrderUseCase(getIt<OrderRepository>()),
  );
  getIt.registerLazySingleton(() => GetOrdersUseCase(getIt<OrderRepository>()));
  getIt.registerLazySingleton(
    () => GetOrderDetailsUseCase(getIt<OrderRepository>()),
  );
  getIt.registerLazySingleton(
    () => CancelOrderUseCase(getIt<OrderRepository>()),
  );
  getIt.registerLazySingleton(
    () => CalculatePriceUseCase(getIt<OrderRepository>()),
  );
  getIt.registerLazySingleton(
    () => RateCourierUseCase(getIt<OrderRepository>()),
  );

  // Use Cases - Notification
  getIt.registerLazySingleton(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerLazySingleton(
    () => MarkNotificationReadUseCase(getIt<NotificationRepository>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      registerUseCase: getIt<RegisterUseCase>(),
      verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<OrderBloc>(
    () => OrderBloc(
      createOrderUseCase: getIt<CreateOrderUseCase>(),
      getOrdersUseCase: getIt<GetOrdersUseCase>(),
      getOrderDetailsUseCase: getIt<GetOrderDetailsUseCase>(),
      cancelOrderUseCase: getIt<CancelOrderUseCase>(),
      calculatePriceUseCase: getIt<CalculatePriceUseCase>(),
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
    () => WalletBloc(walletRepository: getIt<WalletRepository>()),
  );
  getIt.registerFactory<SupportBloc>(
    () => SupportBloc(getIt<SupportRepository>()),
  );
  getIt.registerFactory<IncomingOrderBloc>(
    () => IncomingOrderBloc(getIt<IncomingOrderRepository>()),
  );
  getIt.registerFactory<JekoPaymentBloc>(
    () => JekoPaymentBloc(
      getIt<JekoPaymentRepository>(),
      getIt<SharedPreferences>(),
    ),
  );
  getIt.registerFactory<AddressBloc>(
    () => AddressBloc(getIt<AddressRepository>()),
  );
  getIt.registerFactory<LiveTrackingBloc>(
    () => LiveTrackingBloc(
      webSocketService: getIt<WebSocketService>(),
      apiClient: getIt<ApiClient>(),
    ),
  );
  getIt.registerLazySingleton<OrderChatRepository>(
    () => OrderChatRepository(getIt<ApiClient>()),
  );
  getIt.registerFactory<OrderChatBloc>(
    () => OrderChatBloc(
      getIt<OrderChatRepository>(),
      webSocketService: getIt<WebSocketService>(),
    ),
  );
  getIt.registerLazySingleton<PromoRepository>(
    () => PromoRepository(getIt<ApiClient>()),
  );
  getIt.registerFactory<PromoBloc>(() => PromoBloc(getIt<PromoRepository>()));

  // Services
  getIt.registerLazySingleton<OrderDraftService>(
    () => OrderDraftService(getIt<SharedPreferences>()),
  );
}

Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/',
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Intercepteur principal avec retry automatique
  dio.interceptors.add(
    EnhancedApiInterceptor(getIt<SecureTokenService>(), dio),
  );

  // Cache GET responses (5 min par défaut)
  dio.interceptors.add(CacheInterceptor());

  // Logs détaillés uniquement en debug
  assert(() {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
    return true;
  }());

  return dio;
}
