import 'package:flutter/material.dart';
import 'pages/favorites_page.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'services/favorites_store.dart';
import 'widgets/movie_card.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CinePickApp());
}

class CinePickApp extends StatefulWidget {
  const CinePickApp({super.key});

  @override
  State<CinePickApp> createState() => _CinePickAppState();
}

class _CinePickAppState extends State<CinePickApp> {
  final FavoritesStore _favorites = FavoritesStore();

  @override
  void initState() {
    super.initState();
    _favorites.load();
  }

  @override
  void dispose() {
    _favorites.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CinePick',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: cineBackground,
          colorScheme: ColorScheme.fromSeed(seedColor: cinePurple, brightness: Brightness.dark),
          appBarTheme: const AppBarTheme(backgroundColor: cineBackground, foregroundColor: Colors.white, elevation: 0, centerTitle: false),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF201D2B),
            indicatorColor: cinePurple.withValues(alpha: 0.22),
            labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        home: MainNavigation(favorites: _favorites),
      );
}

class MainNavigation extends StatefulWidget {
  final FavoritesStore favorites;
  const MainNavigation({super.key, required this.favorites});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        key: const PageStorageKey('home'),
        favorites: widget.favorites,
        onExplore: () => setState(() => _selectedIndex = 1),
      ),
      SearchPage(key: const PageStorageKey('search'), favorites: widget.favorites),
      FavoritesPage(key: const PageStorageKey('favorites'), favorites: widget.favorites),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Cari'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Favorit'),
        ],
      ),
    );
  }
}
