import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/location.dart';
import '../models/driver.dart';
import '../models/model.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import "package:http/http.dart" as http;

class FormDataProvider with ChangeNotifier {

  static final String _serverInit = "http://";
  static String _serverIP   = "3.121.234.234";
  static String _serverExt = "/motorcity/api/" ;
  static final String _driversReqUrl = 'get/drivers';
  static final String _locationsReqUrl = 'locations';
  static final String _modelsReqUrl = 'get/models';

  List<Location> locations = [];
  List<Driver> drivers = [];
  List<Model> models = [];

  Map<String, String> _requestHeaders = {'Accept': 'application/json'};

  Future<String> getServerIP() async {
    String tmpServer = await FlutterKeychain.get(key: "serverIP");
    return tmpServer ?? _serverIP;
  }

  Future<bool> loadDrivers() async {
    drivers = [];
    try{
      
      if(_requestHeaders['token']==null || _requestHeaders['userType']==null) await initHeaders();
      if(_serverIP==null) _serverIP = await FlutterKeychain.get(key: "serverIP");

      final request = await http.get(_serverInit + _serverIP + _serverExt + _driversReqUrl, headers: _requestHeaders);
      if(request.statusCode == 200){
        final cleanedResponse = cleanResponse(request.body);
        final Iterable decoded = jsonDecode(cleanedResponse);
        decoded.forEach((driver){
          drivers.add(new Driver(driver['DRVR_ID'], driver['DRVR_NAME']));
        });
        notifyListeners();
        return true;
      } else {
        return false;
      }     
    }catch (e){
      log(e.toString());
      return false;
    }
  }

  Future<bool> loadLocations() async {
    locations = [];
    try{
      
      if(_requestHeaders['token']==null || _requestHeaders['userType']==null) await initHeaders();
      if(_serverIP==null) _serverIP = await FlutterKeychain.get(key: "serverIP");

      var request = await http.get(_serverInit + _serverIP + _serverExt + _locationsReqUrl, headers: _requestHeaders);
      if(request.statusCode == 200){
        final cleanedResponse = cleanResponse(request.body);
        final Iterable decoded = jsonDecode(cleanedResponse);
        decoded.forEach((location){
          locations.add(new Location(id: location['LOCT_ID'], name: location['LOCT_NAME'], latt: location['LOCT_LATT'], long: location['LOCT_LONG']));
        });
        notifyListeners();
        return true;
      } else {
        return false;
      }     
    }catch (e){
      return false;
    }
  }

    Future<bool> loadModels() async {
    drivers = [];
    try{
      
      if(_requestHeaders['token']==null || _requestHeaders['userType']==null) await initHeaders();
      if(_serverIP==null) _serverIP = await FlutterKeychain.get(key: "serverIP");

      var request = await http.get(_serverInit + _serverIP + _serverExt + _modelsReqUrl, headers: _requestHeaders);
      if(request.statusCode == 200){
        final cleanedResponse = cleanResponse(request.body);
        final Iterable decoded = jsonDecode(cleanedResponse);
        decoded.forEach((model){
          models.add(new Model( model['TRMD_ID'], model['TRMD_NAME']));
        });
        notifyListeners();
        return true;
      } else {
        return false;
      }     
    }catch (e){
      return false;
    }
  }

  Location getLocationByID(String id){
    Location retLocation = new Location(id: '0', name: 'N/A', latt: '0', long: '0');
    locations.forEach((loct){
      if(loct.id==id)retLocation=loct;
    });
    return retLocation;
  }

  Future<void> initHeaders() async {
    this._requestHeaders.addAll({
      "token": await FlutterKeychain.get(key: "token"),
      "userType": await FlutterKeychain.get(key: "userType")
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