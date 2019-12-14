import 'dart:convert';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:flutter_keychain/flutter_keychain.dart" ;


class Auth with ChangeNotifier {

  final _serverInit = "http://";
  String _serverIP = "3.121.234.234";
  final String _serverExt = "/motorcity/api/" ;
  final String _login = "managerLogin" ;

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

  Future<bool> login(String user, String password) async {
    try {
      final serverURL = _serverInit + _serverIP + _serverExt ;
      final response = await http.post(serverURL + _login,
          body: {"MNGRName": user, "MNGRPass": password});
      if (response.statusCode == 200) {
        var id = json.decode(response.body)['USER _ID'];
        if (id != null) {
          _isAuthenticated = true;
          await FlutterKeychain.put(key: "userID", value: id);
          await FlutterKeychain.put(key: "userName", value: user);
          return true;
        } else
          return false;
      } else
        return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isloggedIn() async {
    String id = await FlutterKeychain.get(key: "userID");
    return (id != null);
  }

}