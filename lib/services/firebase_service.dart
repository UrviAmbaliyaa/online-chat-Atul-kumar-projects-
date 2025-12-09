import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';

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
        message: 'Failed to sign out. Please try again.',
      );
      return false;
    }
  }

  /// Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppSnackbar.success(
        message: 'Password reset email sent. Please check your inbox.',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      AppSnackbar.error(
        message: 'Failed to send password reset email. Please try again.',
      );
      return false;
    }
  }

  /// Handle Firebase Auth exceptions
  static void _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'invalid-email':
        message = 'The email address is invalid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed.';
        break;
      default:
        message = e.message ?? 'An error occurred. Please try again.';
    }
    AppSnackbar.error(message: message);
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
        message: 'Failed to create document. Please try again.',
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
        message: 'Failed to get document. Please try again.',
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
        message: 'Failed to update document. Please try again.',
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
        message: 'Failed to delete document. Please try again.',
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
        message: 'Failed to get documents. Please try again.',
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
        message: 'Failed to get documents. Please try again.',
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
      
      await _firestore.collection('user').doc(userId).set(data);
      return true;
    } catch (e) {
      AppSnackbar.error(
        message: 'Failed to create user profile. Please try again.',
      );
      return false;
    }
  }

  /// Get user document from Firestore
  /// [userId] - User ID
  /// Returns user data on success, null on failure
  static Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    return await getDocument(collection: 'user', docId: userId);
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
      return await updateDocument(
        collection: 'user',
        docId: userId,
        data: data,
      );
    } catch (e) {
      return false;
    }
  }

  /// Delete user document from Firestore
  /// [userId] - User ID
  /// Returns true on success, false on failure
  static Future<bool> deleteUserDocument(String userId) async {
    return await deleteDocument(collection: 'user', docId: userId);
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
      AppSnackbar.error(
        message: 'Failed to upload file. Please try again.',
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
        message: 'Failed to delete file. Please try again.',
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
        message: 'Failed to perform batch operation. Please try again.',
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

