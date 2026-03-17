# OUAGA CHAP - Flutter Client App Audit Report

**Date:** 7 mars 2026  
**App:** `ouaga_chap_client` v1.0.0  
**SDK:** Flutter 3.10.1+, Dart 3.x  
**Architecture:** Clean Architecture + BLoC  

---

## 1. OVERALL ARCHITECTURE SUMMARY

### Pattern: Clean Architecture with Feature-First Organization

```
lib/
├── core/          # Shared infrastructure
│   ├── constants/ # App-wide constants, API endpoints
│   ├── di/        # Dependency injection (GetIt manual)
│   ├── l10n/      # Localization (custom, not flutter_gen)
│   ├── network/   # Dio HTTP client, interceptors, error handling
│   ├── router/    # GoRouter navigation
│   ├── services/  # Cross-cutting services (19 files)
│   ├── theme/     # Material theme, colors, animations
│   ├── utils/     # Validators, formatters
│   └── widgets/   # Reusable UI components (13 files)
├── features/      # 13 feature modules
│   ├── auth/      # data/domain/presentation (Clean Arch)
│   ├── order/     # data/domain/presentation (Clean Arch)
│   ├── wallet/    # data/domain/presentation (Clean Arch)
│   ├── notification/ # data/domain/presentation (Clean Arch)
│   ├── support/   # data/domain/presentation (Clean Arch)
│   ├── incoming/  # data/domain/presentation (Clean Arch)
│   ├── address/   # data + presentation (partial Clean Arch)
│   ├── tracking/  # presentation only (BLoC + WebSocket)
│   ├── home/      # presentation only
│   ├── profile/   # presentation only
│   ├── settings/  # presentation only
│   ├── onboarding/ # presentation only
│   └── promo/     # presentation only
└── main.dart
```

### Strengths
- **Well-structured Clean Architecture** for core features (auth, order, wallet, notification, support)
- **BLoC pattern** used consistently across all features
- **Manual DI** via GetIt (not injectable code-gen despite dependency being present)
- **Equatable** used for BLoC states/events
- **Good API error handling** with typed `ApiError` class and French error messages
- **Comprehensive notification system** with Firebase Messaging + local notifications
- **WebSocket real-time tracking** with Pusher protocol (Laravel Reverb compatible)
- **Cache service** for offline data persistence
- **Dark theme** support
- **70+ test files** covering data/domain/presentation layers

### Weaknesses (Summary)
- **No token refresh** mechanism — 401 just logs out
- **Client registration endpoint doesn't exist** on backend
- **Firebase API keys exposed** in source code
- **Hardcoded WebSocket app key** in constants
- **No localization integration** in MaterialApp (l10n class exists but unused)
- **Price calculation done locally** instead of using API
- **No payment method for order creation** (wallet-only assumed)
- **Missing `orders/{id}` show route** in client (uses inconsistent paths)

---

## 2. BUGS AND ISSUES

### CRITICAL BUGS

#### BUG-01: Client Registration Calls Non-Existent Endpoint
**File:** `lib/features/auth/data/datasources/auth_remote_datasource.dart` L42  
**Issue:** The client calls `POST auth/register` but the backend has NO `/auth/register` route for clients. The only register route is `/auth/register/courier`.  
**Impact:** Registration will always return 404.  
**Backend behavior:** Client users are auto-created via `User::firstOrCreate` in `AuthService::authenticateUser()` during OTP verification. The `sendOtp` endpoint handles both login and implicit registration.  
**Fix:** Remove the separate `register()` call. The client's register flow should:
1. Call `auth/otp/send` with `{phone}` (same as login)
2. After OTP verification, backend auto-creates the user
3. Use the `name` from the registration form to call `auth/profile` PUT after first login

#### BUG-02: No Token Refresh — Users Get Logged Out
**File:** `lib/core/network/api_interceptor.dart` L33-38  
**Issue:** On 401, the interceptor simply deletes the token and fires a logout event. The backend provides `POST /auth/refresh-token` but the client never uses it.  
**Impact:** Users are logged out whenever their Sanctum token expires, instead of seamlessly refreshing.  
**Fix:** Implement token refresh in the interceptor before logging out:
```dart
// On 401, try POST /auth/refresh-token first
// Only logout if refresh also fails
```

#### BUG-03: Inconsistent API Path Prefixing
**File:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`  
**Issue:** Some API calls use relative paths (e.g. `'auth/register'` L42, `'auth/otp/send'` L56) while others use leading slashes (`'/auth/logout'` L103). The Dio `baseUrl` is `'https://api.ouagachap.bf/api/v1/'` (with trailing slash). Relative paths work correctly but leading-slash paths will fail or behave inconsistently with Dio's URL resolution.  
**Files affected:**
- `auth_remote_datasource.dart` L103: `'/auth/logout'` — leading slash
- `order_remote_datasource.dart` L103, L111, L120: `'/orders/$orderId'` — leading slash  
- `order_remote_datasource.dart` L146: `'orders/$orderId/rate-courier'` — no leading slash  
**Fix:** Standardize to all relative paths (no leading slash) since baseUrl has trailing slash.

#### BUG-04: `VerifyOtpUseCase` Sends Firebase idToken as OTP Code  
**File:** `lib/features/auth/domain/usecases/verify_otp_usecase.dart` L13  
**Issue:** `otp: firebaseIdToken ?? otp` — sends the Firebase ID token (hundreds of chars) as the `code` field. The backend `verifyOtp` checks if `firebase_verified` is true, then validates the `code` as a Firebase ID token. BUT the field name is `code`, and the token is very long.  
**Impact:** Works incidentally since the backend checks `firebase_verified` flag first and uses the `code` field as the Firebase ID token when the flag is true. However, this is fragile and confusing. The backend's `verifyOtp` expects the code/token in the `code` field.

#### BUG-05: `_onAuthResendOtpRequested` Sends Empty Name for Non-Login
**File:** `lib/features/auth/presentation/bloc/auth_bloc.dart` L296  
**Issue:** `await registerUseCase(phone: event.phone, name: '');` — sends empty name to a non-existent endpoint. Even if the endpoint existed, an empty name would fail validation.  
**Impact:** Resend OTP for registration path will fail.

### HIGH-SEVERITY ISSUES

#### BUG-06: Firebase API Keys Committed to Source
**File:** `lib/firebase_options.dart` L50-82  
**Issue:** Firebase API keys for all platforms (web, Android, iOS, macOS) are hardcoded in source code. While Firebase API keys are nominally public, the web API key (`AIzaSyBfVUEKM1KXrScddJ1kfYVoT0g0O4yPIys`) should be restricted by domain/referrer in the Firebase Console.  
**Impact:** Potential abuse of Firebase authentication quotas.  
**Note:** Two different Firebase projects are referenced:
- Web/macOS: `ouaga-chap` (project ID)
- Android/iOS: `ouaga-chap-a888e` (project ID)
This is unusual and may cause issues with FCM tokens being sent to the wrong project.

#### BUG-07: WebSocket App Key Hardcoded
**File:** `lib/core/constants/app_constants.dart` L33  
**Issue:** `static const String wsAppKey = 'ouagachap-app-key';` — hardcoded. Should be fetched from backend config endpoint (`GET /config/websocket`).

#### BUG-08: Orders Show/Details Endpoint Inconsistency
**File:** `lib/features/order/data/datasources/order_remote_datasource.dart` L103  
**Issue:** Uses `/orders/$orderId` but the backend routes show `GET /orders/{order}` is defined outside the `role.client` middleware group (L307). The client middleware group at L145-223 has **no `GET /orders/{id}`** route — only `GET /orders` (list), `POST /orders` (create), `POST /orders/{order}/cancel`, `POST /orders/{order}/rate-courier`.  
The `GET /orders/{order}` is at L307 and is available to both clients and couriers.  
**Impact:** Should work, but the route is outside the client middleware group, meaning it relies on `auth:sanctum` only.

#### BUG-09: Price Calculation Done Locally Instead of API
**File:** `lib/features/order/presentation/bloc/order_bloc.dart` L141-157  
**Issue:** `_onCalculatePriceRequested` uses a local Haversine formula with hardcoded `baseFare=500` and `pricePerKm=200` instead of calling the backend `POST /orders/estimate` or `POST /orders/calculate-price`. The `OrderRemoteDataSource` has a `calculatePrice()` method but it's never called from the BLoC.  
**Impact:** Price shown to user may differ from what backend charges. Backend uses zone-based pricing that the client ignores.

#### BUG-10: `CreateOrderPage` Uses Hardcoded Default Coordinates
**File:** `lib/features/order/presentation/pages/create_order_page.dart` L51-54  
**Issue:** Default coordinates are set to:
```dart
double _pickupLatitude = 12.3714;  // Ouagadougou center
double _pickupLongitude = -1.5197;
double _deliveryLatitude = 12.3814;
double _deliveryLongitude = -1.5097;
```
If the user doesn't select locations on the map, these defaults are sent. The map picker exists (`MapPickerPage`) but there's no guard ensuring the user actually picked valid coordinates.  
**Impact:** Orders could be created with meaningless default coordinates.

#### BUG-11: `WalletRepository` Has Redundant Non-JEKO Recharge Path
**Files:** `lib/features/wallet/domain/repositories/wallet_repository.dart`, `wallet_remote_datasource.dart`  
**Issue:** The `WalletRepository` has `initiateRecharge(amount, provider, phoneNumber)` which calls `POST client-wallet/recharge` — this is the old/direct wallet recharge endpoint. The app also has JEKO payment (via `JekoPaymentBloc`). Both systems coexist:
- `WalletBloc` + `InitiateRecharge` → old direct `client-wallet/recharge`
- `JekoPaymentBloc` + `InitiateWalletRecharge` → new `jeko/recharge`
**Impact:** The Recharge page (L36-37 of `recharge_page.dart`) loads JEKO payment methods but could call either system. This dual system creates confusion.

### MEDIUM-SEVERITY ISSUES

#### BUG-12: No `Localization` Delegates in MaterialApp
**File:** `lib/main.dart` L78-84  
**Issue:** The `MaterialApp.router` doesn't include `localizationsDelegates` or `supportedLocales`. The `AppLocalizations` class exists with full FR/EN translations but is never wired into the widget tree.  
**Impact:** All UI text is hardcoded in French. English users have no option. The l10n infrastructure exists but is unused.

#### BUG-13: Auth Token Stored in SharedPreferences (Insecure)
**File:** `lib/features/auth/data/datasources/auth_local_datasource.dart` L31  
**Issue:** Auth token is stored in `SharedPreferences` which is not encrypted on either platform. Android: XML file in app-internal storage. iOS: NSUserDefaults (not Keychain).  
**Impact:** On rooted/jailbroken devices, the token can be read. Should use `flutter_secure_storage` for sensitive data.

#### BUG-14: `EnhancedApiInterceptor` Not Used
**File:** `lib/core/network/enhanced_interceptors.dart`  
**Issue:** Three enhanced interceptors are defined (`EnhancedApiInterceptor`, `CacheInterceptor`, `OfflineInterceptor`) but NONE are used. The DI (`injection.dart` L237) only registers the basic `ApiInterceptor`. The enhanced interceptor has retry logic, caching, and offline support but is dead code.  
**Impact:** No automatic retry on network failure, no HTTP-level caching, no offline request queuing.

#### BUG-15: `ConnectivityService` Never Registered or Used
**File:** `lib/core/services/connectivity_service.dart`  
**Issue:** The `ConnectivityService` is defined but never registered in `injection.dart` and never used by any widget.  
**Impact:** No network status awareness in the UI. The `network_aware_widgets.dart` exist but likely can't access the service.

#### BUG-16: BLoCs Registered as `Factory` but Used as Global Singletons
**File:** `lib/core/di/injection.dart` L185-230, `lib/main.dart` L50-74  
**Issue:** BLoCs are registered as `registerFactory` (new instance each time), but `main.dart` creates them once via `BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()..add(..))`. The `LiveTrackingBloc` is also created fresh in the router. This is actually correct for BLoC pattern — each `BlocProvider` gets a new instance. However, the `WalletBloc` is provided globally with `add(const LoadWallet())` at app start, but the wallet requires authentication. If the user isn't logged in at startup, this fires an unauthenticated API call.

#### BUG-17: Wallet Loaded Before Auth Check  
**File:** `lib/main.dart` L62  
**Issue:** `BlocProvider<WalletBloc>(create: (_) => getIt<WalletBloc>()..add(const LoadWallet()))` loads wallet at app start, before auth check completes.  
**Impact:** Unauthenticated 401 error on first launch, wasted API call.

#### BUG-18: `RadioGroup` Widget Not from Flutter SDK
**File:** `lib/features/wallet/presentation/widgets/jeko_payment_method_selector.dart` L60  
**Issue:** Uses `RadioGroup<String>` which is not a standard Flutter widget. This will cause a compile error unless it's a custom widget defined elsewhere (not found in the codebase).  
**Impact:** Compile error. This file might not build.

#### BUG-19: Deep Link Listener Subscription Not Cancelled
**File:** `lib/features/home/presentation/pages/home_page.dart` L86  
**Issue:** `deepLinkService.onDeepLink.listen(_handleDeepLink)` — the `StreamSubscription` is never stored or cancelled in `dispose()`.  
**Impact:** Memory leak. Multiple subscriptions created if `HomePage` is rebuilt.

#### BUG-20: JEKO Deep Link Routes Not Registered in Router
**File:** `lib/core/services/jeko_deep_link_handler.dart` L96-145  
**Issue:** `JekoGoRouterExtension.jekoRoutes` defines GoRoute routes for `/payment/success` and `/payment/error` but these are never added to `AppRouter.router.routes`.  
**Impact:** JEKO payment callback deep links won't be handled via routing. The `JekoDeepLinkHandler.handleDeepLink` uses the `ouagachap://` scheme but the GoRouter routes use HTTP paths.

### LOW-SEVERITY ISSUES

#### BUG-21: Promotions Hardcoded on Homepage
**File:** `lib/features/home/presentation/pages/home_page.dart` L43-59  
**Issue:** Promo items (BIENVENUE20, WEEKEND, BIGBOX15) are hardcoded. Backend has `GET /promo-codes/available` but it's not used on the home page.

#### BUG-22: `orders/calculate-price` vs `orders/estimate`
**File:** `lib/core/constants/app_constants.dart` L81  
**Issue:** `ApiEndpoints.calculatePrice = '/orders/calculate-price'` but backend route is `POST /orders/estimate`.

#### BUG-23: Profile Update Endpoint Inconsistency  
**File:** `lib/features/auth/data/datasources/auth_remote_datasource.dart` L97  
**Issue:** Uses `PUT auth/profile` but the update profile handler in `auth_bloc.dart` L403 uses `POST user/profile`. Two different endpoints for the same purpose.  
Backend supports both: `PUT /auth/profile` (L106), `POST /auth/profile` (L107), and `POST /user/profile` (L115).

#### BUG-24: No Order Payment Flow
**Issue:** When creating an order (`CreateOrderPage`), there is no payment method selection. The backend's `POST /orders` may require payment or deduct from wallet. The client doesn't show any payment UI during order creation.

#### BUG-25: Missing `orders/{order}` GET Route in Client Constants
**File:** `lib/core/constants/app_constants.dart` L76-79  
**Issue:** `orderDetails(String id) => '/orders/$id'` uses leading slash. Additionally, the `getOrderDetails` in `order_remote_datasource.dart` uses `/orders/$orderId` (with leading slash) which may cause issues with Dio baseUrl resolution.

#### BUG-26: `AuthRemoteDataSource.logout()` Uses Leading Slash
**File:** `lib/features/auth/data/datasources/auth_remote_datasource.dart` L103  
**Issue:** `await _apiClient.post('/auth/logout');` — the leading slash makes Dio resolve from the host root, bypassing the `/api/v1/` base path.

---

## 3. PAYMENT METHODS ANALYSIS

### Backend JEKO Payment Methods (from `config/jeko.php`):
- **wave** → Wave
- **orange** → Orange Money  
- **mtn** → MTN Money
- **moov** → Moov Money  
- **djamo** → Djamo

### Client Payment Methods:
The JEKO payment method selector widget (`jeko_payment_method_selector.dart`) dynamically loads from the API (`GET jeko/payment-methods`). It has color mappings for: wave, orange, mtn, moov, djamo (L107-113).

**Verdict:** ✅ The client dynamically fetches payment methods from the backend, so new methods (wave, mtn, djamo) will appear automatically. The color/icon mapping has entries for all 5 methods. **However**, the old `WalletRemoteDataSource.initiateRecharge()` calls `client-wallet/recharge` which uses a `provider` field (not `payment_method`) — this older recharge path may not support all JEKO methods.

---

## 4. TOKEN REFRESH ANALYSIS

### Backend:
- `POST /auth/refresh-token` endpoint exists (L109 in routes)
- `AuthService::refreshToken()` method deletes current token and creates new one

### Client:
- ❌ **No token refresh implemented**
- On 401, `ApiInterceptor` removes token and fires logout
- `EnhancedApiInterceptor` (unused) also just removes token on 401
- No background token refresh timer
- No proactive refresh before expiry

### Recommendation:
Implement in `EnhancedApiInterceptor`:
1. On 401, attempt `POST /auth/refresh-token` with current (expired) token
2. On success, update stored token and retry original request  
3. On failure, logout user

---

## 5. WEBSOCKET / REAL-TIME TRACKING ANALYSIS

### Implementation: ✅ Well-done
- `WebSocketService` in `lib/core/services/websocket_service.dart` implements full Pusher protocol
- Connects to Laravel Reverb WebSocket server
- Handles: connection_established, ping/pong, subscribe/unsubscribe
- Auto-reconnect with exponential backoff (3s → 6s → 12s → 24s → 48s, max 5 attempts)
- Channel subscription: `order.{orderId}` (public channels)

### Issues:
1. **Public channels only** — No private channel authentication. Backend likely uses private channels (`private-order.{id}`) for security.
2. **WebSocket URL hardcoded** — Should use `GET /config/websocket` from backend
3. **No auth token sent in WebSocket** — Private channels need Pusher auth endpoint

### Tracking BLoC: ✅ Good
- Handles events: `location.updated`, `tracking.update`, `status.changed`, plus Laravel event class names
- Route history stored (max 100 points)
- ETA and distance updates handled
- Proper cleanup on stop

---

## 6. FIREBASE AUTH INTEGRATION ANALYSIS

### Implementation: ✅ Good for Mobile
- `FirebasePhoneAuthService` properly implements `verifyPhoneNumber()`
- Handles auto-verification (Android), code sent, timeout
- Web disabled (reCAPTCHA complexity)
- Firebase ID token sent to backend for server-side verification

### Issues:
1. **Two different Firebase projects** — `firebase_options.dart` uses `ouaga-chap` for web/macOS and `ouaga-chap-a888e` for Android/iOS. This means:
   - FCM tokens from Android/iOS go to project `ouaga-chap-a888e`
   - Backend must be configured to send push to BOTH projects
   - Phone auth on web uses different project than mobile
2. **No Firebase initialization error handling** — `enhanced_notification_service.dart` initializes Firebase but `main.dart` doesn't wrap it in try/catch for platforms where Firebase isn't configured (Linux).

---

## 7. ERROR HANDLING & OFFLINE SUPPORT

### Error Handling: ⚡ Partial
- ✅ `ApiError` class with typed errors (network, server, timeout, unauthorized, etc.)
- ✅ French error messages throughout
- ✅ `AuthBloc._extractErrorMessage()` handles all HTTP status codes gracefully
- ❌ Most BLoCs catch `Exception` and call `.toString()` instead of using `ApiError`
- ❌ No global error boundary widget

### Offline Support: ❌ Minimal
- `ConnectivityService` exists but is NOT registered or used
- `OfflineInterceptor` exists but is NOT registered in Dio
- `CacheService` exists but is NOT used in any repository
- `network_aware_widgets.dart` exists but likely can't function without ConnectivityService
- No offline queue for mutations (creating orders, etc.)

---

## 8. STATE PERSISTENCE

- ✅ Auth token persisted in SharedPreferences
- ✅ User data cached locally (JSON in SharedPreferences)
- ✅ Theme mode persisted
- ✅ Onboarding completion flag persisted
- ❌ Orders NOT cached — every navigation reloads from API
- ❌ Wallet balance NOT cached
- ❌ Notifications NOT cached

---

## 9. TEST COVERAGE ANALYSIS

### Test Files: 70+ files
**Covered features:**
- auth (14 test files): datasources, models, repos, entities, usecases, bloc, events, states, pages
- order (10 test files): datasources, models, repos, entities, usecases, bloc, events, states
- wallet (10 test files): datasources, models, repos, entities, bloc, events, states, JEKO
- notification (8 test files): datasources, repos, entities, usecases, bloc, events, states
- support (8 test files): datasources, repos, entities, bloc, events, states
- incoming (5 test files): datasources, repos, entities, bloc, events
- core (8 test files): network, theme, utils, widgets

**NOT covered:**
- ❌ tracking feature (0 tests)
- ❌ home feature (0 tests)
- ❌ profile feature (0 tests)
- ❌ settings feature (0 tests)
- ❌ onboarding feature (0 tests)
- ❌ promo feature (0 tests)
- ❌ address feature (0 tests)
- ❌ Services (0 tests for 19 service files)
- ❌ Integration tests (0 files)
- ❌ Widget tests for feature pages (minimal)

---

## 10. LOCALIZATION ANALYSIS

### Status: ⚠️ Infrastructure exists but unused
- `AppLocalizations` class has 200+ translated strings for FR and EN
- `LocalizationsDelegate` defined
- `supportedLocales` defined: `fr_FR`, `en_US`

### Issues:
1. `MaterialApp.router` doesn't include `localizationsDelegates` or `supportedLocales`
2. No widget uses `AppLocalizations.of(context).translate('key')`
3. All UI text is hardcoded in French strings
4. `LocaleService` exists at `lib/core/services/locale_service.dart` but never used

---

## 11. RECOMMENDED IMPROVEMENTS (Priority Order)

### P0 — Must Fix Before Release

1. **Fix client registration flow** — Remove `auth/register` call. Use `auth/otp/send` for both login and registration. After first OTP verification, call `PUT auth/profile` to set user name.

2. **Implement token refresh** — Use `POST /auth/refresh-token` before logging out on 401.

3. **Fix API path consistency** — Remove all leading slashes from API paths to ensure Dio baseUrl resolution works correctly.

4. **Fix `RadioGroup` compile error** — Replace with standard `Column` of `RadioListTile` widgets.

5. **Don't load wallet before auth check** — Move `LoadWallet` to after `AuthAuthenticated` state.

6. **Fix JEKO payment deep link routing** — Add JEKO routes to `AppRouter`.

### P1 — High Priority

7. **Use `EnhancedApiInterceptor`** instead of basic one — get retry logic, caching, and logging.

8. **Register and use `ConnectivityService`** — Enable offline awareness.

9. **Use backend price estimation** — Call `POST /orders/estimate` instead of local Haversine.

10. **Use `flutter_secure_storage`** for auth token instead of SharedPreferences.

11. **Restrict Firebase API keys** — Set up App Check and domain restrictions.

12. **Fetch WebSocket config from backend** — Use `GET /config/websocket` instead of hardcoded values.

13. **Implement private WebSocket channels** — Use auth token for `private-order.{id}` channels.

### P2 — Medium Priority

14. **Wire up localization** — Add delegates to MaterialApp, use `AppLocalizations.of(context)`.

15. **Cache orders and wallet locally** — Use `CacheService` in repositories.

16. **Add payment method to order creation** — Let users choose payment at order time.

17. **Load promotions from API** — Use `GET /promo-codes/available`.

18. **Fix deep link subscription leak** — Store and cancel subscription in `dispose()`.

19. **Add integration tests** — At minimum for auth flow and order creation.

20. **Add tests for tracking, home, profile** — Currently 0% covered.

### P3 — Nice to Have

21. **Consolidate wallet recharge paths** — Remove old `client-wallet/recharge` in favor of JEKO.

22. **Add order chat** — Backend has `orders/{order}/chat` endpoints.

23. **Add traffic incidents** — Backend has `traffic/incidents` endpoints.

24. **Add app loading/error boundaries** — Global error widget.

25. **Remove unused `injectable`/`injectable_generator`** dependencies — DI is manual.

---

## 12. SPECIFIC CODE CHANGES NEEDED

### Change 1: Fix Registration Flow
```dart
// auth_remote_datasource.dart — REMOVE register() method
// auth_repository.dart — REMOVE register() method  
// auth_repository_impl.dart — REMOVE register() method
// register_usecase.dart — CHANGE to just call sendOtp

// In auth_bloc.dart _onAuthRegisterRequested:
// 1. Call loginUseCase (sends OTP) instead of registerUseCase
// 2. After OTP verification, call updateProfile with the name
```

### Change 2: Implement Token Refresh
```dart
// In api_interceptor.dart or enhanced_interceptors.dart:
@override
Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    final token = _prefs.getString(_tokenKey);
    if (token != null) {
      try {
        final refreshDio = Dio(BaseOptions(
          baseUrl: _dio.options.baseUrl,
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        ));
        final response = await refreshDio.post('auth/refresh-token');
        final newToken = response.data['data']['token'];
        await _prefs.setString(_tokenKey, newToken);
        
        // Retry original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await refreshDio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _prefs.remove(_tokenKey);
        _logoutController.add(null);
      }
    }
  }
  super.onError(err, handler);
}
```

### Change 3: Fix API Paths
```dart
// In all datasource files, ensure NO leading slashes:
// WRONG: '/orders/$orderId'
// RIGHT: 'orders/$orderId'

// Files to fix:
// - auth_remote_datasource.dart L103: '/auth/logout' → 'auth/logout'
// - order_remote_datasource.dart L103: '/orders/$orderId' → 'orders/$orderId'
// - order_remote_datasource.dart L111: '/orders/$orderId/cancel' → 'orders/$orderId/cancel'
// - order_remote_datasource.dart L120: '/orders/calculate-price' → 'orders/estimate'
```

### Change 4: Fix Wallet Loading Timing
```dart
// In main.dart, remove ..add(const LoadWallet()) from WalletBloc provider:
BlocProvider<WalletBloc>(
  create: (_) => getIt<WalletBloc>(), // Don't load here
),

// In home_page.dart initState, add:
context.read<WalletBloc>().add(const LoadWallet());
```

### Change 5: Use Backend Price Estimation  
```dart
// In order_bloc.dart, replace _onCalculatePriceRequested:
Future<void> _onCalculatePriceRequested(
  CalculatePriceRequested event,
  Emitter<OrderState> emit,
) async {
  try {
    // Use the remote datasource instead of local calculation
    final price = await getIt<OrderRemoteDataSource>().calculatePrice(
      pickupLatitude: event.pickupLatitude,
      pickupLongitude: event.pickupLongitude,
      deliveryLatitude: event.deliveryLatitude,
      deliveryLongitude: event.deliveryLongitude,
    );
    // Need to also get distance from backend response
    emit(PriceCalculated(price: price, distance: 0)); // or parse distance
  } catch (e) {
    // Fallback to local calculation
    // ... existing Haversine code ...
  }
}
```

---

## 13. DEPENDENCY AUDIT

| Dependency | Version | Status |
|---|---|---|
| flutter_bloc | ^9.1.1 | ✅ Current |
| dio | ^5.9.0 | ✅ Current |
| go_router | ^17.0.1 | ✅ Current |
| get_it | ^9.2.0 | ✅ Current |
| injectable | ^2.7.1+4 | ⚠️ Unused (DI is manual) |
| injectable_generator | ^2.12.0 | ⚠️ Unused dev dep |
| google_maps_flutter | ^2.14.0 | ✅ Current |
| firebase_core | ^4.4.0 | ✅ Current |
| firebase_auth | ^6.1.4 | ✅ Current |
| firebase_messaging | ^16.1.1 | ✅ Current |
| web_socket_channel | ^3.0.1 | ✅ Current |
| shared_preferences | ^2.5.4 | ⚠️ Not secure for tokens |
| flutter_secure_storage | N/A | ❌ Missing — needed |
| build_runner | ^2.10.5 | ⚠️ Unused (no code gen) |

---

## 14. SUMMARY SCORECARD

| Area | Score | Notes |
|---|---|---|
| Architecture | 8/10 | Clean Architecture well-applied |
| Code Quality | 6/10 | Good patterns but inconsistencies |
| API Integration | 4/10 | Critical registration bug, no token refresh |
| Payment Methods | 8/10 | JEKO dynamic loading supports all 5 methods |
| Real-time Tracking | 7/10 | Good WebSocket impl, missing private channels |
| Firebase Integration | 7/10 | Good phone auth, dual project concern |
| Error Handling | 5/10 | Infrastructure exists but partially unused |
| Offline Support | 2/10 | Services exist but none are wired up |
| Security | 4/10 | Token in SharedPrefs, API keys exposed |
| Localization | 3/10 | Full FR/EN translations but not connected |
| Testing | 6/10 | 70+ files but 0% for 7 features and services |
| State Persistence | 4/10 | Only auth data persisted |

**Overall: 5.3/10** — Solid architecture foundation with critical integration bugs that must be fixed before release.
