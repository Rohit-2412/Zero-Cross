import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// UIKit - A responsive UI helper class for consistent sizing across different screen sizes
///
/// This class provides helper functions to scale width, height, padding, text, etc.,
/// based on device screen size and aspect ratio to avoid hardcoded dimensions.
///
/// Usage:
/// 1. Initialize in your widget: UIKit.init(context)
/// 2. Use helper methods: UIKit.width(80) for 80% screen width
/// 3. Scale fonts: UIKit.scaledFont(16) for responsive font size
/// 4. Get responsive padding: UIKit.padding(16) for scaled padding
class UIKit {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockWidth;
  static late double blockHeight;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late Orientation orientation;

  /// Initialize the UIKit with context
  /// Call this method in the build method of your widget
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    // Calculate safe area
    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    // Calculate blocks (1% of screen)
    blockWidth = (screenWidth - _safeAreaHorizontal) / 100;
    blockHeight = (screenHeight - _safeAreaVertical) / 100;
  }

  /// Get responsive width as percentage of screen width
  /// Example: UIKit.width(80) returns 80% of screen width
  static double width(double percent) {
    return blockWidth * percent;
  }

  /// Get responsive height as percentage of screen height
  /// Example: UIKit.height(20) returns 20% of screen height
  static double height(double percent) {
    return blockHeight * percent;
  }

  /// Get scaled font size based on screen size
  /// Uses a combination of width and height for better scaling
  static double scaledFont(double size) {
    double scaleFactor = math.min(blockWidth, blockHeight) / 4.0;
    return size * scaleFactor;
  }

  /// Get responsive padding/margin
  static double padding(double size) {
    return blockWidth * (size / 8.0); // Adjust divisor for scaling
  }

  /// Get responsive border radius
  static double radius(double size) {
    return blockWidth * (size / 10.0);
  }

  /// Check if screen is small (phones)
  static bool get isSmallScreen => screenWidth < 600;

  /// Check if screen is medium (small tablets)
  static bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;

  /// Check if screen is large (tablets/desktop)
  static bool get isLargeScreen => screenWidth >= 900;

  /// Check if device is in landscape mode
  static bool get isLandscape => orientation == Orientation.landscape;

  /// Check if device is in portrait mode
  static bool get isPortrait => orientation == Orientation.portrait;

  /// Get aspect ratio
  static double get aspectRatio => screenWidth / screenHeight;

  /// Get safe screen width (excluding notches, etc.)
  static double get safeScreenWidth => screenWidth - _safeAreaHorizontal;

  /// Get safe screen height (excluding status bar, etc.)
  static double get safeScreenHeight => screenHeight - _safeAreaVertical;

  /// Get responsive icon size
  static double iconSize(double size) {
    return math.min(width(size / 5), height(size / 5));
  }

  /// Get responsive elevation for Material widgets
  static double elevation(double size) {
    return blockWidth * (size / 20.0);
  }

  /// Get responsive gap/spacing between widgets
  static double gap(double size) {
    return blockHeight * (size / 10.0);
  }

  /// Get minimum dimension (useful for square widgets)
  static double minDimension(double percent) {
    return math.min(width(percent), height(percent));
  }

  /// Get maximum dimension
  static double maxDimension(double percent) {
    return math.max(width(percent), height(percent));
  }

  /// Breakpoint helpers for different screen sizes
  static T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isLargeScreen && desktop != null) return desktop;
    if (isMediumScreen && tablet != null) return tablet;
    return mobile;
  }

  /// Get text scale factor for better readability
  static double get textScaleFactor => _mediaQueryData.textScaleFactor;
}

/// Extension for convenient access to UIKit methods
extension UIKitExtension on num {
  /// Convert number to responsive width
  double get w => UIKit.width(toDouble());

  /// Convert number to responsive height
  double get h => UIKit.height(toDouble());

  /// Convert number to responsive font size
  double get sp => UIKit.scaledFont(toDouble());

  /// Convert number to responsive padding
  double get p => UIKit.padding(toDouble());

  /// Convert number to responsive radius
  double get r => UIKit.radius(toDouble());
}
