/** A single day's pickup schedule stored inside an Item document. */
export interface DaySchedule {
  enabled: boolean;
  startHour: number;
  startMinute: number;
  endHour: number;
  endMinute: number;
  quantity: number;
}

/**
 * Weekly schedule map.
 * Keys are ISO weekday strings ("1"=Monday … "7"=Sunday).
 */
export type WeeklySchedule = Record<string, DaySchedule>;

/** Shape of a document in `stores/{storeId}/items/{itemId}`. */
export interface ItemDoc {
  name: string;
  price: number | { amount: number };
  schedule: WeeklySchedule;
  estimatedValue?: number | { amount: number } | null;
  imageUrl?: string | null;
  description?: string | null;
  category?: string | null;
  dietaryType?: string;
  packagingType?: string;
  collectionInstructions?: string | null;
  isActive?: boolean;
  isBuffetFood?: boolean;
  storingAndAllergens?: string | null;
}
