import 'transitions/portal_transition.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: androidFirebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFE86D1F),
        scaffoldBackgroundColor: const Color(0xFF1A2931),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(
              fallbackColor: Color(0xFF1A2931),
            ),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(
              backgroundColor: Color(0xFF1A2931),
            ),
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(
              backgroundColor: Color(0xFF1A2931),
            ),
            TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(
              backgroundColor: Color(0xFF1A2931),
            ),
          },
        ),
        colorScheme: ColorScheme.light(primary: const Color(0xFFE86D1F)),
      ),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarContrastEnforced: false,
        ),
        child: ColoredBox(
          color: const Color(0xFF1A2931),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color.fromRGBO(26, 41, 49, 1),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return AuthPortalTransition(
            signedIn: snapshot.hasData,
            child: snapshot.hasData
                ? HomePage(key: ValueKey(snapshot.data!.uid))
                : const LoginPage(),
          );
        },
      ),
    );
  }
}
