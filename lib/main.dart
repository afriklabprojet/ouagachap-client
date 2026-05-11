import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'firebase_options.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection.dart';
import 'core/l10n/app_localizations.dart';
import 'core/services/app_config_service.dart';
import 'core/services/enhanced_notification_service.dart';
import 'core/services/locale_service.dart';
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
import 'features/promo/presentation/bloc/promo_bloc.dart';
import 'features/promo/presentation/bloc/promo_event.dart';

void main() async {
  // ── Error handlers globaux ───────────────────────────────────────
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Sentry.captureException(details.exception, stackTrace: details.stack);
    debugPrint('❌ FlutterError: ${details.exceptionAsString()}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('❌ ErrorWidget: ${details.exceptionAsString()}');
    return const SizedBox.shrink();
  };

  // ── Initialisation Sentry (no-op si DSN vide en dev) ─────────────
  await SentryFlutter.init((options) {
    options.dsn = AppConfig.sentryDsn;
    options.tracesSampleRate = AppConfig.isProd ? 0.1 : 0.0;
    options.environment = AppConfig.initialized
        ? AppConfig.environment.name
        : 'dev';
    options.release = '1.0.0+1';
    options.sendDefaultPii = false;
  }, appRunner: () => _boot());
}

Future<void> _boot() async {
  // ── Démarrage dans une zone protégée ─────────────────────────────
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ── UI config synchrone ───────────────────────────────────────
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase initialisé');
      } catch (e, stack) {
        debugPrint('❌ Firebase.initializeApp failed: $e\n$stack');
      }

      // Guard : si l'app est lancée via `flutter run` sans -t,
      // AppConfig.init() n'a pas été appelé → LateInitializationError garanti.
      if (!AppConfig.initialized) {
        AppConfig.init(Environment.dev);
        debugPrint(
          '⚠️ AppConfig non initialisé — fallback sur Environment.dev. '
          'Utilisez `flutter run -t lib/main_prod.dart` en production.',
        );
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
    },
    (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      debugPrint('❌ Uncaught error: $error\n$stack');
    },
  );
}

/// Services initialisés APRÈS le premier frame pour un démarrage rapide.
Future<void> _initDeferredServices() async {
  try {
    await EnhancedFirebaseNotificationService().initialize();
    debugPrint('✅ Services différés initialisés');
  } catch (e) {
    debugPrint('⚠️ Erreur services différés (non bloquant): $e');
  }

  // Pré-charger la configuration backend (montants recharge, etc.)
  try {
    await getIt<AppConfigService>().getConfig();
    debugPrint('✅ Configuration backend chargée');
  } catch (e) {
    debugPrint('⚠️ Config backend indisponible (non bloquant): $e');
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
        BlocProvider<OrderBloc>(create: (_) => getIt<OrderBloc>()),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>(),
        ),
        BlocProvider<WalletBloc>(create: (_) => getIt<WalletBloc>()),
        BlocProvider<SupportBloc>(create: (_) => getIt<SupportBloc>()),
        BlocProvider<IncomingOrderBloc>(
          create: (_) => getIt<IncomingOrderBloc>(),
        ),
        BlocProvider<JekoPaymentBloc>(create: (_) => getIt<JekoPaymentBloc>()),
        BlocProvider<AddressBloc>(create: (_) => getIt<AddressBloc>()),
        BlocProvider<PromoBloc>(
          create: (_) => getIt<PromoBloc>()..add(const LoadPromoCodes()),
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
            final localeService = getIt<LocaleService>();
            return ListenableBuilder(
              listenable: localeService,
              builder: (context, _) {
                return MaterialApp.router(
                  title: 'OUAGA CHAP',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeService.themeMode,
                  locale: localeService.currentLocale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  routerConfig: AppRouter.router,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
