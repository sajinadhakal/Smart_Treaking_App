import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/itinerary_provider.dart';
import 'providers/mountain_mode_provider.dart';
import 'providers/review_provider.dart';
import 'screens/auth/auth_wrapper_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => MountainModeProvider()..loadPreference()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: Consumer<MountainModeProvider>(
        builder: (context, mountainMode, _) => MaterialApp(
          title: 'Nepal Trekking App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.mountainTheme,
          themeMode: mountainMode.enabled ? ThemeMode.dark : ThemeMode.light,
          themeAnimationDuration: mountainMode.reduceMotion ? Duration.zero : kThemeAnimationDuration,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(disableAnimations: mountainMode.reduceMotion),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AuthWrapperScreen(),
        ),
      ),
    );
  }
}
