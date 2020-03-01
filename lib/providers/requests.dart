import 'dart:convert';

import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motorcity_tracking/models/truckrequest.dart';
import 'package:http/http.dart' as http;

class Requests with ChangeNotifier {
  //Requests Provider
  final _serverInit = "http://";
  String _serverIP ;
  final String _serverExt = "/motorcity/api/";
  final String _requestsExt = "requests/inprogress";
  final String _requestsDet = "request/details";

  List<TruckRequest> _requests = [];

  Map<String, String> _requestHeaders = {'Accept': 'application/json'};


  Future<String> getServerIP() async {
    final prefs = await SharedPreferences.getInstance();
    String tmpServer = prefs.get("serverIP");
    return tmpServer ?? _serverIP;
  }

  Future<void> setServerIP(newIP) async {
    _serverIP = newIP;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("serverIP", _serverIP);
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
       final prefs = await SharedPreferences.getInstance();
      _requests = [];
      if(_requestHeaders['token']==null || _requestHeaders['userType']==null) await initHeaders();
      if(_serverIP==null) _serverIP = prefs.get("serverIP");
      var response =
          await http.get(_serverInit + _serverIP + _serverExt + _requestsExt, headers: _requestHeaders);
      if (response.statusCode == 200) {
        final cleanRequests = cleanResponse(response.body);
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
      TruckRequest tmp ;
      final prefs = await SharedPreferences.getInstance();
      if(_requestHeaders['token']==null || _requestHeaders['userType']==null) await initHeaders();
      if(_serverIP==null) _serverIP = prefs.get("serverIP");
      var response =
          await http.post(_serverInit + _serverIP + _serverExt + _requestsDet, 
          headers: _requestHeaders, body: {"RequestID":id});
      if (response.statusCode == 200) {
        final cleanRequests = cleanResponse(response.body);
        final decoded = json.decode(cleanRequests);
        tmp = TruckRequest.fromJson(decoded[0]);

        return tmp;      
      }
      return new TruckRequest();
  }

   Future<void> initHeaders() async {
     final prefs = await SharedPreferences.getInstance();
    this._requestHeaders.addAll({
      "token": prefs.get("token"),
      "userType": prefs.get("userType")
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
