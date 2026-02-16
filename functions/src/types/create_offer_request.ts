
// Описание запроса для создания оффера
export interface CreateOfferRequest {
    storeId: string,
    productId: string,
    quantity: number,
    pickupStart: string,
    pickupEnd: string,
}
