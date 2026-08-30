# Church Community App

A production-ready Flutter application for church communities that allows admins to share various types of content (text, images, videos, audio, files) with members who can view and react to posts.

## Features

### For Admins
- **Post Creation**: Create posts with text, images, videos, audio, or files
- **Member Management**: View all registered members, their details
- **User Control**: Change user roles (admin/member), deactivate/reactivate users
- **Post Management**: Delete any post from the community
- **Analytics**: View user statistics (total, active, admins)

### For Members
- **Simple Registration**: Register with name, age, and phone number
- **Content Viewing**: View all posts shared by admins
- **Reactions**: React to posts with emojis
- **Notifications**: Receive push notifications for new posts
- **Read-Only Access**: Members can only view and react, not modify content

## Tech Stack

- **Frontend**: Flutter 3.11+
- **Backend**: Firebase (Authentication, Firestore, Storage, Messaging)
- **State Management**: Provider
- **Architecture**: Clean Architecture with separation of concerns

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart
│   ├── post_model.dart
│   └── reaction_model.dart
├── services/                 # Business logic and API calls
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   ├── post_service.dart
│   ├── admin_service.dart
│   └── notification_service.dart
├── providers/                # State management
│   └── user_provider.dart
├── screens/                  # UI screens
│   ├── registration_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── create_post_screen.dart
│   └── admin_screen.dart
├── widgets/                  # Reusable widgets
│   └── post_card.dart
└── utils/                    # Utilities and constants
    └── constants.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (3.11.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd church-app/telegram_clone
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up Firebase**
   - Follow the detailed setup guide in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Create a Firebase project
   - Add Android and iOS apps
   - Enable required services (Auth, Firestore, Storage, FCM)
   - Configure security rules
   - Update `firebase_options.dart`

4. **Run the app**
```bash
flutter run
```

## Firebase Configuration

This app requires Firebase configuration. Please refer to [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed setup instructions including:

- Creating Firebase project
- Adding Android/iOS apps
- Enabling Firebase services
- Setting up security rules
- Configuring platforms

## Usage

### First-Time Setup

1. **Register as Admin**:
   - Register a new user through the app
   - Go to Firebase Console → Firestore Database
   - Navigate to the `users` collection
   - Find your user and change `role` to "admin"

2. **Create Content**:
   - Admin users can create posts with various content types
   - Use the floating action button (+) on the home screen
   - Select content type (text, image, video, audio, file)
   - Add content and publish

### For Members

1. **Register**: Sign up with name, age, and phone number
2. **Login**: Use phone number to log in
3. **View Posts**: Browse content shared by admins
4. **React**: Tap the reaction button to respond to posts

### For Admins

1. **Access Admin Panel**: Tap the admin icon in the app bar
2. **Manage Users**: View all members, change roles, deactivate users
3. **Manage Posts**: Delete inappropriate content
4. **View Statistics**: Monitor community engagement

## Security Features

- **Firebase Authentication**: Secure user authentication
- **Role-Based Access**: Admin vs member permissions
- **Firestore Security Rules**: Server-side data protection
- **Storage Rules**: Controlled media upload access
- **Input Validation**: Client-side data validation

## Production Deployment

### Android

1. Update `android/app/build.gradle` with your signing configuration
2. Build release APK:
```bash
flutter build apk --release
```
3. Or build App Bundle:
```bash
flutter build appbundle --release
```

### iOS

1. Update signing in Xcode
2. Build release:
```bash
flutter build ios --release
```

### Pre-Deployment Checklist

- [ ] Update Firebase security rules for production
- [ ] Enable Firebase Analytics and Crashlytics
- [ ] Test all features thoroughly
- [ ] Update app icons and splash screens
- [ ] Configure push notifications properly
- [ ] Set up database backups
- [ ] Monitor performance and errors

## Troubleshooting

### Common Issues

1. **Firebase initialization errors**
   - Check `firebase_options.dart` configuration
   - Verify `google-services.json` / `GoogleService-Info.plist` placement

2. **Permission denied errors**
   - Review Firestore and Storage security rules
   - Ensure user is authenticated with correct role

3. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Check platform-specific configurations

## Development

### Adding New Features

1. Create model in `models/`
2. Add service logic in `services/`
3. Create provider for state management
4. Build UI in `screens/` or `widgets/`
5. Update routing in `main.dart`

### Code Style

- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Check the [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for Firebase-related issues
- Review Firebase Console for service-specific problems
- Check Flutter documentation for platform issues

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- The open-source community for various packages