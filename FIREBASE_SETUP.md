# Firebase Setup Guide for Church Community App

This guide will help you set up Firebase for the Church Community Flutter application.

## Prerequisites
- Firebase account (free tier is sufficient)
- Flutter project with Firebase dependencies installed
- Android Studio / Xcode for platform-specific configuration

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or create a new project
3. Enter project name (e.g., "church-community-app")
4. Follow the setup wizard (you can disable Google Analytics for now)
5. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click the Android icon to add an Android app
2. Enter your Android package name:
   - Find this in `android/app/build.gradle` under `applicationId`
   - Default: `com.example.telegram_clone`
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Follow the remaining setup steps in Firebase Console

## Step 3: Add iOS App

1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter your iOS bundle ID:
   - Find this in `ios/Runner.xcodeproj/project.pbxproj` under `PRODUCT_BUNDLE_IDENTIFIER`
   - Default: `com.example.telegramClone`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory
5. Follow the remaining setup steps in Firebase Console

## Step 4: Enable Required Firebase Services

### Authentication
1. Go to Authentication → Sign-in method
2. Enable "Phone" authentication
3. For testing, you can also enable "Email/Password"

### Cloud Firestore
1. Go to Firestore Database → Create Database
2. Choose production mode or test mode (test mode for development)
3. Select a location (choose closest to your users)

### Firebase Storage
1. Go to Storage → Get Started
2. Choose rules for development (allow read/write for testing)
3. Select a location (same as Firestore)

### Cloud Messaging (FCM)
1. Go to Project Settings → Cloud Messaging
2. FCM is automatically enabled
3. Note your Server Key and Sender ID for backend integration

## Step 5: Configure Firebase Security Rules

### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      allow update, delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      
      // Reactions subcollection
      match /reactions/{reactionId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null && request.auth.uid == resource.data.userId;
        allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
      }
    }
  }
}
```

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Step 6: Update Firebase Configuration

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase for your project:
```bash
flutterfire configure
```

3. This will automatically update `lib/firebase_options.dart` with your project credentials

## Step 7: Platform-Specific Configuration

### Android Configuration

Add to `android/build.gradle` (project level):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Add to `android/app/build.gradle` (app level):
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos for posts</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images for posts</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio for posts</string>
```

## Step 8: Create First Admin User

After setting up Firebase, you'll need to create the first admin user manually:

1. Register a user through the app
2. Go to Firebase Console → Firestore Database
3. Navigate to the `users` collection
4. Find your user document
5. Change the `role` field from "member" to "admin"

## Step 9: Test Your Setup

Run the app:
```bash
flutter run
```

Test the following:
- User registration
- Session persistence after app restart
- Admin posting
- Member viewing posts
- Reactions
- Admin panel

## Troubleshooting

### Common Issues

1. **"Firebase has not been initialized"**
   - Make sure `firebase_options.dart` is properly configured
   - Check that `google-services.json` or `GoogleService-Info.plist` is in the correct location

2. **"Permission denied" errors**
   - Check Firestore and Storage security rules
   - Ensure user is authenticated
   - Verify user has correct role

3. **FCM not working**
   - Ensure FCM is enabled in Firebase Console
   - Check that notification permissions are granted
   - Verify FCM token is properly set in user document

## Production Checklist

Before deploying to production:

1. **Security Rules**: Update rules to be more restrictive
2. **Indexes**: Create Firestore indexes for complex queries
3. **Analytics**: Enable Firebase Analytics
4. **Crashlytics**: Enable Firebase Crashlytics
5. **Performance**: Enable Firebase Performance Monitoring
6. **Testing**: Test all features thoroughly
7. **Backup**: Set up database backups
8. **Monitoring**: Set up alerts for critical issues

## Additional Resources

- [Flutter Firebase Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://github.com/firebase/flutterfire_cli)