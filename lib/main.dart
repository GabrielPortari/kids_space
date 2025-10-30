import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/util/getit_factory.dart';
import 'package:kids_space/view/all_active_children_screen.dart';
import 'package:kids_space/view/app_bottom_nav.dart';
import 'package:kids_space/view/company_selection_screen.dart';
import 'package:kids_space/view/home_screen.dart';
import 'package:kids_space/view/login_screen.dart';
import 'package:kids_space/view/profile_screen.dart';
import 'package:kids_space/view/register_screen.dart';
import 'package:kids_space/view/splash_screen.dart';
import 'package:kids_space/view/user_profile_screen.dart';
import 'package:kids_space/view/users_screen.dart';

void main() {
  setup(GetIt.I);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Space',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/company_selection': (context) => const CompanySelectionScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/users': (context) => const UsersScreen(),
        '/app_bottom_nav': (context) => const AppBottomNav(),
        '/profile': (context) => const ProfileScreen(),
        '/user_profile_screen': (context) => const UserProfileScreen(),
        '/all_active_children': (context) => const AllActiveChildrenScreen(),
        
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
