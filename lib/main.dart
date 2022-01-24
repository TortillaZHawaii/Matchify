import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/common/route_path.dart';
import 'package:matchify/features/common/theme_provider.dart';
import 'package:matchify/features/common/pages/error_page.dart';
import 'package:matchify/data/auth/auth_service.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_cubit.dart';
import 'features/common/pages/loading.dart';
import 'features/common/theme_provider.dart';

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
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const ErrorPage();

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              Provider(
                create: (_) => AuthService(
                  firebaseAuth: FirebaseAuth.instance,
                ),
              ),
              Provider(
                create: (_) => PoiSourceFirebase() as PoiSource,
              ),
              BlocProvider(
                create: (context) => AuthCubit(
                  authService: context.read(),
                ),
              ),
              BlocProvider(
                create: (context) => PoiCubit(
                  dataSource: context.read(),
                ),
              ),
            ],
            builder: (ctx, child) {
              final PoiSource poiSource = ctx.read();
              return MaterialApp.router(
                title: 'Matchify',
                key: const Key('app'),
                theme:
                    kReleaseMode ? _matchifyTheme : ThemeProvider.buildTheme(),
                routeInformationParser: MatchifyRouteInformationParser(),
                routerDelegate: MatchifyRouterDelegate(poiSource: poiSource),
              );
            },
          );
        }

        return const Loading();
      },
    );
  }
}
