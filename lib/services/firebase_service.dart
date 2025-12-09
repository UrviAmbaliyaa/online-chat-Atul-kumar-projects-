import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      Query query =
          _firestore.collection(collection).where(field, isEqualTo: value);

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

      await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .set(data);
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
    return await getDocument(
        collection: FirebaseConstants.userCollection, docId: userId);
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

      final doc = await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .get();
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
      if (userModel.profileImage != null &&
          userModel.profileImage!.isNotEmpty) {
        data['profileImage'] = userModel.profileImage;
      }

      data['updatedAt'] = FieldValue.serverTimestamp();

      // Update the user document in Firestore
      // The profileImage URL will be stored in the document with userId as documentId
      await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .update(data);
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
      if (e.toString().contains('network') ||
          e.toString().contains('Network')) {
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

      await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .update(data);
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
      if (e.toString().contains('network') ||
          e.toString().contains('Network')) {
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
    return await deleteDocument(
        collection: FirebaseConstants.userCollection, docId: userId);
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
