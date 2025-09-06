import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallpaper_provider.dart';
import 'services/local_storage_service.dart';
import 'services/background_scheduler_service.dart';
import 'services/permissions_service.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/niche_selection_screen.dart';
import 'screens/onboarding/interval_selection_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/wallpaper_preview_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'models/wallpaper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await LocalStorageService.instance.initialize();
  await BackgroundSchedulerService.instance.initialize();
  
  runApp(const WallFluxApp());
}

class WallFluxApp extends StatelessWidget {
  const WallFluxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WallpaperProvider()..initialize(),
      child: MaterialApp(
        title: 'WallFlux',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF667eea),
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF667eea),
            secondary: const Color(0xFF764ba2),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/niche-selection': (context) => const NicheSelectionScreen(),
          '/home': (context) => const HomeScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/interval-selection') {
            final selectedNiches = settings.arguments as List<String>;
            return MaterialPageRoute(
              builder: (context) => IntervalSelectionScreen(
                selectedNiches: selectedNiches,
              ),
            );
          }
          
          if (settings.name == '/wallpaper-preview') {
            final wallpaper = settings.arguments as Wallpaper;
            return MaterialPageRoute(
              builder: (context) => WallpaperPreviewScreen(
                wallpaper: wallpaper,
              ),
            );
          }
          
          return null;
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check permissions
      final permissionsService = PermissionsService.instance;
      
      // Request basic permissions if needed
      if (!await permissionsService.hasBasicPermissions()) {
        await permissionsService.requestAllPermissions(context);
      }

      // Wait for provider to initialize
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        final provider = Provider.of<WallpaperProvider>(context, listen: false);
        
        // Navigate based on onboarding status
        if (provider.shouldShowOnboarding) {
          Navigator.of(context).pushReplacementNamed('/welcome');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
          
          // Set up background scheduling
          final scheduler = BackgroundSchedulerService.instance;
          await scheduler.scheduleWallpaperUpdates(provider.userPreferences);
        }
      }
    } catch (e) {
      print('Error initializing app: $e');
      // Navigate to welcome screen as fallback
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Icon(
                Icons.wallpaper,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              
              // App Name
              Text(
                'WallFlux',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8),
              
              // Tagline
              Text(
                'Dynamic Wallpapers',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
              
              SizedBox(height: 48),
              
              // Loading indicator
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
