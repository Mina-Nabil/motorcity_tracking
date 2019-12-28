import 'package:flutter/material.dart';
import 'package:motorcity_tracking/providers/auth.dart';
import 'package:motorcity_tracking/screens/home.dart';
import 'package:provider/provider.dart';
import "package:fab_menu/fab_menu.dart";
import 'package:motorcity_tracking/screens/settings.dart';

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

  void initState() {
    super.initState();
    menuDataList = [
      new MenuData(Icons.settings, (context, menuData) {
        Navigator.of(context).pushNamed(SettingsScreen.routeName);
      }, labelText: "Settings")
    ];
  }

  void _showLoginFailed(String msg, context) {
    Scaffold.of(context)
        .showSnackBar(new SnackBar(content: new Text("Error: " + msg)));
  }

  Future<void> checkUser(context) async {
    this.username = LoginScreen._user.text;
    this.password = LoginScreen._pass.text;

    Provider.of<Auth>(context).login(username, password).then((response) {
      if (response == 1) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else if (response == 0) {
        _showLoginFailed("Invalid data, please check user/pass", context);
      } else {
        _showLoginFailed("No connection to server", context);
      }
    });
  }

  // Future<String> newCheckUser(String user, String pass) {
  //   Provider.of<Auth>(context).login(user, pass).then((response) {
  //     if (response == 1) {
  //       return null; //success
  //     } else if (response == 1) {
  //       return "Invalid data, Please Check User and Pass";
  //     } else {
  //       return "Please try Again, Connection down :/ ";
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var oldLogin = Builder(
        builder: (context) => Container(
            padding: EdgeInsets.only(right: 80, left: 80),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/Motorcity_Logo.png'),
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
                  child: RaisedButton(
                    color: Colors.blue,
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => checkUser(context),
                  ),
                )
              ],
            )));

    var newLogin = Builder(
        builder: (context) => Container(
            color: Color.fromRGBO(0,46,72,0.5),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[
                  Hero(
                    tag: 'hero',
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 48.0,
                      child: Image.asset('assets/images/Motorcity-Logo-wht-blue2.png'),
                    ),
                  ),
                  SizedBox(height: 48.0),
                  TextFormField(
                    controller: LoginScreen._user,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    autofocus: false,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white54),
                      hoverColor: Colors.blue,
                      hintText: 'Username',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.white)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    controller: LoginScreen._pass,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    autofocus: false,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white54),
                      hoverColor: Colors.blue,
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.white)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      onPressed: () => checkUser(context),
                      padding: EdgeInsets.all(12),
                      color: Color.fromRGBO(0,46,72,1),
                      child:
                          Text('Log In', style: TextStyle(fontSize: 18,color: Colors.white)),
                    ),
                  )
                ],
              ),
            )));

    return Scaffold(
        floatingActionButton: new FabMenu(
          menus: menuDataList,
          maskColor: Colors.black,
        ),
        floatingActionButtonLocation: fabMenuLocation,
        body: newLogin);
  }
}
