import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Gère les traductions de l'application OUAGA CHAP
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'), // Français (langue principale)
    Locale('en', 'US'), // Anglais
  ];

  // Récupère la traduction pour une clé donnée
  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }

  // === TRADUCTIONS ===
  static final Map<String, Map<String, String>> _localizedStrings = {
    'fr': {
      // General
      'app_name': 'OUAGA CHAP',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'close': 'Fermer',
      'retry': 'Réessayer',
      'ok': 'OK',
      'yes': 'Oui',
      'no': 'Non',
      'search': 'Rechercher',
      'no_results': 'Aucun résultat',
      'see_all': 'Voir tout',

      // Auth
      'welcome': 'Bienvenue',
      'welcome_back': 'Bon retour !',
      'login': 'Connexion',
      'logout': 'Déconnexion',
      'logout_confirm': 'Voulez-vous vraiment vous déconnecter ?',
      'phone_number': 'Numéro de téléphone',
      'enter_phone': 'Entrez votre numéro',
      'phone_hint': '70 00 00 00',
      'continue_btn': 'Continuer',
      'otp_verification': 'Vérification OTP',
      'otp_sent': 'Un code a été envoyé au',
      'enter_otp': 'Entrez le code',
      'resend_otp': 'Renvoyer le code',
      'resend_in': 'Renvoyer dans',
      'invalid_phone': 'Numéro de téléphone invalide',
      'invalid_otp': 'Code OTP invalide',
      'otp_expired': 'Code expiré',

      // Onboarding
      'onboarding_title_1': 'Livraison rapide',
      'onboarding_desc_1': 'Faites livrer vos colis rapidement partout à Ouagadougou',
      'onboarding_title_2': 'Suivi en temps réel',
      'onboarding_desc_2': 'Suivez votre livraison en direct sur la carte',
      'onboarding_title_3': 'Paiement facile',
      'onboarding_desc_3': 'Payez facilement avec Mobile Money',
      'skip': 'Passer',
      'next': 'Suivant',
      'get_started': 'Commencer',

      // Home
      'home': 'Accueil',
      'hello': 'Bonjour',
      'new_order': 'Nouvelle commande',
      'recent_orders': 'Commandes récentes',
      'active_orders': 'Commandes en cours',
      'no_active_orders': 'Aucune commande en cours',

      // Order
      'order': 'Commande',
      'orders': 'Commandes',
      'order_history': 'Historique',
      'create_order': 'Créer une commande',
      'pickup_location': 'Lieu de ramassage',
      'pickup_details': 'Détails du ramassage',
      'dropoff_location': 'Lieu de livraison',
      'dropoff_details': 'Détails de livraison',
      'select_on_map': 'Sélectionner sur la carte',
      'sender_name': 'Nom de l\'expéditeur',
      'sender_phone': 'Téléphone de l\'expéditeur',
      'receiver_name': 'Nom du destinataire',
      'receiver_phone': 'Téléphone du destinataire',
      'package_description': 'Description du colis',
      'package_size': 'Taille du colis',
      'small': 'Petit',
      'medium': 'Moyen',
      'large': 'Grand',
      'extra_large': 'Très grand',
      'distance': 'Distance',
      'estimated_time': 'Temps estimé',
      'estimated_price': 'Prix estimé',
      'confirm_order': 'Confirmer la commande',
      'order_confirmed': 'Commande confirmée !',
      'searching_courier': 'Recherche d\'un coursier...',
      'courier_assigned': 'Coursier assigné',
      'courier_arriving': 'Coursier en route',
      'package_collected': 'Colis récupéré',
      'in_delivery': 'En livraison',
      'delivered': 'Livré',
      'cancelled': 'Annulé',
      'cancel_order': 'Annuler la commande',
      'cancel_order_confirm': 'Voulez-vous vraiment annuler cette commande ?',
      'order_cancelled': 'Commande annulée',

      // Tracking
      'track_order': 'Suivre la commande',
      'live_tracking': 'Suivi en direct',
      'call_courier': 'Appeler le coursier',
      'message_courier': 'Message',

      // Payment
      'payment': 'Paiement',
      'pay_now': 'Payer maintenant',
      'payment_method': 'Mode de paiement',
      'mobile_money': 'Mobile Money',
      'orange_money': 'Orange Money',
      'moov_money': 'Moov Money',
      'cash': 'Espèces',
      'payment_success': 'Paiement réussi !',
      'payment_failed': 'Échec du paiement',
      'payment_pending': 'Paiement en attente',
      'total_amount': 'Montant total',
      'base_fare': 'Tarif de base',
      'distance_fare': 'Tarif distance',
      'service_fee': 'Frais de service',

      // Wallet
      'wallet': 'Portefeuille',
      'balance': 'Solde',
      'add_funds': 'Recharger',
      'transactions': 'Transactions',
      'transaction_history': 'Historique',
      'no_transactions': 'Aucune transaction',
      'recharge': 'Recharger',
      'recharge_amount': 'Montant à recharger',
      'recharge_success': 'Recharge réussie !',
      'min_amount': 'Montant minimum : ',

      // Profile
      'profile': 'Profil',
      'edit_profile': 'Modifier le profil',
      'full_name': 'Nom complet',
      'email': 'Email',
      'change_photo': 'Changer la photo',
      'update_profile': 'Mettre à jour',
      'profile_updated': 'Profil mis à jour !',
      'settings': 'Paramètres',
      'notifications': 'Notifications',
      'language': 'Langue',
      'french': 'Français',
      'english': 'English',
      'dark_mode': 'Mode sombre',
      'about': 'À propos',
      'help_support': 'Aide & Support',
      'terms_conditions': 'Conditions d\'utilisation',
      'privacy_policy': 'Politique de confidentialité',
      'version': 'Version',

      // Support
      'support': 'Support',
      'contact_us': 'Nous contacter',
      'faq': 'FAQ',
      'send_message': 'Envoyer un message',
      'message_sent': 'Message envoyé !',
      'subject': 'Sujet',
      'your_message': 'Votre message',

      // Rating
      'rate_courier': 'Noter le coursier',
      'rate_delivery': 'Noter la livraison',
      'add_comment': 'Ajouter un commentaire',
      'comment_placeholder': 'Comment s\'est passée la livraison ?',
      'submit_rating': 'Envoyer',
      'thanks_rating': 'Merci pour votre avis !',

      // Promo
      'promo_code': 'Code promo',
      'enter_promo': 'Entrez votre code promo',
      'apply': 'Appliquer',
      'promo_applied': 'Code promo appliqué !',
      'invalid_promo': 'Code promo invalide',
      'expired_promo': 'Code promo expiré',

      // Errors
      'error_network': 'Erreur de connexion. Vérifiez votre internet.',
      'error_server': 'Erreur serveur. Réessayez plus tard.',
      'error_timeout': 'Délai d\'attente dépassé. Réessayez.',
      'error_unknown': 'Une erreur est survenue.',
      'error_location': 'Impossible d\'obtenir votre position.',
      'error_permission': 'Permission refusée.',
      'session_expired': 'Session expirée. Reconnectez-vous.',

      // Empty states
      'empty_orders': 'Vous n\'avez pas encore de commande',
      'empty_notifications': 'Aucune notification',
      'empty_transactions': 'Aucune transaction',
      'start_order': 'Créer votre première commande',

      // Currency
      'currency': 'FCFA',
    },
    'en': {
      // General
      'app_name': 'OUAGA CHAP',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'retry': 'Retry',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'search': 'Search',
      'no_results': 'No results',
      'see_all': 'See all',

      // Auth
      'welcome': 'Welcome',
      'welcome_back': 'Welcome back!',
      'login': 'Login',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'phone_number': 'Phone number',
      'enter_phone': 'Enter your number',
      'phone_hint': '70 00 00 00',
      'continue_btn': 'Continue',
      'otp_verification': 'OTP Verification',
      'otp_sent': 'A code was sent to',
      'enter_otp': 'Enter the code',
      'resend_otp': 'Resend code',
      'resend_in': 'Resend in',
      'invalid_phone': 'Invalid phone number',
      'invalid_otp': 'Invalid OTP code',
      'otp_expired': 'Code expired',

      // Onboarding
      'onboarding_title_1': 'Fast Delivery',
      'onboarding_desc_1': 'Get your packages delivered quickly anywhere in Ouagadougou',
      'onboarding_title_2': 'Real-time Tracking',
      'onboarding_desc_2': 'Track your delivery live on the map',
      'onboarding_title_3': 'Easy Payment',
      'onboarding_desc_3': 'Pay easily with Mobile Money',
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',

      // Home
      'home': 'Home',
      'hello': 'Hello',
      'new_order': 'New Order',
      'recent_orders': 'Recent Orders',
      'active_orders': 'Active Orders',
      'no_active_orders': 'No active orders',

      // Order
      'order': 'Order',
      'orders': 'Orders',
      'order_history': 'History',
      'create_order': 'Create Order',
      'pickup_location': 'Pickup Location',
      'pickup_details': 'Pickup Details',
      'dropoff_location': 'Dropoff Location',
      'dropoff_details': 'Dropoff Details',
      'select_on_map': 'Select on map',
      'sender_name': 'Sender name',
      'sender_phone': 'Sender phone',
      'receiver_name': 'Receiver name',
      'receiver_phone': 'Receiver phone',
      'package_description': 'Package description',
      'package_size': 'Package size',
      'small': 'Small',
      'medium': 'Medium',
      'large': 'Large',
      'extra_large': 'Extra large',
      'distance': 'Distance',
      'estimated_time': 'Estimated time',
      'estimated_price': 'Estimated price',
      'confirm_order': 'Confirm Order',
      'order_confirmed': 'Order confirmed!',
      'searching_courier': 'Searching for a courier...',
      'courier_assigned': 'Courier assigned',
      'courier_arriving': 'Courier on the way',
      'package_collected': 'Package collected',
      'in_delivery': 'In delivery',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'cancel_order': 'Cancel Order',
      'cancel_order_confirm': 'Are you sure you want to cancel this order?',
      'order_cancelled': 'Order cancelled',

      // Tracking
      'track_order': 'Track Order',
      'live_tracking': 'Live Tracking',
      'call_courier': 'Call Courier',
      'message_courier': 'Message',

      // Payment
      'payment': 'Payment',
      'pay_now': 'Pay Now',
      'payment_method': 'Payment Method',
      'mobile_money': 'Mobile Money',
      'orange_money': 'Orange Money',
      'moov_money': 'Moov Money',
      'cash': 'Cash',
      'payment_success': 'Payment successful!',
      'payment_failed': 'Payment failed',
      'payment_pending': 'Payment pending',
      'total_amount': 'Total amount',
      'base_fare': 'Base fare',
      'distance_fare': 'Distance fare',
      'service_fee': 'Service fee',

      // Wallet
      'wallet': 'Wallet',
      'balance': 'Balance',
      'add_funds': 'Add Funds',
      'transactions': 'Transactions',
      'transaction_history': 'History',
      'no_transactions': 'No transactions',
      'recharge': 'Recharge',
      'recharge_amount': 'Amount to recharge',
      'recharge_success': 'Recharge successful!',
      'min_amount': 'Minimum amount: ',

      // Profile
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'full_name': 'Full name',
      'email': 'Email',
      'change_photo': 'Change photo',
      'update_profile': 'Update',
      'profile_updated': 'Profile updated!',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'language': 'Language',
      'french': 'Français',
      'english': 'English',
      'dark_mode': 'Dark mode',
      'about': 'About',
      'help_support': 'Help & Support',
      'terms_conditions': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',
      'version': 'Version',

      // Support
      'support': 'Support',
      'contact_us': 'Contact Us',
      'faq': 'FAQ',
      'send_message': 'Send Message',
      'message_sent': 'Message sent!',
      'subject': 'Subject',
      'your_message': 'Your message',

      // Rating
      'rate_courier': 'Rate Courier',
      'rate_delivery': 'Rate Delivery',
      'add_comment': 'Add a comment',
      'comment_placeholder': 'How was the delivery?',
      'submit_rating': 'Submit',
      'thanks_rating': 'Thanks for your feedback!',

      // Promo
      'promo_code': 'Promo Code',
      'enter_promo': 'Enter your promo code',
      'apply': 'Apply',
      'promo_applied': 'Promo code applied!',
      'invalid_promo': 'Invalid promo code',
      'expired_promo': 'Expired promo code',

      // Errors
      'error_network': 'Connection error. Check your internet.',
      'error_server': 'Server error. Try again later.',
      'error_timeout': 'Request timed out. Try again.',
      'error_unknown': 'An error occurred.',
      'error_location': 'Unable to get your location.',
      'error_permission': 'Permission denied.',
      'session_expired': 'Session expired. Please login again.',

      // Empty states
      'empty_orders': 'You don\'t have any orders yet',
      'empty_notifications': 'No notifications',
      'empty_transactions': 'No transactions',
      'start_order': 'Create your first order',

      // Currency
      'currency': 'FCFA',
    },
  };

  // === ACCESSORS ===
  String get appName => translate('app_name');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get retry => translate('retry');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get search => translate('search');
  
  // Auth
  String get welcome => translate('welcome');
  String get welcomeBack => translate('welcome_back');
  String get login => translate('login');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logout_confirm');
  String get phoneNumber => translate('phone_number');
  String get enterPhone => translate('enter_phone');
  String get continueBtn => translate('continue_btn');
  String get otpVerification => translate('otp_verification');
  String get invalidPhone => translate('invalid_phone');
  String get invalidOtp => translate('invalid_otp');
  
  // Home
  String get home => translate('home');
  String get hello => translate('hello');
  String get newOrder => translate('new_order');
  String get recentOrders => translate('recent_orders');
  String get activeOrders => translate('active_orders');
  String get noActiveOrders => translate('no_active_orders');
  
  // Orders
  String get order => translate('order');
  String get orders => translate('orders');
  String get orderHistory => translate('order_history');
  String get createOrder => translate('create_order');
  String get pickupLocation => translate('pickup_location');
  String get dropoffLocation => translate('dropoff_location');
  String get confirmOrder => translate('confirm_order');
  String get orderConfirmed => translate('order_confirmed');
  String get searchingCourier => translate('searching_courier');
  String get delivered => translate('delivered');
  String get cancelled => translate('cancelled');
  String get cancelOrder => translate('cancel_order');
  String get cancelOrderConfirm => translate('cancel_order_confirm');
  
  // Tracking
  String get trackOrder => translate('track_order');
  String get liveTracking => translate('live_tracking');
  String get callCourier => translate('call_courier');
  
  // Payment
  String get payment => translate('payment');
  String get payNow => translate('pay_now');
  String get paymentMethod => translate('payment_method');
  String get paymentSuccess => translate('payment_success');
  String get paymentFailed => translate('payment_failed');
  String get totalAmount => translate('total_amount');
  
  // Wallet
  String get wallet => translate('wallet');
  String get balance => translate('balance');
  String get addFunds => translate('add_funds');
  String get transactions => translate('transactions');
  String get recharge => translate('recharge');
  String get rechargeSuccess => translate('recharge_success');
  
  // Profile
  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get fullName => translate('full_name');
  String get email => translate('email');
  String get settings => translate('settings');
  String get notifications => translate('notifications');
  String get language => translate('language');
  String get about => translate('about');
  String get helpSupport => translate('help_support');
  String get termsConditions => translate('terms_conditions');
  String get privacyPolicy => translate('privacy_policy');
  
  // Support
  String get support => translate('support');
  String get contactUs => translate('contact_us');
  String get faq => translate('faq');
  String get sendMessage => translate('send_message');
  String get messageSent => translate('message_sent');
  
  // Rating
  String get rateCourier => translate('rate_courier');
  String get rateDelivery => translate('rate_delivery');
  String get submitRating => translate('submit_rating');
  String get thanksRating => translate('thanks_rating');
  
  // Errors
  String get errorNetwork => translate('error_network');
  String get errorServer => translate('error_server');
  String get errorTimeout => translate('error_timeout');
  String get errorUnknown => translate('error_unknown');
  String get errorLocation => translate('error_location');
  String get sessionExpired => translate('session_expired');
  
  // Empty states
  String get emptyOrders => translate('empty_orders');
  String get emptyNotifications => translate('empty_notifications');
  String get startOrder => translate('start_order');
  
  // Currency
  String get currency => translate('currency');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension pour accéder facilement aux traductions depuis un BuildContext
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  
  /// Traduit une clé
  String tr(String key) => l10n.translate(key);
}
