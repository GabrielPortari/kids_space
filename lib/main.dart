import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kids_space/util/getit_factory.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kids_space/view/design_system/app_theme_colors.dart';
import 'package:kids_space/view/screens/admin_company_screen.dart';
import 'package:kids_space/view/screens/admin_panel_screen.dart';
import 'package:kids_space/view/screens/all_active_children_screen.dart';
import 'package:kids_space/view/screens/childrens_screen.dart';
import 'package:kids_space/view/widgets/app_bottom_nav.dart';
import 'package:kids_space/view/screens/company_selection_screen.dart';
import 'package:kids_space/view/screens/home_screen.dart';
import 'package:kids_space/view/screens/login_screen.dart';
import 'package:kids_space/view/screens/collaborator_profile_screen.dart';
import 'package:kids_space/view/screens/splash_screen.dart';
import 'package:kids_space/view/screens/user_profile_screen.dart';
import 'package:kids_space/view/screens/users_screen.dart';
import 'package:kids_space/view/screens/collaborators_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  setup(GetIt.I);
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      path: 'assets/langs',
      fallbackLocale: const Locale('pt', 'BR'),
        child: Builder(builder: (context) => const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
      theme: theme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/company_selection': (context) => const CompanySelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/users': (context) => const UsersScreen(),
        '/collaborators': (context) => const CollaboratorsScreen(),
        '/childrens': (context) => const ChildrensScreen(),
        '/app_bottom_nav': (context) => const AppBottomNav(),
        '/profile': (context) => const ProfileScreen(),
        '/user_profile_screen': (context) => const UserProfileScreen(),
        '/all_active_children': (context) => const AllActiveChildrenScreen(),
        '/admin_panel': (context) => const AdminPanelScreen(),
        '/admin_company_screen': (context) => const AdminCompanyScreen(),
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
