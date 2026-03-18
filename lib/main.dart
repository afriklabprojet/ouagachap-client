import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection.dart';
import 'core/services/enhanced_notification_service.dart';
import 'core/services/theme_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/order/presentation/bloc/order_bloc.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_event.dart';
import 'features/wallet/presentation/bloc/jeko_payment_bloc.dart';
import 'features/support/presentation/bloc/support_bloc.dart';
import 'features/incoming/presentation/bloc/incoming_order_bloc.dart';
import 'features/address/presentation/bloc/address_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Error handlers globaux ───────────────────────────────────────
  // En release, Flutter affiche un Container gris silencieux.
  // On le remplace pour logger l'erreur et éviter l'écran gris.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('❌ FlutterError: ${details.exceptionAsString()}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('❌ ErrorWidget: ${details.exceptionAsString()}');
    return const SizedBox.shrink();
  };

  // ── UI config synchrone ──────────────────────────────────────────
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // ── Démarrage dans une zone protégée ─────────────────────────────
  runZonedGuarded(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialisé');
    } catch (e, stack) {
      debugPrint('❌ Firebase.initializeApp failed: $e\n$stack');
    }

    try {
      await configureDependencies();
    } catch (e, stack) {
      debugPrint('❌ configureDependencies failed: $e\n$stack');
    }

    runApp(const OuagaChapApp());

    // Services non-critiques après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeferredServices();
    });
  }, (error, stack) {
    debugPrint('❌ Uncaught error: $error\n$stack');
  });
}

/// Services initialisés APRÈS le premier frame pour un démarrage rapide.
Future<void> _initDeferredServices() async {
  try {
    await EnhancedFirebaseNotificationService().initialize();
    debugPrint('✅ Services différés initialisés');
  } catch (e) {
    debugPrint('⚠️ Erreur services différés (non bloquant): $e');
  }
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
          create: (_) => getIt<WalletBloc>(),
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
        BlocProvider<AddressBloc>(
          create: (_) => getIt<AddressBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            curr is AuthAuthenticated && prev is! AuthAuthenticated,
        listener: (context, state) {
          context.read<WalletBloc>().add(const LoadWallet());
        },
        child: ListenableBuilder(
          listenable: getIt<ThemeService>(),
          builder: (context, _) {
            final themeService = getIt<ThemeService>();
            return MaterialApp.router(
              title: 'OUAGA CHAP',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeService.themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
