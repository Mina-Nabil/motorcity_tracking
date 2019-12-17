import 'package:flutter/material.dart';
import 'package:motorcity_tracking/providers/requests.dart';
import 'package:motorcity_tracking/providers/auth.dart';
import 'package:motorcity_tracking/screens/home.dart';
import 'package:motorcity_tracking/screens/login.dart';
import 'package:motorcity_tracking/screens/settings.dart';
import 'package:provider/provider.dart';

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
            SettingsScreen.routeName: (context) => SettingsScreen()
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
