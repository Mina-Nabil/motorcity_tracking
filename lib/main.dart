import 'package:flutter/material.dart';
import 'package:motorcity_tracking/providers/formData.dart';
import 'package:provider/provider.dart';

import './providers/requests.dart';
import './providers/auth.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/newRequest.dart';
import './screens/settings.dart';
import './screens/splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Requests()),
        ChangeNotifierProvider.value(value: FormDataProvider())
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Truck Tracker',
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            HomeScreen.routeName: (context) => HomeScreen(),
            NewRequestScreen.routeName: (context) => NewRequestScreen(),
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
          home: SplashScreen(),
        ),
      ),
    );
  }
}
