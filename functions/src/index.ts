// Импорты
import * as admin from "firebase-admin";

// Инициализация админ-панели (чтобы сервер мог писать в базу)
admin.initializeApp();

export { registerBusiness } from "./register_business";

export { createOffer } from "./create_offer";
