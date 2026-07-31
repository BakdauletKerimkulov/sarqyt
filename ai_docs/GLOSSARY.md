# Glossary

Канонический словарь домена. Один концепт = один идентификатор в коде + одно слово на локаль в UI + слова, с которыми его нельзя путать.

Правила и формат — `spec-driven-rules.md` § 3. Термин, решённый во время работы, пишется сюда **в том же прогоне**, не батчем. Расхождение кода с этим файлом — находка ревью, а не уборка на потом.

Засеяно из `lib/src/features/*/domain/`, enum'ов и `lib/l10n/app_{ru,kk,en}.arb`. Пункты с `<!-- TODO: canonical? -->` — реальные расхождения, найденные в коде; их решает человек, а не агент.

## Terminology

**Business** (`Business`, ru «бизнес», kk «бизнес», en "business") — юридическое лицо, владеющее одним или несколькими `Store`. Проходит верификацию в 3 шага (`BusinessVerificationDraft`, `VerificationStatus`), держит участников с ролями (`BusinessMembershipRole`).
NOT: `Store` — это точка, а не владелец. NOT «магазин» в UI.

**Store** (`Store`, en "store") — конкретная точка продажи: ресторан, пекарня, кафе. Принадлежит `Business`, имеет адрес, гео-локацию, тип (`StoreType`) и роли персонала (`StoreRole`).
UI-слово не решено:
- ru «заведение» — `storeNotFound`, `moreInfoAboutStore`, `howWasTheStore`
- ru «магазин» — `orderCancelledByStore`, `reviewStoreDetails`
- kk «дүкен» (= магазин), en "store"

<!-- TODO: canonical? «заведение» или «магазин» в ru. Сейчас в ARB живут оба слова для одного концепта; kk и en однозначны. Выбор влияет на ~15 ключей ARB. -->

**Item** (`Item`, ru «товар», kk «тауар», en "item") — то, что заведение определяет у себя: конкретный продукт или сюрприз-пакет. Разовый или по недельному расписанию (`WeeklySchedule`). Item сам не продаётся — из активных Item'ов `daily-sync-offers` порождает `Offer`.
NOT: `Offer` — Item это шаблон, Offer это опубликованный экземпляр. NOT «предложение».

**Offer** (`Offer`, ru «предложение», kk «ұсыныс», en "offer") — опубликованный экземпляр `Item` с количеством, окном самовывоза, гео-локацией, бейджами (`BadgeType`) и рейтингом. То, что покупатель видит на карте и бронирует. Статусы — `OfferStatus`.
NOT: `Item` (шаблон), NOT `Order` (покупка).

**Surprise bag** (нет класса в домене, ru «сюрприз-пакет», kk «тосын-пакет», en "Surprise Bag") — разновидность `Item`: набор товаров, состав которого покупатель не знает заранее. Существует **только как UI-слово**: в коде это `Item` без отдельного типа.

<!-- TODO: canonical? Слово несёт продуктовый смысл (ядро модели TGTG), но в домене ему ничего не соответствует — ни поля, ни подтипа Item. Либо это признак Item, либо термин надо убрать из UI. -->

**Order** (`Order`, ru «заказ», kk «тапсырыс», en "order") — покупка `Offer` конкретным покупателем. Жизненный цикл `OrderStatus`: `confirmed → preparing → readyForPickup → completed | cancelled | expired`. Отмена хранит инициатора (`CancelledBy`).
NOT «бронь»: бронирование — это действие, создающее Order (`reserve-offer`, ru «Забронировать»), а не отдельная сущность.

<!-- TODO: canonical? В ARB есть третье слово для предмета заказа: termsAndConditionsReserve говорит «Бронируя этот обед». «Обед» не соответствует ни Item, ни Offer. -->

**Pickup window** (`pickupWindow`, ru «время самовывоза», kk TODO, en "pickup window") — интервал, в который покупатель обязан забрать заказ. Живёт на `Offer`, порождает напоминания (`sendOrderReminders`) и `expired`-переход.
NOT «доставка»: доставки в продукте нет, только самовывоз (`payOnPickup`).

**Review** (`Review`, ru «отзыв», en "review") — оценка `Store` после завершённого `Order`. Запрашивается отложенным пушем.
NOT `Rating` — `Rating` это агрегат на `Offer`/`Store`, а `Review` это одна запись от покупателя.

**AppUser** (`AppUser`, ru «пользователь», en "user") — авторизованный пользователь. Роль в системе — `UserRole`; роль внутри заведения — `StoreRole`; роль внутри бизнеса — `BusinessMembershipRole`. Три разные шкалы, не смешивать.

<!-- TODO: остальные термины по мере работы: Money/Currency, SalesTax, PackagingOption, DietaryType, SubscriptionPlan, PushAudience, SortBy/PickupTimeFilter. Добавлять по одному, когда термин становится спорным — не заполнять впрок. -->
