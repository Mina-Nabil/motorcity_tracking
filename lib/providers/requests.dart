import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import "package:flutter/material.dart";
import 'package:motorcity_tracking/models/truckrequest.dart';
import 'package:http/http.dart' as http;

class Requests with ChangeNotifier {
  //Requests Provider
  final _serverInit = "http://";
  String _serverIP;
  final String _serverExt = "/motorcity/api/";
  final String _requestsExt = "requests";
  final String _requestsDet = "request/details";

  List<TruckRequest> _requests = [];

  Map<String, String> _requestHeaders = {'Accept': 'application/json'};

  Future<String> getServerIP() async {
    String tmpServer = "3.121.234.234";
    final directory = await getApplicationDocumentsDirectory();
    final mgFile = new File("${directory.path}/mg_server.txt");
    if (await mgFile.exists()) {
      _serverIP = await mgFile.readAsString();
    }
    return tmpServer ?? _serverIP;
  }

  Future<void> setServerIP(newIP) async {
    _serverIP = newIP;
    final directory = await getApplicationDocumentsDirectory();
    final mgFile = new File("${directory.path}/mg_server.txt");
    if (await mgFile.exists()) {
      mgFile.writeAsStringSync(newIP);
    }
  }

  // set serverIP(String newIP) {
  //   _serverIP = newIP;
  //   FlutterKeychain.put(key: "serverIP", value: _serverIP);
  // }

  List<TruckRequest> get requests {
    return [..._requests];
  }

  Future<void> loadRequests({force: false}) async {
    if (force || _requests.length == 0) {
      _requests = [];
      if (_requestHeaders['token'] == null ||
          _requestHeaders['userType'] == null) await initHeaders();
      if (_serverIP == null) _serverIP = await getServerIP();
      var response = await http.post(
          _serverInit + _serverIP + _serverExt + _requestsExt,
          body: {"DriverID": "-1"},
          headers: _requestHeaders);
      if (response.statusCode == 200) {
        final dynamic cleanRequests = cleanResponse(response.body);
        if (cleanRequests is Map<String, dynamic> &&
            cleanRequests.containsKey("headers") &&
            cleanRequests['headers'] == "false") {
          return;
        }
        final Iterable decoded = json.decode(cleanRequests);
        decoded.forEach((tmp) => _requests.add(TruckRequest.fromJson(tmp)));
        notifyListeners();
        return;
      }
    } else {
      return;
    }
  }

  Future<TruckRequest> getFullRequest(id) async {
    TruckRequest tmp;

    if (_requestHeaders['token'] == null || _requestHeaders['userType'] == null)
      await initHeaders();
    if (_serverIP == null) _serverIP = await getServerIP();
    var response = await http.post(
        _serverInit + _serverIP + _serverExt + _requestsDet,
        headers: _requestHeaders,
        body: {"RequestID": id});
    if (response.statusCode == 200) {
      final cleanRequests = cleanResponse(response.body);
      final decoded = json.decode(cleanRequests);
      tmp = TruckRequest.fromJson(decoded[0]);

      return tmp;
    }
    return new TruckRequest();
  }

  Future<void> initHeaders() async {
    final directory = await getApplicationDocumentsDirectory();

    final tokenFile = new File("${directory.path}/token.txt");
    final typeFile = new File("${directory.path}/userType.txt");

    this._requestHeaders.addAll({
      "token": tokenFile.readAsStringSync(),
      "userType": typeFile.readAsStringSync()
    });
  }

  String cleanResponse(json) {
    int shitIndex = json.indexOf("<script");
    if (shitIndex > 0)
      return json.substring(0, shitIndex);
    else
      return json;
  }
}
