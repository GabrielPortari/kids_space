import 'package:flutter/material.dart';
import 'package:kids_space/view/all_active_children_screen.dart';
import 'package:kids_space/view/app_bottom_nav.dart';
import 'package:kids_space/view/company_selection_screen.dart';
import 'package:kids_space/view/home_screen.dart';
import 'package:kids_space/view/login_screen.dart';
import 'package:kids_space/view/register_screen.dart';
import 'package:kids_space/view/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/company_selection': (context) => const CompanySelectionScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(companyName: 'Empresa Exemplo'),
        '/app_bottom_nav': (context) => const AppBottomNav(),
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
