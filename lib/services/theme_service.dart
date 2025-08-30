import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Service to force light mode across all platforms
/// Especially important for Huawei devices and other Android OEMs
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static bool _isInitialized = false;
  static String? _deviceBrand;
  static String? _deviceModel;

  /// Initialize theme service and detect device information
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceBrand = androidInfo.brand.toLowerCase();
        _deviceModel = androidInfo.model.toLowerCase();

        print('🔍 Device detected: $_deviceBrand $_deviceModel');

        // Special handling for Huawei devices
        if (_deviceBrand?.contains('huawei') == true ||
            _deviceBrand?.contains('honor') == true) {
          print(
              '📱 Huawei/Honor device detected - applying enhanced light mode');
          await _applyHuaweiSpecificSettings();
        }

        await _forceAndroidLightMode();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceBrand = 'apple';
        _deviceModel = iosInfo.model.toLowerCase();

        print('🍎 iOS device detected: $_deviceModel');
        await _forceIOSLightMode();
      }

      _isInitialized = true;
      print('🌞 ThemeService initialized successfully');
    } catch (e) {
      print('❌ ThemeService initialization failed: $e');
    }
  }

  /// Force light mode on Android devices
  static Future<void> _forceAndroidLightMode() async {
    try {
      // Set system UI overlay style for light mode
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );

      print('✅ Android light mode applied');
    } catch (e) {
      print('❌ Failed to apply Android light mode: $e');
    }
  }

  /// Special settings for Huawei devices
  static Future<void> _applyHuaweiSpecificSettings() async {
    try {
      // Huawei devices sometimes need additional system UI calls
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );

      // Additional delay for Huawei EMUI to process the changes
      await Future.delayed(const Duration(milliseconds: 100));

      // Apply again to ensure it sticks on EMUI
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      print('✅ Huawei-specific light mode settings applied');
    } catch (e) {
      print('❌ Failed to apply Huawei-specific settings: $e');
    }
  }

  /// Force light mode on iOS devices
  static Future<void> _forceIOSLightMode() async {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      print('✅ iOS light mode applied');
    } catch (e) {
      print('❌ Failed to apply iOS light mode: $e');
    }
  }

  /// Apply light mode system UI - call this when navigating between screens
  static void applyLightModeSystemUI() {
    try {
      if (Platform.isAndroid) {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );
      } else if (Platform.isIOS) {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
      }
    } catch (e) {
      print('❌ Failed to apply light mode system UI: $e');
    }
  }

  /// Get the forced light theme data
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      canvasColor: Colors.white,
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        primary: Colors.blue,
        onPrimary: Colors.white,
        secondary: Colors.blueAccent,
        onSecondary: Colors.white,
        onSurface: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black87),
        headlineLarge: TextStyle(color: Colors.black),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      dividerColor: Colors.grey[300],
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.grey[200],
        elevation: 2,
      ),
    );
  }

  /// Check if device is Huawei/Honor
  static bool get isHuaweiDevice {
    return _deviceBrand?.contains('huawei') == true ||
        _deviceBrand?.contains('honor') == true;
  }

  /// Get device brand
  static String? get deviceBrand => _deviceBrand;

  /// Get device model
  static String? get deviceModel => _deviceModel;
}
