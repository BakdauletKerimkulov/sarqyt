
export interface FirebaseAuthError {
    code: string;
    message: string;
}

// 2. Описываем данные для удобства
export interface Country {
    name: string;
    isoCode: string;
}

export interface RegisterBusinessData {
    email: string;
    password: string;
    name: string;
    address: string;
    locality: string;
    location: number[];
    postalCode: string;
    country: Country;
    phoneNumber: string;
    storeType: string;
}
