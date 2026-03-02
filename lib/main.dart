import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE8E8E8),
        colorScheme: const ColorScheme.light(
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF1A1A1A),
          primary: Color(0xFFD4AF37),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return const Color(0xFF88888A);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return const Color(0xFF4A4A4A);
            return const Color(0xFFCCCCCC);
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          showDragHandle: false,
        ),
        fontFamily: 'Alexandria',
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF2A2A2A),
          onSurface: Colors.white,
          primary: Color(0xFFD4AF37),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return const Color(0xFF88888A);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return const Color(0xFF4A4A4A);
            return const Color(0xFF2A2A2A);
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          showDragHandle: false,
        ),
        fontFamily: 'Alexandria',
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: LoginPage(),
      ),
    );
  }
}
