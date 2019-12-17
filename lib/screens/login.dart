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

  void initState(){
    super.initState();
    menuDataList = [
      new MenuData(Icons.settings, (context, menuData){
        Navigator.of(context).pushNamed(SettingsScreen.routeName);
      },
      labelText: "Settings")
    ];
  }

  void _showLoginFailed(String msg, context) {
    Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
            "Error: " + msg)));
  }

  Future<void> checkUser(context) async {
    this.username = LoginScreen._user.text;
    this.password = LoginScreen._pass.text;

    Provider.of<Auth>(context).login(username, password).then((response) {
      if (response == 1) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else if (response == 0){
        _showLoginFailed("Invalid data, please check user/pass", context);
      } else {
        _showLoginFailed("No connection to server", context);
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
        body: Builder(
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
            ))));
  }
}
