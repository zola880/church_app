import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register user with phone number
  Future<UserModel?> registerUser({
    required String name,
    required int age,
    required String phoneNumber,
  }) async {
    try {
      // Check if phone number already exists
      final phoneQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        throw Exception('Phone number already registered');
      }

      // Create auth user with phone (will need phone verification)
      // For now, we'll create a simple email-based auth or use phone auth
      // This is a simplified version - in production you'd use phone auth
      
      // Create user document
      final userDoc = await _firestore.collection('users').add({
        'name': name,
        'age': age,
        'phoneNumber': phoneNumber,
        'role': 'member', // Default role
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });

      return UserModel.fromMap({
        'name': name,
        'age': age,
        'phoneNumber': phoneNumber,
        'role': 'member',
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      }, userDoc.id);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user FCM token
  Future<void> updateFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?.role == 'admin';
    } catch (e) {
      return false;
    }
  }
}