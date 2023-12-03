/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.getUserInfo = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const userRecord = await admin.auth().getUserByEmail(email);
  const {uid, emailVerified, metadata, customClaims} = userRecord.toJSON();
  const isAdmin = customClaims && customClaims.admin === true;
  return {uid, emailVerified, metadata, isAdmin};
});

exports.checkAuthenticatedUser = functions.https.onCall(async (data, context)=>{
  // Ensure the user is signed in.
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const {uid} = context.auth;

  // Return the authenticated user's uid
  return {uid: uid};
});

exports.updateAdminStatus = functions.https.onCall(async (data, context) => {
  // Ensure the user is signed in.
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const uid = context.auth.uid;

  // Check if the user is an admin.
  let userRecord;
  try {
    userRecord = await admin.auth().getUser(uid);
  } catch (error) {
    throw new functions.https.HttpsError("unknown", error.message, error);
  }

  if (!(userRecord.customClaims && userRecord.customClaims.admin)) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "The function must be called by an administrator.",
    );
  }

  const {uidToUpdate, isAdmin} = data;
  try {
    await admin.auth().setCustomUserClaims(uidToUpdate, {admin: isAdmin});
    return {result: "Admin status updated successfully"};
  } catch (error) {
    throw new functions.https.HttpsError("unknown", error.message, error);
  }
});

exports.updateEmailVerificationStatus = functions.https.onCall(
    async (data, context) => {
      // Ensure the user is signed in.
      if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "The function must be called while authenticated.",
        );
      }

      const uid = context.auth.uid;

      // Check if the user is an admin.
      let userRecord;
      try {
        userRecord = await admin.auth().getUser(uid);
      } catch (error) {
        throw new functions.https.HttpsError("unknown", error.message, error);
      }

      if (!(userRecord.customClaims && userRecord.customClaims.admin)) {
        throw new functions.https.HttpsError(
            "permission-denied",
            "The function must be called by an administrator.",
        );
      }

      const {uidToUpdate, status} = data;

      // Update the email verification status in Firebase Authentication.
      try {
        await admin.auth().updateUser(uidToUpdate, {emailVerified: status});
        return {result: "Email verification status updated successfully."};
      } catch (error) {
        throw new functions.https.HttpsError("unknown", error.message);
      }
    },
);


exports.deleteUnverifiedUser = functions.https.onRequest(async (req, res) => {
  let unverifiedUsers = [];
  const listAllUsers = async (nextPageToken) => {
    const listUsersResult = await admin.auth().listUsers(1000, nextPageToken);
    const userPromises = listUsersResult.users.map(async (userRecord) => {
      if (!userRecord.emailVerified) {
        const userDoc = db.collection("users").doc(userRecord.uid);
        await db.runTransaction(async (transaction) => {
          transaction.delete(userDoc);
        });
        await admin.auth().deleteUser(userRecord.uid);
        unverifiedUsers.push(userRecord.toJSON());
      }
    });
    await Promise.all(userPromises);
    if (listUsersResult.pageToken) {
      await listAllUsers(listUsersResult.pageToken);
    }
  };
  await listAllUsers();
  res.send(unverifiedUsers);
});

exports.deleteUnverifiedUserOverTenMinutes = functions.https.
    onRequest(async (req, res) => {
      let unverifiedUsers = [];
      // List batch of users, 1000 at a time.
      const listAllUsers = async (nextPageToken) => {
        // List batch of users, 1000 at a time.
        const listUsersResult = await admin.auth().
            listUsers(1000, nextPageToken);
        const userPromises = listUsersResult.users.map(async (userRecord) => {
          const creationTime = new Date(userRecord.metadata.creationTime)
              .getTime();
          const now = Date.now();
          if (!userRecord.emailVerified && now - creationTime > 10 * 60 * 1000
          ) {
            await admin.auth().deleteUser(userRecord.uid);
            unverifiedUsers.push(userRecord.toJSON());
          }
        });
        await Promise.all(userPromises);
        if (listUsersResult.pageToken) {
          // List next batch of users.
          await listAllUsers(listUsersResult.pageToken);
        }
      };
      await listAllUsers();
      res.send(unverifiedUsers);
    });

exports.deleteUnverifiedUserOverOneHour = functions.https.
    onRequest(async (req, res) => {
      let unverifiedUsers = [];
      // List batch of users, 1000 at a time.
      const listAllUsers = async (nextPageToken) => {
        // List batch of users, 1000 at a time.
        const listUsersResult = await admin.auth().
            listUsers(1000, nextPageToken);
        const userPromises = listUsersResult.users.map(async (userRecord) => {
          const creationTime = new Date(userRecord.metadata.creationTime)
              .getTime();
          const now = Date.now();
          if (!userRecord.emailVerified && now - creationTime > 1*60*60*1000
          ) {
            await admin.auth().deleteUser(userRecord.uid);
            unverifiedUsers.push(userRecord.toJSON());
          }
        });
        await Promise.all(userPromises);
        if (listUsersResult.pageToken) {
          // List next batch of users.
          await listAllUsers(listUsersResult.pageToken);
        }
      };
      await listAllUsers();
      res.send(unverifiedUsers);
    });

exports.deleteUnverifiedUserOverFiveDays = functions.https.
    onRequest(async (req, res) => {
      let unverifiedUsers = [];
      // List batch of users, 1000 at a time.
      const listAllUsers = async (nextPageToken) => {
        // List batch of users, 1000 at a time.
        const listUsersResult = await admin.auth().
            listUsers(1000, nextPageToken);
        const userPromises = listUsersResult.users.map(async (userRecord) => {
          const creationTime = new Date(userRecord.metadata.creationTime)
              .getTime();
          const now = Date.now();
          if (!userRecord.emailVerified && now - creationTime > 5*24*60*60*1000
          ) {
            await admin.auth().deleteUser(userRecord.uid);
            unverifiedUsers.push(userRecord.toJSON());
          }
        });
        await Promise.all(userPromises);
        if (listUsersResult.pageToken) {
          // List next batch of users.
          await listAllUsers(listUsersResult.pageToken);
        }
      };
      await listAllUsers();
      res.send(unverifiedUsers);
    });


/**


**/
/**
exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
**/


