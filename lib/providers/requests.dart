import 'dart:convert';

import "package:flutter/material.dart";
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:motorcity_tracking/models/truckrequest.dart';
import 'package:motorcity_tracking/widgets/request.dart';
import 'package:http/http.dart' as http;

class Requests with ChangeNotifier {
  //Requests Provider
  final _serverInit = "http://";
  String _serverIP = "3.121.234.234";
  final String _serverExt = "/motorcity/api/";
  final String _requestsExt = "requests/inprogress";

  List<TruckRequest> _requests = [];

  Future<String> getServerIP() async {
    String tmpServer = await FlutterKeychain.get(key: "serverIP");
    return tmpServer ?? _serverIP;
  }

  set serverIP(String newIP) {
    _serverIP = newIP;
    FlutterKeychain.put(key: "serverIP", value: _serverIP);
  }

  List<TruckRequest> get requests {
    return [..._requests];
  }

  Future<void> loadRequests({force: false}) async {
    if (force || _requests.length == 0) {
      _requests = [];
      var response =
          await http.get(_serverInit + _serverIP + _serverExt + _requestsExt);
      if (response.statusCode == 200) {
        final cleanRequests = cleanResponse(response.body);
        final Iterable decoded = json.decode(cleanRequests);
        decoded.forEach((tmp) => _requests.add(TruckRequest.fromJson(tmp)));
        print(_requests);
        notifyListeners();
        return;
      }
    } else {
      return;
    }
  }

  String cleanResponse(json) {
    int shitIndex = json.indexOf("<script");
    if (shitIndex > 0)
      return json.substring(0, shitIndex);
    else
      return json;
  }
}
