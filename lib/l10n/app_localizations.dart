import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sarqyt'**
  String get appTitle;

  /// No description provided for @appTitleBusiness.
  ///
  /// In en, this message translates to:
  /// **'Sarqyt Business'**
  String get appTitleBusiness;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirmTitle;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @notImplemented.
  ///
  /// In en, this message translates to:
  /// **'Not implemented'**
  String get notImplemented;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get locationNotFound;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'404 - Page not found!'**
  String get pageNotFound;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoInternet;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Try again'**
  String get errorTimeout;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again'**
  String get errorGeneric;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get errorWrongPassword;

  /// No description provided for @errorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorInvalidCredential;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already registered'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password too weak (min 6 characters)'**
  String get errorWeakPassword;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get errorInvalidEmail;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try later'**
  String get errorTooManyRequests;

  /// No description provided for @errorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get errorUserDisabled;

  /// No description provided for @errorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Operation not allowed'**
  String get errorOperationNotAllowed;

  /// No description provided for @errorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue'**
  String get errorRequiresRecentLogin;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Try again'**
  String get errorAuth;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get errorUnauthenticated;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFound;

  /// No description provided for @errorAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get errorAccessDenied;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable. Try later'**
  String get errorUnavailable;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get errorInvalidInput;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check internet'**
  String get errorNoConnection;

  /// No description provided for @errorOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Try again'**
  String get errorOperationFailed;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorPasswordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get errorPasswordTooWeak;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'The operation can\'\'t be completed (not signed in)'**
  String get errorNotSignedIn;

  /// No description provided for @errorCartUpdate.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred while updating the shopping cart'**
  String get errorCartUpdate;

  /// No description provided for @errorEmptyCart.
  ///
  /// In en, this message translates to:
  /// **'Can\'\'t place an order if the cart is empty'**
  String get errorEmptyCart;

  /// No description provided for @errorNullImage.
  ///
  /// In en, this message translates to:
  /// **'Can\'\'t upload a product with a null image'**
  String get errorNullImage;

  /// No description provided for @errorParseOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not parse order status: {status}'**
  String errorParseOrderStatus(String status);

  /// No description provided for @helloCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Hello! Create Account'**
  String get helloCreateAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password (8+ characters)'**
  String get passwordHint;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get signInFailed;

  /// No description provided for @emailCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email can\'\'t be empty'**
  String get emailCantBeEmpty;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password can\'\'t be empty'**
  String get passwordCantBeEmpty;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get passwordTooShort;

  /// No description provided for @logInToMystore.
  ///
  /// In en, this message translates to:
  /// **'LOG IN TO MYSTORE'**
  String get logInToMystore;

  /// No description provided for @logInToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get logInToYourAccount;

  /// No description provided for @emailAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address *'**
  String get emailAddressRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUpYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Sign up your food business'**
  String get signUpYourBusiness;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+7 (777) 123-4567'**
  String get phoneHint;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your data will be permanently deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get versionNumber;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @offerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Offer not found'**
  String get offerNotFound;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @addressNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Address is not specified'**
  String get addressNotSpecified;

  /// No description provided for @moreInfoAboutStore.
  ///
  /// In en, this message translates to:
  /// **'More information about store'**
  String get moreInfoAboutStore;

  /// No description provided for @offerStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String offerStatus(String status);

  /// No description provided for @availableItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Available items: {quantity}'**
  String availableItemsCount(int quantity);

  /// No description provided for @offerDetailsSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Offer details are loaded from store and product snapshot at creation time.'**
  String get offerDetailsSnapshot;

  /// No description provided for @noOffersFound.
  ///
  /// In en, this message translates to:
  /// **'No offers found'**
  String get noOffersFound;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @pickupTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup time'**
  String get pickupTime;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @nearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get nearest;

  /// No description provided for @cheapest.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get cheapest;

  /// No description provided for @soonest.
  ///
  /// In en, this message translates to:
  /// **'Soonest'**
  String get soonest;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @storeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found'**
  String get storeNotFound;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get paymentMethod;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card payment'**
  String get cardPayment;

  /// No description provided for @selectedAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Selected at checkout'**
  String get selectedAtCheckout;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @pastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past orders'**
  String get pastOrders;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumber(String number);

  /// No description provided for @itemQuantityPrefix.
  ///
  /// In en, this message translates to:
  /// **'x{quantity}'**
  String itemQuantityPrefix(int quantity);

  /// No description provided for @pickupWindow.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get pickupWindow;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @refundPending.
  ///
  /// In en, this message translates to:
  /// **'Refund pending'**
  String get refundPending;

  /// No description provided for @refundFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund failed'**
  String get refundFailed;

  /// No description provided for @leaveAReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveAReview;

  /// No description provided for @pickupTimeExpired.
  ///
  /// In en, this message translates to:
  /// **'Pickup time expired'**
  String get pickupTimeExpired;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel order?'**
  String get cancelOrderConfirm;

  /// No description provided for @cancelOrderRefund.
  ///
  /// In en, this message translates to:
  /// **'You will receive a full refund.'**
  String get cancelOrderRefund;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get yesCancel;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get activeOrders;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @noOrdersWithStatus.
  ///
  /// In en, this message translates to:
  /// **'No orders with this status'**
  String get noOrdersWithStatus;

  /// No description provided for @startPreparing.
  ///
  /// In en, this message translates to:
  /// **'Start preparing'**
  String get startPreparing;

  /// No description provided for @readyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get readyForPickup;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get markCompleted;

  /// No description provided for @noOrdersDescription.
  ///
  /// In en, this message translates to:
  /// **'Once customers start ordering, their reservations will appear here.'**
  String get noOrdersDescription;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @howWasTheStore.
  ///
  /// In en, this message translates to:
  /// **'How was the store?'**
  String get howWasTheStore;

  /// No description provided for @howWasTheOffer.
  ///
  /// In en, this message translates to:
  /// **'How was the offer?'**
  String get howWasTheOffer;

  /// No description provided for @anyComments.
  ///
  /// In en, this message translates to:
  /// **'Any comments? (optional)'**
  String get anyComments;

  /// No description provided for @tellUsAboutExperience.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience'**
  String get tellUsAboutExperience;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @itemCreated.
  ///
  /// In en, this message translates to:
  /// **'Item created'**
  String get itemCreated;

  /// No description provided for @createSurpriseBag.
  ///
  /// In en, this message translates to:
  /// **'Create surprise bag'**
  String get createSurpriseBag;

  /// No description provided for @surpriseBag.
  ///
  /// In en, this message translates to:
  /// **'Surprise Bag'**
  String get surpriseBag;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @rescueSurpriseBag.
  ///
  /// In en, this message translates to:
  /// **'Rescue a surprise bag with a selection of items'**
  String get rescueSurpriseBag;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @estimatedValueOptional.
  ///
  /// In en, this message translates to:
  /// **'Estimated value (optional)'**
  String get estimatedValueOptional;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @createItem.
  ///
  /// In en, this message translates to:
  /// **'Create item'**
  String get createItem;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly schedule'**
  String get weeklySchedule;

  /// No description provided for @setPickupWindowAndQuantity.
  ///
  /// In en, this message translates to:
  /// **'Set pickup window and quantity for each day'**
  String get setPickupWindowAndQuantity;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @customerRatings.
  ///
  /// In en, this message translates to:
  /// **'Customer ratings'**
  String get customerRatings;

  /// No description provided for @sellingNow.
  ///
  /// In en, this message translates to:
  /// **'Selling now'**
  String get sellingNow;

  /// No description provided for @quantityAvailable.
  ///
  /// In en, this message translates to:
  /// **'{quantity} available'**
  String quantityAvailable(int quantity);

  /// No description provided for @quantityPerDay.
  ///
  /// In en, this message translates to:
  /// **'{quantity} per day'**
  String quantityPerDay(int quantity);

  /// No description provided for @notReadyYet.
  ///
  /// In en, this message translates to:
  /// **'Not ready yet?'**
  String get notReadyYet;

  /// No description provided for @startSelling.
  ///
  /// In en, this message translates to:
  /// **'Start selling'**
  String get startSelling;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @nameCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name can\'\'t be empty'**
  String get nameCantBeEmpty;

  /// No description provided for @priceCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Price can\'\'t be empty'**
  String get priceCantBeEmpty;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get enterValidPrice;

  /// No description provided for @estimatedValuePositive.
  ///
  /// In en, this message translates to:
  /// **'Estimated value must be > 0'**
  String get estimatedValuePositive;

  /// No description provided for @estimatedValueGreater.
  ///
  /// In en, this message translates to:
  /// **'Estimated value must be greater than price'**
  String get estimatedValueGreater;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item details'**
  String get itemDetails;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @addEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Add your email and password'**
  String get addEmailAndPassword;

  /// No description provided for @mustAcceptPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'You must accept the privacy policy'**
  String get mustAcceptPrivacyPolicy;

  /// No description provided for @addBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Add your business details'**
  String get addBusinessDetails;

  /// No description provided for @provideBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide your business details below.'**
  String get provideBusinessDetails;

  /// No description provided for @registerYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Register your business'**
  String get registerYourBusiness;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @reviewStoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Review your store details'**
  String get reviewStoreDetails;

  /// No description provided for @welcomeToSarqyt.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sarqyt'**
  String get welcomeToSarqyt;

  /// No description provided for @noStoreFound.
  ///
  /// In en, this message translates to:
  /// **'No store found'**
  String get noStoreFound;

  /// No description provided for @letsSetUp.
  ///
  /// In en, this message translates to:
  /// **'Let\'\'s set up {name}'**
  String letsSetUp(String name);

  /// No description provided for @createYourFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Create your first item'**
  String get createYourFirstItem;

  /// No description provided for @addSurpriseBagDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a surprise bag with a pickup window and price'**
  String get addSurpriseBagDescription;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @verifyYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Verify your business'**
  String get verifyYourBusiness;

  /// No description provided for @resubmit.
  ///
  /// In en, this message translates to:
  /// **'Resubmit'**
  String get resubmit;

  /// No description provided for @startVerification.
  ///
  /// In en, this message translates to:
  /// **'Start verification'**
  String get startVerification;

  /// No description provided for @continueToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Continue to dashboard'**
  String get continueToDashboard;

  /// No description provided for @submitBusinessForPayouts.
  ///
  /// In en, this message translates to:
  /// **'Submit business details to start receiving payouts'**
  String get submitBusinessForPayouts;

  /// No description provided for @reviewingDocuments.
  ///
  /// In en, this message translates to:
  /// **'We are reviewing your documents'**
  String get reviewingDocuments;

  /// No description provided for @businessVerified.
  ///
  /// In en, this message translates to:
  /// **'Your business is verified'**
  String get businessVerified;

  /// No description provided for @verificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Verification was rejected — please resubmit'**
  String get verificationRejected;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @registeredEntity.
  ///
  /// In en, this message translates to:
  /// **'A registered business entity'**
  String get registeredEntity;

  /// No description provided for @individualOrSole.
  ///
  /// In en, this message translates to:
  /// **'An individual or sole proprietor'**
  String get individualOrSole;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillAllFields;

  /// No description provided for @verificationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Verification submitted. Processing may take up to 30 seconds...'**
  String get verificationSubmitted;

  /// No description provided for @businessInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'Business information required'**
  String get businessInfoRequired;

  /// No description provided for @whyTaxInfo.
  ///
  /// In en, this message translates to:
  /// **'Why we require your tax information'**
  String get whyTaxInfo;

  /// No description provided for @whyTaxInfoReason1.
  ///
  /// In en, this message translates to:
  /// **'We need to verify your identity and register you as a partner so we can process payouts.'**
  String get whyTaxInfoReason1;

  /// No description provided for @whyTaxInfoReason2.
  ///
  /// In en, this message translates to:
  /// **'Your information is securely stored and will only be used for compliance purposes.'**
  String get whyTaxInfoReason2;

  /// No description provided for @selectBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Select your business type'**
  String get selectBusinessType;

  /// No description provided for @areYouVatRegistered.
  ///
  /// In en, this message translates to:
  /// **'Are you vat registered?'**
  String get areYouVatRegistered;

  /// No description provided for @vatId.
  ///
  /// In en, this message translates to:
  /// **'VAT ID *'**
  String get vatId;

  /// No description provided for @companyBin.
  ///
  /// In en, this message translates to:
  /// **'Company BIN'**
  String get companyBin;

  /// No description provided for @iin.
  ///
  /// In en, this message translates to:
  /// **'Individual identification number *'**
  String get iin;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth *'**
  String get dateOfBirth;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name *'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name *'**
  String get lastName;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address line 1 *'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address line 2'**
  String get addressLine2;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code *'**
  String get postalCode;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get city;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region *'**
  String get region;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country *'**
  String get country;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @helpCentre.
  ///
  /// In en, this message translates to:
  /// **'Help centre'**
  String get helpCentre;

  /// No description provided for @dailyOperations.
  ///
  /// In en, this message translates to:
  /// **'Daily Operations'**
  String get dailyOperations;

  /// No description provided for @financials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financials;

  /// No description provided for @payoutsAndInvoices.
  ///
  /// In en, this message translates to:
  /// **'Information about payouts and invoices.'**
  String get payoutsAndInvoices;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get sharing;

  /// No description provided for @spreadTheWord.
  ///
  /// In en, this message translates to:
  /// **'Spread the word about our collaboration!'**
  String get spreadTheWord;

  /// No description provided for @commonQuestions.
  ///
  /// In en, this message translates to:
  /// **'Common Questions'**
  String get commonQuestions;

  /// No description provided for @needFurtherHelp.
  ///
  /// In en, this message translates to:
  /// **'Need any further help?'**
  String get needFurtherHelp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @chooseAStore.
  ///
  /// In en, this message translates to:
  /// **'Choose a store'**
  String get chooseAStore;

  /// No description provided for @noStoresFound.
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get noStoresFound;

  /// No description provided for @ratingDisplay.
  ///
  /// In en, this message translates to:
  /// **'{average} / 5.0'**
  String ratingDisplay(String average);

  /// No description provided for @addHighlights.
  ///
  /// In en, this message translates to:
  /// **'Add highlights'**
  String get addHighlights;

  /// No description provided for @quickCollection.
  ///
  /// In en, this message translates to:
  /// **'Quick collection'**
  String get quickCollection;

  /// No description provided for @friendlyStaff.
  ///
  /// In en, this message translates to:
  /// **'Friendly staff'**
  String get friendlyStaff;

  /// No description provided for @basedOnRatings.
  ///
  /// In en, this message translates to:
  /// **'Based on 122 ratings over the past 2 months'**
  String get basedOnRatings;

  /// No description provided for @surpriseBagIsSurprise.
  ///
  /// In en, this message translates to:
  /// **'Your surprise bag is a surprise'**
  String get surpriseBagIsSurprise;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @surpriseBagsForSale.
  ///
  /// In en, this message translates to:
  /// **'Surprise Bags for sale'**
  String get surpriseBagsForSale;

  /// No description provided for @soldCount.
  ///
  /// In en, this message translates to:
  /// **'Sold: {count}'**
  String soldCount(int count);

  /// No description provided for @totalSurpriseBags.
  ///
  /// In en, this message translates to:
  /// **'Total Surprise Bags'**
  String get totalSurpriseBags;

  /// No description provided for @flashOffer.
  ///
  /// In en, this message translates to:
  /// **'Flash offer'**
  String get flashOffer;

  /// No description provided for @createOneTimeOffer.
  ///
  /// In en, this message translates to:
  /// **'Create a one-time offer'**
  String get createOneTimeOffer;

  /// No description provided for @offerName.
  ///
  /// In en, this message translates to:
  /// **'Offer name'**
  String get offerName;

  /// No description provided for @egSurpriseBag.
  ///
  /// In en, this message translates to:
  /// **'e.g. Surprise Bag'**
  String get egSurpriseBag;

  /// No description provided for @createFlashOffer.
  ///
  /// In en, this message translates to:
  /// **'Create flash offer'**
  String get createFlashOffer;

  /// No description provided for @confirmAndStartSelling.
  ///
  /// In en, this message translates to:
  /// **'Confirm and start selling'**
  String get confirmAndStartSelling;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @surpriseBagDetails.
  ///
  /// In en, this message translates to:
  /// **'Surprise Bag details'**
  String get surpriseBagDetails;

  /// No description provided for @estimatedValue.
  ///
  /// In en, this message translates to:
  /// **'Estimated value'**
  String get estimatedValue;

  /// No description provided for @priceInApp.
  ///
  /// In en, this message translates to:
  /// **'Price in app'**
  String get priceInApp;

  /// No description provided for @surpriseBagsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Surprise Bags per day'**
  String get surpriseBagsPerDay;

  /// No description provided for @collectionTimes.
  ///
  /// In en, this message translates to:
  /// **'Collection times'**
  String get collectionTimes;

  /// No description provided for @chooseSurpriseBagType.
  ///
  /// In en, this message translates to:
  /// **'Choose the type of surprise bag'**
  String get chooseSurpriseBagType;

  /// No description provided for @recurringSchedule.
  ///
  /// In en, this message translates to:
  /// **'Recurring surprise bag based on weekly schedule.'**
  String get recurringSchedule;

  /// No description provided for @singleSpecificDate.
  ///
  /// In en, this message translates to:
  /// **'Single surprise bag for a specific date.'**
  String get singleSpecificDate;

  /// No description provided for @pleaseFillRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Please, fill in the required field'**
  String get pleaseFillRequiredField;

  /// No description provided for @pleaseSelectStoreType.
  ///
  /// In en, this message translates to:
  /// **'Please select a store type'**
  String get pleaseSelectStoreType;

  /// No description provided for @pleaseSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get pleaseSelectCountry;

  /// No description provided for @phoneNumberCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Phone number can\'\'t be empty'**
  String get phoneNumberCantBeEmpty;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @sectionStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get sectionStore;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @menuDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get menuDashboard;

  /// No description provided for @menuPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get menuPerformance;

  /// No description provided for @menuFinancials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get menuFinancials;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuHelpCentre.
  ///
  /// In en, this message translates to:
  /// **'Help Centre'**
  String get menuHelpCentre;

  /// No description provided for @storeDescription.
  ///
  /// In en, this message translates to:
  /// **'Store description'**
  String get storeDescription;

  /// No description provided for @noDescriptionYet.
  ///
  /// In en, this message translates to:
  /// **'No description yet'**
  String get noDescriptionYet;

  /// No description provided for @storeDetails.
  ///
  /// In en, this message translates to:
  /// **'Store details'**
  String get storeDetails;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get contactDetails;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettings;

  /// No description provided for @teamManagement.
  ///
  /// In en, this message translates to:
  /// **'Team management'**
  String get teamManagement;

  /// No description provided for @tabStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get tabStore;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @tabTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get tabTeam;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @storeType.
  ///
  /// In en, this message translates to:
  /// **'Store type'**
  String get storeType;

  /// No description provided for @streetNameAndNumber.
  ///
  /// In en, this message translates to:
  /// **'Street name and number'**
  String get streetNameAndNumber;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @deliciousFood.
  ///
  /// In en, this message translates to:
  /// **'Delicious food'**
  String get deliciousFood;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ve sent a verification email to your inbox. Open the link to verify your account.'**
  String get verifyEmailMessage;

  /// No description provided for @onboardingPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept our privacy policy'**
  String get onboardingPrivacyNote;

  /// No description provided for @termsAndConditionsReserve.
  ///
  /// In en, this message translates to:
  /// **'By reserving this meal you agree to Sarqyt\'\'s terms & conditions'**
  String get termsAndConditionsReserve;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'{storeName} added to favorites'**
  String addedToFavorites(String storeName);

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'{storeName} removed from favorites'**
  String removedFromFavorites(String storeName);

  /// No description provided for @failedToUpdateFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorites'**
  String get failedToUpdateFavorites;

  /// No description provided for @noFavoriteRestaurants.
  ///
  /// In en, this message translates to:
  /// **'You don\'\'t have any favorite restaurants yet'**
  String get noFavoriteRestaurants;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @loadingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Loading, please wait...'**
  String get loadingPleaseWait;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
