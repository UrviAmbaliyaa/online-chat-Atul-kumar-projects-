import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:online_chat/features/home/models/chat_info_model.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/firebase_constants.dart';

/// Firebase Service - Centralized Firebase CRUD operations
/// All Firebase operations should go through this service
class FirebaseService {
  // Firebase instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== AUTHENTICATION METHODS ====================

  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Check if user is logged in
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Sign in with email and password
  /// Returns UserCredential on success, null on failure
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.signInError,
      );
      return null;
    }
  }

  /// Sign up with email and password
  /// Returns UserCredential on success, null on failure
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.signUpError,
      );
      return null;
    }
  }

  /// Sign out current user
  static Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.signOutError,
      );
      return false;
    }
  }

  /// Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppSnackbar.success(
        message: AppString.passwordResetEmailSent,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.passwordResetEmailError,
      );
      return false;
    }
  }

  /// Change user password
  /// Requires reauthentication with current password
  /// [currentPassword] - User's current password
  /// [newPassword] - New password to set
  /// Returns true on success, false on failure
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppSnackbar.error(message: AppString.userNotLoggedIn);
        return false;
      }

      // Step 1: Reauthenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        final errorMessage = FirebaseConstants.getAuthErrorMessage(e.code);
        if (e.code == FirebaseConstants.authErrorWrongPassword) {
          AppSnackbar.error(message: AppString.reauthenticationFailed);
        } else {
          AppSnackbar.error(message: errorMessage);
        }
        return false;
      } catch (e) {
        AppSnackbar.error(message: AppString.reauthenticationFailed);
        return false;
      }

      // Step 2: Update password
      try {
        await user.updatePassword(newPassword);
        AppSnackbar.success(message: AppString.passwordChanged);
        return true;
      } on FirebaseAuthException catch (e) {
        final errorMessage = FirebaseConstants.getAuthErrorMessage(e.code);
        AppSnackbar.error(message: errorMessage);
        return false;
      } catch (e) {
        AppSnackbar.error(message: AppString.passwordChangeError);
        return false;
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.passwordChangeError);
      return false;
    }
  }

  /// Handle Firebase Auth exceptions
  static void _handleAuthException(FirebaseAuthException e) {
    final message = FirebaseConstants.getAuthErrorMessage(e.code);
    AppSnackbar.error(message: e.message ?? message);
  }

  // ==================== FIRESTORE CRUD METHODS ====================

  /// Create a document in Firestore
  /// [collection] - Collection name
  /// [docId] - Document ID (optional, auto-generated if not provided)
  /// [data] - Data to save
  /// Returns document ID on success, null on failure
  static Future<String?> createDocument({
    required String collection,
    String? docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      DocumentReference docRef;
      if (docId != null && docId.isNotEmpty) {
        docRef = _firestore.collection(collection).doc(docId);
        await docRef.set(data);
      } else {
        docRef = await _firestore.collection(collection).add(data);
      }
      return docRef.id;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.createDocumentError,
      );
      return null;
    }
  }

  /// Get a document from Firestore
  /// [collection] - Collection name
  /// [docId] - Document ID
  /// Returns document data on success, null on failure
  static Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.getDocumentError,
      );
      return null;
    }
  }

  /// Update a document in Firestore
  /// [collection] - Collection name
  /// [docId] - Document ID
  /// [data] - Data to update
  /// Returns true on success, false on failure
  static Future<bool> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      return true;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.updateDocumentError,
      );
      return false;
    }
  }

  /// Delete a document from Firestore
  /// [collection] - Collection name
  /// [docId] - Document ID
  /// Returns true on success, false on failure
  static Future<bool> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return true;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.deleteDocumentError,
      );
      return false;
    }
  }

  /// Get all documents from a collection
  /// [collection] - Collection name
  /// [orderBy] - Field to order by (optional)
  /// [limit] - Maximum number of documents (optional)
  /// Returns list of documents
  static Future<List<Map<String, dynamic>>> getDocuments({
    required String collection,
    String? orderBy,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      AppSnackbar.error(
        message: AppString.getDocumentsError,
      );
      return [];
    }
  }

  /// Get documents with where clause
  /// [collection] - Collection name
  /// [field] - Field name to filter
  /// [operator] - Comparison operator (==, <, >, <=, >=, !=, array-contains, etc.)
  /// [value] - Value to compare
  /// Returns list of matching documents
  static Future<List<Map<String, dynamic>>> getDocumentsWhere({
    required String collection,
    required String field,
    required String operator,
    required dynamic value,
    String? orderBy,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection).where(field, isEqualTo: value);

      if (orderBy != null) {
        query = query.orderBy(orderBy);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      AppSnackbar.error(
        message: AppString.getDocumentsError,
      );
      return [];
    }
  }

  /// Stream documents from a collection (real-time updates)
  /// [collection] - Collection name
  /// [orderBy] - Field to order by (optional)
  /// [limit] - Maximum number of documents (optional)
  /// Returns stream of document snapshots
  static Stream<QuerySnapshot> streamDocuments({
    required String collection,
    String? orderBy,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Stream a single document (real-time updates)
  /// [collection] - Collection name
  /// [docId] - Document ID
  /// Returns stream of document snapshot
  static Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // ==================== FIRESTORE USER METHODS ====================

  /// Create user document in Firestore
  /// [userId] - User ID (from Firebase Auth)
  /// [userData] - User data to save
  /// Returns true on success, false on failure
  static Future<bool> createUserDocument({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Add timestamps
      final data = {
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(FirebaseConstants.userCollection).doc(userId).set(data);
      return true;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.createUserDocumentError,
      );
      return false;
    }
  }

  /// Get user document from Firestore
  /// [userId] - User ID
  /// Returns user data on success, null on failure
  static Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    return await getDocument(collection: FirebaseConstants.userCollection, docId: userId);
  }

  /// Get current user document from Firestore
  /// Returns user data on success, null on failure
  static Future<Map<String, dynamic>?> getCurrentUserDocument() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return await getUserDocument(userId);
  }

  /// Get current user as UserModel from Firestore
  /// Returns UserModel on success, null on failure
  static Future<UserModel?> getCurrentUserModel() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;

      final doc = await _firestore.collection(FirebaseConstants.userCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile using UserModel
  /// [userId] - User ID
  /// [userModel] - Updated UserModel
  /// Returns true on success, false on failure
  static Future<bool> updateUserProfile({
    required String userId,
    required UserModel userModel,
  }) async {
    try {
      final data = userModel.toJson();
      // Remove id from data as it's the document ID
      data.remove('id');

      // Ensure profileImage URL is always included in the update if it exists
      // This ensures the profile image URL is stored in the user document
      if (userModel.profileImage != null && userModel.profileImage!.isNotEmpty) {
        data['profileImage'] = userModel.profileImage;
      }

      data['updatedAt'] = FieldValue.serverTimestamp();

      // Update the user document in Firestore
      // The profileImage URL will be stored in the document with userId as documentId
      await _firestore.collection(FirebaseConstants.userCollection).doc(userId).update(data);
      return true;
    } on FirebaseException catch (e) {
      // Handle Firebase specific errors with dynamic messages
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.profileUpdateError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      // Handle other errors
      String errorMessage = AppString.profileUpdateError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  /// Update user document in Firestore
  /// [userId] - User ID
  /// [userData] - User data to update
  /// Returns true on success, false on failure
  static Future<bool> updateUserDocument({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final data = {
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(FirebaseConstants.userCollection).doc(userId).update(data);
      return true;
    } on FirebaseException catch (e) {
      // Handle Firebase specific errors with dynamic messages
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.profileUpdateError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      // Handle other errors
      String errorMessage = AppString.profileUpdateError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  /// Delete user document from Firestore
  /// [userId] - User ID
  /// Returns true on success, false on failure
  static Future<bool> deleteUserDocument(String userId) async {
    return await deleteDocument(collection: FirebaseConstants.userCollection, docId: userId);
  }

  // ==================== STORAGE METHODS ====================

  /// Upload file to Firebase Storage
  /// [file] - File to upload
  /// [path] - Storage path (e.g., 'profile_images/user123.jpg')
  /// Returns download URL on success, null on failure
  static Future<String?> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log("Upload image error  ::::::::::::::::::::::::::$e");
      AppSnackbar.error(
        message: AppString.uploadFileError,
      );
      return null;
    }
  }

  /// Delete file from Firebase Storage
  /// [path] - Storage path
  /// Returns true on success, false on failure
  static Future<bool> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      return true;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.deleteFileError,
      );
      return false;
    }
  }

  /// Get download URL for a file
  /// [path] - Storage path
  /// Returns download URL on success, null on failure
  static Future<String?> getDownloadUrl(String path) async {
    try {
      final url = await _storage.ref().child(path).getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Perform batch write operations
  /// [operations] - List of operations to perform
  /// Returns true on success, false on failure
  static Future<bool> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (var operation in operations) {
        switch (operation.type) {
          case BatchOperationType.create:
            batch.set(
              _firestore.collection(operation.collection).doc(operation.docId),
              operation.data!,
            );
            break;
          case BatchOperationType.update:
            batch.update(
              _firestore.collection(operation.collection).doc(operation.docId),
              operation.data!,
            );
            break;
          case BatchOperationType.delete:
            batch.delete(
              _firestore.collection(operation.collection).doc(operation.docId),
            );
            break;
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.batchOperationError,
      );
      return false;
    }
  }

  // ==================== CONTACT METHODS ====================

  /// Check if user exists by email
  /// [email] - Email to search for
  /// Returns UserExistsResult with userId if found
  static Future<UserExistsResult> checkUserExistsByEmail(String email) async {
    try {
      // Query Firestore for user with matching email
      final querySnapshot =
          await _firestore.collection(FirebaseConstants.userCollection).where('email', isEqualTo: email.toLowerCase()).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserExistsResult(exists: true, userId: querySnapshot.docs.first.id);
      }
      return UserExistsResult(exists: false, userId: null);
    } catch (e) {
      log("Check user exists error: $e");
      return UserExistsResult(exists: false, userId: null);
    }
  }

  /// Check if contact already exists
  /// [currentUserId] - Current user ID
  /// [contactUserId] - Contact user ID to check
  /// Returns true if contact exists, false otherwise
  static Future<bool> checkContactExists({
    required String currentUserId,
    required String contactUserId,
  }) async {
    try {
      final userDoc = await _firestore.collection(FirebaseConstants.userCollection).doc(currentUserId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        return false;
      }

      final contacts = userDoc.data()!['contacts'] as List<dynamic>?;
      if (contacts == null) {
        return false;
      }

      return contacts.contains(contactUserId);
    } catch (e) {
      log("Check contact exists error: $e");
      return false;
    }
  }

  /// Add contact to user's document
  /// [currentUserId] - Current user ID
  /// [contactUserId] - Contact user ID to add
  /// Returns true on success, false on failure
  static Future<bool> addContact({
    required String currentUserId,
    required String contactUserId,
  }) async {
    try {
      final userRef = _firestore.collection(FirebaseConstants.userCollection).doc(currentUserId);

      // Use FieldValue.arrayUnion to add contact if not already present
      await userRef.update({
        'contacts': FieldValue.arrayUnion([contactUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseException catch (e) {
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.contactAddError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      String errorMessage = AppString.contactAddError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  /// Get user contacts
  /// [userId] - User ID
  /// Returns list of contact user IDs
  static Future<List<String>> getUserContacts(String userId) async {
    try {
      final userDoc = await _firestore.collection(FirebaseConstants.userCollection).doc(userId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        return [];
      }

      final contacts = userDoc.data()!['contacts'] as List<dynamic>?;
      if (contacts == null) {
        return [];
      }

      return contacts.map((e) => e.toString()).toList();
    } catch (e) {
      log("Get user contacts error: $e");
      return [];
    }
  }

  /// Search users by prefix of email or name (case-insensitive for email)
  /// [query] - The search text; performs prefix search
  /// Returns up to [limit] users matching either email or name prefix
  static Future<List<UserModel>> searchUsersByQuery({
    required String query,
    int limit = 20,
  }) async {
    try {
      final q = query.trim();
      if (q.isEmpty) return [];

      final String qLower = q.toLowerCase();

      // Email prefix search
      final emailSnap = await _firestore
          .collection(FirebaseConstants.userCollection)
          .orderBy('email')
          .startAt([qLower])
          .endAt(['$qLower\uf8ff'])
          .limit(limit)
          .get();

      // Name prefix search (best-effort; case-sensitive depending on stored data)
      final nameSnap =
          await _firestore.collection(FirebaseConstants.userCollection).orderBy('name').startAt([q]).endAt(['$q\uf8ff']).limit(limit).get();

      final Map<String, UserModel> byId = {};

      for (final doc in emailSnap.docs) {
        if (doc.exists) {
          byId[doc.id] = UserModel.fromFirestore(doc.data(), doc.id);
        }
      }
      for (final doc in nameSnap.docs) {
        if (doc.exists) {
          byId[doc.id] = UserModel.fromFirestore(doc.data(), doc.id);
        }
      }

      return byId.values.toList();
    } catch (e) {
      log("Search users error: $e");
      return [];
    }
  }

  /// Get users by IDs
  /// [userIds] - List of user IDs
  /// Returns list of UserModel
  static Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) {
        return [];
      }

      // Firestore 'in' query limit is 10, so we need to batch if more than 10
      List<UserModel> users = [];

      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final querySnapshot = await _firestore.collection(FirebaseConstants.userCollection).where(FieldPath.documentId, whereIn: batch).get();

        for (var doc in querySnapshot.docs) {
          if (doc.exists) {
            final data = doc.data();
            try {
              users.add(UserModel.fromFirestore(data, doc.id));
            } catch (e) {
              log("Error parsing user ${doc.id}: $e");
            }
          }
        }
      }

      return users;
    } catch (e) {
      log("Get users by IDs error: $e");
      return [];
    }
  }

  // ==================== PRESENCE METHODS ====================

  /// Mark current user online with updated lastSeen
  static Future<void> setUserOnline() async {
    try {
      final uid = getCurrentUserId();
      if (uid == null) return;
      await _firestore.collection(FirebaseConstants.userCollection).doc(uid).update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ==================== CALL HISTORY METHODS ====================

  /// Record a one-to-one call for both users under user/{uid}/callHistory
  static Future<void> recordOneToOneCall({
    required String otherUserId,
    required bool isVideo,
    required bool missed,
    required DateTime startedAt,
    DateTime? endedAt,
    Duration? duration,
  }) async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId == null) return;

      final String type = isVideo ? 'video' : 'audio';
      final String callerDirection = missed ? 'missed' : 'out';
      final String calleeDirection = missed ? 'missed' : 'in';

      final Map<String, dynamic> base = {
        'type': type,
        'startedAt': Timestamp.fromDate(startedAt),
        if (endedAt != null) 'endedAt': Timestamp.fromDate(endedAt),
        if (duration != null) 'durationSec': duration.inSeconds,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // For current user
      await _firestore.collection(FirebaseConstants.userCollection).doc(currentUserId).collection('callHistory').add({
        ...base,
        'peerId': otherUserId,
        'direction': callerDirection,
      });

      // For other user
      await _firestore.collection(FirebaseConstants.userCollection).doc(otherUserId).collection('callHistory').add({
        ...base,
        'peerId': currentUserId,
        'direction': calleeDirection,
      });
    } catch (_) {}
  }

  /// Record a group call under group/{groupId}/callHistory
  static Future<void> recordGroupCall({
    required String groupId,
    required bool isVideo,
    required DateTime startedAt,
    DateTime? endedAt,
    Duration? duration,
    bool missed = false,
  }) async {
    try {
      await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).collection('callHistory').add({
        'type': isVideo ? 'video' : 'audio',
        'startedAt': Timestamp.fromDate(startedAt),
        if (endedAt != null) 'endedAt': Timestamp.fromDate(endedAt),
        if (duration != null) 'durationSec': duration.inSeconds,
        'missed': missed,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Stream call history for a user, optionally filtered by peerId
  static Stream<QuerySnapshot> streamUserCallHistory({
    required String userId,
    String? peerId,
    int limit = 20,
  }) {
    Query q = _firestore
        .collection(FirebaseConstants.userCollection)
        .doc(userId)
        .collection('callHistory')
        .orderBy('startedAt', descending: true)
        .limit(limit);
    if (peerId != null) {
      q = q.where('peerId', isEqualTo: peerId);
    }
    return q.snapshots();
  }

  /// Stream call history for a group
  static Stream<QuerySnapshot> streamGroupCallHistory({
    required String groupId,
    int limit = 20,
  }) {
    return _firestore
        .collection(FirebaseConstants.groupCollection)
        .doc(groupId)
        .collection('callHistory')
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Delete a single group call history entry
  static Future<bool> deleteGroupCallHistoryEntry({
    required String groupId,
    required String entryId,
  }) async {
    try {
      await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).collection('callHistory').doc(entryId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all call history for a group
  static Future<bool> clearGroupCallHistory({
    required String groupId,
  }) async {
    try {
      final snap = await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).collection('callHistory').get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark current user offline and update lastSeen
  static Future<void> setUserOffline() async {
    try {
      final uid = getCurrentUserId();
      if (uid == null) return;
      await _firestore.collection(FirebaseConstants.userCollection).doc(uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ==================== GROUP METHODS ====================

  /// Create a new group
  /// [name] - Group name
  /// [createdBy] - User ID of the creator (admin)
  /// [members] - List of member user IDs (includes creator)
  /// Returns group ID on success, null on failure
  static Future<String?> createGroup({
    required String name,
    required String createdBy,
    required List<String> members,
    String? description,
    String? groupImage,
  }) async {
    try {
      // Generate unique group ID
      final groupRef = _firestore.collection(FirebaseConstants.groupCollection).doc();
      final groupId = groupRef.id;

      final groupData = {
        'id': groupId,
        'name': name.trim(),
        'description': description,
        'groupImage': groupImage,
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
        'members': members,
        'memberCount': members.length,
        'admins': [createdBy], // Creator is admin
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await groupRef.set(groupData);
      return groupId;
    } on FirebaseException catch (e) {
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.groupCreateError,
      );
      AppSnackbar.error(message: errorMessage);
      return null;
    } catch (e) {
      String errorMessage = AppString.groupCreateError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return null;
    }
  }

  /// Get groups created by user
  /// [userId] - User ID
  /// Returns list of GroupChatModel
  static Future<List<GroupChatModel>> getUserGroups(String userId) async {
    try {
      final querySnapshot = await _firestore.collection(FirebaseConstants.groupCollection).where('members', arrayContains: userId).get();

      // Sort by createdAt descending manually since we can't use orderBy with arrayContains
      final sortedDocs = querySnapshot.docs.toList()
        ..sort((a, b) {
          final aTime = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          final bTime = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
          return bTime.compareTo(aTime);
        });

      return sortedDocs.map((doc) {
        final data = doc.data();
        return GroupChatModel(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          description: data['description'],
          groupImage: data['groupImage'],
          createdBy: data['createdBy'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          members: List<String>.from(data['members'] ?? []),
          memberCount: data['memberCount'] ?? 0,
          lastMessage: data['lastMessage'],
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
        );
      }).toList();
    } catch (e) {
      log("Get user groups error: $e");
      return [];
    }
  }

  /// Update group name
  /// [groupId] - Group ID
  /// [newName] - New group name
  /// Returns true on success, false on failure
  static Future<bool> updateGroupName({
    required String groupId,
    required String newName,
  }) async {
    try {
      await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).update({
        'name': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseException catch (e) {
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.groupUpdateError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      String errorMessage = AppString.groupUpdateError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  /// Add members to group
  /// [groupId] - Group ID
  /// [memberIds] - List of member user IDs to add
  /// [adminId] - User ID of the admin performing the action
  /// Returns true on success, false on failure
  static Future<bool> addGroupMembers({
    required String groupId,
    required List<String> memberIds,
    required String adminId,
  }) async {
    try {
      // Check if user is admin
      final groupDoc = await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).get();

      if (!groupDoc.exists || groupDoc.data() == null) {
        AppSnackbar.error(message: AppString.groupNotFound);
        return false;
      }

      final admins = List<String>.from(groupDoc.data()!['admins'] ?? []);
      if (!admins.contains(adminId)) {
        AppSnackbar.error(message: AppString.onlyAdminCanAddMembers);
        return false;
      }

      final currentMembers = List<String>.from(groupDoc.data()!['members'] ?? []);
      final newMembers = memberIds.where((id) => !currentMembers.contains(id)).toList();

      if (newMembers.isEmpty) {
        AppSnackbar.info(message: AppString.allMembersAlreadyAdded);
        return true;
      }

      final updatedMembers = [...currentMembers, ...newMembers];

      await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).update({
        'members': updatedMembers,
        'memberCount': updatedMembers.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseException catch (e) {
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.groupUpdateError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      String errorMessage = AppString.groupUpdateError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  /// Exit from group (remove user from group members)
  /// [groupId] - Group ID
  /// [userId] - User ID to remove
  /// Returns true on success, false on failure
  static Future<bool> exitFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final groupDoc = await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).get();

      if (!groupDoc.exists || groupDoc.data() == null) {
        AppSnackbar.error(message: AppString.groupNotFound);
        return false;
      }

      final data = groupDoc.data()!;
      final currentMembers = List<String>.from(data['members'] ?? []);

      if (!currentMembers.contains(userId)) {
        AppSnackbar.info(message: AppString.userNotInGroup);
        return true; // Already not in group
      }

      // Remove user from members
      currentMembers.remove(userId);

      // Also remove from admins if they are admin
      final admins = List<String>.from(data['admins'] ?? []);
      admins.remove(userId);

      await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).update({
        'members': currentMembers,
        'memberCount': currentMembers.length,
        'admins': admins,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseException catch (e) {
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.exitGroupError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      String errorMessage = AppString.exitGroupError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  /// Get group members with user details
  /// [groupId] - Group ID
  /// Returns list of maps with user info and admin status
  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final groupDoc = await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).get();

      if (!groupDoc.exists || groupDoc.data() == null) {
        return [];
      }

      final data = groupDoc.data()!;
      final memberIds = List<String>.from(data['members'] ?? []);
      final admins = List<String>.from(data['admins'] ?? []);

      if (memberIds.isEmpty) {
        return [];
      }

      // Get user details for all members
      final members = <Map<String, dynamic>>[];

      for (int i = 0; i < memberIds.length; i += 10) {
        final batch = memberIds.skip(i).take(10).toList();
        final querySnapshot = await _firestore.collection(FirebaseConstants.userCollection).where(FieldPath.documentId, whereIn: batch).get();

        for (var doc in querySnapshot.docs) {
          if (doc.exists) {
            final userData = doc.data();
            final userId = doc.id;
            final isAdmin = admins.contains(userId);

            try {
              final user = UserModel.fromFirestore(userData, userId);
              members.add({
                'user': user,
                'isAdmin': isAdmin,
              });
            } catch (e) {
              log("Error parsing user $userId: $e");
            }
          }
        }
      }

      // Sort: admins first, then by name
      members.sort((a, b) {
        final aIsAdmin = a['isAdmin'] as bool;
        final bIsAdmin = b['isAdmin'] as bool;
        if (aIsAdmin != bIsAdmin) {
          return bIsAdmin ? 1 : -1;
        }
        final aName = (a['user'] as UserModel).name;
        final bName = (b['user'] as UserModel).name;
        return aName.compareTo(bName);
      });

      return members;
    } catch (e) {
      log("Get group members error: $e");
      return [];
    }
  }

  /// Remove member from group (admin only)
  /// [groupId] - Group ID
  /// [memberId] - Member user ID to remove
  /// [adminId] - User ID of the admin performing the action
  /// Returns true on success, false on failure
  static Future<bool> removeGroupMember({
    required String groupId,
    required String memberId,
    required String adminId,
  }) async {
    try {
      // Check if user is admin
      final groupDoc = await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).get();

      if (!groupDoc.exists || groupDoc.data() == null) {
        AppSnackbar.error(message: AppString.groupNotFound);
        return false;
      }

      final data = groupDoc.data()!;
      final admins = List<String>.from(data['admins'] ?? []);
      if (!admins.contains(adminId)) {
        AppSnackbar.error(message: AppString.onlyAdminCanRemoveMembers);
        return false;
      }

      // Check if trying to remove admin
      if (admins.contains(memberId)) {
        AppSnackbar.error(message: AppString.cannotRemoveAdmin);
        return false;
      }

      final currentMembers = List<String>.from(data['members'] ?? []);
      if (!currentMembers.contains(memberId)) {
        AppSnackbar.info(message: AppString.userNotInGroup);
        return true; // Already not in group
      }

      // Remove member
      currentMembers.remove(memberId);

      await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).update({
        'members': currentMembers,
        'memberCount': currentMembers.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseException catch (e) {
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.removeMemberError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      String errorMessage = AppString.removeMemberError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  /// Delete group (admin only)
  /// [groupId] - Group ID
  /// [adminId] - User ID of the admin performing the action
  /// Returns true on success, false on failure
  static Future<bool> deleteGroup({
    required String groupId,
    required String adminId,
  }) async {
    try {
      // Check if user is admin
      final groupDoc = await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).get();

      if (!groupDoc.exists || groupDoc.data() == null) {
        AppSnackbar.error(message: AppString.groupNotFound);
        return false;
      }

      final data = groupDoc.data()!;
      final admins = List<String>.from(data['admins'] ?? []);
      if (!admins.contains(adminId)) {
        AppSnackbar.error(message: AppString.onlyAdminCanDeleteGroup);
        return false;
      }

      // Delete the group
      await _firestore.collection(FirebaseConstants.groupCollection).doc(groupId).delete();

      return true;
    } on FirebaseException catch (e) {
      final errorMessage = FirebaseConstants.getFirestoreErrorMessage(
        e.code,
        defaultMessage: e.message ?? AppString.deleteGroupError,
      );
      AppSnackbar.error(message: errorMessage);
      return false;
    } catch (e) {
      String errorMessage = AppString.deleteGroupError;
      if (e.toString().contains('network') || e.toString().contains('Network')) {
        errorMessage = AppString.networkError;
      } else if (e.toString().contains('permission')) {
        errorMessage = AppString.permissionDenied;
      }
      AppSnackbar.error(message: errorMessage);
      return false;
    }
  }

  // ==================== MESSAGE METHODS ====================

  /// Send a message (one-to-one or group)
  /// [chatId] - Chat ID (for one-to-one: sorted user IDs, for group: group ID)
  /// [senderId] - Sender user ID
  /// [senderName] - Sender name
  /// [senderImage] - Sender profile image URL (optional)
  /// [message] - Message text
  /// [type] - Message type (text, image, file)
  /// [chatType] - Chat type (oneToOne, group)
  /// [imageUrl] - Image URL if type is image (optional)
  /// [fileUrl] - File URL if type is file (optional)
  /// [fileName] - File name if type is file (optional)
  /// [fileSize] - File size if type is file (optional)
  /// [fileExtension] - File extension if type is file (optional)
  /// [replyToMessageId] - ID of message being replied to (optional)
  /// [replyToMessage] - Text of message being replied to (optional)
  /// [replyToSenderName] - Name of sender of message being replied to (optional)
  /// Returns message ID on success, null on failure
  static Future<String?> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderImage,
    required String message,
    required String type,
    required String chatType,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    String? fileExtension,
    String? replyToMessageId,
    String? replyToMessage,
    String? replyToSenderName,
  }) async {
    try {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final messageData = {
        'id': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'senderImage': senderImage,
        'message': message,
        'type': type,
        'imageUrl': imageUrl,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'fileExtension': fileExtension,
        'replyToMessageId': replyToMessageId,
        'replyToMessage': replyToMessage,
        'replyToSenderName': replyToSenderName,
        // Use server-side time to avoid device clock skew
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'readBy': [],
      };

      // Get chat document reference
      final chatDocRef = _firestore.collection(FirebaseConstants.chatCollection).doc(chatId);

      // Get current chat document
      final chatDoc = await chatDocRef.get();

      List<Map<String, dynamic>> messages = [];
      if (chatDoc.exists && chatDoc.data() != null) {
        final data = chatDoc.data()!;
        messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);

        // Remove messages older than 7 days
        messages = messages.where((msg) {
          final msgTimestamp = msg['timestamp'] is Timestamp ? (msg['timestamp'] as Timestamp).toDate() : DateTime.parse(msg['timestamp']);
          return msgTimestamp.isAfter(sevenDaysAgo);
        }).toList();
      }

      // Add new message
      messages.add(messageData);

      // Update or create chat document
      await chatDocRef.set({
        'chatId': chatId,
        'chatType': chatType,
        'messages': messages,
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update group last message if it's a group chat
      if (chatType == 'group') {
        await _firestore.collection(FirebaseConstants.groupCollection).doc(chatId).update({
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }

      return messageId;
    } catch (e) {
      AppSnackbar.error(message: AppString.sendMessageError);
      return null;
    }
  }

  /// Stream messages for a chat (real-time)
  /// [chatId] - Chat ID
  /// Returns stream of chat document with messages array
  static Stream<DocumentSnapshot> streamMessages(String chatId) {
    return _firestore.collection(FirebaseConstants.chatCollection).doc(chatId).snapshots();
  }

  /// Upload image for chat
  /// [file] - Image file
  /// [chatId] - Chat ID
  /// Returns download URL on success, null on failure
  static Future<String?> uploadChatImage({
    required File file,
    required String chatId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(FirebaseConstants.chatImagesPath).child(chatId).child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      AppSnackbar.error(message: AppString.uploadFileError);
      return null;
    }
  }

  /// Upload file for chat (PDF, ZIP, etc.)
  /// [file] - File to upload
  /// [chatId] - Chat ID
  /// Returns download URL on success, null on failure
  static Future<String?> uploadChatFile({
    required File file,
    required String chatId,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(FirebaseConstants.chatFilesPath).child(chatId).child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      AppSnackbar.error(message: AppString.uploadFileError);
      return null;
    }
  }

  /// Mark message as read
  /// [chatId] - Chat ID
  /// [messageId] - Message ID
  /// [userId] - User ID who read the message
  /// Returns true on success, false on failure
  static Future<bool> markMessageAsRead({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final chatDocRef = _firestore.collection(FirebaseConstants.chatCollection).doc(chatId);

      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists || chatDoc.data() == null) {
        return false;
      }

      final data = chatDoc.data()!;
      final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);

      // Find and update the message
      for (int i = 0; i < messages.length; i++) {
        if (messages[i]['id'] == messageId) {
          final readBy = List<String>.from(messages[i]['readBy'] ?? []);
          if (!readBy.contains(userId)) {
            readBy.add(userId);
            messages[i]['readBy'] = readBy;
            messages[i]['isRead'] = readBy.isNotEmpty;
          }
          break;
        }
      }

      await chatDocRef.update({'messages': messages});

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark multiple messages as read in a single write
  /// Updates 'readBy' and 'isRead' for provided message IDs (or all unread if messageIds is null)
  static Future<bool> markMessagesAsReadBatch({
    required String chatId,
    required String userId,
    List<String>? messageIds,
  }) async {
    try {
      final chatDocRef = _firestore.collection(FirebaseConstants.chatCollection).doc(chatId);

      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists || chatDoc.data() == null) {
        return false;
      }

      final data = chatDoc.data()!;
      final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);

      final Set<String>? ids = messageIds != null ? messageIds.toSet() : null;

      bool changed = false;
      for (int i = 0; i < messages.length; i++) {
        final msg = messages[i];
        final id = msg['id'] as String?;
        final senderId = msg['senderId'] as String?;
        if (id == null) continue;
        if (senderId == userId) continue; // don't mark own messages
        if (ids != null && !ids.contains(id)) continue;
        final readBy = List<String>.from(msg['readBy'] ?? []);
        if (!readBy.contains(userId)) {
          readBy.add(userId);
          msg['readBy'] = readBy;
          msg['isRead'] = readBy.isNotEmpty;
          messages[i] = msg;
          changed = true;
        }
      }

      if (changed) {
        await chatDocRef.update({'messages': messages});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a message from chat
  /// [chatId] - Chat ID
  /// [messageId] - Message ID to delete
  /// [userId] - User ID who is deleting (must be the sender)
  /// Returns true on success, false on failure
  static Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final chatDocRef = _firestore.collection(FirebaseConstants.chatCollection).doc(chatId);

      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists || chatDoc.data() == null) {
        AppSnackbar.error(message: AppString.chatNotFound);
        return false;
      }

      final data = chatDoc.data()!;
      final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);

      // Find the message
      final messageIndex = messages.indexWhere((msg) => msg['id'] == messageId);
      if (messageIndex == -1) {
        AppSnackbar.error(message: AppString.messageNotFound);
        return false;
      }

      // Check if user is the sender
      if (messages[messageIndex]['senderId'] != userId) {
        AppSnackbar.error(message: AppString.onlySenderCanDeleteMessage);
        return false;
      }

      // Remove the message
      messages.removeAt(messageIndex);

      // Update chat document
      await chatDocRef.update({
        'messages': messages,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update last message if needed
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        await chatDocRef.update({
          'lastMessage': lastMessage['message'] ?? '',
          'lastMessageTime': lastMessage['timestamp'],
        });
      } else {
        await chatDocRef.update({
          'lastMessage': '',
          'lastMessageTime': null,
        });
      }

      // Update group last message if it's a group chat
      final chatType = data['chatType'] as String?;
      if (chatType == 'group') {
        if (messages.isNotEmpty) {
          final lastMessage = messages.last;
          await _firestore.collection(FirebaseConstants.groupCollection).doc(chatId).update({
            'lastMessage': lastMessage['message'] ?? '',
            'lastMessageTime': lastMessage['timestamp'],
          });
        } else {
          await _firestore.collection(FirebaseConstants.groupCollection).doc(chatId).update({
            'lastMessage': '',
            'lastMessageTime': null,
          });
        }
      }

      return true;
    } catch (e) {
      AppSnackbar.error(message: AppString.deleteMessageError);
      return false;
    }
  }

  /// Get chat ID for one-to-one chat
  /// [userId1] - First user ID
  /// [userId2] - Second user ID
  /// Returns sorted chat ID
  static String getOneToOneChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Get last message for a one-to-one chat
  /// [currentUserId] - Current user ID
  /// [otherUserId] - Other user ID
  /// Returns last message text or null if no messages
  static Future<String?> getLastMessageForUser({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      final chatId = getOneToOneChatId(currentUserId, otherUserId);
      final chatDoc = await _firestore.collection(FirebaseConstants.chatCollection).doc(chatId).get();

      if (chatDoc.exists && chatDoc.data() != null) {
        final data = chatDoc.data()!;
        final lastMessage = data['lastMessage'] as String?;
        return lastMessage?.isNotEmpty == true ? lastMessage : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get last messages for multiple users
  /// [currentUserId] - Current user ID
  /// [userIds] - List of other user IDs
  /// Returns map of userId -> lastMessage
  static Future<Map<String, String?>> getLastMessagesForUsers({
    required String currentUserId,
    required List<String> userIds,
  }) async {
    final Map<String, String?> lastMessages = {};

    try {
      // Get all chat IDs
      final chatIds = userIds.map((userId) => getOneToOneChatId(currentUserId, userId)).toList();

      // Batch fetch chat documents
      for (int i = 0; i < chatIds.length; i += 10) {
        final batch = chatIds.skip(i).take(10).toList();
        final futures = batch.map((chatId) async {
          try {
            final chatDoc = await _firestore.collection(FirebaseConstants.chatCollection).doc(chatId).get();

            if (chatDoc.exists && chatDoc.data() != null) {
              final data = chatDoc.data()!;
              final lastMessage = data['lastMessage'] as String?;
              return lastMessage?.isNotEmpty == true ? lastMessage : null;
            }
            return null;
          } catch (e) {
            return null;
          }
        }).toList();

        final results = await Future.wait(futures);
        for (int j = 0; j < batch.length && j < results.length; j++) {
          final chatId = batch[j];
          // Extract userId from chatId (chatId format: userId1_userId2)
          final parts = chatId.split('_');
          if (parts.length == 2) {
            final userId = parts[0] == currentUserId ? parts[1] : parts[0];
            lastMessages[userId] = results[j];
          }
        }
      }
    } catch (e) {
      // Return empty map on error
    }

    return lastMessages;
  }

  /// Stream chat info for real-time updates (last message, unread count)
  /// [chatId] - Chat ID
  /// [currentUserId] - Current user ID
  /// Returns stream of ChatInfoModel
  static Stream<ChatInfoModel?> streamChatInfo({
    required String chatId,
    required String currentUserId,
  }) {
    return _firestore.collection(FirebaseConstants.chatCollection).doc(chatId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      final data = snapshot.data()!;
      return ChatInfoModel.fromFirestore(data, chatId, currentUserId);
    });
  }

  /// Get unread message count for a chat
  /// [chatId] - Chat ID
  /// [currentUserId] - Current user ID
  /// Returns unread message count
  static Future<int> getUnreadMessageCount({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      final chatDoc = await _firestore.collection(FirebaseConstants.chatCollection).doc(chatId).get();

      if (!chatDoc.exists || chatDoc.data() == null) {
        return 0;
      }

      final data = chatDoc.data()!;
      final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);

      int unreadCount = 0;
      for (var message in messages) {
        final readBy = List<String>.from(message['readBy'] ?? []);
        final senderId = message['senderId'] as String?;

        // Count as unread if current user didn't send it and hasn't read it
        if (senderId != currentUserId && !readBy.contains(currentUserId)) {
          unreadCount++;
        }
      }

      return unreadCount;
    } catch (e) {
      return 0;
    }
  }
}

/// User exists result model
class UserExistsResult {
  final bool exists;
  final String? userId;

  UserExistsResult({
    required this.exists,
    required this.userId,
  });
}

/// Batch operation model
class BatchOperation {
  final BatchOperationType type;
  final String collection;
  final String docId;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.collection,
    required this.docId,
    this.data,
  });
}

/// Batch operation types
enum BatchOperationType {
  create,
  update,
  delete,
}
