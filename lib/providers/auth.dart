import 'dart:convert';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:flutter_keychain/flutter_keychain.dart" ;


class Auth with ChangeNotifier {

  final _serverInit = "http://";
  String _serverIP = "3.121.234.234";
  final String _serverExt = "/motorcity/api/" ;
  final String _login = "managerlogin" ;

  bool _isAuthenticated = false;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  Auth() {
    Future.delayed(Duration.zero).then( (_) async {
      String tmpServerUrl = await FlutterKeychain.get(key: "serverIP");
      if(tmpServerUrl != null)
        _serverIP = tmpServerUrl;
      else 
        FlutterKeychain.put(key: "serverIP", value: _serverIP);
    });
  }

  Future<int> login(String user, String password) async {

    _serverIP = await FlutterKeychain.get(key: "serverIP");

    try {
      final serverURL = _serverInit + _serverIP + _serverExt ;
      final response = await http.post(serverURL + _login,
          body: {"MNGRName": user, "MNGRPass": password});
      if (response.statusCode == 200) {
        var id = json.decode(response.body)['USER_ID'];
        if (id != null) {
          _isAuthenticated = true;
          await FlutterKeychain.put(key: "userID", value: id);
          await FlutterKeychain.put(key: "userName", value: user);
          return 1;
        } else
          
          return 0;
      } else {
        
        return -1;
      }
    } catch (e) {
      return -1;
    }
  }

  Future<bool> isloggedIn() async {
    String id = await FlutterKeychain.get(key: "userID");
    return (id != null);
  }

  void logout() {
    FlutterKeychain.clear();
  }

}