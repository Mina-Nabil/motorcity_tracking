import 'package:provider/provider.dart';
import '../providers/auth.dart';
import './login.dart';
import './home.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;
  bool isAuthenicated = false;
  Future<bool> checkAuthentication(BuildContext context) async {
    return await Provider.of<Auth>(context).isloggedIn();
  }

  @override
  void initState() {
    super.initState();
    _visible = false;

    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _visible = true;
      });
    });

    Future.delayed(Duration(seconds: 1)).then((_) async {
      isAuthenicated =
          await Provider.of<Auth>(context, listen: false).isloggedIn();
      print("LOGGING IN NOW"); //function el login hna
      if (isAuthenicated) {
        //replace with authentication result
        Navigator.pushReplacement(
            context,
            new PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 500),
                child: HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context,
            new PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 500),
                child: LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        color: Color.fromRGBO(0, 46, 72, 0.5),
                        child: AnimatedOpacity(
                            opacity: _visible ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 1000),
                            child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                child: Image.asset(
                                    "assets/images/Motorcity-Logo-wht-blue2.png")))))
              ],
            )));
  }
}
