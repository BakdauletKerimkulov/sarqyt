import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { auth, db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections, UserRole } from "../../../shared/constants/constants";
import { assertStoreAccess } from "../../../shared/helpers/assert-store-access";

interface InviteTeamMemberRequest {
  storeId: string;
  email: string;
  role: "operator" | "employer";
  permissions: string[];
}

const DEFAULT_PERMISSIONS: Record<string, string[]> = {
  operator: ["manage_orders", "manage_offers", "manage_team"],
  employer: ["manage_orders"],
};

/**
 * Invites a user to a store team by email.
 * Caller must be owner or operator of the store.
 * If invitee is not a partner, upgrades their custom claims.
 * Idempotency: composite storeShip ID `{storeId}_{uid}` — set with merge.
 */
export const inviteTeamMember = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const callerUid = req.auth.uid;

    const data = req.data as InviteTeamMemberRequest;
    if (!data.storeId || typeof data.storeId !== "string") {
      throw new AppError("invalid-argument", "storeId is required");
    }
    if (!data.email || typeof data.email !== "string") {
      throw new AppError("invalid-argument", "email is required");
    }
    if (!data.role || !["operator", "employer"].includes(data.role)) {
      throw new AppError("invalid-argument", "role must be 'operator' or 'employer'");
    }

    // Auth: caller must have store access with owner or operator role
    const callerShip = await assertStoreAccess(callerUid, data.storeId);
    if (callerShip.role !== "owner" && callerShip.role !== "operator") {
      throw new AppError("permission-denied", "Only owner or operator can invite");
    }

    // Find invitee by email
    const usersSnap = await db
      .collection(FirestoreCollections.USERS)
      .where("email", "==", data.email)
      .limit(1)
      .get();

    if (usersSnap.empty) {
      throw new AppError("not-found", "User not found with this email");
    }

    const inviteeDoc = usersSnap.docs[0];
    const inviteeUid = inviteeDoc.data().uid as string;

    if (inviteeUid === callerUid) {
      throw new AppError("invalid-argument", "Cannot invite yourself");
    }

    // Create storeShip for invitee
    const permissions = data.permissions?.length
      ? data.permissions
      : DEFAULT_PERMISSIONS[data.role] ?? [];

    const now = serverTimestamp();
    const shipId = `${data.storeId}_${inviteeUid}`;

    // Read store for name/logo
    const storeSnap = await db
      .collection(FirestoreCollections.STORES)
      .doc(data.storeId)
      .get();
    const storeData = storeSnap.data();

    const storeShipDoc = {
      id: shipId,
      storeId: data.storeId,
      businessId: callerShip.businessId,
      userId: inviteeUid,
      role: data.role,
      storeRole: data.role, // backward compat — Phase 1
      name: storeData?.name ?? "",
      logoUrl: storeData?.logoUrl ?? null,
      permissions,
      welcomeCompleted: true, // invited members skip welcome
      hasFirstItem: true,
      createdAt: now,
      updatedAt: now,
    };

    await db
      .collection(FirestoreCollections.STORE_SHIPS)
      .doc(shipId)
      .set(storeShipDoc, { merge: true });

    // Upgrade invitee to partner if they're currently a customer
    const inviteeRole = inviteeDoc.data().role;
    if (inviteeRole !== UserRole.PARTNER && inviteeRole !== UserRole.ADMIN) {
      await auth.setCustomUserClaims(inviteeUid, {
        role: UserRole.PARTNER,
        canCreateStore: false,
      });
      await db.collection(FirestoreCollections.USERS).doc(inviteeUid).update({
        role: UserRole.PARTNER,
        updatedAt: now,
      });
    }

    logInfo("inviteTeamMember done", {
      callerUid,
      inviteeUid,
      storeId: data.storeId,
      role: data.role,
    });
    return { success: true };
  } catch (error) {
    logError("inviteTeamMember failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
