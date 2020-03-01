import 'dart:convert';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class Auth with ChangeNotifier {
  final _serverInit = "http://";
  String _serverIP ;
  final String _serverExt = "/motorcity/api/";
  final String _login = "managerlogin";
  final String _authToken = "checkauth";
  Map<String, String> _requestHeaders = {'Accept': 'application/json'};

  bool _isAuthenticated = false;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  Future<int> login(String user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    _serverIP = prefs.get("serverIP");
    String loginIP = (_serverIP) ?? "3.121.234.234";
    try {
      final serverURL = _serverInit + loginIP + _serverExt;
      final response = await http.post(serverURL + _login,
          body: {"MNGRName": user, "MNGRPass": password});
      if (response.statusCode == 200) {
        final decodedJson = json.decode(cleanResponse(response.body));
        var id = decodedJson['id'];
        var token = decodedJson['token'];
        if (id != null) {
          _isAuthenticated = true;
          await prefs.setString("userID", id);
          await prefs.setString("userName", user);
          await prefs.setString("token", token);
          await prefs.setString("userType", "manager");
          await prefs.setString("serverIP","3.121.234.234");
          _serverIP = "3.121.234.234";
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
    if(_serverIP != null)
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
    final prefs = await SharedPreferences.getInstance();
    String id = prefs.get("userID");
    String token = prefs.get("token");

    if (id == null || token == null) 
      return false;

    return await checkToken(token);

  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  String cleanResponse(json) {
    int shitIndex = json.indexOf("<script");
    if (shitIndex > 0)
      return json.substring(0, shitIndex);
    else
      return json;
  }

  Future<void> initHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    this._requestHeaders.addAll({
      "token": prefs.get("token"),
      "userType": prefs.get("userType")
    });
  }
}
