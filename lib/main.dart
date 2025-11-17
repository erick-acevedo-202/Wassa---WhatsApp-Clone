import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/theme_settings.dart';
import 'package:wasaaaaa/components/value_listener.dart';
import 'package:wasaaaaa/firebase_options.dart';
import 'package:wasaaaaa/screens/errors/errores_screen.dart';
import 'package:wasaaaaa/screens/home/home_screen.dart';
import 'package:wasaaaaa/screens/loading/loading_screen.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';
import 'package:wasaaaaa/screens/register/otp_screen.dart';
import 'package:wasaaaaa/screens/register/register_screen.dart';
import 'package:wasaaaaa/screens/register/users_info_screen.dart';
import 'package:wasaaaaa/screens/terms_conds_screen.dart/terms_and_cons_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: ValueListener.isLightTheme,
      builder: (context, value, _) {
        return MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: const Locale('es'),
          theme: value ? ThemeSettings.lightTheme() : ThemeSettings.darkTheme(),
          title: 'Material App',
          routes: {
            "/home": (context) => HomeScreen(),
            "/login": (context) => RegisterScreen(),
            "/otp": (context) => OtpScreen(),
            "/user_info": (context) => UsersInfoScreen(),
          },
          //home: TermsAndConsScreen(),
          home: ref.watch(userDataProvider).when(data: (data) {
            if (data != null) {
              return HomeScreen();
            } else {
              return TermsAndConsScreen();
            }
          }, error: (error, er) {
            return ErrorScreen(errorMessage: error.toString());
          }, loading: () {
            return LoadingScreen();
          }),
        );
      },
    );
  }
}
