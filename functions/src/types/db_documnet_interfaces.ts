
export interface StoreFromDb {
    id: string,
    ownerId: string,
    staffIds: string[],
}

export interface Money {
    amount: number,
    code: string,
    symbol: string,
}

export interface ProductFromDb {
    id: string,
    name: string,
    imageUrl: string | null,
    money: Money,
}
