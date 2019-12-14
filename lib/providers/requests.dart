import "package:flutter/material.dart";
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:motorcity_tracking/widgets/request.dart';


class Requests with ChangeNotifier {
  //Requests Provider
  final _serverInit = "http://";
  String _serverIP = "3.121.234.234";
  final String _serverExt = "/motorcity/api/" ;
  final String _login = "managerLogin" ;

  List<RequestItem> _requests = [];

  Future<String> getServerIP() async {
    String tmpServer = await FlutterKeychain.get(key: "serverIP");
    return tmpServer ?? _serverIP;
  }

  set serverIP(String newIP){
    _serverIP = newIP;
    FlutterKeychain.put(key: "serverIP", value: _serverIP);
  }

  List<RequestItem> get requests {
    return [..._requests];
  }

  Future<void> loadRequests({force: false}) async {

    if(force || _requests.length == 0){
      _requests = [];

    }
    else {
      return;
    }

  }

}