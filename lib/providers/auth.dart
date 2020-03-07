import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

class Auth with ChangeNotifier {
  final _serverInit = "http://";
  String _serverIP;
  final String _serverExt = "/motorcity/api/";
  final String _login = "managerlogin";
  final String _authToken = "checkauth";
  Map<String, String> _requestHeaders = {'Accept': 'application/json'};

  bool _isAuthenticated = false;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  Future<int> login(String user, String password) async {
    final directory = await getApplicationDocumentsDirectory();
    final mgFile = new File("${directory.path}/mg_server.txt"); 
    if(mgFile.existsSync())
      _serverIP = mgFile.readAsStringSync();
    else _serverIP = "3.121.234.234";
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
          _serverIP = "3.121.234.234";
          
          final idFile = new File("${directory.path}/id.txt");
          final tokenFile = new File("${directory.path}/token.txt");
          final userType = new File("${directory.path}/userType.txt");
          final userName = new File("${directory.path}/userName.txt");
          mgFile.writeAsString(_serverIP);
          idFile.writeAsString(id);
          tokenFile.writeAsString(token);
          userType.writeAsString("manager");
          userName.writeAsString(user);
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
    if (_serverIP != null)
      try {
        final serverURL = _serverInit + _serverIP + _serverExt;
        await initHeaders();
        final response =
            await http.post(serverURL + _authToken, headers: _requestHeaders);
        if (response.statusCode == 200) {
          final cleaned = cleanResponse(response.body);
          return (json.decode(cleaned)['headers'] ?? false);
        }
      } catch (e) {}
    return false;
  }

  Future<bool> isloggedIn() async {
    final directory = await getApplicationDocumentsDirectory();
    final mgFile = new File("${directory.path}/mg_server.txt");
    final idFile = new File("${directory.path}/id.txt");
    final tokenFile = new File("${directory.path}/token.txt");
    final userNameFile = new File("${directory.path}/userName.txt");
    String serverIP;
    String id;
    String token;
    String userName;
    if ( mgFile.existsSync() && idFile.existsSync() && tokenFile.existsSync() && userNameFile.existsSync()) {
      serverIP = mgFile.readAsStringSync();
      id = idFile.readAsStringSync();
      token = tokenFile.readAsStringSync(); 
      userName = userNameFile.readAsStringSync();
    } else return false;

    if (id == null || serverIP == null || token == null || userName == null) return false;

    return true;
  }

  void logout() async {
    final directory = await getApplicationDocumentsDirectory();

    final tokenFile = new File("${directory.path}/token.txt");
    final idFile = new File("${directory.path}/id.txt");
    final typeFile = new File("${directory.path}/userType.txt");
    final userName = new File("${directory.path}/userName.txt");

    tokenFile.deleteSync();
    idFile.deleteSync();
    typeFile.deleteSync();
    userName.deleteSync();
    
  }

  String cleanResponse(json) {
    int shitIndex = json.indexOf("<script");
    if (shitIndex > 0)
      return json.substring(0, shitIndex);
    else
      return json;
  }

  Future<void> initHeaders() async {
    final directory = await getApplicationDocumentsDirectory();

    final tokenFile = new File("${directory.path}/token.txt");
    final typeFile = new File("${directory.path}/id.txt");

    this._requestHeaders.addAll(
        {"token": tokenFile.readAsStringSync(), "userType": typeFile.readAsStringSync()});
  }
}
