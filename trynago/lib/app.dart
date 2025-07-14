import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/discover/discover_screen.dart';
import 'screens/matches/matches_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'providers/app_state.dart';

class TrynaGoApp extends ConsumerWidget {
  const TrynaGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: isAuthenticated ? '/discover' : '/login',
      routes: [
        // Auth Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        
        // Main App Routes
        ShellRoute(
          builder: (context, state, child) => MainNavigationShell(child: child),
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
            GoRoute(
              path: '/matches',
              builder: (context, state) => const MatchesScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final isAuthenticated = ref.read(authStateProvider);
        final isOnAuthPage = state.fullPath == '/login' || state.fullPath == '/register';
        
        if (!isAuthenticated && !isOnAuthPage) {
          return '/login';
        }
        if (isAuthenticated && isOnAuthPage) {
          return '/discover';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'TrynaGo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFFF6B6B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color(0xFFFF6B6B),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final Widget child;
  
  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/discover');
        break;
      case 1:
        context.go('/matches');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    final location = GoRouterState.of(context).fullPath;
    if (location == '/discover') _selectedIndex = 0;
    if (location == '/matches') _selectedIndex = 1;
    if (location == '/profile') _selectedIndex = 2;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}