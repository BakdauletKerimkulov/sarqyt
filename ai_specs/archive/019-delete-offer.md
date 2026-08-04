---
title: Delete Offer
status: draft
date: 2026-05-23
type: feature
---

добавить возможность удаления оффера. Только если нет бронирования

---

## Проверка реализации (2026-08-02)

Уже реализовано и обкатано. В терминологии кодовой базы «оффер» в этом запросе = `Item` (то, что публикует продавец); гард «только если нет бронирования» = проверка активных `Order`.

- Клиент: `lib/src/features/items/presentation/item_screen/settings_content.dart:71-129` (`_DeleteItemButton`) — предпроверка `hasActiveOrders()`, диалог «нельзя удалить» при активных бронях, иначе подтверждение.
- Сервер (авторитетный гард): `functions/src/features/items/functions/delete-item.ts:19,50-62` — callable `deleteItem` перепроверяет `orders` по `itemId` со статусами `confirmed/preparing/readyForPickup`, при найденных бросает `failed-precondition`; затем каскадно удаляет связанные `offers` и картинку из Storage.
- Багфиксы поверх фичи уже закрыты: `archive/023-fix-delete-item-error-{spec,plan}.md`, `archive/025-fix-item-delete-nav-spec.md`, `archive/026-fix-disposed-ref-delete-spec.md`.

**Дальнейшие действия:** файл устарел, запрошенная возможность полностью реализована с обеими сторонами гарда (client UX + server-authoritative). Кандидат на архивацию как дубль/уже сделано — если у пользователя нет уточнения, что именно ещё не работает.