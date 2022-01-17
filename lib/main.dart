import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchify/features/theme_provider.dart';
import 'package:matchify/features/utils/pages/error_page.dart';
import 'package:matchify/data/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_cubit.dart';
import 'features/auth/auth_gate.dart';
import 'features/utils/pages/loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final ThemeData _matchifyTheme = ThemeProvider.buildTheme();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matchify',
      theme: kReleaseMode ? _matchifyTheme : ThemeProvider.buildTheme(),
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // // Check for errors
          if (snapshot.hasError) {
            return const ErrorPage();
          }

          // // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return //const PoiPage();
                Provider(
              create: (_) => AuthService(
                firebaseAuth: FirebaseAuth.instance,
              ),
              child: BlocProvider(
                create: (context) => AuthCubit(
                  authService: context.read(),
                ),
                child: const AuthGate(),
              ),
            );
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return const Loading();
        },
      ),
    );
  }
}
