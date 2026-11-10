import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/course_seed_helper.dart';
import 'data/database/resource_seed_helper.dart';
import 'data/database/chapter_seed_helper.dart';
import 'data/database/user_seed_helper.dart';
import 'data/database/module4_seed_helper.dart';
import 'data/database/module5_seed_helper.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/forum_provider.dart';
import 'providers/messaging_provider.dart';
import 'providers/mentorship_provider.dart';
import 'providers/internship_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/forum/forum_list_screen.dart';
import 'screens/forum/forum_create_post_screen.dart';
import 'screens/forum/forum_post_detail_screen.dart';
import 'screens/web_not_supported_screen.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser FFI pour les plateformes desktop (Windows, Linux, macOS)
  // Skip this for web platform
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Initialize date formatting for French locale
  await initializeDateFormatting('fr_FR', null);
  
  // Only seed database on non-web platforms
  if (!kIsWeb) {
    // Seed default users (admin + test user)
    try {
      await UserSeedHelper.createTestUsersIfNeeded();
      await CourseSeedHelper.seedIfEmpty();
      await ChapterSeedHelper.seedChaptersIfNeeded();
      await ResourceSeedHelper.seedTestResources();
      await Module4SeedHelper.seedIfNeeded();
      await Module5SeedHelper.seedIfNeeded();
    } catch (e) {
      print('Error seeding database: $e');
    }
  } else {
    print('🌐 Running on web - Database features not available');
  }
  
  runApp(const EduPalestineApp());
}

class EduPalestineApp extends StatelessWidget {
  const EduPalestineApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // If running on web, show not supported screen
    if (kIsWeb) {
      return MaterialApp(
        title: 'EduPalestine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const WebNotSupportedScreen(),
      );
    }
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => MentorshipProvider()),
        ChangeNotifierProvider(create: (_) => InternshipProvider()),
      ],
      child: MaterialApp(
        title: 'EduPalestine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
        },
        onGenerateRoute: (settings) {
          // Routes dynamiques pour le forum
          if (settings.name?.startsWith('/forum/') == true) {
            final uri = Uri.parse(settings.name!);
            
            // Route: /forum/course/:courseId?title=CourseTitle
            if (uri.pathSegments.length == 3 && uri.pathSegments[0] == 'forum' && uri.pathSegments[1] == 'course') {
              final courseId = int.tryParse(uri.pathSegments[2]);
              final courseTitle = uri.queryParameters['title'] ?? 'Forum';
              
              if (courseId != null) {
                return MaterialPageRoute(
                  builder: (_) => ForumListScreen(
                    courseId: courseId,
                    courseTitle: courseTitle,
                  ),
                );
              }
            }
            
            // Route: /forum/create/:courseId
            if (uri.pathSegments.length == 3 && uri.pathSegments[0] == 'forum' && uri.pathSegments[1] == 'create') {
              final courseId = int.tryParse(uri.pathSegments[2]);
              
              if (courseId != null) {
                return MaterialPageRoute(
                  builder: (_) => ForumCreatePostScreen(courseId: courseId),
                );
              }
            }
            
            // Route: /forum/post/:postId
            if (uri.pathSegments.length == 3 && uri.pathSegments[0] == 'forum' && uri.pathSegments[1] == 'post') {
              final postId = int.tryParse(uri.pathSegments[2]);
              
              if (postId != null) {
                return MaterialPageRoute(
                  builder: (_) => ForumPostDetailScreen(postId: postId),
                );
              }
            }
          }
          
          return null;
        },
      ),
    );
  }
}

/// Écran de démarrage pour vérifier la session
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    // Attendre un peu pour l'effet splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'EduPalestine',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Application Mobile d\'Apprentissage',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
