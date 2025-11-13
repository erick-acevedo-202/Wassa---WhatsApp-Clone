import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wasaaaaa/components/theme_settings.dart';
import 'package:wasaaaaa/components/value_listener.dart';
import 'package:wasaaaaa/firebase_options.dart';
import 'package:wasaaaaa/screens/home_screen.dart';
import 'package:wasaaaaa/screens/logRegister/log_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ValueListener.isLightTheme,
      builder: (context, value, _) {
        return MaterialApp(
          theme: value ? ThemeSettings.lightTheme() : ThemeSettings.darkTheme(),
          title: 'Material App',
          routes: {"/home": (context) => HomeScreen()},
          home: LogScreen(),
        );
      },
    );
  }
}
