class AppConstants {
  // App Information
  static const String appName = 'Church Community';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String reactionsCollection = 'reactions';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';
  
  // Content Types
  static const String contentTypeText = 'text';
  static const String contentTypeImage = 'image';
  static const String contentTypeVideo = 'video';
  static const String contentTypeAudio = 'audio';
  static const String contentTypeFile = 'file';
  
  // Storage Paths
  static const String storagePostsPath = 'posts';
  
  // Notification Topics
  static const String topicAllUsers = 'all_users';
  static const String topicAdmins = 'admins';
  
  // Validation
  static const int minAge = 13;
  static const int maxAge = 120;
  static const int minPhoneLength = 10;
  
  // Reaction Emojis
  static const List<String> defaultReactions = [
    '❤️', '👍', '🙏', '🎉', '😊', '🔥', '💯', '👏'
  ];
}