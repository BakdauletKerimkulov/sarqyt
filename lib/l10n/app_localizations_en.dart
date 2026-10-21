// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sarqyt';

  @override
  String get appTitleBusiness => 'Sarqyt Business';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get back => 'Back';

  @override
  String get goHome => 'Go Home';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirmTitle => 'Are you sure you want to log out?';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get notImplemented => 'Not implemented';

  @override
  String get locationNotFound => 'Location not found';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get pageNotFound => '404 - Page not found!';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get continueText => 'Continue';

  @override
  String get createNew => 'Create new';

  @override
  String get delete => 'Delete';

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get errorTimeout => 'Request timed out. Try again';

  @override
  String get errorGeneric => 'Something went wrong. Try again';

  @override
  String get errorUserNotFound => 'User not found';

  @override
  String get errorWrongPassword => 'Wrong password';

  @override
  String get errorInvalidCredential => 'Invalid email or password';

  @override
  String get errorEmailInUse => 'Email already registered';

  @override
  String get errorWeakPassword => 'Password too weak (min 6 characters)';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorTooManyRequests => 'Too many attempts. Try later';

  @override
  String get errorUserDisabled => 'This account has been disabled';

  @override
  String get errorOperationNotAllowed => 'Operation not allowed';

  @override
  String get errorRequiresRecentLogin => 'Please sign in again to continue';

  @override
  String get errorAuth => 'Authentication error. Try again';

  @override
  String get errorUnauthenticated => 'Please sign in';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorAccessDenied => 'Access denied';

  @override
  String get errorUnavailable => 'Service unavailable. Try later';

  @override
  String get errorInvalidInput => 'Invalid input';

  @override
  String get errorNoConnection => 'No connection. Check internet';

  @override
  String get errorOperationFailed => 'Operation failed. Try again';

  @override
  String get errorEmailAlreadyInUse => 'Email already in use';

  @override
  String get errorPasswordTooWeak => 'Password is too weak';

  @override
  String get errorNotSignedIn =>
      'The operation can\'\'t be completed (not signed in)';

  @override
  String get errorCartUpdate =>
      'An error has occurred while updating the shopping cart';

  @override
  String get errorEmptyCart => 'Can\'\'t place an order if the cart is empty';

  @override
  String get errorNullImage => 'Can\'\'t upload a product with a null image';

  @override
  String errorParseOrderStatus(String status) {
    return 'Could not parse order status: $status';
  }

  @override
  String get helloCreateAccount => 'Hello! Create Account';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get yourName => 'Your name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Password (8+ characters)';

  @override
  String get createAnAccount => 'Create an Account';

  @override
  String get signIn => 'Sign in';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get signInFailed => 'Sign in failed';

  @override
  String get emailCantBeEmpty => 'Email can\'\'t be empty';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordCantBeEmpty => 'Password can\'\'t be empty';

  @override
  String get passwordTooShort => 'Password is too short';

  @override
  String get logInToMystore => 'LOG IN TO MYSTORE';

  @override
  String get logInToYourAccount => 'Log in to your account';

  @override
  String get emailAddressRequired => 'Email address *';

  @override
  String get passwordRequired => 'Password *';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logIn => 'Log in';

  @override
  String get signUpYourBusiness => 'Sign up your food business';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordDescription =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetLinkSent => 'Password reset email sent. Check your inbox.';

  @override
  String sendResetLinkConfirm(String email) {
    return 'Send a password reset link to $email?';
  }

  @override
  String get signOutConfirm =>
      'You will need to log in again to access your account.';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get phoneHint => '+7 (777) 123-4567';

  @override
  String get account => 'Account';

  @override
  String get changePassword => 'Change password';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm => 'Delete account?';

  @override
  String get deleteAccountWarning =>
      'This action is irreversible. All your data will be permanently deleted.';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get about => 'About';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get appVersion => 'App version';

  @override
  String get versionNumber => '1.0.0';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get change => 'Change';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get discover => 'Discover';

  @override
  String get offerNotFound => 'Offer not found';

  @override
  String get soldOut => 'Sold out';

  @override
  String itemsLeft(int quantity) {
    return 'Left $quantity';
  }

  @override
  String get reserve => 'Reserve';

  @override
  String get addressNotSpecified => 'Address is not specified';

  @override
  String get moreInfoAboutStore => 'More information about store';

  @override
  String offerStatus(String status) {
    return 'Status: $status';
  }

  @override
  String get offerStatusActive => 'Active';

  @override
  String get offerStatusPaused => 'Paused';

  @override
  String get offerStatusExpired => 'Expired';

  @override
  String availableItemsCount(int quantity) {
    return 'Available items: $quantity';
  }

  @override
  String get offerDetailsSnapshot =>
      'Offer details are loaded from store and product snapshot at creation time.';

  @override
  String get noOffersFound => 'No offers found';

  @override
  String get searchOffersHint => 'Search by store or item';

  @override
  String get filters => 'Filters';

  @override
  String get reset => 'Reset';

  @override
  String get favoritesOnly => 'Favorites only';

  @override
  String get pickupTime => 'Pickup time';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get sortBy => 'Sort by';

  @override
  String get nearest => 'Nearest';

  @override
  String get cheapest => 'Cheapest';

  @override
  String get soonest => 'Soonest';

  @override
  String get apply => 'Apply';

  @override
  String get storeNotFound => 'Store not found';

  @override
  String get address => 'Address';

  @override
  String get pickup => 'Pickup';

  @override
  String get available => 'Available';

  @override
  String get paymentMethod => 'PAYMENT METHOD';

  @override
  String get cardPayment => 'Card payment';

  @override
  String get selectedAtCheckout => 'Selected at checkout';

  @override
  String get total => 'Total';

  @override
  String get myOrders => 'My Orders';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get current => 'Current';

  @override
  String get pastOrders => 'Past orders';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String orderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String itemQuantityPrefix(int quantity) {
    return 'x$quantity';
  }

  @override
  String get pickupWindow => 'Pickup window';

  @override
  String get payment => 'Payment';

  @override
  String get paid => 'Paid';

  @override
  String get refunded => 'Refunded';

  @override
  String get refundPending => 'Refund pending';

  @override
  String get refundFailed => 'Refund failed';

  @override
  String get leaveAReview => 'Leave a review';

  @override
  String get pickupTimeExpired => 'Pickup time expired';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get cancelOrderConfirm => 'Cancel order?';

  @override
  String get cancelOrderRefund => 'This action cannot be undone.';

  @override
  String get yesCancel => 'Yes, cancel';

  @override
  String get payOnPickup => 'Pay on pickup';

  @override
  String get cancelReason => 'Cancellation reason';

  @override
  String get cancelReasonHint => 'Enter reason';

  @override
  String get orderCancelledByStore => 'Cancelled by store';

  @override
  String get cancelReasonRequired => 'Please enter a reason';

  @override
  String get activeOrders => 'Active orders';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get noOrdersWithStatus => 'No orders with this status';

  @override
  String get startPreparing => 'Start preparing';

  @override
  String get readyForPickup => 'Ready for pickup';

  @override
  String get markCompleted => 'Mark completed';

  @override
  String get pickupWindowNotOpenYet => 'Available once the pickup window opens';

  @override
  String get pickupWindowAlreadyClosed => 'Pickup window has closed';

  @override
  String get noOrdersDescription =>
      'Once customers start ordering, their reservations will appear here.';

  @override
  String get orders => 'Orders';

  @override
  String get howWasTheStore => 'How was the store?';

  @override
  String get howWasTheOffer => 'How was the offer?';

  @override
  String get anyComments => 'Any comments? (optional)';

  @override
  String get tellUsAboutExperience => 'Tell us about your experience';

  @override
  String get submitReview => 'Submit review';

  @override
  String get itemCreated => 'Item created';

  @override
  String get createSurpriseBag => 'Create surprise bag';

  @override
  String get surpriseBag => 'Surprise Bag';

  @override
  String get description => 'Description';

  @override
  String get rescueSurpriseBag =>
      'Rescue a surprise bag with a selection of items';

  @override
  String get price => 'Price';

  @override
  String get estimatedValueOptional => 'Estimated value (optional)';

  @override
  String get type => 'Type';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get createItem => 'Create item';

  @override
  String get weeklySchedule => 'Weekly schedule';

  @override
  String get setPickupWindowAndQuantity =>
      'Set pickup window and quantity for each day';

  @override
  String get date => 'Date';

  @override
  String get quantity => 'Quantity';

  @override
  String get overview => 'Overview';

  @override
  String get calendar => 'Calendar';

  @override
  String get schedule => 'Schedule';

  @override
  String get customerRatings => 'Customer ratings';

  @override
  String get sellingNow => 'Selling now';

  @override
  String quantityAvailable(int quantity) {
    return '$quantity available';
  }

  @override
  String quantityPerDay(int quantity) {
    return '$quantity per day';
  }

  @override
  String get notReadyYet => 'Not ready yet?';

  @override
  String get startSelling => 'Start selling';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get nameCantBeEmpty => 'Name can\'\'t be empty';

  @override
  String get priceCantBeEmpty => 'Price can\'\'t be empty';

  @override
  String get enterValidPrice => 'Enter a valid price';

  @override
  String get estimatedValuePositive => 'Estimated value must be > 0';

  @override
  String get estimatedValueGreater =>
      'Estimated value must be greater than price';

  @override
  String get itemDetails => 'Item details';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get next => 'Next';

  @override
  String get addEmailAndPassword => 'Add your email and password';

  @override
  String get mustAcceptPrivacyPolicy => 'You must accept the privacy policy';

  @override
  String get addBusinessDetails => 'Add your business details';

  @override
  String get provideBusinessDetails =>
      'Please provide your business details below.';

  @override
  String get registerYourBusiness => 'Register your business';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get checkYourInbox => 'Check your inbox';

  @override
  String get retry => 'Retry';

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get reviewStoreDetails => 'Review your store details';

  @override
  String get welcomeToSarqyt => 'Welcome to Sarqyt';

  @override
  String get noStoreFound => 'No store found';

  @override
  String letsSetUp(String name) {
    return 'Let\'\'s set up $name';
  }

  @override
  String get createYourFirstItem => 'Create your first item';

  @override
  String get addSurpriseBagDescription =>
      'Add a surprise bag with a pickup window and price';

  @override
  String get created => 'Created';

  @override
  String get verifyYourBusiness => 'Verify your business';

  @override
  String get resubmit => 'Resubmit';

  @override
  String get startVerification => 'Start verification';

  @override
  String get continueToDashboard => 'Continue to dashboard';

  @override
  String get submitBusinessForPayouts =>
      'Submit business details to start receiving payouts';

  @override
  String get reviewingDocuments => 'We are reviewing your documents';

  @override
  String get businessVerified => 'Your business is verified';

  @override
  String get verificationRejected =>
      'Verification was rejected — please resubmit';

  @override
  String get verified => 'Verified';

  @override
  String get pending => 'Pending';

  @override
  String get company => 'Company';

  @override
  String get individual => 'Individual';

  @override
  String get registeredEntity => 'A registered business entity';

  @override
  String get individualOrSole => 'An individual or sole proprietor';

  @override
  String get fillAllFields => 'Please fill all required fields';

  @override
  String get verificationSubmitted =>
      'Verification submitted. Processing may take up to 30 seconds...';

  @override
  String get businessInfoRequired => 'Business information required';

  @override
  String get whyTaxInfo => 'Why we require your tax information';

  @override
  String get whyTaxInfoReason1 =>
      'We need to verify your identity and register you as a partner so we can process payouts.';

  @override
  String get whyTaxInfoReason2 =>
      'Your information is securely stored and will only be used for compliance purposes.';

  @override
  String get selectBusinessType => 'Select your business type';

  @override
  String get areYouVatRegistered => 'Are you vat registered?';

  @override
  String get vatId => 'VAT ID *';

  @override
  String get companyBin => 'Company BIN';

  @override
  String get iin => 'Individual identification number *';

  @override
  String get dateOfBirth => 'Date of birth *';

  @override
  String get firstName => 'First name *';

  @override
  String get lastName => 'Last name *';

  @override
  String get addressLine1 => 'Address line 1 *';

  @override
  String get addressLine2 => 'Address line 2';

  @override
  String get postalCode => 'Postal code *';

  @override
  String get city => 'City *';

  @override
  String get region => 'Region *';

  @override
  String get country => 'Country *';

  @override
  String get thisFieldIsRequired => 'This field is required';

  @override
  String get helpCentre => 'Help centre';

  @override
  String get dailyOperations => 'Daily Operations';

  @override
  String get financials => 'Financials';

  @override
  String get payoutsAndInvoices => 'Information about payouts and invoices.';

  @override
  String get sharing => 'Sharing';

  @override
  String get spreadTheWord => 'Spread the word about our collaboration!';

  @override
  String get commonQuestions => 'Common Questions';

  @override
  String get needFurtherHelp => 'Need any further help?';

  @override
  String get contactUs => 'Contact us';

  @override
  String get chooseAStore => 'Choose a store';

  @override
  String get noStoresFound => 'No stores found';

  @override
  String ratingDisplay(String average) {
    return '$average / 5.0';
  }

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get allReviews => 'All reviews';

  @override
  String reviewCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get surpriseBagIsSurprise => 'Your surprise bag is a surprise';

  @override
  String get gotIt => 'Got it!';

  @override
  String get surpriseBagsForSale => 'Surprise Bags for sale';

  @override
  String soldCount(int count) {
    return 'Sold: $count';
  }

  @override
  String get totalSurpriseBags => 'Total Surprise Bags';

  @override
  String get flashOffer => 'Flash offer';

  @override
  String get createOneTimeOffer => 'Create a one-time offer';

  @override
  String get offerName => 'Offer name';

  @override
  String get egSurpriseBag => 'e.g. Surprise Bag';

  @override
  String get createFlashOffer => 'Create flash offer';

  @override
  String get confirmAndStartSelling => 'Confirm and start selling';

  @override
  String get startDate => 'Start date';

  @override
  String get surpriseBagDetails => 'Surprise Bag details';

  @override
  String get estimatedValue => 'Estimated value';

  @override
  String get priceInApp => 'Price in app';

  @override
  String get surpriseBagsPerDay => 'Surprise Bags per day';

  @override
  String get collectionTimes => 'Collection times';

  @override
  String get chooseSurpriseBagType => 'Choose the type of surprise bag';

  @override
  String get recurringSchedule =>
      'Recurring surprise bag based on weekly schedule.';

  @override
  String get singleSpecificDate => 'Single surprise bag for a specific date.';

  @override
  String get pleaseFillRequiredField => 'Please, fill in the required field';

  @override
  String get pleaseSelectStoreType => 'Please select a store type';

  @override
  String get pleaseSelectCountry => 'Please select a country';

  @override
  String get phoneNumberCantBeEmpty => 'Phone number can\'\'t be empty';

  @override
  String get enterValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get sectionStore => 'Store';

  @override
  String get sectionSupport => 'Support';

  @override
  String get menuDashboard => 'Dashboard';

  @override
  String get menuPerformance => 'Performance';

  @override
  String get menuFinancials => 'Financials';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuHelpCentre => 'Help Centre';

  @override
  String get storeDescription => 'Store description';

  @override
  String get noDescriptionYet => 'No description yet';

  @override
  String get storeDetails => 'Store details';

  @override
  String get contactDetails => 'Contact details';

  @override
  String get accountSettings => 'Account settings';

  @override
  String get teamManagement => 'Team management';

  @override
  String get tabStore => 'Store';

  @override
  String get tabAccount => 'Account';

  @override
  String get tabTeam => 'Team';

  @override
  String get businessName => 'Business name';

  @override
  String get storeType => 'Store type';

  @override
  String get streetNameAndNumber => 'Street name and number';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get deliciousFood => 'Delicious food';

  @override
  String get verifyEmailMessage =>
      'We\'\'ve sent a verification email to your inbox. Open the link to verify your account.';

  @override
  String get onboardingPrivacyNote =>
      'By continuing you accept our privacy policy';

  @override
  String get termsAndConditionsReserve =>
      'By reserving this meal you agree to Sarqyt\'\'s terms & conditions';

  @override
  String get favorites => 'Favorites';

  @override
  String addedToFavorites(String storeName) {
    return '$storeName added to favorites';
  }

  @override
  String removedFromFavorites(String storeName) {
    return '$storeName removed from favorites';
  }

  @override
  String get failedToUpdateFavorites => 'Failed to update favorites';

  @override
  String get noFavoriteRestaurants =>
      'You don\'\'t have any favorite restaurants yet';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get loadingPleaseWait => 'Loading, please wait...';

  @override
  String get draftExpiredTitle => 'Registration session expired';

  @override
  String get draftExpiredMessage =>
      'Your store details have expired. Please fill in your details again to complete registration.';

  @override
  String get fillDetailsAgain => 'Fill in details again';

  @override
  String get submitDetails => 'Submit details';

  @override
  String get storingAndAllergensLabel => 'Storing and allergens';

  @override
  String get storingAndAllergensHint =>
      'e.g. Store in fridge, may contain nuts';

  @override
  String get storingAndAllergensDescription =>
      'You can add recommendations for storing and handling food, including warnings about allergens, here, and they will be shown in the app.';

  @override
  String get descriptionHint => 'Describe your product';

  @override
  String get orderHistory => 'Order history';

  @override
  String get recentOrders => 'Recent orders';

  @override
  String get noActiveOrders => 'No active orders';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusCompleted => 'Completed';
}
