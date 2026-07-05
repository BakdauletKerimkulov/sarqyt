---
title: Checkout Partnership System
status: done
date: 2026-05-25
type: feature
---

# Spec: Аудит и доработка системы партнёрства (Registration, Business, Store, Team)


## Goal

Устранить критические архитектурные проблемы в системе регистрации, создания бизнеса/магазина и связей между документами. Разделить `businessId` и `storeId`, выбрать единый source of truth для доступа сотрудников, реализовать добавление команды и создание второго магазина.

## Background

### Текущее состояние

Система партнёрства работает, но содержит ряд проблем, которые станут критичными при масштабировании:

**1. `businessId == storeId` — общий ID**
В `completeMerchantOnboarding` (строка 84): `const businessId = storeId;`. Business и Store — логически разные сущности (один бизнес может иметь несколько магазинов), но делят один ID. Это делает невозможным создание второго магазина в рамках одного бизнеса.

**2. Два конкурирующих механизма доступа сотрудников**
- `stores/{storeId}.staffIds: string[]` — плоский массив UID. Используется в `firestore.rules` (функция `isStoreStaff()`), в `storage.rules`, и во всех Cloud Functions для авторизации. Всегда пустой — ни одна функция не добавляет в него значения.
- `storeShips/{storeId}_{uid}` — отдельные документы с ролью, правами, onboarding-статусом. Используется клиентом для роутинга и UI. Создаётся только для owner при onboarding.

Проблема: security rules и Cloud Functions проверяют `staffIds`, а клиент работает с `storeShips`. Если добавить сотрудника через storeShip, он не получит доступ — rules его не пропустят.

**3. `business_membership` — пустая коллекция**
Определена в constants и firestore.rules, но ни одна функция не создаёт документы. Dart-модели нет. Задумана для связи user-business, но не реализована.

**4. Dart-модель `Store` не содержит `ownerId`**
Бэкенд записывает `ownerId` в store-документ, но Dart-модель его не читает. Информация о владельце доступна только через `storeShip`.

**5. Нет механизма создания второго магазина**
`completeMerchantOnboarding` имеет idempotency guard: если у пользователя уже есть активный storeShip, возвращается существующий storeId. UI для "Добавить магазин" отсутствует.

**6. Конфликтующие статусные поля в StoreShip**
- `onboardingStatus` (legacy): `pending`, `itemCreated`, `storeCreated`, `completed`
- `status` (бэкенд): `active`
- `welcomeCompleted` + `hasFirstItem` (новые bool-поля)

Три разных механизма для одной концепции.

### Карта документов (текущая)

```
users/{uid}
  └── role: "partner" (custom claim)

storeDrafts/{draftId}
  ├── ownerId → users/{uid}
  └── storeId → stores/{storeId}  (pre-generated)

businesses/{businessId}        ← businessId == storeId (!)
  └── ownerId → users/{uid}

stores/{storeId}
  ├── ownerId → users/{uid}
  ├── businessId → businesses/{businessId}
  └── staffIds: []              ← всегда пустой

storeShips/{storeId}_{uid}
  ├── storeId → stores/{storeId}
  ├── businessId → businesses/{businessId}
  ├── userId → users/{uid}
  └── storeRole: "owner"        ← единственная реальная роль

business_membership/{id}        ← не создаётся нигде
```

## Целевая архитектура

### Карта документов (после доработки)

```
users/{uid}
  └── role: "partner" (custom claim)

businesses/{businessId}         ← собственный ID, генерируется отдельно
  └── ownerId → users/{uid}

business_membership/{businessId}_{uid}
  ├── businessId → businesses/{businessId}
  ├── userId → users/{uid}
  └── role: "owner" | "admin"   ← уровень бизнеса

stores/{storeId}                ← собственный ID
  ├── businessId → businesses/{businessId}
  └── (ownerId сохраняется как denormalized, но не используется для auth)

storeShips/{storeId}_{uid}      ← единый source of truth для доступа
  ├── storeId → stores/{storeId}
  ├── businessId → businesses/{businessId}
  ├── userId → users/{uid}
  ├── role: "owner" | "operator" | "employer"
  └── permissions: [...]

(staffIds убирается из stores)
```

### Ключевые решения

**A. storeShips — единый source of truth**
- `stores.staffIds` удаляется
- `stores.ownerId` сохраняется как denormalized поле (для запросов списка магазинов), но НЕ используется для auth
- Все проверки доступа (rules, Cloud Functions) переходят на storeShips
- storeShip создаётся для каждого пользователя с доступом к магазину, включая owner

**B. Разделение businessId и storeId**
- `businesses/{businessId}` получает собственный UUID
- `stores/{storeId}` ссылается на `businessId`
- Один бизнес → N магазинов

**C. business_membership — связь user-business**
- Документ создаётся при создании бизнеса (owner)
- Позволяет иметь несколько владельцев/администраторов бизнеса
- Используется для доступа к бизнес-уровню (финансы, верификация, настройки)

**D. Упрощение onboarding-статусов**
- `onboardingStatus` (legacy) удаляется
- Остаются `welcomeCompleted` и `hasFirstItem` — простые bool-флаги

## User Flows

### Flow 1: Регистрация и создание первого магазина (существующий, с исправлениями)

1. Пользователь вводит данные магазина (name, type, address, phone)
2. Вводит email + password → Firebase Auth account created
3. `startMerchantOnboarding` → создаёт `storeDraft` (без изменений)
4. Пользователь верифицирует email
5. `completeMerchantOnboarding` (изменения):
   - Генерирует **отдельные** `businessId` и `storeId`
   - Создаёт `businesses/{businessId}` с `ownerId: uid`
   - Создаёт `stores/{storeId}` с `businessId`, `ownerId` (denormalized, без `staffIds`)
   - Создаёт `storeShips/{storeId}_{uid}` с `role: "owner"`
   - Создаёт `business_membership/{businessId}_{uid}` с `role: "owner"`
   - Помечает draft как consumed
   - Устанавливает custom claims: `role: "partner"`, `canCreateStore: true`
6. Клиент получает обновлённый токен → redirect на welcome screen
7. Welcome screen → dashboard

### Flow 2: Создание второго магазина

1. Партнёр нажимает "Добавить магазин" в store list
2. Заполняет данные магазина (аналогично onboarding step 1-2, без регистрации)
3. Выбирает существующий бизнес (или создаёт новый — out of scope)
4. Вызывает новую Cloud Function `createAdditionalStore`:
   - Проверяет: пользователь — partner, canCreateStore, бизнес принадлежит пользователю (через business_membership)
   - Создаёт `stores/{newStoreId}` с `businessId`
   - Создаёт `storeShips/{newStoreId}_{uid}` с `role: "owner"`
5. Клиент перенаправляет на welcome для нового магазина

### Flow 3: Добавление члена команды

1. Owner магазина переходит в Team tab (в настройках магазина)
2. Нажимает "Пригласить сотрудника"
3. Вводит email сотрудника и выбирает роль (`operator` или `employer`)
4. Вызывает Cloud Function `inviteTeamMember`:
   - Проверяет: вызывающий — owner или operator данного магазина (через storeShip)
   - Находит пользователя по email (или создаёт invite)
   - Создаёт `storeShips/{storeId}_{inviteeUid}` с выбранной ролью и permissions
   - Если invitee ещё customer → обновляет custom claims на `role: "partner"`
5. Приглашённый пользователь видит новый магазин в store list

### Flow 4: Верификация бизнеса (без изменений в flow)

1. Owner переходит в Business → Verify
2. 3-step form (тип, данные, подтверждение)
3. Dart `BusinessRepository.submitVerification()` → вызывает Cloud Function `fakeVerifyBusiness` → статус verified
4. Без изменений, кроме: businessId теперь отдельный от storeId

## Requirements

### Must Have

#### Разделение businessId/storeId
- [ ] `completeMerchantOnboarding`: генерировать отдельные UUID для businessId и storeId
- [ ] Обновить все ссылки в batch write: business doc, store doc, storeShip doc
- [ ] Добавить `businessId` в Dart `Store` model и обновить `Store.fromMap()` (NB: `Store` использует hand-written `fromMap`, не codegen)
- [ ] `Business` должен быть independent от storeId

#### Миграция с staffIds на storeShips
- [ ] Удалить `staffIds` из TypeScript `StoreDoc` interface
- [ ] Удалить запись `staffIds: []` из `completeMerchantOnboarding`
- [ ] Обновить `firestore.rules`: заменить `isStoreStaff()` на проверку через storeShips collection
- [ ] Обновить `storage.rules`: аналогично
- [ ] Обновить все Cloud Functions, которые проверяют `staffIds`:
  - `create-one-time-offer.ts`
  - `update-offer-quantity.ts`
  - `update-order-status.ts`
  - `cancel-order.ts`
  - `delete-item.ts`
  - `load-offer-sync-context.ts`
  - NB: `on-order-status-changed.ts` — Firestore trigger (не callable), auth checks нет, изменений не требует
- [ ] Перевести `ownerId` в stores на denormalized-only: убрать из auth checks, оставить для запросов списка магазинов
- [ ] Обновить `isStoreOwner()` в rules на проверку через storeShips
- [ ] Обновить storeShips read rules: заменить `isStoreOwner(resource.data.storeId)` на `isStoreOwnerViaShip(resource.data.storeId)` чтобы избежать циклической зависимости при удалении `ownerId` из auth

#### business_membership
- [ ] Создать TypeScript interface `BusinessMembershipDoc`: `id`, `businessId`, `userId`, `role` ("owner" | "admin"), `createdAt`, `updatedAt`
- [ ] Создать Dart domain model `BusinessMembership`
- [ ] Создать Dart repository `BusinessMembershipRepository`
- [ ] Добавить создание документа в `completeMerchantOnboarding`
- [ ] Обновить firestore.rules: бизнес-документ доступен не только по `ownerId`, но и по membership

#### Переход ownerId в stores на denormalized
- [ ] Оставить `ownerId` в `StoreDoc` TypeScript interface как denormalized поле (нужно для запроса списка магазинов)
- [ ] Убрать ВСЕ auth checks через `store.ownerId` из rules и Cloud Functions — заменить на storeShips
- [ ] Обновить `StoreRepository.watchStoresList`: оставить запрос по `ownerId`, но дополнительно получать storeIds из storeShips для полного списка (partner может быть operator/employer чужого магазина)

#### Обновление TypeScript interfaces
- [ ] Обновить `StoreDoc` interface: добавить отсутствующие поля (`id`, `businessId`, `storeType`, `isVisible`, `createdAt`, `updatedAt`)
- [ ] Создать `StoreShipDoc` TypeScript interface (сейчас отсутствует, shape определён только inline в `completeMerchantOnboarding`)
- [ ] Переименовать поле `storeRole` → `role` в StoreShipDoc и Dart `StoreShip` (breaking change, требует миграции существующих документов в Фазе 2)

#### Безопасность fakeVerifyBusiness
- [ ] `fakeVerifyBusiness` сейчас проверяет только `role === 'partner'` — любой партнёр может верифицировать любой бизнес
- [ ] Добавить проверку `business_membership`: вызывающий должен быть owner бизнеса

#### Cleanup onboarding статусов в storeShip
- [ ] Удалить `onboardingStatus` из TypeScript и Dart моделей
- [ ] Удалить `status` поле (или оставить как soft-delete: `active`/`removed`)
- [ ] Убрать `skipOptionalOnboarding` Cloud Function (пишет `onboardingStatus`, но ни один consumer его не читает — dead-end)
- [ ] Обновить Dart `StoreShip` model: убрать backward-compat parsing

#### Cloud Function: createAdditionalStore
- [ ] Новая callable function: принимает store data + businessId
- [ ] Валидация: user is partner, canCreateStore, user has business_membership для businessId
- [ ] Transaction: создать store + storeShip
- [ ] Idempotency: deterministic storeId или check-before-write

#### Cloud Function: inviteTeamMember
- [ ] Новая callable function: принимает storeId, email, role, permissions
- [ ] Валидация: вызывающий — owner или operator (через storeShip)
- [ ] Найти user по email. Если не найден — создать invite record (или ошибка, решить в impl)
- [ ] Создать storeShip для invitee
- [ ] Если invitee customer → обновить custom claims на partner
- [ ] Idempotency: composite storeShip ID `{storeId}_{uid}` — set с merge

#### UI: Team Management
- [ ] Экран списка команды магазина (read storeShips where storeId == current)
- [ ] Создать Firestore composite index для `storeShips` на поле `storeId` (сейчас нет ни одного индекса на storeShips)
- [ ] Обновить firestore.rules: разрешить чтение storeShips по storeId для owner/operator (использовать `isStoreOwnerViaShip`, не `isStoreOwner`)
- [ ] Dialog приглашения: email + role selector
- [ ] Отображение роли, permissions для каждого member
- [ ] Действие: удалить сотрудника (Cloud Function `removeTeamMember`)

#### UI: Add Store
- [ ] Кнопка "Добавить магазин" в store list screen
- [ ] Переиспользовать форму из onboarding (name, type, address, phone)
- [ ] Выбор бизнеса (если один — автоматически)
- [ ] Вызов `createAdditionalStore`

### Nice to Have

- [ ] Cloud Function `removeTeamMember`: удаляет storeShip, откатывает claims если нет других магазинов
- [ ] Transfer ownership: передача роли owner другому member
- [ ] Invite link: приглашение по ссылке вместо email
- [ ] Activity log: лог действий по магазину (кто что изменил)

## Technical Constraints

### Обратная совместимость и миграция данных

Критический момент: в prod уже есть документы со старой структурой.

**Стратегия: двухфазная миграция**

1. **Фаза 1 (код)**: новый код читает и старые, и новые поля. Новые записи создаются в новом формате.
   - storeShips auth: проверять storeShips, но fallback на `ownerId` + `staffIds` если storeShip не найден
   - store docs: `ownerId` остаётся как denormalized поле (не удаляется), но не используется для auth
   - businessId == storeId: поддерживать старые документы, новые — с раздельными ID
   - storeShips: читать и `storeRole` и `role` (fallback на `storeRole` если `role` отсутствует). Новые записи используют `role`

2. **Фаза 2 (миграция)**: one-time Cloud Function или admin script:
   - Для каждого store с `ownerId` — создать storeShip если не существует
   - Для каждого business с `id == storeId` — создать новый business doc с отдельным ID, обновить store.businessId
   - Создать business_membership для каждого существующего business owner
   - Переименовать `storeRole` → `role` во всех storeShip документах
   - Удалить `staffIds` из store docs (ownerId остаётся как denormalized)

### Packages
- Без новых зависимостей

### Security rules — новые helper functions

```
// Заменяет isStoreOwner и isStoreStaff
function hasStoreAccess(storeId) {
  // 1 exists() call — используй для простых проверок доступа
  return exists(/databases/$(database)/documents/storeShips/$(storeId + '_' + request.auth.uid));
}

function hasStoreRole(storeId, role) {
  // 1 get() call — используй только когда нужна проверка роли
  // Не вызывай hasStoreAccess + hasStoreRole вместе — hasStoreRole имплицитно проверяет доступ
  return get(/databases/$(database)/documents/storeShips/$(storeId + '_' + request.auth.uid)).data.role == role;
}

function isStoreOwnerViaShip(storeId) {
  return hasStoreRole(storeId, 'owner');
}
```

NB: Текущие rules (`isStoreOwner` + `isStoreStaff`) делают до 4 `get()` вызовов на один rule evaluation. Новый паттерн — максимум 1 `exists()` или 1 `get()`. Это снижает Firestore billing и улучшает latency.

### Roles и permissions

| StoreShip Role | Описание | Default Permissions |
|---|---|---|
| `owner` | Полный доступ, управление командой | `manage_store`, `manage_orders`, `manage_offers`, `manage_team` |
| `operator` | Управление заказами и товарами, приглашение employer | `manage_orders`, `manage_offers`, `manage_team` |
| `employer` | Обработка заказов | `manage_orders` |

NB: Поле переименовывается с `storeRole` на `role` (breaking change). Фаза 1: Dart `StoreShip` читает оба имени (fallback). Фаза 2: миграция переименовывает поле во всех документах.

| BusinessMembership Role | Описание |
|---|---|
| `owner` | Создание магазинов, верификация, финансы |
| `admin` | Просмотр финансов, настройки бизнеса |

### Cloud Functions — auth helper переход

Текущий паттерн (во всех функциях):
```typescript
const storeData = (await db.doc(`stores/${storeId}`).get()).data();
if (storeData.ownerId !== uid && !(storeData.staffIds ?? []).includes(uid)) {
  throw new HttpsError('permission-denied', '...');
}
```

Новый паттерн:
```typescript
async function assertStoreAccess(uid: string, storeId: string): Promise<StoreShipDoc> {
  const shipDoc = await db.doc(`storeShips/${storeId}_${uid}`).get();
  if (!shipDoc.exists) {
    throw new HttpsError('permission-denied', 'No access to this store');
  }
  return shipDoc.data() as StoreShipDoc;
}
```

Это одно чтение вместо одного чтения + array check. Плюс возвращает роль и permissions для дальнейших проверок.

## Edge Cases

### Регистрация
- **Пользователь регистрируется дважды**: idempotency guard в `completeMerchantOnboarding` — существующий. Нужно обновить: проверять storeShip, а не только наличие.
- **Email уже занят**: Firebase Auth вернёт ошибку — обработано.
- **Draft expired**: `completeMerchantOnboarding` не проверяет `expiresAt`. Нужно добавить проверку.

### Создание второго магазина
- **Пользователь пытается создать магазин для чужого бизнеса**: проверка business_membership.
- **Максимум магазинов на бизнес**: пока без лимита, но стоит добавить soft limit (например, 10).
- **Создание магазина с тем же адресом**: разрешить — разные точки могут быть по одному адресу.

### Команда
- **Приглашение пользователя, который ещё не зарегистрирован**: два варианта:
  - Ошибка "пользователь не найден" — проще, рекомендуется для MVP.
  - Создать pending invite — сложнее, nice to have.
- **Удаление последнего owner**: запретить. Хотя бы один owner должен остаться.
- **Самоудаление**: owner не может удалить себя из последнего своего магазина.
- **Удаление сотрудника с активными заказами**: разрешить удаление, но заказы остаются привязаны к магазину.

### Миграция
- **Старые store docs с ownerId**: fallback в rules и functions на время миграции.
- **Старые storeShips с onboardingStatus**: Dart-модель парсит оба формата (уже реализовано, удалить после миграции).
- **businessId == storeId для старых данных**: при миграции создать новый business doc, обновить все ссылки.

### Права доступа
- **StoreShip удалён, но claims остались partner**: при удалении последнего storeShip → проверить, есть ли другие магазины. Если нет — откатить claims на customer.
- **Concurrent modifications**: storeShip create/delete через Cloud Functions в transaction.

## Out of Scope

- Создание нового бизнеса для существующего партнёра (пока один бизнес на пользователя)
- Transfer ownership бизнеса
- Invite link (приглашение по ссылке)
- Роли и permissions на уровне UI (permission-based UI gating) — пока только backend enforcement
- Уведомления при приглашении (push/email)
- Аудит-лог действий команды
- Миграция существующих данных (отдельная задача после внедрения)
- Изменение потока верификации бизнеса (fakeVerifyBusiness остаётся)

## Risk Assessment

| Риск | Severity | Mitigation |
|---|---|---|
| Миграция ломает доступ у существующих партнёров | Critical | Двухфазная миграция: fallback на старые поля |
| Security rules become более сложными (storeShips reads) | Medium | Composite ID — 1 read вместо 4; чистый выигрыш по billing |
| storeShip deletion creates orphan references | Medium | Cloud Function проверяет зависимости перед удалением |
| Custom claims race condition (partner ↔ customer) | Low | Claims set только в Cloud Functions, sequential |
| `fakeVerifyBusiness` не проверяет ownership бизнеса | Medium | Добавить проверку business_membership перед верификацией |
| Переименование `storeRole` → `role` — breaking change | Medium | Фаза 1: fallback чтение обоих полей. Фаза 2: миграция документов |
| Team list query по storeId — нет composite index | Low | Создать index в firestore.indexes.json; обновить rules для query |

## Definition of Done

- [ ] `businessId` и `storeId` генерируются отдельно при onboarding
- [ ] `staffIds` удалён из StoreDoc, все auth checks через storeShips
- [ ] `ownerId` остаётся как denormalized, но убран из всех auth checks
- [ ] `storeRole` переименован в `role` (с backward-compat fallback в Фазе 1)
- [ ] `business_membership` создаётся при создании бизнеса
- [ ] `fakeVerifyBusiness` проверяет business_membership
- [ ] Firestore rules обновлены на storeShips-based access
- [ ] Storage rules обновлены аналогично
- [ ] StoreShips read rules используют `isStoreOwnerViaShip` (без циклической зависимости)
- [ ] Composite index для storeShips на `storeId` создан
- [ ] `StoreDoc` и `StoreShipDoc` TypeScript interfaces актуальны
- [ ] Все Cloud Functions с auth checks обновлены на `assertStoreAccess()`
- [ ] `createAdditionalStore` Cloud Function работает
- [ ] `inviteTeamMember` Cloud Function работает
- [ ] UI: Team tab с списком и приглашением
- [ ] UI: "Добавить магазин" в store list
- [ ] `onboardingStatus` удалён из storeShip
- [ ] Dart модели обновлены (Store с `businessId`, StoreShip с `role`, Business, BusinessMembership)
- [ ] `flutter analyze` проходит
- [ ] Cloud Functions компилируются (`npm run build`)
- [ ] Firestore rules покрыты тестами (emulator)
- [ ] Ручной QA: полный flow регистрации → создание магазина → приглашение сотрудника → второй магазин
