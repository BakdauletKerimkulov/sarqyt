import { RegisterBusinessData } from "../types/register_business_types";

/**
 * Функция валидирует поля в отправленном из клиента объекте
 * @param {RegisterBusinessData} data - данные нового бизнеса
 * @return {string | null} - возвращает строку или null
 */
export function validateRegisterBusinessData(data: RegisterBusinessData):
    string | null {
  // Проверка обязательных строковых полей
  if (!data.email || typeof data.email !== "string") {
    return "Email обязателен и должен быть строкой";
  }

  if (!data.password || typeof data.password !== "string") {
    return "Пароль обязателен и должен быть строкой";
  }

  if (data.password.length < 6) {
    return "Пароль должен содержать минимум 6 символов";
  }

  if (!data.name || typeof data.name !== "string") {
    return "Название магазина обязательно";
  }

  if (!data.address || typeof data.address !== "string") {
    return "Адрес обязателен";
  }

  if (!data.locality || typeof data.locality !== "string") {
    return "Местность обязательна";
  }

  if (!data.postalCode || typeof data.postalCode !== "string") {
    return "Почтовый код обязателен";
  }

  if (!data.phoneNumber || typeof data.phoneNumber !== "string") {
    return "Номер телефона обязателен";
  }

  if (!data.storeType || typeof data.storeType !== "string") {
    return "Тип магазина обязателен";
  }

  // Проверка формата email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(data.email)) {
    return "Некорректный формат email";
  }

  // Проверка location (массив с 2 числами для координат)
  if (!Array.isArray(data.location) || data.location.length !== 2) {
    return "Location должен быть массивом из 2 чисел [latitude, longitude]";
  }

  if (!data.location.every((coord) => typeof coord === "number")) {
    return "Координаты должны быть числами";
  }

  // Проверка country объекта
  if (!data.country || typeof data.country !== "object") {
    return "Страна обязательна";
  }

  if (!data.country.name || !data.country.isoCode) {
    return "Страна должна иметь name и isoCode";
  }

  return null; // Все валиден
}
