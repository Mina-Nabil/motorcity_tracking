import 'package:flutter/material.dart';
import 'package:motorcity_tracking/providers/auth.dart';
import 'package:motorcity_tracking/screens/home.dart';
import 'package:provider/provider.dart';
import "package:fab_menu/fab_menu.dart";
import 'package:motorcity_tracking/screens/settings.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login";

  static final TextEditingController _user = new TextEditingController();
  static final TextEditingController _pass = new TextEditingController();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<MenuData> menuDataList;

  void initState() {
    super.initState();
    menuDataList = [
      new MenuData(Icons.settings, (context, menuData) {
        Navigator.of(context).pushNamed(SettingsScreen.routeName);
      }, labelText: "Settings")
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: new FabMenu(
          menus: menuDataList,
          maskColor: Colors.black,
        ),
        floatingActionButtonLocation: fabMenuLocation,
        body: NewLogin());
  }
}

class NewLogin extends StatelessWidget {
  

  void _showLoginFailed(String msg, context) {
    Scaffold.of(context)
        .showSnackBar(new SnackBar(content: new Text("Error: " + msg)));
  }

  Future<void> checkUser(context) async {

    String username = LoginScreen._user.text;
    String password = LoginScreen._pass.text;

    Provider.of<Auth>(context, listen: false)
        .login(username, password)
        .then((response) {
      if (response == 1) {
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: HomeScreen(),
                duration: Duration(milliseconds: 500)));
      } else if (response == 0) {
        _showLoginFailed("Invalid data, please check user/pass", context);
      } else {
        _showLoginFailed("No connection to server", context);
      }
    });
  }

  Widget build(BuildContext context) {
    return Container(
        color: Color.fromRGBO(0, 46, 72, 0.5),
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
                  child:
                      Image.asset('assets/images/Motorcity-Logo-wht-blue2.png'),
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
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
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
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
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
                  color: Color.fromRGBO(0, 46, 72, 1),
                  child: Text('Log In',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ));
  }
}
