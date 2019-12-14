import 'package:flutter/material.dart';
import 'package:motorcity_tracking/providers/auth.dart';
import 'package:motorcity_tracking/screens/home.dart';
import 'package:provider/provider.dart';
import "package:fab_menu/fab_menu.dart";

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login";

  static final TextEditingController _user = new TextEditingController();
  static final TextEditingController _pass = new TextEditingController();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username;
  String password;
  List<MenuData> menuDataList;

  void _showLoginFailed(context2) {
    Scaffold.of(context2).showSnackBar(new SnackBar(
        content: new Text(
            'Invalid Data! Please check User/Pass and selected Server')));
  }

  Future<void> checkUser(context2) async {
    this.username = LoginScreen._user.text;
    this.password = LoginScreen._pass.text;

    Provider.of<Auth>(context2).login(username, password).then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else {
        _showLoginFailed(context2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        floatingActionButton: new FabMenu(
          menus: menuDataList,
          maskColor: Colors.black,
        ),
        floatingActionButtonLocation: fabMenuLocation,
        body: Container(
            padding: EdgeInsets.only(right: 80, left: 80),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/Motorcity_Logo.png'),
                TextField(
                  controller: LoginScreen._user,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: TextField(
                    controller: LoginScreen._pass,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onSubmitted: null,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                    width: double.infinity,
                    child: Builder(
                      builder: (context2) => RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () => checkUser(context2),
                      ),
                    ))
              ],
            )));
  }
}
