export interface Country {
    name: string,
    isoCode: string
}

export interface StoreDraftRequestDto {
    storeName: string,
    address: string,
    locality: string,
    country: Country,
    location: number[],
    postalCode: string,
    phoneNumber: string,
    storeType: string,
}
