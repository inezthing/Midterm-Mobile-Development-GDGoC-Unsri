import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/app_state.dart';
import 'data/secure_storage_service.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/sell_page.dart';
import 'pages/community_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Peringatan: File .env tidak ditemukan, menggunakan nilai default.');
  }

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://plmoyaxwjefvswtxpigq.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsbW95YXh3amVmdnN3dHhwaWdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0ODA1NzMsImV4cCI6MjA5ODA1NjU3M30.GLaU4IXTRGn0vXRAwlboWTPrEkk8DvP_-0m42cp0TNg';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
      // ✅ Token JWT tersimpan di Keychain/Keystore, bukan SharedPreferences biasa
      pkceAsyncStorage: SecureStorageService(),
    ),
  );

  runApp(const WhimsifyApp());
}

class WhimsifyApp extends StatelessWidget {
  const WhimsifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadThemePreference();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppState, ThemeMode>((s) => s.themeMode);
    return MaterialApp(
      title: 'Whimsify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRoute();
  }

  Future<void> _checkAuthAndRoute() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await context.read<AppState>().loadAllData();
      if (!mounted) return;
      _navigateTo(const MainNavigation());
    } else {
      _navigateTo(const LoginPage());
    }
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A0D1A) : AppTheme.blush,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌷', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Whimsify',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MAIN NAVIGATION
// ==========================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0: return const HomePage();
      case 1: return const ExplorePage();
      case 3: return const CommunityPage();
      case 4: return const ProfilePage();
      default: return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      floatingActionButton: _SellFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _SellFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Jual barang baru',
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellPage())),
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BottomAppBar(
      color: isDark ? const Color(0xFF1A0D1A) : Colors.white,
      elevation: 8, notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(index: 0, icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', currentIndex: currentIndex, onTap: onTap),
            _NavItem(index: 1, icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore', currentIndex: currentIndex, onTap: onTap),
            const SizedBox(width: 60),
            _NavItem(index: 3, icon: Icons.people_outline, activeIcon: Icons.people, label: 'Komunitas', currentIndex: currentIndex, onTap: onTap),
            _NavItem(index: 4, icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil', currentIndex: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index, currentIndex;
  final IconData icon, activeIcon;
  final String label;
  final void Function(int) onTap;
  const _NavItem({required this.index, required this.icon, required this.activeIcon, required this.label, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return Semantics(
      label: label, selected: isSelected,
      child: GestureDetector(
        onTap: () => onTap(index), behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? activeIcon : icon, color: isSelected ? AppTheme.primary : Colors.grey[400], size: 24),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? AppTheme.primary : Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }
}