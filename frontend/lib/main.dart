import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart'; // ✅ added (mouse drag)

// Screens
import 'screens/welcome.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'screens/verify_code.dart';
import 'screens/forgot_password.dart';
import 'screens/otp_verification.dart';
import 'screens/set_new_password.dart';
import 'screens/oauth_callback.dart';
import 'screens/complete_profile.dart';
import 'screens/home_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/photo_scan_guided.dart';
import 'screens/settings_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/analysis_screen.dart'; 
import 'payments/payment_screen.dart';
import 'api/marketplace_service.dart';
import 'screens/freelance_hub_screen.dart';
import 'screens/freelance_workspace.dart';

import 'screens/spline_scan_hero.dart';

// ✅ GLOBAL THEME NOTIFIER
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(R2VApp());
}

/// ✅ Enables dragging scroll with mouse/trackpad on web/desktop
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class R2VApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'R2V App',

          // ✅ IMPORTANT: allows PageView/ListView drag by mouse on web
          scrollBehavior: const AppScrollBehavior(),

          // ✅ THEME MODE CONFIGURATION
          themeMode: currentMode,
          
          // ✅ LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFF72585),
            scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light background
            fontFamily: "Poppins",
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBC70FF),
              secondary: Color(0xFF4CC9F0),
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFFBC70FF)),
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ✅ DARK THEME (Your original theme)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFFF72585),
            scaffoldBackgroundColor: const Color(0xFFCAF0F8),
            fontFamily: "Poppins",
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFBC70FF),
              secondary: Color(0xFF4CC9F0),
              surface: Color(0xFF1A1B20),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFFBC70FF)),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          initialRoute: '/signin',

          // -------------------------------------------------------------
          // STATIC ROUTES (all routed through onGenerateRoute)
          // -------------------------------------------------------------
          onGenerateRoute: (settings) {
            Widget page;

            switch (settings.name) {
              case '/welcome':
                page = Welcome();
                break;
              case '/signup':
                page = SignUp();
                break;
              case '/signin':
                page = SignIn();
                break;
              case '/forgot':
                page = ForgotPassword();
                break;
              case '/setnewpass':
                page = SetNewPasswordPage(
                  resetToken: settings.arguments is String ? settings.arguments as String : null,
                );
                break;
              case '/completeprofile':
                page = CompleteProfile();
                break;
              case '/oauth/callback':
                page = const OAuthCallbackScreen();
                break;
              case '/home':
                page = const HomeScreen();
                break;
              case '/aichat':
                page = const AIChatScreen();
                break;
              case '/photo_scan':
                page = const PhotoScanGuidedScreen();
                break;
              case '/settings':
                page = const SettingsScreen();
                break;
              case '/explore':
                page = const ExploreScreen();
                break;
              case '/analysis':
                page = const AnalysisScreen();
                break;
                
              // ✅ ADDED FREELANCE ROUTES
              case '/freelance_hub':
                page = const FreelanceHubScreen();
                break;
              case '/freelance_workspace':
                page = const FreelanceWorkspaceScreen();
                break;

              case '/profile':
                final args = settings.arguments;
                String? userId;
                String? username;
                String? initialTab;
                if (args is Map) {
                  userId = args['userId']?.toString();
                  username = args['username']?.toString();
                  initialTab = args['tab']?.toString();
                }
                page = ProfileScreen(
                  userId: userId,
                  username: username ?? 'User',
                  initialTab: initialTab,
                );
                break;
              case '/editprofile':
                page = const ProfileScreen();
                break;

              // ---------------------- Dynamic routes ----------------------
              case '/verifycode':
                page = VerifyCode(email: settings.arguments as String);
                break;

              case '/verifyotp':
                page = OTPVerification(email: settings.arguments as String);
                break;

              case '/payment':
              final args = settings.arguments;

              if (args is MarketplaceAsset) {
                page = PaymentScreen(asset: args); 
              } else {
                page = const Scaffold(
                  body: Center(child: Text("Missing payment arguments")),
                );
              }
              break;

            case '/spline_test':
              page = SplineScanHeroScreen();
              break;

              default:
                return null;
            }

            return _animatedRoute(page, settings);
          },
        );
      },
    );
  }
}

// --------------------------------------------------------------------
// 🔥 GLOBAL PAGE TRANSITION (Fade + Slide Up)
// --------------------------------------------------------------------
Route _animatedRoute(Widget page, RouteSettings settings) {
  if (kIsWeb) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 230),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuad,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) {
      final slideUp = Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuad,
        ),
      );

      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );

      final scaleBackground = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      );

      return Stack(
        children: [
          Transform.scale(
            scale: scaleBackground.value,
            child: IgnorePointer(ignoring: true),
          ),
          FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slideUp,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}