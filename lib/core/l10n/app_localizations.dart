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
      'otp_sent_confirmation': 'Code de vérification envoyé',
      'otp_sent_registration': 'Compte créé ! Code de vérification envoyé',

      // Onboarding
      'onboarding_title_1': 'Livraison rapide',
      'onboarding_desc_1':
          'Faites livrer vos colis rapidement partout à Ouagadougou',
      'onboarding_title_2': 'Suivi en temps réel',
      'onboarding_desc_2': 'Suivez votre livraison en direct sur la carte',
      'onboarding_title_3': 'Paiement facile',
      'onboarding_desc_3': 'Payez facilement avec Mobile Money',
      'skip': 'Passer',
      'next': 'Suivant',
      'previous': 'Précédent',
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
      'pay_cash_subtitle': 'Payer à la livraison',
      'pay_mobile_money_subtitle': 'Payer par mobile money',
      'pay_wave_subtitle': 'Payer par Wave',

      // Wallet
      'wallet': 'Portefeuille',
      'wallet_title': 'Mon Portefeuille',
      'balance': 'Solde',
      'add_funds': 'Recharger',
      'transactions': 'Transactions',
      'recent_transactions': 'Transactions récentes',
      'transaction_history': 'Historique',
      'no_transactions': 'Aucune transaction pour le moment',
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
      'connection_restored': 'Connexion rétablie',
      'no_internet': 'Pas de connexion internet',
      'error_server': 'Erreur serveur. Réessayez plus tard.',
      'error_timeout': 'Délai d\'attente dépassé. Réessayez.',
      'error_unknown': 'Une erreur est survenue.',
      'error_location': 'Impossible d\'obtenir votre position.',
      'error_permission': 'Permission refusée.',
      'session_expired': 'Session expirée. Reconnectez-vous.',
      'fill_required_fields': 'Veuillez remplir les champs obligatoires',
      'please_select_rating': 'Veuillez sélectionner une note',
      'enter_your_name': 'Veuillez entrer votre nom',
      'name_min_length': 'Le nom doit contenir au moins 3 caractères',
      'loading_notifications': 'Chargement des notifications...',
      'loading_tracking': 'Chargement du suivi...',

      // Empty states
      'empty_orders': 'Vous n\'avez pas encore de commande',
      'empty_notifications': 'Aucune notification',
      'empty_transactions': 'Aucune transaction',
      'start_order': 'Créer votre première commande',

      // Currency
      'currency': 'FCFA',

      // Home - Services
      'services': 'Services',
      'services_count': '6 services',
      'service_send': 'Envoyer',
      'service_send_subtitle': 'Livraison rapide',
      'service_addresses': 'Adresses',
      'service_addresses_subtitle': 'Carnet d\'adresses',
      'service_orders': 'Commandes',
      'service_orders_subtitle': 'Historique',
      'service_topup': 'Recharger',
      'service_topup_subtitle': 'Mobile Money',
      'service_support': 'Support',
      'service_support_subtitle': '24/7',
      'service_profile': 'Profil',
      'service_profile_subtitle': 'Mon compte',
      'new_delivery': 'Nouvelle livraison',
      'current_offers': 'Offres du moment',
      'promo_code_copied': 'Code %s copié !',
      'promo_applied_snack': 'Code promo %s appliqué !',
      'referral_validated': 'Parrainage %s validé !',

      // Addresses
      'my_addresses': 'Mes adresses',
      'add_address': 'Ajouter une adresse',
      'no_saved_addresses': 'Aucune adresse sauvegardée',
      'default_label': 'Par défaut',
      'set_as_default': 'Définir par défaut',
      'address_set_default': 'Adresse définie par défaut',
      'delete_address_title': 'Supprimer l\'adresse ?',
      'address_deleted': 'Adresse supprimée',
      'edit_address': 'Modifier l\'adresse',
      'new_address': 'Nouvelle adresse',
      'address_type': 'Type d\'adresse',
      'address_name_label': 'Nom de l\'adresse *',
      'full_address_label': 'Adresse complète *',
      'contact_on_site': 'Contact sur place (optionnel)',
      'contact_name': 'Nom du contact',
      'contact_phone': 'Téléphone du contact',
      'instructions': 'Instructions',
      'set_default_address': 'Définir comme adresse par défaut',
      'address_added': 'Adresse ajoutée',

      // Jeko Payment
      'select_payment_method': 'Veuillez sélectionner un mode de paiement',
      'min_amount_100': 'Montant minimum: 100 FCFA',
      'cannot_open_payment_link': 'Impossible d\'ouvrir le lien de paiement',
      'recharge_wallet': 'Recharger mon portefeuille',
      'mobile_recharge': 'Recharge Mobile Money',
      'recharge_wallet_subtitle': 'Rechargez votre portefeuille facilement',
      'quick_amounts': 'Montants rapides',
      'custom_amount': 'Montant personnalisé',
      'enter_amount': 'Entrez le montant',
      'no_payment_methods': 'Aucune méthode de paiement disponible',
      'secure_payment': 'Paiement sécurisé via JEKO...',
      'payment_in_progress': 'Paiement en cours',
      'redirected_to_payment':
          'Vous avez été redirigé vers votre application de paiement.',
      'complete_payment_msg':
          'Complétez le paiement puis revenez ici pour vérifier le statut.',
      'i_have_paid': 'J\'ai payé',
      'payment_success_title': 'Paiement réussi',

      // Incoming Orders
      'incoming_parcels': 'Colis à recevoir',
      'pending': 'En attente',
      'on_the_way': 'En route',
      'in_progress': 'En cours',
      'no_incoming_parcels': 'Aucun colis à recevoir',
      'no_incoming_parcels_desc':
          'Quand quelqu\'un vous enverra un colis, il apparaîtra ici.',
      'your_courier': 'Votre coursier',
      'confirmation_code': 'Code de confirmation',
      'show_code_to_courier': 'Montrez ce code au coursier à la livraison',
      'track': 'Suivre',
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
      'otp_sent_confirmation': 'Verification code sent',
      'otp_sent_registration': 'Account created! Verification code sent',

      // Onboarding
      'onboarding_title_1': 'Fast Delivery',
      'onboarding_desc_1':
          'Get your packages delivered quickly anywhere in Ouagadougou',
      'onboarding_title_2': 'Real-time Tracking',
      'onboarding_desc_2': 'Track your delivery live on the map',
      'onboarding_title_3': 'Easy Payment',
      'onboarding_desc_3': 'Pay easily with Mobile Money',
      'skip': 'Skip',
      'next': 'Next',
      'previous': 'Previous',
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
      'pay_cash_subtitle': 'Pay on delivery',
      'pay_mobile_money_subtitle': 'Pay with mobile money',
      'pay_wave_subtitle': 'Pay with Wave',

      // Wallet
      'wallet': 'Wallet',
      'wallet_title': 'My Wallet',
      'balance': 'Balance',
      'add_funds': 'Add Funds',
      'transactions': 'Transactions',
      'recent_transactions': 'Recent transactions',
      'transaction_history': 'History',
      'no_transactions': 'No transactions yet',
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
      'connection_restored': 'Connection restored',
      'no_internet': 'No internet connection',
      'error_server': 'Server error. Try again later.',
      'error_timeout': 'Request timed out. Try again.',
      'error_unknown': 'An error occurred.',
      'error_location': 'Unable to get your location.',
      'error_permission': 'Permission denied.',
      'session_expired': 'Session expired. Please login again.',
      'fill_required_fields': 'Please fill in the required fields',
      'please_select_rating': 'Please select a rating',
      'enter_your_name': 'Please enter your name',
      'name_min_length': 'Name must be at least 3 characters',
      'loading_notifications': 'Loading notifications...',
      'loading_tracking': 'Loading tracking...',

      // Empty states
      'empty_orders': 'You don\'t have any orders yet',
      'empty_notifications': 'No notifications',
      'empty_transactions': 'No transactions',
      'start_order': 'Create your first order',

      // Currency
      'currency': 'FCFA',

      // Home - Services
      'services': 'Services',
      'services_count': '6 services',
      'service_send': 'Send',
      'service_send_subtitle': 'Fast delivery',
      'service_addresses': 'Addresses',
      'service_addresses_subtitle': 'My address book',
      'service_orders': 'Orders',
      'service_orders_subtitle': 'History',
      'service_topup': 'Top up',
      'service_topup_subtitle': 'Mobile Money',
      'service_support': 'Support',
      'service_support_subtitle': '24/7',
      'service_profile': 'Profile',
      'service_profile_subtitle': 'My account',
      'new_delivery': 'New delivery',
      'current_offers': 'Current offers',
      'promo_code_copied': 'Code %s copied!',
      'promo_applied_snack': 'Promo code %s applied!',
      'referral_validated': 'Referral %s validated!',

      // Addresses
      'my_addresses': 'My addresses',
      'add_address': 'Add address',
      'no_saved_addresses': 'No saved addresses',
      'default_label': 'Default',
      'set_as_default': 'Set as default',
      'address_set_default': 'Address set as default',
      'delete_address_title': 'Delete address?',
      'address_deleted': 'Address deleted',
      'edit_address': 'Edit address',
      'new_address': 'New address',
      'address_type': 'Address type',
      'address_name_label': 'Address name *',
      'full_address_label': 'Full address *',
      'contact_on_site': 'On-site contact (optional)',
      'contact_name': 'Contact name',
      'contact_phone': 'Contact phone',
      'instructions': 'Instructions',
      'set_default_address': 'Set as default address',
      'address_added': 'Address added',

      // Jeko Payment
      'select_payment_method': 'Please select a payment method',
      'min_amount_100': 'Minimum amount: 100 FCFA',
      'cannot_open_payment_link': 'Unable to open payment link',
      'recharge_wallet': 'Top up my wallet',
      'mobile_recharge': 'Mobile Money Top-up',
      'recharge_wallet_subtitle': 'Top up your wallet easily',
      'quick_amounts': 'Quick amounts',
      'custom_amount': 'Custom amount',
      'enter_amount': 'Enter amount',
      'no_payment_methods': 'No payment methods available',
      'secure_payment': 'Secure payment via JEKO...',
      'payment_in_progress': 'Payment in progress',
      'redirected_to_payment': 'You have been redirected to your payment app.',
      'complete_payment_msg':
          'Complete the payment then come back here to check the status.',
      'i_have_paid': 'I have paid',
      'payment_success_title': 'Payment successful',

      // Incoming Orders
      'incoming_parcels': 'Incoming parcels',
      'pending': 'Pending',
      'on_the_way': 'On the way',
      'in_progress': 'In progress',
      'no_incoming_parcels': 'No incoming parcels',
      'no_incoming_parcels_desc':
          'When someone sends you a parcel, it will appear here.',
      'your_courier': 'Your courier',
      'confirmation_code': 'Confirmation code',
      'show_code_to_courier': 'Show this code to the courier upon delivery',
      'track': 'Track',
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
  String get payCashSubtitle => translate('pay_cash_subtitle');
  String get payMobileMoneySubtitle => translate('pay_mobile_money_subtitle');
  String get payWaveSubtitle => translate('pay_wave_subtitle');
  String get fillRequiredFields => translate('fill_required_fields');
  String get pleaseSelectRating => translate('please_select_rating');
  String get enterYourName => translate('enter_your_name');
  String get nameMinLength => translate('name_min_length');
  String get loadingNotifications => translate('loading_notifications');
  String get loadingTracking => translate('loading_tracking');

  // Wallet
  String get wallet => translate('wallet');
  String get walletTitle => translate('wallet_title');
  String get balance => translate('balance');
  String get addFunds => translate('add_funds');
  String get transactions => translate('transactions');
  String get recentTransactions => translate('recent_transactions');
  String get noTransactions => translate('no_transactions');
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

  // Home - Services
  String get services => translate('services');
  String get servicesCount => translate('services_count');
  String get newDelivery => translate('new_delivery');
  String get currentOffers => translate('current_offers');
  String get myAddresses => translate('my_addresses');
  String get addAddress => translate('add_address');
  String get defaultLabel => translate('default_label');
  String get incomingParcels => translate('incoming_parcels');
  String get paymentInProgress => translate('payment_in_progress');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
