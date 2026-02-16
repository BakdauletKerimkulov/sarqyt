
import * as admin from "firebase-admin";
import { FieldValue, GeoPoint } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { FirebaseAuthError, RegisterBusinessData } from "./types/register_business_types";
import { validateRegisterBusinessData } from "./validators/register_business_validators";

/**
 * Регистрирует новый бизнес и создает пользователя-владельца
 * в Firebase Auth и Firestore.
 * Проверяет данные, переданные с клиента, и если они валидны:
 * 1. Создает пользователя в Firebase Auth с email и паролем.
 * 2. Создает документ пользователя в коллекции `users`.
 * 3. Создает документ магазина в коллекции `stores`.
 * 4. Связывает пользователя с магазином через поле `ownedStore`.
 *
 * @param {object} request - Объект запроса от клиента Firebase Functions.
 * @param {RegisterBusinessData} request.data - Данные нового бизнеса.
 * @returns {Promise<{success: boolean, uid: string}>} -
 * Возвращает объект с флагом успешного создания и UID нового пользователя.
 * @throws {HttpsError} Если данные некорректны или регистрация не удалась.
 */
export const registerBusiness = onCall(async (request) => {
  const data = request.data as RegisterBusinessData;

  // 1. Валидация полученных данных
  const validationError = validateRegisterBusinessData(data);
  if (validationError) {
    throw new HttpsError("invalid-argument", validationError);
  }

  // 2. Создание пользователя в Auth
  const userRecord = await admin.auth().createUser({
    email: data.email,
    password: data.password,
  });
  try {
    const db = admin.firestore();
    const batch = db.batch();

    const userRef = db.collection("users").doc(userRecord.uid);
    const storeRef = db.collection("stores").doc();
    const storeId = storeRef.id;

    // 3. НАПОЛНЕНИЕ ДАННЫМИ
    batch.set(userRef, {
      email: data.email,
      role: "owner",
      createdAt: FieldValue.serverTimestamp(),
      ownedStores: [storeId],
    });

    await admin.auth().setCustomUserClaims(userRecord.uid, {
      role: "owner",
    });

    logger.info(`User role has been set in custom claims: 
        ${userRecord.uid} - ${userRecord.customClaims}`);

    logger.info("LOCATION DEBUG", data.location);
    const geoPoint = new GeoPoint(data.location[0], data.location[1]);

    const createdAt = FieldValue.serverTimestamp();

    batch.set(storeRef, {
      id: storeId,
      name: data.name,
      location: {
        address: {
          country: {
            name: data.country.name,
            isoCode: data.country.isoCode,
          },
          address: data.address,
          locality: data.locality,
          postalCode: data.postalCode,
        },
        point: geoPoint,
      },
      storeType: data.storeType,
      staffIds: [],
      // metadata
      phoneNumber: data.phoneNumber,
      ownerId: userRecord.uid,
      isVisible: true,
      rating: 0,
      createdAt: createdAt,
    });

    await batch.commit();

    logger.info(`Business created: ${data.name}`);

    return { success: true, uid: userRecord.uid };
  } catch (rawError) {
    await admin.auth().deleteUser(userRecord.uid);
    const error = rawError as FirebaseAuthError;

    logger.error("Registration failed", rawError);

    // 4. Обработка дубликата Email
    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "Пользователь с таким email уже зарегистрирован."
      );
    }

    // 5. Обработка слабого пароля (если вдруг валидация пропустила)
    if (error.code === "auth/weak-password") {
      throw new HttpsError(
        "invalid-argument",
        "Пароль слишком слабый."
      );
    }

    throw new HttpsError(
      "internal",
      "Не удалось создать бизнес-аккаунт. Попробуйте позже.",
      { originalError: error.message } // Передаем текст ошибки в деталях
    );
  }
});
