import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection.dart';
import 'core/services/enhanced_notification_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/order/presentation/bloc/order_bloc.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_event.dart';
import 'features/wallet/presentation/bloc/jeko_payment_bloc.dart';
import 'features/support/presentation/bloc/support_bloc.dart';
import 'features/incoming/presentation/bloc/incoming_order_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  // Initialiser les dépendances
  await configureDependencies();
  
  // Initialiser le service de notifications amélioré
  await EnhancedFirebaseNotificationService().initialize();
  
  runApp(const OuagaChapApp());
}

class OuagaChapApp extends StatelessWidget {
  const OuagaChapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => getIt<OrderBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>(),
        ),
        BlocProvider<WalletBloc>(
          create: (_) => getIt<WalletBloc>()..add(const LoadWallet()),
        ),
        BlocProvider<SupportBloc>(
          create: (_) => getIt<SupportBloc>(),
        ),
        BlocProvider<IncomingOrderBloc>(
          create: (_) => getIt<IncomingOrderBloc>(),
        ),
        BlocProvider<JekoPaymentBloc>(
          create: (_) => getIt<JekoPaymentBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'OUAGA CHAP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
