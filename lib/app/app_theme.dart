import 'package:flutter/material.dart';

/// CGV Cinema Brand Design System
class AppTheme {
  // ── Brand Colours ─────────────────────────────────────────
  static const cgvRed = Color(0xFFD7262D);
  static const cgvDarkRed = Color(0xFFAF1E24);

  // ── Dark-mode surfaces ─────────────────────────────────────
  static const _darkBg = Color(0xFF0E0E0E);
  static const _darkSurface = Color(0xFF1A1A1A);
  static const _darkCard = Color(0xFF252525);
  static const _darkDivider = Color(0xFF2E2E2E);

  // ── Light-mode surfaces ────────────────────────────────────
  static const _lightBg = Color(0xFFF5F5F5);
  static const _lightCard = Color(0xFFFFFFFF);
  static const _lightDivider = Color(0xFFE0E0E0);

  // ── Neutral ────────────────────────────────────────────────
  static const _grey = Color(0xFF8A8A8A);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      // primary – CGV Red
      primary: cgvRed,
      onPrimary: Colors.white,
      primaryContainer:
          dark ? const Color(0xFF4A0A0C) : const Color(0xFFFFDADA),
      onPrimaryContainer:
          dark ? const Color(0xFFFFB3B3) : const Color(0xFF8B0000),
      // secondary – neutral content colour
      secondary: dark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
      onSecondary: dark ? const Color(0xFF212121) : Colors.white,
      secondaryContainer:
          dark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
      onSecondaryContainer:
          dark ? Colors.white : const Color(0xFF212121),
      // tertiary – muted grey
      tertiary: _grey,
      onTertiary: Colors.white,
      tertiaryContainer:
          dark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
      onTertiaryContainer:
          dark ? Colors.white : const Color(0xFF212121),
      // error
      error: const Color(0xFFFF5252),
      onError: Colors.white,
      errorContainer: const Color(0xFF4A0000),
      onErrorContainer: const Color(0xFFFFB3B3),
      // surfaces
      surface: dark ? _darkBg : _lightBg,
      onSurface: dark ? Colors.white : const Color(0xFF121212),
      surfaceContainerHighest: dark ? _darkCard : _lightCard,
      surfaceContainerHigh: dark ? _darkCard : _lightCard,
      surfaceContainer: dark ? _darkSurface : _lightCard,
      surfaceContainerLow: dark ? _darkSurface : _lightBg,
      surfaceContainerLowest: dark ? _darkBg : _lightBg,
      onSurfaceVariant:
          dark ? const Color(0xFFBDBDBD) : const Color(0xFF616161),
      outline: dark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
      outlineVariant:
          dark ? _darkDivider : _lightDivider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: dark ? Colors.white : const Color(0xFF212121),
      onInverseSurface: dark ? const Color(0xFF212121) : Colors.white,
      inversePrimary: cgvDarkRed,
      surfaceTint: cgvRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: dark ? _darkBg : _lightBg,
      splashFactory: InkRipple.splashFactory,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
        },
      ),

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: dark ? _darkBg : _lightCard,
        surfaceTintColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : const Color(0xFF121212),
        iconTheme: IconThemeData(
          color: dark ? Colors.white : const Color(0xFF121212),
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(color: cgvRed, size: 24),
        titleTextStyle: TextStyle(
          color: dark ? Colors.white : const Color(0xFF121212),
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? _darkCard : _lightCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── FilledButton ─────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cgvRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              dark ? const Color(0xFF3A3A3A) : const Color(0xFFCCCCCC),
          disabledForegroundColor:
              dark ? const Color(0xFF888888) : const Color(0xFF666666),
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? const Color(0xFFFF6B6B) : cgvRed,
          side: BorderSide(
            color: dark ? const Color(0xFFFF6B6B) : cgvRed,
            width: 1.5,
          ),
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? const Color(0xFFFF6B6B) : cgvRed,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),

      // ── ElevatedButton ───────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? _darkCard : Colors.white,
          foregroundColor: dark ? Colors.white : const Color(0xFF121212),
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),

      // ── Input / TextField ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? _darkCard : _lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cgvRed, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: dark ? const Color(0xFF9E9E9E) : const Color(0xFF757575),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: dark ? _darkCard : const Color(0xFFF2F2F2),
        selectedColor: cgvRed,
        disabledColor: dark ? _darkCard : const Color(0xFFEEEEEE),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: dark ? Colors.white : const Color(0xFF121212),
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        side: BorderSide(
          color: dark ? const Color(0xFF4A4A4A) : const Color(0xFFCCCCCC),
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        checkmarkColor: Colors.white,
        showCheckmark: false,
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: dark ? _darkDivider : _lightDivider,
        thickness: 1,
        space: 0,
      ),

      // ── BottomSheet ──────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? _darkSurface : _lightCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 8,
        modalElevation: 12,
        modalBackgroundColor: dark ? _darkSurface : _lightCard,
      ),

      // ── TabBar ───────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: cgvRed,
        unselectedLabelColor: _grey,
        indicatorColor: cgvRed,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle:
            TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
      ),

      // ── ListTile ─────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        iconColor: cgvRed,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── FloatingActionButton ─────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: cgvRed,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),

      // ── NavigationBar ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: dark ? _darkSurface : _lightCard,
        indicatorColor: cgvRed.withValues(alpha: .12),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: cgvRed, size: 24);
          }
          return const IconThemeData(size: 24);
        }),
      ),
    );
  }

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);
}

/// Custom page transition builder providing smooth fade & scale transitions.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeOutCubic;
    final scaleTween =
        Tween<double>(begin: 0.96, end: 1.0).chain(CurveTween(curve: curve));
    final fadeTween =
        Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

    return FadeTransition(
      opacity: animation.drive(fadeTween),
      child: ScaleTransition(
        scale: animation.drive(scaleTween),
        child: child,
      ),
    );
  }
}

