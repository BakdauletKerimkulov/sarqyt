import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { db } from "../../app/firebase";
import { FirestoreCollections } from "../../shared/constants/constants";

export const onReviewWritten = onDocumentWritten(
  { document: "reviews/{reviewId}", region: "asia-south1" },
  async (event) => {
    // Determine storeId from before or after data (handles delete case)
    const afterData = event.data?.after?.data();
    const beforeData = event.data?.before?.data();
    const storeId = (afterData?.storeId ?? beforeData?.storeId) as
      | string
      | undefined;

    if (!storeId) {
      console.error(`Review ${event.params.reviewId} missing storeId`);
      return;
    }

    const storeRef = db
      .collection(FirestoreCollections.STORES)
      .doc(storeId);

    await db.runTransaction(async (tx) => {
      // Verify store exists
      const storeSnap = await tx.get(storeRef);
      if (!storeSnap.exists) {
        console.warn(`Store ${storeId} not found, skipping aggregation`);
        return;
      }

      // Query all reviews for this store
      const reviewsSnap = await tx.get(
        db
          .collection("reviews")
          .where("storeId", "==", storeId),
      );

      const reviewCount = reviewsSnap.size;

      if (reviewCount === 0) {
        tx.update(storeRef, { avgRating: 0, reviewCount: 0 });
        return;
      }

      // Compute average of each review's averageRating
      // averageRating = (storeRating + offerRating) / 2
      // Read offerRating with fallback to foodRating for old docs
      let totalAvg = 0;
      for (const doc of reviewsSnap.docs) {
        const data = doc.data();
        const storeRating = (data.storeRating as number) ?? 0;
        const offerRating =
          (data.offerRating as number) ?? (data.foodRating as number) ?? 0;
        totalAvg += (storeRating + offerRating) / 2;
      }

      const avgRating =
        Math.round((totalAvg / reviewCount) * 10) / 10;

      tx.update(storeRef, { avgRating, reviewCount });
    });
  },
);
