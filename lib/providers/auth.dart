import 'dart:convert';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:flutter_keychain/flutter_keychain.dart";

class Auth with ChangeNotifier {
  final _serverInit = "http://";
  String _serverIP = "3.121.234.234";
  final String _serverExt = "/motorcity/api/";
  final String _login = "managerlogin";
  final String _authToken = "checkauth";
  Map<String, String> _requestHeaders = {'Accept': 'application/json'};

  bool _isAuthenticated = false;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  Auth() {
    Future.delayed(Duration.zero).then((_) async {
      String tmpServerUrl = await FlutterKeychain.get(key: "serverIP");
      if (tmpServerUrl != null)
        _serverIP = tmpServerUrl;
      else
        FlutterKeychain.put(key: "serverIP", value: _serverIP);
    });
  }

  Future<int> login(String user, String password) async {
    _serverIP = await FlutterKeychain.get(key: "serverIP");

    try {
      final serverURL = _serverInit + _serverIP + _serverExt;
      final response = await http.post(serverURL + _login,
          body: {"MNGRName": user, "MNGRPass": password});
      if (response.statusCode == 200) {
        final decodedJson = json.decode(cleanResponse(response.body));
        var id = decodedJson['id'];
        var token = decodedJson['token'];
        if (id != null) {
          _isAuthenticated = true;
          await FlutterKeychain.put(key: "userID", value: id);
          await FlutterKeychain.put(key: "userName", value: user);
          await FlutterKeychain.put(key: "token", value: token);
          await FlutterKeychain.put(key: "userType", value: "manager");
          initHeaders();
          return 1; //Login Success
        } else
          return 0; //Invalid data
      } else {
        return -1; //No server connection
      }
    } catch (e) {
      return -1; //No server connection
    }
  }

  Future<bool> checkToken(token) async {
    try {
      final serverURL = _serverInit + _serverIP + _serverExt;
      await initHeaders();
      final response  = await http.post(serverURL + _authToken, headers: _requestHeaders);
      if(response.statusCode == 200){
        final cleaned = cleanResponse(response.body);
        return (json.decode(cleaned)['headers'] ?? false);
      }
    }  catch (e){
    }
      return false;
  }

  Future<bool> isloggedIn() async {

    String id = await FlutterKeychain.get(key: "userID");
    String token = await FlutterKeychain.get(key: "token");

    if (id == null || token == null) 
      return false;

    return await checkToken(token);

  }

  void logout() {
    FlutterKeychain.clear();
  }

  String cleanResponse(json) {
    int shitIndex = json.indexOf("<script");
    if (shitIndex > 0)
      return json.substring(0, shitIndex);
    else
      return json;
  }

  Future<void> initHeaders() async {
    this._requestHeaders.addAll({
      "token": await FlutterKeychain.get(key: "token"),
      "userType": await FlutterKeychain.get(key: "userType")
    });
  }
}
