import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

enum AppColorScheme {
  blue('Blue Ocean', Colors.blue, Color(0xFF1976D2)),
  green('Forest Green', Colors.green, Color(0xFF388E3C)),
  purple('Royal Purple', Colors.purple, Color(0xFF7B1FA2)),
  orange('Sunset Orange', Colors.orange, Color(0xFFF57C00)),
  red('Ruby Red', Colors.red, Color(0xFFD32F2F)),
  teal('Ocean Teal', Colors.teal, Color(0xFF00796B)),
  indigo('Deep Indigo', Colors.indigo, Color(0xFF303F9F)),
  pink('Rose Pink', Colors.pink, Color(0xFFC2185B));

  const AppColorScheme(this.displayName, this.lightColor, this.darkColor);

  final String displayName;
  final Color lightColor;
  final Color darkColor;
}

enum BoardStyle {
  classic('Classic', 'Traditional tic-tac-toe board'),
  modern('Modern', 'Sleek rounded corners'),
  neon('Neon', 'Glowing neon effects'),
  minimal('Minimal', 'Clean and simple'),
  retro('Retro', 'Vintage pixel-style board'),
  glass('Glass', 'Translucent glass effect'),
  wood('Wood', 'Wooden texture board'),
  cyberpunk('Cyberpunk', 'Futuristic digital theme');

  const BoardStyle(this.displayName, this.description);

  final String displayName;
  final String description;
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  AppColorScheme _colorScheme = AppColorScheme.blue;
  BoardStyle _boardStyle = BoardStyle.classic;
  bool _animationsEnabled = true;
  double _boardCornerRadius = 12.0;
  String _playerXSymbol = 'X';
  String _playerOSymbol = 'O';

  bool get isDarkMode => _isDarkMode;
  AppColorScheme get colorScheme => _colorScheme;
  BoardStyle get boardStyle => _boardStyle;
  bool get animationsEnabled => _animationsEnabled;
  double get boardCornerRadius => _boardCornerRadius;
  String get playerXSymbol => _playerXSymbol;
  String get playerOSymbol => _playerOSymbol;

  Color get primaryColor => _isDarkMode ? _colorScheme.darkColor : _colorScheme.lightColor;
  Color get secondaryColor => _isDarkMode ? Colors.orange : Colors.deepOrange;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    _isDarkMode = LocalStorageService.getThemeMode();
    _colorScheme = LocalStorageService.getColorScheme();
    _boardStyle = LocalStorageService.getBoardStyle();
    _animationsEnabled = LocalStorageService.getAnimationsEnabled();
    _boardCornerRadius = LocalStorageService.getBoardCornerRadius();
    _playerXSymbol = LocalStorageService.getPlayerXSymbol();
    _playerOSymbol = LocalStorageService.getPlayerOSymbol();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    LocalStorageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  void setColorScheme(AppColorScheme scheme) {
    _colorScheme = scheme;
    LocalStorageService.saveColorScheme(scheme);
    notifyListeners();
  }

  void setBoardStyle(BoardStyle style) {
    _boardStyle = style;
    LocalStorageService.saveBoardStyle(style);
    notifyListeners();
  }

  void setAnimationsEnabled(bool enabled) {
    _animationsEnabled = enabled;
    LocalStorageService.saveAnimationsEnabled(enabled);
    notifyListeners();
  }

  void setBoardCornerRadius(double radius) {
    _boardCornerRadius = radius;
    LocalStorageService.saveBoardCornerRadius(radius);
    notifyListeners();
  }

  void setPlayerXSymbol(String symbol) {
    _playerXSymbol = symbol;
    LocalStorageService.savePlayerXSymbol(symbol);
    notifyListeners();
  }

  void setPlayerOSymbol(String symbol) {
    _playerOSymbol = symbol;
    LocalStorageService.savePlayerOSymbol(symbol);
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? _buildDarkTheme() : _buildLightTheme();

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: MaterialColor(primaryColor.toARGB32(), _getMaterialColorSwatch(primaryColor)),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_boardCornerRadius)),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(primaryColor.toARGB32(), _getMaterialColorSwatch(primaryColor)),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212), foregroundColor: Colors.white, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_boardCornerRadius)),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
    );
  }

  Map<int, Color> _getMaterialColorSwatch(Color color) {
    final int red = (color.r * 255).round();
    final int green = (color.g * 255).round();
    final int blue = (color.b * 255).round();

    final Map<int, Color> swatch = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };
    return swatch;
  }

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.orange,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212), foregroundColor: Colors.white, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.orange,
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
  );
}
