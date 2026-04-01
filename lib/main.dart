import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/service/api_client.dart';
import 'package:kids_space/util/getit_factory.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kids_space/view/design_system/app_theme.dart';
import 'package:kids_space/view/screens/admin_panel_screen.dart';
import 'package:kids_space/view/screens/childrens_screen.dart';
import 'package:kids_space/view/screens/parents_screen.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/view/screens/reports_screen.dart';
import 'package:kids_space/view/widgets/app_bottom_nav.dart';
// Company selection screen removed; navigation now goes to /login
import 'package:kids_space/view/screens/home_screen.dart';
import 'package:kids_space/view/screens/login_screen.dart';
import 'package:kids_space/view/screens/register_company_screen.dart';
import 'package:kids_space/view/screens/splash_screen.dart';
import 'package:kids_space/view/screens/collaborators_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env is missing, continue with defaults and avoid crashing the app.
    // This prevents a FileNotFoundError from stopping app startup in dev setups.
    // ignore: avoid_print
    print('dotenv: .env not found, continuing with default env values.');
  }
  // helper to safely read env variables even if dotenv failed to initialize
  String safeEnv(String key, [String? fallback]) {
    try {
      return dotenv.env[key] ?? (fallback ?? '');
    } catch (_) {
      return fallback ?? '';
    }
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: safeEnv('FIREBASE_API_KEY', ''),
          authDomain: safeEnv('FIREBASE_AUTH_DOMAIN', ''),
          projectId: safeEnv('FIREBASE_PROJECT_ID', ''),
          storageBucket: safeEnv('FIREBASE_STORAGE_BUCKET', ''),
          messagingSenderId: safeEnv('FIREBASE_MESSAGING_SENDER_ID', ''),
          appId: safeEnv('FIREBASE_APP_ID', ''),
          measurementId: safeEnv('FIREBASE_MEASUREMENT_ID', null),
        ),
      );
    } else {
      // ignore: avoid_print
      print('Firebase already initialized, skipping initializeApp');
    }
  } catch (e) {
    // ignore: avoid_print
    print('Firebase.initializeApp error: $e');
  }
  setup(GetIt.I);
  ApiClient().init(
    baseUrl: safeEnv('API_BASE_URL', 'http://10.0.2.2:3000'),
    tokenProvider: () async {
      final authController = GetIt.I<AuthController>();
      return await authController.getIdToken();
    },
    refreshToken: () async {
      final authController = GetIt.I<AuthController>();
      return await authController.refreshToken();
    },
  );
  // Load persisted auth state and print diagnostics to help verify token persistence
  try {
    final authController = GetIt.I<AuthController>();
    await authController.loadFromStorage();
    // ignore: avoid_print
    print(
      'Startup Auth: idToken=${authController.idToken} role=${authController.role}',
    );
    // attempt to repopulate logged user/collaborator/company info
    await authController.checkLoggedUser();
    final collabCtrl = GetIt.I<CollaboratorController>();
    final companyCtrl = GetIt.I<CompanyController>();
    // ignore: avoid_print
    print('Startup Auth: loggedCollaborator=${collabCtrl.loggedCollaborator}');
    // ignore: avoid_print
    print('Startup Auth: loadedCompany=${companyCtrl.company}');
  } catch (e) {
    // ignore: avoid_print
    print('Startup Auth diagnostics failed: $e');
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      path: 'assets/langs',
      fallbackLocale: const Locale('pt', 'BR'),
      child: Builder(builder: (context) => const MyApp()),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _authController = GetIt.I.get<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Removed post-frame session check since splash now performs startup session validation.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSessionOnResume();
    }
  }

  void _checkSessionOnResume() async {
    final valid = await _authController.ensureSessionValid();
    if (!valid) {
      try {
        await _authController.logout();
      } catch (_) {}
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        showDialog<void>(
          context: ctx,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            title: const Text('Sessão expirada'),
            content: const Text('Sua sessão expirou. Faça login novamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(c).pop();
                  Navigator.of(
                    ctx,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...context.localizationDelegates,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Kids Space',
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        // '/company_selection' removed: navigation now uses '/login'
        '/login': (context) => const LoginScreen(),
        '/register_company': (context) => const RegisterCompanyScreen(),
        '/parents': (context) => const ParentsScreen(),
        '/collaborators': (context) => const CollaboratorsScreen(),
        '/childrens': (context) => const ChildrensScreen(),
        '/app_bottom_nav': (context) => const AppBottomNav(),
        '/profile': (context) => const ProfileScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/admin_panel': (context) => const AdminPanelScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(),
    );
  }
}
