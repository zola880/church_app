import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.instance.initialize();
  
  // Initialize Notifications
  await NotificationService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..restoreSession(),
      child: MaterialApp(
        title: 'Church Community App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SessionGate(),
        routes: {
          '/register': (context) => const RegistrationScreen(),
          '/home': (context) => const HomeScreen(),
          '/create-post': (context) => const CreatePostScreen(),
          '/admin': (context) => const AdminScreen(),
        },
      ),
    );
  }
}

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isSessionRestored) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.isRegistered) {
          return const HomeScreen();
        }

        return const RegistrationScreen();
      },
    );
  }
}
