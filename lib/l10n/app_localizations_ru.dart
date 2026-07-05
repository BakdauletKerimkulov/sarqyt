// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Sarqyt';

  @override
  String get appTitleBusiness => 'Sarqyt Business';

  @override
  String get error => 'Ошибка';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get back => 'Назад';

  @override
  String get goHome => 'На главную';

  @override
  String get logOut => 'Выйти';

  @override
  String get logOutConfirmTitle => 'Вы уверены, что хотите выйти?';

  @override
  String get areYouSure => 'Вы уверены?';

  @override
  String get notImplemented => 'Не реализовано';

  @override
  String get locationNotFound => 'Местоположение не найдено';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get noProductsFound => 'Товары не найдены';

  @override
  String get pageNotFound => '404 — Страница не найдена!';

  @override
  String get goToLogin => 'Перейти ко входу';

  @override
  String get comingSoon => 'Скоро будет';

  @override
  String get continueText => 'Продолжить';

  @override
  String get createNew => 'Создать';

  @override
  String get delete => 'Удалить';

  @override
  String get errorNoInternet => 'Нет подключения к интернету';

  @override
  String get errorTimeout => 'Истекло время ожидания. Попробуйте снова';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте снова';

  @override
  String get errorUserNotFound => 'Пользователь не найден';

  @override
  String get errorWrongPassword => 'Неверный пароль';

  @override
  String get errorInvalidCredential => 'Неверный email или пароль';

  @override
  String get errorEmailInUse => 'Email уже зарегистрирован';

  @override
  String get errorWeakPassword => 'Слишком простой пароль (мин. 6 символов)';

  @override
  String get errorInvalidEmail => 'Неверный email';

  @override
  String get errorTooManyRequests => 'Слишком много попыток. Попробуйте позже';

  @override
  String get errorUserDisabled => 'Этот аккаунт заблокирован';

  @override
  String get errorOperationNotAllowed => 'Операция не разрешена';

  @override
  String get errorRequiresRecentLogin => 'Войдите снова, чтобы продолжить';

  @override
  String get errorAuth => 'Ошибка авторизации. Попробуйте снова';

  @override
  String get errorUnauthenticated => 'Войдите в аккаунт';

  @override
  String get errorNotFound => 'Не найдено';

  @override
  String get errorAccessDenied => 'Доступ запрещён';

  @override
  String get errorUnavailable => 'Сервис недоступен. Попробуйте позже';

  @override
  String get errorInvalidInput => 'Неверные данные';

  @override
  String get errorNoConnection => 'Нет подключения. Проверьте интернет';

  @override
  String get errorOperationFailed => 'Операция не удалась. Попробуйте снова';

  @override
  String get errorEmailAlreadyInUse => 'Email уже используется';

  @override
  String get errorPasswordTooWeak => 'Слишком простой пароль';

  @override
  String get errorNotSignedIn => 'Невозможно выполнить (вы не вошли)';

  @override
  String get errorCartUpdate => 'Ошибка при обновлении корзины';

  @override
  String get errorEmptyCart => 'Нельзя оформить заказ с пустой корзиной';

  @override
  String get errorNullImage => 'Нельзя загрузить товар без изображения';

  @override
  String errorParseOrderStatus(String status) {
    return 'Не удалось определить статус заказа: $status';
  }

  @override
  String get helloCreateAccount => 'Привет! Создайте аккаунт';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get passwordHint => 'Пароль (8+ символов)';

  @override
  String get createAnAccount => 'Создать аккаунт';

  @override
  String get signIn => 'Войти';

  @override
  String get registrationFailed => 'Ошибка регистрации';

  @override
  String get signInFailed => 'Ошибка входа';

  @override
  String get emailCantBeEmpty => 'Email не может быть пустым';

  @override
  String get invalidEmail => 'Неверный email';

  @override
  String get passwordCantBeEmpty => 'Пароль не может быть пустым';

  @override
  String get passwordTooShort => 'Пароль слишком короткий';

  @override
  String get logInToMystore => 'ВХОД В MYSTORE';

  @override
  String get logInToYourAccount => 'Войдите в свой аккаунт';

  @override
  String get emailAddressRequired => 'Email адрес *';

  @override
  String get passwordRequired => 'Пароль *';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get logIn => 'Войти';

  @override
  String get signUpYourBusiness => 'Зарегистрируйте свой бизнес';

  @override
  String get profile => 'Профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get logout => 'Выйти';

  @override
  String get name => 'Имя';

  @override
  String get phone => 'Телефон';

  @override
  String get phoneHint => '+7 (777) 123-4567';

  @override
  String get account => 'Аккаунт';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountConfirm => 'Удалить аккаунт?';

  @override
  String get deleteAccountWarning =>
      'Это действие необратимо. Все ваши данные будут удалены.';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get about => 'О приложении';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get versionNumber => '1.0.0';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get change => 'Изменить';

  @override
  String get passwordUpdated => 'Пароль обновлён';

  @override
  String get discover => 'Обзор';

  @override
  String get offerNotFound => 'Предложение не найдено';

  @override
  String get soldOut => 'Распродано';

  @override
  String itemsLeft(int quantity) {
    return 'Осталось $quantity';
  }

  @override
  String get reserve => 'Забронировать';

  @override
  String get addressNotSpecified => 'Адрес не указан';

  @override
  String get moreInfoAboutStore => 'Подробнее о заведении';

  @override
  String offerStatus(String status) {
    return 'Статус: $status';
  }

  @override
  String get offerStatusActive => 'Активно';

  @override
  String get offerStatusPaused => 'Приостановлено';

  @override
  String get offerStatusExpired => 'Истекло';

  @override
  String availableItemsCount(int quantity) {
    return 'Доступно: $quantity';
  }

  @override
  String get offerDetailsSnapshot =>
      'Данные предложения загружены из снимка магазина и товара на момент создания.';

  @override
  String get noOffersFound => 'Предложения не найдены';

  @override
  String get filters => 'Фильтры';

  @override
  String get reset => 'Сбросить';

  @override
  String get favoritesOnly => 'Только избранные';

  @override
  String get pickupTime => 'Время самовывоза';

  @override
  String get all => 'Все';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get nearest => 'Ближайшие';

  @override
  String get cheapest => 'Дешевле';

  @override
  String get soonest => 'Скорее';

  @override
  String get apply => 'Применить';

  @override
  String get storeNotFound => 'Заведение не найдено';

  @override
  String get address => 'Адрес';

  @override
  String get pickup => 'Самовывоз';

  @override
  String get available => 'Доступно';

  @override
  String get paymentMethod => 'СПОСОБ ОПЛАТЫ';

  @override
  String get cardPayment => 'Оплата картой';

  @override
  String get selectedAtCheckout => 'Выбирается при оплате';

  @override
  String get total => 'Итого';

  @override
  String get myOrders => 'Мои заказы';

  @override
  String get noOrdersYet => 'Заказов пока нет';

  @override
  String get current => 'Текущие';

  @override
  String get pastOrders => 'Прошлые заказы';

  @override
  String get orderDetails => 'Детали заказа';

  @override
  String get orderNotFound => 'Заказ не найден';

  @override
  String orderNumber(String number) {
    return 'Заказ #$number';
  }

  @override
  String itemQuantityPrefix(int quantity) {
    return 'x$quantity';
  }

  @override
  String get pickupWindow => 'Время самовывоза';

  @override
  String get payment => 'Оплата';

  @override
  String get paid => 'Оплачено';

  @override
  String get refunded => 'Возврат';

  @override
  String get refundPending => 'Возврат в обработке';

  @override
  String get refundFailed => 'Ошибка возврата';

  @override
  String get leaveAReview => 'Оставить отзыв';

  @override
  String get pickupTimeExpired => 'Время самовывоза истекло';

  @override
  String get cancelOrder => 'Отменить заказ';

  @override
  String get cancelOrderConfirm => 'Отменить заказ?';

  @override
  String get cancelOrderRefund => 'Это действие нельзя отменить.';

  @override
  String get yesCancel => 'Да, отменить';

  @override
  String get payOnPickup => 'Оплата при получении';

  @override
  String get cancelReason => 'Причина отмены';

  @override
  String get cancelReasonHint => 'Укажите причину';

  @override
  String get orderCancelledByStore => 'Отменено магазином';

  @override
  String get cancelReasonRequired => 'Укажите причину отмены';

  @override
  String get activeOrders => 'Активные заказы';

  @override
  String get active => 'Активные';

  @override
  String get completed => 'Завершённые';

  @override
  String get cancelled => 'Отменённые';

  @override
  String get noOrdersWithStatus => 'Нет заказов с этим статусом';

  @override
  String get startPreparing => 'Начать приготовление';

  @override
  String get readyForPickup => 'Готово к выдаче';

  @override
  String get markCompleted => 'Завершить';

  @override
  String get noOrdersDescription =>
      'Когда клиенты начнут заказывать, их бронирования появятся здесь.';

  @override
  String get orders => 'Заказы';

  @override
  String get howWasTheStore => 'Как вам заведение?';

  @override
  String get howWasTheOffer => 'Как вам предложение?';

  @override
  String get anyComments => 'Комментарии (необязательно)';

  @override
  String get tellUsAboutExperience => 'Расскажите о своём опыте';

  @override
  String get submitReview => 'Отправить отзыв';

  @override
  String get itemCreated => 'Товар создан';

  @override
  String get createSurpriseBag => 'Создать сюрприз-пакет';

  @override
  String get surpriseBag => 'Сюрприз-пакет';

  @override
  String get description => 'Описание';

  @override
  String get rescueSurpriseBag => 'Спасите сюрприз-пакет с набором товаров';

  @override
  String get price => 'Цена';

  @override
  String get estimatedValueOptional => 'Оригинальная стоимость (необязательно)';

  @override
  String get type => 'Тип';

  @override
  String get scheduled => 'По расписанию';

  @override
  String get createItem => 'Создать товар';

  @override
  String get weeklySchedule => 'Недельное расписание';

  @override
  String get setPickupWindowAndQuantity =>
      'Укажите время самовывоза и количество для каждого дня';

  @override
  String get date => 'Дата';

  @override
  String get quantity => 'Количество';

  @override
  String get overview => 'Обзор';

  @override
  String get calendar => 'Календарь';

  @override
  String get schedule => 'Расписание';

  @override
  String get customerRatings => 'Отзывы клиентов';

  @override
  String get sellingNow => 'Продаётся';

  @override
  String quantityAvailable(int quantity) {
    return 'Доступно: $quantity';
  }

  @override
  String quantityPerDay(int quantity) {
    return '$quantity в день';
  }

  @override
  String get notReadyYet => 'Ещё не готово?';

  @override
  String get startSelling => 'Начать продавать';

  @override
  String get noItemsFound => 'Товары не найдены';

  @override
  String get nameCantBeEmpty => 'Название не может быть пустым';

  @override
  String get priceCantBeEmpty => 'Цена не может быть пустой';

  @override
  String get enterValidPrice => 'Введите корректную цену';

  @override
  String get estimatedValuePositive => 'Стоимость должна быть > 0';

  @override
  String get estimatedValueGreater => 'Стоимость должна быть больше цены';

  @override
  String get itemDetails => 'Детали товара';

  @override
  String get skip => 'Пропустить';

  @override
  String get getStarted => 'Начать';

  @override
  String get next => 'Далее';

  @override
  String get addEmailAndPassword => 'Введите email и пароль';

  @override
  String get mustAcceptPrivacyPolicy =>
      'Необходимо принять политику конфиденциальности';

  @override
  String get addBusinessDetails => 'Добавьте данные вашего бизнеса';

  @override
  String get provideBusinessDetails =>
      'Пожалуйста, укажите данные вашего бизнеса.';

  @override
  String get registerYourBusiness => 'Зарегистрируйте бизнес';

  @override
  String get skipForNow => 'Пропустить';

  @override
  String get checkYourInbox => 'Проверьте почту';

  @override
  String get retry => 'Повторить';

  @override
  String get resendVerificationEmail => 'Отправить письмо повторно';

  @override
  String get reviewStoreDetails => 'Проверьте данные магазина';

  @override
  String get welcomeToSarqyt => 'Добро пожаловать в Sarqyt';

  @override
  String get noStoreFound => 'Магазин не найден';

  @override
  String letsSetUp(String name) {
    return 'Настроим $name';
  }

  @override
  String get createYourFirstItem => 'Создайте первый товар';

  @override
  String get addSurpriseBagDescription =>
      'Добавьте сюрприз-пакет с временем самовывоза и ценой';

  @override
  String get created => 'Создано';

  @override
  String get verifyYourBusiness => 'Подтвердите бизнес';

  @override
  String get resubmit => 'Отправить повторно';

  @override
  String get startVerification => 'Начать проверку';

  @override
  String get continueToDashboard => 'Перейти к панели';

  @override
  String get submitBusinessForPayouts =>
      'Отправьте данные бизнеса для получения выплат';

  @override
  String get reviewingDocuments => 'Мы проверяем ваши документы';

  @override
  String get businessVerified => 'Ваш бизнес подтверждён';

  @override
  String get verificationRejected => 'Проверка отклонена — отправьте повторно';

  @override
  String get verified => 'Подтверждено';

  @override
  String get pending => 'На рассмотрении';

  @override
  String get company => 'Компания';

  @override
  String get individual => 'Индивидуальный предприниматель';

  @override
  String get registeredEntity => 'Зарегистрированное юридическое лицо';

  @override
  String get individualOrSole => 'Физическое лицо или ИП';

  @override
  String get fillAllFields => 'Заполните все обязательные поля';

  @override
  String get verificationSubmitted =>
      'Заявка отправлена. Обработка может занять до 30 секунд...';

  @override
  String get businessInfoRequired => 'Требуются данные о бизнесе';

  @override
  String get whyTaxInfo => 'Зачем нам налоговая информация';

  @override
  String get whyTaxInfoReason1 =>
      'Мы должны подтвердить вашу личность и зарегистрировать вас как партнёра для обработки выплат.';

  @override
  String get whyTaxInfoReason2 =>
      'Ваши данные хранятся в безопасности и используются только для соответствия требованиям.';

  @override
  String get selectBusinessType => 'Выберите тип бизнеса';

  @override
  String get areYouVatRegistered => 'Вы платите НДС?';

  @override
  String get vatId => 'Номер НДС *';

  @override
  String get companyBin => 'БИН компании';

  @override
  String get iin => 'ИИН *';

  @override
  String get dateOfBirth => 'Дата рождения *';

  @override
  String get firstName => 'Имя *';

  @override
  String get lastName => 'Фамилия *';

  @override
  String get addressLine1 => 'Адрес (строка 1) *';

  @override
  String get addressLine2 => 'Адрес (строка 2)';

  @override
  String get postalCode => 'Почтовый индекс *';

  @override
  String get city => 'Город *';

  @override
  String get region => 'Область *';

  @override
  String get country => 'Страна *';

  @override
  String get thisFieldIsRequired => 'Обязательное поле';

  @override
  String get helpCentre => 'Центр помощи';

  @override
  String get dailyOperations => 'Ежедневные операции';

  @override
  String get financials => 'Финансы';

  @override
  String get payoutsAndInvoices => 'Информация о выплатах и счетах.';

  @override
  String get sharing => 'Поделиться';

  @override
  String get spreadTheWord => 'Расскажите о нашем сотрудничестве!';

  @override
  String get commonQuestions => 'Частые вопросы';

  @override
  String get needFurtherHelp => 'Нужна помощь?';

  @override
  String get contactUs => 'Связаться с нами';

  @override
  String get chooseAStore => 'Выберите магазин';

  @override
  String get noStoresFound => 'Магазины не найдены';

  @override
  String ratingDisplay(String average) {
    return '$average / 5.0';
  }

  @override
  String get noReviewsYet => 'Отзывов пока нет';

  @override
  String get allReviews => 'Все отзывы';

  @override
  String reviewCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзывов',
      many: '$count отзывов',
      few: '$count отзыва',
      one: '1 отзыв',
    );
    return '$_temp0';
  }

  @override
  String get surpriseBagIsSurprise => 'Ваш сюрприз-пакет — это сюрприз';

  @override
  String get gotIt => 'Понятно!';

  @override
  String get surpriseBagsForSale => 'Сюрприз-пакеты в продаже';

  @override
  String soldCount(int count) {
    return 'Продано: $count';
  }

  @override
  String get totalSurpriseBags => 'Всего сюрприз-пакетов';

  @override
  String get flashOffer => 'Быстрое предложение';

  @override
  String get createOneTimeOffer => 'Создать разовое предложение';

  @override
  String get offerName => 'Название предложения';

  @override
  String get egSurpriseBag => 'напр. Сюрприз-пакет';

  @override
  String get createFlashOffer => 'Создать быстрое предложение';

  @override
  String get confirmAndStartSelling => 'Подтвердить и начать продажу';

  @override
  String get startDate => 'Дата начала';

  @override
  String get surpriseBagDetails => 'Детали сюрприз-пакета';

  @override
  String get estimatedValue => 'Оригинальная стоимость';

  @override
  String get priceInApp => 'Цена в приложении';

  @override
  String get surpriseBagsPerDay => 'Сюрприз-пакетов в день';

  @override
  String get collectionTimes => 'Время сбора';

  @override
  String get chooseSurpriseBagType => 'Выберите тип сюрприз-пакета';

  @override
  String get recurringSchedule =>
      'Регулярный сюрприз-пакет по недельному расписанию.';

  @override
  String get singleSpecificDate => 'Разовый сюрприз-пакет на конкретную дату.';

  @override
  String get pleaseFillRequiredField =>
      'Пожалуйста, заполните обязательное поле';

  @override
  String get pleaseSelectStoreType => 'Выберите тип заведения';

  @override
  String get pleaseSelectCountry => 'Выберите страну';

  @override
  String get phoneNumberCantBeEmpty => 'Номер телефона не может быть пустым';

  @override
  String get enterValidPhoneNumber => 'Введите корректный номер телефона';

  @override
  String get sectionStore => 'Магазин';

  @override
  String get sectionSupport => 'Поддержка';

  @override
  String get menuDashboard => 'Панель';

  @override
  String get menuPerformance => 'Показатели';

  @override
  String get menuFinancials => 'Финансы';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get menuHelpCentre => 'Центр помощи';

  @override
  String get storeDescription => 'Описание магазина';

  @override
  String get noDescriptionYet => 'Описание отсутствует';

  @override
  String get storeDetails => 'Данные магазина';

  @override
  String get contactDetails => 'Контакты';

  @override
  String get accountSettings => 'Настройки аккаунта';

  @override
  String get teamManagement => 'Управление командой';

  @override
  String get tabStore => 'Магазин';

  @override
  String get tabAccount => 'Аккаунт';

  @override
  String get tabTeam => 'Команда';

  @override
  String get businessName => 'Название бизнеса';

  @override
  String get storeType => 'Тип заведения';

  @override
  String get streetNameAndNumber => 'Улица и номер дома';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get deliciousFood => 'Вкусная еда';

  @override
  String get verifyEmailMessage =>
      'Мы отправили письмо для подтверждения на вашу почту. Откройте ссылку, чтобы подтвердить аккаунт.';

  @override
  String get onboardingPrivacyNote =>
      'Продолжая, вы принимаете политику конфиденциальности';

  @override
  String get termsAndConditionsReserve =>
      'Бронируя этот обед, вы соглашаетесь с условиями Sarqyt';

  @override
  String get favorites => 'Избранное';

  @override
  String addedToFavorites(String storeName) {
    return '$storeName добавлен в избранное';
  }

  @override
  String removedFromFavorites(String storeName) {
    return '$storeName удалён из избранного';
  }

  @override
  String get failedToUpdateFavorites => 'Не удалось обновить избранное';

  @override
  String get noFavoriteRestaurants => 'У вас пока нет избранных ресторанов';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get removeFromFavorites => 'Убрать из избранного';

  @override
  String get loadingPleaseWait => 'Загрузка, подождите...';

  @override
  String get draftExpiredTitle => 'Сессия регистрации истекла';

  @override
  String get draftExpiredMessage =>
      'Данные вашего магазина устарели. Пожалуйста, заполните данные снова для завершения регистрации.';

  @override
  String get fillDetailsAgain => 'Заполнить данные снова';

  @override
  String get submitDetails => 'Отправить данные';

  @override
  String get storingAndAllergensLabel => 'Хранение и аллергены';

  @override
  String get storingAndAllergensHint =>
      'Напр. хранить в холодильнике, может содержать орехи';

  @override
  String get storingAndAllergensDescription =>
      'Здесь вы можете добавить рекомендации по хранению и обращению с продуктами, включая информацию об аллергенах. Они будут показаны в приложении.';

  @override
  String get descriptionHint => 'Опишите ваш продукт';
}
