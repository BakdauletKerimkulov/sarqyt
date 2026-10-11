// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Sarqyt';

  @override
  String get appTitleBusiness => 'Sarqyt Business';

  @override
  String get error => 'Қате';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get save => 'Сақтау';

  @override
  String get edit => 'Өзгерту';

  @override
  String get yes => 'Иә';

  @override
  String get no => 'Жоқ';

  @override
  String get back => 'Артқа';

  @override
  String get goHome => 'Басты бет';

  @override
  String get logOut => 'Шығу';

  @override
  String get logOutConfirmTitle => 'Шығуды қалайсыз ба?';

  @override
  String get areYouSure => 'Сенімдісіз бе?';

  @override
  String get notImplemented => 'Әлі жүзеге асырылмаған';

  @override
  String get locationNotFound => 'Орналасқан жері табылмады';

  @override
  String get anErrorOccurred => 'Қате орын алды';

  @override
  String get noProductsFound => 'Тауарлар табылмады';

  @override
  String get pageNotFound => '404 — Бет табылмады!';

  @override
  String get goToLogin => 'Кіруге өту';

  @override
  String get comingSoon => 'Жақында';

  @override
  String get continueText => 'Жалғастыру';

  @override
  String get createNew => 'Жаңасын құру';

  @override
  String get delete => 'Жою';

  @override
  String get errorNoInternet => 'Интернет қосылымы жоқ';

  @override
  String get errorTimeout => 'Күту уақыты өтті. Қайта көріңіз';

  @override
  String get errorGeneric => 'Бір нәрсе дұрыс емес. Қайта көріңіз';

  @override
  String get errorUserNotFound => 'Пайдаланушы табылмады';

  @override
  String get errorWrongPassword => 'Қате құпия сөз';

  @override
  String get errorInvalidCredential => 'Қате email немесе құпия сөз';

  @override
  String get errorEmailInUse => 'Бұл email тіркелген';

  @override
  String get errorWeakPassword => 'Құпия сөз өте қарапайым (мин. 6 таңба)';

  @override
  String get errorInvalidEmail => 'Қате email';

  @override
  String get errorTooManyRequests => 'Өте көп әрекет. Кейінірек көріңіз';

  @override
  String get errorUserDisabled => 'Бұл аккаунт құрсауланған';

  @override
  String get errorOperationNotAllowed => 'Операцияға рұқсат етілмеді';

  @override
  String get errorRequiresRecentLogin => 'Жалғастыру үшін қайта кіріңіз';

  @override
  String get errorAuth => 'Авторизация қатесі. Қайта көріңіз';

  @override
  String get errorUnauthenticated => 'Аккаунтқа кіріңіз';

  @override
  String get errorNotFound => 'Табылмады';

  @override
  String get errorAccessDenied => 'Қол жетімділік тыйым';

  @override
  String get errorUnavailable => 'Сервис қол жетімді емес. Кейінірек көріңіз';

  @override
  String get errorInvalidInput => 'Қате деректер';

  @override
  String get errorNoConnection => 'Қосылым жоқ. Интернетті тексеріңіз';

  @override
  String get errorOperationFailed => 'Операция сәтсіз. Қайта көріңіз';

  @override
  String get errorEmailAlreadyInUse => 'Email қолданылуда';

  @override
  String get errorPasswordTooWeak => 'Құпия сөз өте қарапайым';

  @override
  String get errorNotSignedIn => 'Операцияны аяқтау мүмкін емес (кірмегенсіз)';

  @override
  String get errorCartUpdate => 'Себетті жаңарту кезінде қате орын алды';

  @override
  String get errorEmptyCart => 'Бос себетпен тапсырыс беру мүмкін емес';

  @override
  String get errorNullImage => 'Суретсіз тауар жүктеу мүмкін емес';

  @override
  String errorParseOrderStatus(String status) {
    return 'Тапсырыс статусын анықтау мүмкін емес: $status';
  }

  @override
  String get helloCreateAccount => 'Сәлем! Аккаунт ашыңыз';

  @override
  String get welcomeBack => 'Қайта қош келдіңіз!';

  @override
  String get yourName => 'Атыңыз';

  @override
  String get email => 'Email';

  @override
  String get password => 'Құпия сөз';

  @override
  String get passwordHint => 'Құпия сөз (8+ таңба)';

  @override
  String get createAnAccount => 'Аккаунт ашу';

  @override
  String get signIn => 'Кіру';

  @override
  String get registrationFailed => 'Тіркелу қатесі';

  @override
  String get signInFailed => 'Кіру қатесі';

  @override
  String get emailCantBeEmpty => 'Email бос болмауы керек';

  @override
  String get invalidEmail => 'Қате email';

  @override
  String get passwordCantBeEmpty => 'Құпия сөз бос болмауы керек';

  @override
  String get passwordTooShort => 'Құпия сөз өте қысқа';

  @override
  String get logInToMystore => 'MYSTORE-ГЕ КІРУ';

  @override
  String get logInToYourAccount => 'Аккаунтыңызға кіріңіз';

  @override
  String get emailAddressRequired => 'Email мекенжайы *';

  @override
  String get passwordRequired => 'Құпия сөз *';

  @override
  String get forgotPassword => 'Құпия сөзді ұмыттыңыз ба?';

  @override
  String get logIn => 'Кіру';

  @override
  String get signUpYourBusiness => 'Бизнесіңізді тіркеңіз';

  @override
  String get resetPasswordTitle => 'Құпия сөзді қалпына келтіру';

  @override
  String get resetPasswordDescription =>
      'Email мекенжайыңызды енгізіңіз, біз құпия сөзді қалпына келтіру сілтемесін жібереміз.';

  @override
  String get sendResetLink => 'Сілтеме жіберу';

  @override
  String get resetLinkSent =>
      'Құпия сөзді қалпына келтіру хаты жіберілді. Поштаңызды тексеріңіз.';

  @override
  String sendResetLinkConfirm(String email) {
    return '$email мекенжайына құпия сөзді қалпына келтіру сілтемесін жіберу керек пе?';
  }

  @override
  String get signOutConfirm =>
      'Аккаунтқа қайта кіру үшін қайта авторизациядан өтуіңіз керек болады.';

  @override
  String get profile => 'Профиль';

  @override
  String get editProfile => 'Профильді өзгерту';

  @override
  String get settings => 'Баптаулар';

  @override
  String get logout => 'Шығу';

  @override
  String get name => 'Аты';

  @override
  String get phone => 'Телефон';

  @override
  String get phoneHint => '+7 (777) 123-4567';

  @override
  String get account => 'Аккаунт';

  @override
  String get changePassword => 'Құпия сөзді өзгерту';

  @override
  String get deleteAccount => 'Аккаунтты жою';

  @override
  String get deleteAccountConfirm => 'Аккаунтты жою?';

  @override
  String get deleteAccountWarning =>
      'Бұл әрекет қайтарылмайды. Барлық деректеріңіз жойылады.';

  @override
  String get notifications => 'Хабарламалар';

  @override
  String get pushNotifications => 'Push-хабарламалар';

  @override
  String get about => 'Қосымша туралы';

  @override
  String get termsOfService => 'Қолдану шарттары';

  @override
  String get privacyPolicy => 'Құпиялылық саясаты';

  @override
  String get appVersion => 'Қосымша нұсқасы';

  @override
  String get versionNumber => '1.0.0';

  @override
  String get currentPassword => 'Ағымдағы құпия сөз';

  @override
  String get newPassword => 'Жаңа құпия сөз';

  @override
  String get change => 'Өзгерту';

  @override
  String get passwordUpdated => 'Құпия сөз жаңартылды';

  @override
  String get discover => 'Жаңалықтар';

  @override
  String get offerNotFound => 'Ұсыныс табылмады';

  @override
  String get soldOut => 'Тауысылды';

  @override
  String itemsLeft(int quantity) {
    return 'Қалды $quantity';
  }

  @override
  String get reserve => 'Брондау';

  @override
  String get addressNotSpecified => 'Мекенжай көрсетілмеген';

  @override
  String get moreInfoAboutStore => 'Дүкен туралы толықтау';

  @override
  String offerStatus(String status) {
    return 'Статус: $status';
  }

  @override
  String get offerStatusActive => 'Белсенді';

  @override
  String get offerStatusPaused => 'Тоқтатылған';

  @override
  String get offerStatusExpired => 'Мерзімі өткен';

  @override
  String availableItemsCount(int quantity) {
    return 'Қол жетімді: $quantity';
  }

  @override
  String get offerDetailsSnapshot =>
      'Ұсыныс мәліметтері құрылу кезіндегі дүкен мен тауар суретінен жүктелген.';

  @override
  String get noOffersFound => 'Ұсыныстар табылмады';

  @override
  String get searchOffersHint => 'Дүкен немесе тауар бойынша іздеу';

  @override
  String get filters => 'Сүзгілер';

  @override
  String get reset => 'Тастау';

  @override
  String get favoritesOnly => 'Тек таңдаулылар';

  @override
  String get pickupTime => 'Алу уақыты';

  @override
  String get all => 'Барлық';

  @override
  String get today => 'Бүгін';

  @override
  String get tomorrow => 'Ертең';

  @override
  String get sortBy => 'Сұрыптау';

  @override
  String get nearest => 'Жақын';

  @override
  String get cheapest => 'Арзан';

  @override
  String get soonest => 'Тезірек';

  @override
  String get apply => 'Қолдану';

  @override
  String get storeNotFound => 'Дүкен табылмады';

  @override
  String get address => 'Мекенжай';

  @override
  String get pickup => 'Алу';

  @override
  String get available => 'Қол жетімді';

  @override
  String get paymentMethod => 'ТӨЛЕМ ТӘСІЛІ';

  @override
  String get cardPayment => 'Картамен төлеу';

  @override
  String get selectedAtCheckout => 'Төлем кезінде таңдалады';

  @override
  String get total => 'Жиыны';

  @override
  String get myOrders => 'Менің тапсырыстарым';

  @override
  String get noOrdersYet => 'Тапсырыстар әлі жоқ';

  @override
  String get current => 'Ағымдағы';

  @override
  String get pastOrders => 'Өткен тапсырыстар';

  @override
  String get orderDetails => 'Тапсырыс туралы';

  @override
  String get orderNotFound => 'Тапсырыс табылмады';

  @override
  String orderNumber(String number) {
    return 'Тапсырыс #$number';
  }

  @override
  String itemQuantityPrefix(int quantity) {
    return 'x$quantity';
  }

  @override
  String get pickupWindow => 'Алу уақыты';

  @override
  String get payment => 'Төлем';

  @override
  String get paid => 'Төленген';

  @override
  String get refunded => 'Қайтарылған';

  @override
  String get refundPending => 'Қайтару өңделуде';

  @override
  String get refundFailed => 'Қайтару қатесі';

  @override
  String get leaveAReview => 'Пікір қалдыру';

  @override
  String get pickupTimeExpired => 'Алу уақыты өтті';

  @override
  String get cancelOrder => 'Тапсырысты болдырмау';

  @override
  String get cancelOrderConfirm => 'Тапсырысты болдырмау?';

  @override
  String get cancelOrderRefund => 'Бұл әрекетті кері қайтару мүмкін емес.';

  @override
  String get yesCancel => 'Иә, болдырмау';

  @override
  String get payOnPickup => 'Алған кезде төлеу';

  @override
  String get cancelReason => 'Болдырмау себебі';

  @override
  String get cancelReasonHint => 'Себебін жазыңыз';

  @override
  String get orderCancelledByStore => 'Дүкен болдырмаған';

  @override
  String get cancelReasonRequired => 'Болдырмау себебін жазыңыз';

  @override
  String get activeOrders => 'Белсенді тапсырыстар';

  @override
  String get active => 'Белсенді';

  @override
  String get completed => 'Аяқталған';

  @override
  String get cancelled => 'Болдырылмаған';

  @override
  String get noOrdersWithStatus => 'Бұл статуста тапсырыстар жоқ';

  @override
  String get startPreparing => 'Дайындауды бастау';

  @override
  String get readyForPickup => 'Алуға дайын';

  @override
  String get markCompleted => 'Аяқтау';

  @override
  String get pickupWindowNotOpenYet =>
      'Алу терезесі ашылғанда қолжетімді болады';

  @override
  String get pickupWindowAlreadyClosed => 'Алу терезесі жабылды';

  @override
  String get noOrdersDescription =>
      'Клиенттер тапсырыс бергенде, олардың броны осында пайда болады.';

  @override
  String get orders => 'Тапсырыстар';

  @override
  String get howWasTheStore => 'Дүкен қалай болды?';

  @override
  String get howWasTheOffer => 'Ұсыныс қалай болды?';

  @override
  String get anyComments => 'Пікірлер (міндетті емес)';

  @override
  String get tellUsAboutExperience => 'Тәжірибеңіз туралы айтыңыз';

  @override
  String get submitReview => 'Пікір жіберу';

  @override
  String get itemCreated => 'Тауар құрылды';

  @override
  String get createSurpriseBag => 'Тосын-пакет құру';

  @override
  String get surpriseBag => 'Тосын-пакет';

  @override
  String get description => 'Сипаттама';

  @override
  String get rescueSurpriseBag =>
      'Тауарлар жиынтығымен тосын-пакетті құтқарыңыз';

  @override
  String get price => 'Баға';

  @override
  String get estimatedValueOptional => 'Бастапқы құны (міндетті емес)';

  @override
  String get type => 'Түрі';

  @override
  String get scheduled => 'Жоспарлы';

  @override
  String get createItem => 'Тауар құру';

  @override
  String get weeklySchedule => 'Апталық кесте';

  @override
  String get setPickupWindowAndQuantity =>
      'Әр күнге алу уақыты мен санын көрсетіңіз';

  @override
  String get date => 'Күні';

  @override
  String get quantity => 'Саны';

  @override
  String get overview => 'Шолу';

  @override
  String get calendar => 'Күнтізбе';

  @override
  String get schedule => 'Кесте';

  @override
  String get customerRatings => 'Клиент пікірлері';

  @override
  String get sellingNow => 'Сатылуда';

  @override
  String quantityAvailable(int quantity) {
    return 'Қол жетімді: $quantity';
  }

  @override
  String quantityPerDay(int quantity) {
    return 'Күніне $quantity';
  }

  @override
  String get notReadyYet => 'Әлі дайын емес пе?';

  @override
  String get startSelling => 'Сатуды бастау';

  @override
  String get noItemsFound => 'Тауарлар табылмады';

  @override
  String get nameCantBeEmpty => 'Аты бос болмауы керек';

  @override
  String get priceCantBeEmpty => 'Баға бос болмауы керек';

  @override
  String get enterValidPrice => 'Дұрыс баға енгізіңіз';

  @override
  String get estimatedValuePositive => 'Құны 0-ден жоғары болуы керек';

  @override
  String get estimatedValueGreater => 'Құны бағадан жоғары болуы керек';

  @override
  String get itemDetails => 'Тауар туралы';

  @override
  String get skip => 'Өткізу';

  @override
  String get getStarted => 'Бастау';

  @override
  String get next => 'Келесі';

  @override
  String get addEmailAndPassword => 'Email мен құпия сөзді енгізіңіз';

  @override
  String get mustAcceptPrivacyPolicy => 'Құпиялылық саясатын қабылдау керек';

  @override
  String get addBusinessDetails => 'Бизнес мәліметтерін қосыңыз';

  @override
  String get provideBusinessDetails =>
      'Бизнес мәліметтеріңізді төменде көрсетіңіз.';

  @override
  String get registerYourBusiness => 'Бизнесті тіркеу';

  @override
  String get skipForNow => 'Өткізу';

  @override
  String get checkYourInbox => 'Поштаны тексеріңіз';

  @override
  String get retry => 'Қайталау';

  @override
  String get resendVerificationEmail => 'Хатты қайта жіберу';

  @override
  String get reviewStoreDetails => 'Дүкен мәліметтерін тексеру';

  @override
  String get welcomeToSarqyt => 'Sarqyt-қа қош келдіңіз';

  @override
  String get noStoreFound => 'Дүкен табылмады';

  @override
  String letsSetUp(String name) {
    return '$name баптайық';
  }

  @override
  String get createYourFirstItem => 'Бірінші тауарды құрыңыз';

  @override
  String get addSurpriseBagDescription =>
      'Алу уақыты мен бағамен тосын-пакет қосыңыз';

  @override
  String get created => 'Құрылды';

  @override
  String get verifyYourBusiness => 'Бизнесті растаңыз';

  @override
  String get resubmit => 'Қайта жіберу';

  @override
  String get startVerification => 'Тексеруді бастау';

  @override
  String get continueToDashboard => 'Панельге өту';

  @override
  String get submitBusinessForPayouts =>
      'Төлемдер алу үшін бизнес мәліметтерін жіберіңіз';

  @override
  String get reviewingDocuments => 'Біз құжаттарыңызды тексерудеміз';

  @override
  String get businessVerified => 'Бизнесіңіз расталды';

  @override
  String get verificationRejected => 'Тексеру қабылданбады — қайта жіберіңіз';

  @override
  String get verified => 'Расталды';

  @override
  String get pending => 'Күтуде';

  @override
  String get company => 'Компания';

  @override
  String get individual => 'Жеке кәсіпкер';

  @override
  String get registeredEntity => 'Тіркелген заңды тұлға';

  @override
  String get individualOrSole => 'Жеке тұлға немесе ЖК';

  @override
  String get fillAllFields => 'Барлық міндетті өрістерді толтырыңыз';

  @override
  String get verificationSubmitted =>
      'Өтінім жіберілді. Өңдеу 30 секундқа дейін созылуы мүмкін...';

  @override
  String get businessInfoRequired => 'Бизнес мәліметтері қажет';

  @override
  String get whyTaxInfo => 'Салық ақпараты неге қажет';

  @override
  String get whyTaxInfoReason1 =>
      'Төлемдерді өңдеу үшін жеке басыңызды растау және сізді серіктес ретінде тіркеу керек.';

  @override
  String get whyTaxInfoReason2 =>
      'Деректеріңіз қауіпсіз сақталады және тек талаптарға сәйкестік үшін қолданылады.';

  @override
  String get selectBusinessType => 'Бизнес түрін таңдаңыз';

  @override
  String get areYouVatRegistered => 'ҚОС төлейсіз бе?';

  @override
  String get vatId => 'ҚОС нөмірі *';

  @override
  String get companyBin => 'Компания БСН';

  @override
  String get iin => 'ЖСН *';

  @override
  String get dateOfBirth => 'Туған күні *';

  @override
  String get firstName => 'Аты *';

  @override
  String get lastName => 'Тегі *';

  @override
  String get addressLine1 => 'Мекенжай (1-қатар) *';

  @override
  String get addressLine2 => 'Мекенжай (2-қатар)';

  @override
  String get postalCode => 'Пошта индексі *';

  @override
  String get city => 'Қала *';

  @override
  String get region => 'Облыс *';

  @override
  String get country => 'Ел *';

  @override
  String get thisFieldIsRequired => 'Міндетті өріс';

  @override
  String get helpCentre => 'Көмек орталығы';

  @override
  String get dailyOperations => 'Күнделікті операциялар';

  @override
  String get financials => 'Қаржы';

  @override
  String get payoutsAndInvoices =>
      'Төлемдер мен шот-фактуралар туралы ақпарат.';

  @override
  String get sharing => 'Бөлісу';

  @override
  String get spreadTheWord => 'Біздің ынтымақтастығымыз туралы айтыңыз!';

  @override
  String get commonQuestions => 'Жиі қойылатын сұрақтар';

  @override
  String get needFurtherHelp => 'Көмек қажет пе?';

  @override
  String get contactUs => 'Бізбен байланысу';

  @override
  String get chooseAStore => 'Дүкенді таңдаңыз';

  @override
  String get noStoresFound => 'Дүкендер табылмады';

  @override
  String ratingDisplay(String average) {
    return '$average / 5.0';
  }

  @override
  String get noReviewsYet => 'Пікірлер әлі жоқ';

  @override
  String get allReviews => 'Барлық пікірлер';

  @override
  String reviewCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пікір',
      one: '1 пікір',
    );
    return '$_temp0';
  }

  @override
  String get surpriseBagIsSurprise => 'Сіздің тосын-пакетіңіз — тосын';

  @override
  String get gotIt => 'Түсіндім!';

  @override
  String get surpriseBagsForSale => 'Сатылымдағы тосын-пакеттер';

  @override
  String soldCount(int count) {
    return 'Сатылды: $count';
  }

  @override
  String get totalSurpriseBags => 'Барлық тосын-пакеттер';

  @override
  String get flashOffer => 'Жылдам ұсыныс';

  @override
  String get createOneTimeOffer => 'Бір реттік ұсыныс құру';

  @override
  String get offerName => 'Ұсыныс аты';

  @override
  String get egSurpriseBag => 'мыс. Тосын-пакет';

  @override
  String get createFlashOffer => 'Жылдам ұсыныс құру';

  @override
  String get confirmAndStartSelling => 'Растау және сатуды бастау';

  @override
  String get startDate => 'Басталу күні';

  @override
  String get surpriseBagDetails => 'Тосын-пакет мәліметтері';

  @override
  String get estimatedValue => 'Бастапқы құны';

  @override
  String get priceInApp => 'Қосымшадағы баға';

  @override
  String get surpriseBagsPerDay => 'Күніне тосын-пакеттер';

  @override
  String get collectionTimes => 'Жинау уақыты';

  @override
  String get chooseSurpriseBagType => 'Тосын-пакет түрін таңдаңыз';

  @override
  String get recurringSchedule => 'Апталық кесте бойынша тұрақты тосын-пакет.';

  @override
  String get singleSpecificDate => 'Конкретті күнге бір реттік тосын-пакет.';

  @override
  String get pleaseFillRequiredField => 'Міндетті өрісті толтырыңыз';

  @override
  String get pleaseSelectStoreType => 'Дүкен түрін таңдаңыз';

  @override
  String get pleaseSelectCountry => 'Елді таңдаңыз';

  @override
  String get phoneNumberCantBeEmpty => 'Телефон нөмірі бос болмауы керек';

  @override
  String get enterValidPhoneNumber => 'Дұрыс телефон нөмірін енгізіңіз';

  @override
  String get sectionStore => 'Дүкен';

  @override
  String get sectionSupport => 'Қолдау';

  @override
  String get menuDashboard => 'Панель';

  @override
  String get menuPerformance => 'Көрсеткіштер';

  @override
  String get menuFinancials => 'Қаржы';

  @override
  String get menuSettings => 'Баптаулар';

  @override
  String get menuHelpCentre => 'Көмек орталығы';

  @override
  String get storeDescription => 'Дүкен сипаттамасы';

  @override
  String get noDescriptionYet => 'Сипаттама жоқ';

  @override
  String get storeDetails => 'Дүкен мәліметтері';

  @override
  String get contactDetails => 'Байланыс';

  @override
  String get accountSettings => 'Аккаунт баптаулары';

  @override
  String get teamManagement => 'Команданы басқару';

  @override
  String get tabStore => 'Дүкен';

  @override
  String get tabAccount => 'Аккаунт';

  @override
  String get tabTeam => 'Команда';

  @override
  String get businessName => 'Бизнес аты';

  @override
  String get storeType => 'Дүкен түрі';

  @override
  String get streetNameAndNumber => 'Көше мен үй нөмірі';

  @override
  String get phoneNumber => 'Телефон нөмірі';

  @override
  String get deliciousFood => 'Дәмді тамақ';

  @override
  String get verifyEmailMessage =>
      'Біз поштаңызға растау хатын жібердік. Аккаунтыңызды растау үшін сілтемені ашыңыз.';

  @override
  String get onboardingPrivacyNote =>
      'Жалғастыра отырып, құпиялылық саясатын қабылдайсыз';

  @override
  String get termsAndConditionsReserve =>
      'Бұл тамақты брондай отырып, Sarqyt шарттарын қабылдайсыз';

  @override
  String get favorites => 'Таңдаулылар';

  @override
  String addedToFavorites(String storeName) {
    return '$storeName таңдаулыларға қосылды';
  }

  @override
  String removedFromFavorites(String storeName) {
    return '$storeName таңдаулылардан алынды';
  }

  @override
  String get failedToUpdateFavorites => 'Таңдаулыларды жаңарту мүмкін болмады';

  @override
  String get noFavoriteRestaurants => 'Сізде әлі таңдаулы мейрамханалар жоқ';

  @override
  String get addToFavorites => 'Таңдаулыларға қосу';

  @override
  String get removeFromFavorites => 'Таңдаулылардан алу';

  @override
  String get loadingPleaseWait => 'Жүктелуде, күте тұрыңыз...';

  @override
  String get draftExpiredTitle => 'Тіркелу сессиясының мерзімі өтті';

  @override
  String get draftExpiredMessage =>
      'Дүкен деректеріңіздің мерзімі өтті. Тіркелуді аяқтау үшін деректеріңізді қайтадан толтырыңыз.';

  @override
  String get fillDetailsAgain => 'Деректерді қайта толтыру';

  @override
  String get submitDetails => 'Деректерді жіберу';

  @override
  String get storingAndAllergensLabel => 'Сақтау және аллергендер';

  @override
  String get storingAndAllergensHint =>
      'Мыс. тоңазытқышта сақтаңыз, жаңғақ болуы мүмкін';

  @override
  String get storingAndAllergensDescription =>
      'Мұнда тамақ сақтау және пайдалану бойынша ұсыныстарды, соның ішінде аллергендер туралы ескертулерді қосуға болады. Олар қолданбада көрсетіледі.';

  @override
  String get descriptionHint => 'Өніміңізді сипаттаңыз';

  @override
  String get orderHistory => 'Тапсырыстар тарихы';

  @override
  String get recentOrders => 'Соңғы тапсырыстар';

  @override
  String get noActiveOrders => 'Белсенді тапсырыстар жоқ';

  @override
  String get statusConfirmed => 'Расталды';

  @override
  String get statusPreparing => 'Дайындалуда';

  @override
  String get statusReady => 'Алуға дайын';

  @override
  String get statusCompleted => 'Аяқталды';
}
