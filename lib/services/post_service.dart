import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';
import '../models/reaction_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new post
  Future<PostModel> createPost({
    required String adminId,
    required String adminName,
    required String contentType,
    required String content,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
  }) async {
    try {
      final postDoc = await _firestore.collection('posts').add({
        'adminId': adminId,
        'adminName': adminName,
        'contentType': contentType,
        'content': content,
        'mediaUrl': mediaUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'createdAt': DateTime.now().toIso8601String(),
        'reactions': {},
        'viewCount': 0,
      });

      return PostModel.fromMap({
        'adminId': adminId,
        'adminName': adminName,
        'contentType': contentType,
        'content': content,
        'mediaUrl': mediaUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'createdAt': DateTime.now().toIso8601String(),
        'reactions': {},
        'viewCount': 0,
      }, postDoc.id);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Get all posts stream
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data()!, doc.id))
            .toList());
  }

  // Get single post
  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      return PostModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  // Upload media to Firebase Storage
  Future<String> uploadMedia({
    required String filePath,
    required String fileName,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref().child('posts/$contentType/$fileName');
      final uploadTask = await ref.putFile(
        // This would require the actual file, to be implemented with file_picker
        // For now, this is a placeholder
        throw UnimplementedError('File upload needs file picker integration'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  // Add reaction to post
  Future<void> addReaction({
    required String postId,
    required String userId,
    required String emoji,
  }) async {
    try {
      // Add reaction to reactions subcollection
      await _firestore.collection('posts').doc(postId).collection('reactions').add({
        'userId': userId,
        'emoji': emoji,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update post reactions count
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        final reactions = Map<String, int>.from(postDoc.data()!['reactions'] ?? {});
        reactions[emoji] = (reactions[emoji] ?? 0) + 1;
        await _firestore.collection('posts').doc(postId).update({
          'reactions': reactions,
        });
      }
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  // Remove reaction from post
  Future<void> removeReaction({
    required String postId,
    required String userId,
    required String emoji,
  }) async {
    try {
      // Find and remove the reaction
      final reactionsQuery = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('reactions')
          .where('userId', isEqualTo: userId)
          .where('emoji', isEqualTo: emoji)
          .get();

      for (var doc in reactionsQuery.docs) {
        await doc.reference.delete();
      }

      // Update post reactions count
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        final reactions = Map<String, int>.from(postDoc.data()!['reactions'] ?? {});
        if (reactions.containsKey(emoji) && reactions[emoji]! > 0) {
          reactions[emoji] = reactions[emoji]! - 1;
          if (reactions[emoji] == 0) {
            reactions.remove(emoji);
          }
        }
        await _firestore.collection('posts').doc(postId).update({
          'reactions': reactions,
        });
      }
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  // Delete post (admin only)
  Future<void> deletePost(String postId) async {
    try {
      // Delete post document
      await _firestore.collection('posts').doc(postId).delete();
      
      // Delete all reactions
      final reactions = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('reactions')
          .get();
      
      for (var doc in reactions.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}