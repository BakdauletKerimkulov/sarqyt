---
title: Небезопасное чтение custom claims в isPartner() и canCreateStore()
status: done
date: 2026-08-16
type: fix
severity: S
references: [ai_specs/archive/046-prepare-region-migration-plan.md]
---

## Symptom

Наблюдаемого симптома нет — и это главное, что нужно знать про эту запись.

`firestore.rules` читал custom claims в форме, которая при отсутствующем claim роняет вычисление условия вместо возврата `false`. В логах эмулятора отказ выглядел как ошибка правил, а не как штатный `deny`, и зашумлял вывод rules-тестов. Наружу это не выходило: доступ отклонялся ровно там, где и должен был.

Находка пришла не из багрепорта, а из Phase 3 плана 046 — там **та же форма в `storage.rules` уже стоила продового бага**: `isAdmin()` стоял первым в цепочке `||`, у участника магазина без claim `role` выражение падало целиком вместе с ветками после `||`, и он не мог загрузить ни одной картинки. Правка `storage.rules` была выровнена по безопасной форме, а `firestore.rules:18` остался с небезопасной. Зафиксировано как хвост вне объёма фазы.

## Root cause

`firestore.rules:18` и `:24` обращались к свойствам токена напрямую:

```
function isPartner() {
  return isSignedIn() && request.auth.token.role == 'partner';
}

function canCreateStore() {
  return isAdmin() || (isPartner() && request.auth.token.canCreateStore == true);
}
```

В Firestore Security Rules чтение отсутствующего свойства токена — не `null` и не `false`, а ошибка вычисления: `Property role is undefined` роняет всё выражение, включая ветки после `||`.

Почему это не выстрелило здесь, в отличие от `storage.rules`: единственная точка использования — `allow create` на `stores/{storeId}` (`firestore.rules:77`) через `canCreateStore()`, а там первым стоит `isAdmin()`, уже переведённый на `token.get('role', '')` в более раннем фиксе. `||` в rules вычисляется с коротким замыканием, поэтому админ до сломанной ветки не доходит, а для всех остальных упавшее выражение даёт тот же `deny`, что и корректный `false`.

То есть корневая причина — небезопасная форма чтения claims, а её безвредность здесь обеспечена **позиционной случайностью**, а не замыслом. Любая перестановка веток в `canCreateStore()` или новое использование `isPartner()` в цепочке `||` превратила бы это в продовый отказ доступа — ровно по сценарию `storage.rules`.

## Fix

- **Files changed:** `firestore.rules`, `functions/test/firestore-rules.test.ts`
- **Failing test that catches the regression:** RED-теста нет и быть не могло — см. «Отклонение от процедуры» ниже. Инвариант закреплён набором `functions/test/firestore-rules.test.ts::stores — create` (7 тестов), доказанным мутацией.
- **`ai_toolkit/` rules applied:** `RULES-backend.md → Security rules` («deny by default»; «rules are tested with the emulator, as an ordinary authenticated user and as an anonymous one» — покрыты оба, плюс партнёр, клиент и админ)
- **Toolkit deviations:** отклонение от hard rule команды `/fix` — «write a failing test (RED) before the fix». Описано ниже, согласовано с пользователем 2026-08-16.

Оба чтения переведены на форму с дефолтом, выровненную с `isAdmin()` на `firestore.rules:14`: `request.auth.token.get('role', '')` и `request.auth.token.get('canCreateStore', false)`. Поведение доступа не изменилось ни в одном из проверенных сценариев — изменилось то, что отказ теперь штатный, а не аварийный, и не зависит от порядка веток в выражении. Вторую небезопасную форму (`canCreateStore` claim) нашёл при правке первой: партнёр *с* ролью, но без флага ронял вычисление ровно так же.

## Отклонение от процедуры: почему нет RED-теста

`/fix` требует красный тест до правки. Здесь он невозможен: обе формы дают `deny`, различимого снаружи исхода у бага нет. Тест, который «падает до и проходит после», пришлось бы подделать.

Вместо него — **мутационная проверка**. Семь тестов на `stores/{storeId}` create закрепляют таблицу истинности: партнёр с флагом → allow; партнёр без флага → deny; партнёр с `canCreateStore: false` → deny; пользователь вовсе без claims → deny; клиент (`role: 'client'`) с флагом → deny; админ без флага → allow; аноним → deny. Ослабление правила (`canCreateStore()` → просто `isPartner()`) валит 2 из них.

Что это доказывает и чего не доказывает, честно: доказывает, что тесты держат инвариант доступа и переписывание формы его не сдвинуло. **Не доказывает, что баг был** — потому что наблюдаемого бага и не было. Ценность правки в устранении прецедента, а не симптома.

## Проверка

Эмулятор (`firebase emulators:exec --only firestore,auth,storage "cd functions && npm test"`): 13 файлов, 120 тестов зелёных. Мутация правила даёт `2 failed | 118 passed`. `firestore.rules` восстановлен после мутации, sha256 совпал с дозамерным.

**Требуется деплой:** `firebase deploy --only firestore:rules`. До него прод и репозиторий расходятся — функционально одинаково, но форма в проде старая.

## Урок

Небезопасная форма чтения claims безвредна только до первой перестановки веток. Искать её надо не по симптому (его может не быть годами), а по образцу: `request.auth.token.<name>` без `.get()`. На момент этой записи в `firestore.rules` и `storage.rules` таких обращений не осталось; при добавлении новых claim-проверок использовать только `token.get(name, default)`.
