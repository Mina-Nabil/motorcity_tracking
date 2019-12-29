import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/requests.dart';
import './providers/auth.dart';
import './screens/home.dart';
import './screens/login.dart';
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
          debugShowCheckedModeBanner: false,
          title: 'Truck Tracker',
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            HomeScreen.routeName: (context) => HomeScreen(),
            SettingsScreen.routeName: (context) => SettingsScreen(),
          },
          theme: ThemeData(
            fontFamily: 'NotoSerif',
            textTheme: TextTheme(body1: TextStyle(fontSize: 14)),
            primaryColor: Color.fromRGBO(0,46,72,1),
            cursorColor: Color.fromRGBO(0,46,72,1),
              primarySwatch: Colors.blue,
              hintColor: Colors.white70,
          ),
          home: auth.isAuthenticated ? HomeScreen() : LoginScreen(),
        ),
      ),
    );
  }
}
