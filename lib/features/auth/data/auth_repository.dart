import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/models/app_user.dart';

class AuthRepository {
  const AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser?> getCurrentAppUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(firebaseUser.uid)
        .get();
    return snapshot.exists && snapshot.data() != null
        ? AppUser.fromMap(snapshot.id, snapshot.data()!)
        : null;
  }

  Stream<AppUser?> watchCurrentAppUser() {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream<AppUser?>.value(null);
      return _firestore
          .collection(FirestorePaths.users)
          .doc(firebaseUser.uid)
          .snapshots()
          .map((snapshot) {
            final data = snapshot.data();
            return snapshot.exists && data != null
                ? AppUser.fromMap(snapshot.id, data)
                : null;
          });
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final now = Timestamp.now();
      await _firestore
          .collection(FirestorePaths.users)
          .doc(credential.user!.uid)
          .set({
            'displayName': name.trim(),
            'email': email.trim(),
            'role': UserRole.user.value,
            'createdAt': now,
            'updatedAt': now,
          });
    } catch (error) {
      await _auth.signOut();
      if (error is FirebaseAuthException) throw _mapAuthError(error);
      throw AppException.unknown(error);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    }
  }

  Future<void> updateProfile({required String displayName}) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw const AppException(
        code: 'not_authenticated',
        message: 'Bạn chưa đăng nhập.',
      );
    }
    final name = displayName.trim();
    if (name.isEmpty) {
      throw const AppException(
        code: 'invalid_display_name',
        message: 'Tên hiển thị không được để trống.',
      );
    }
    await firebaseUser.updateDisplayName(name);
    await _firestore.collection(FirestorePaths.users).doc(firebaseUser.uid).set(
      {'displayName': name, 'updatedAt': Timestamp.now()},
      SetOptions(merge: true),
    );
  }

  Future<void> signOut() => _auth.signOut();

  AppException _mapAuthError(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-email' => 'Email không hợp lệ.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email hoặc mật khẩu không đúng.',
      'email-already-in-use' => 'Email đã được sử dụng.',
      'weak-password' => 'Mật khẩu quá yếu.',
      'network-request-failed' => 'Không thể kết nối mạng.',
      _ => 'Không thể hoàn tất thao tác xác thực. Vui lòng thử lại.',
    };
    return AppException(code: error.code, message: message, cause: error);
  }
}
