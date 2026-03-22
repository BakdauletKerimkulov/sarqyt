import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { UserRole } from "../constants/constants";

export interface PreferencesDoc {
    vegetarian: boolean,
    halal: boolean,
}

export interface UserStatsDoc {
    savedMoney: number,
}

export interface UserDoc {
    uid: string,
    displayName: string | null,
    email: string,
    avatarUrl: string | null,
    preferences: PreferencesDoc,
    favorites: Array<string>,
    stats: UserStatsDoc,
    role: UserRole,
    refreshTime: FieldValue | Timestamp,
}
