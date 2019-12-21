import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/requests.dart';
import './providers/auth.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/map.dart';
import './screens/settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Requests())
      ],
      child: Consumer<Auth>(

        builder: (context, auth, _) => MaterialApp(
          title: 'Truck Tracker',
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            HomeScreen.routeName: (context) => HomeScreen(),
            SettingsScreen.routeName: (context) => SettingsScreen(),
            MapScreen.routeName : (_) => MapScreen()
          },
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuthenticated ? HomeScreen() : LoginScreen(),
        ),
      ),
    );
  }
}
