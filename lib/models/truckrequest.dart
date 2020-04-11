import 'package:flutter/material.dart';
import 'package:motorcity_tracking/providers/distance_time.dart';
import 'package:motorcity_tracking/providers/requests.dart';
import 'dart:convert';

import 'package:motorcity_tracking/widgets/request.dart';

class TruckRequest {
  String id;
  String from;
  String to;
  String reqDate;
  String startDate;
  String chassis;
  String model;
  String km;
  String status;
  String comment;
  //Request In Progress additional data
  String driverName;
  double startLong;
  double startLatt;
  double endLong;
  double endLatt;
  String driverID;
  ValueNotifier timeStr= new ValueNotifier("N/A");
  ValueNotifier distanceStr= new ValueNotifier("N/A");

  TruckRequest(
      {id,
      from,
      to,
      reqDate,
      startDate,
      chassis,
      model,
      km,
      status,
      comment,
      startLong,
      startLatt,
      endLong,
      endLatt,
      driverName,
      distanceStr,
      timeStr}) {
    this.id = id ?? "0";
    this.from = from ?? "N/A";
    this.to = to ?? "N/A";
    this.reqDate = reqDate ?? "N/A";
    this.startDate = startDate ?? "N/A";
    this.chassis = chassis ?? "N/A";
    this.model = model ?? "N/A";
    this.km = km ?? "N/A";
    this.status = status ?? "N/A";
    this.comment = comment ?? "N/A";
    this.startLong = (startLong != null) ? double.parse(startLong) : 0;
    this.startLatt = (startLatt != null) ? double.parse(startLatt) : 0;
    this.endLong = (endLong != null) ? double.parse(endLong) : 0;
    this.endLatt = (endLatt != null) ? double.parse(endLatt) : 0;
    this.driverID = driverID ?? "N/A";
    this.driverName = driverName ?? "N/A";
  }

  TruckRequest.fromJson(Map<String, dynamic> response) {
    try {
      print("A");
      this.id = response['TKRQ_ID'];
      this.from = response['TKRQ_STRT_LOC'] ?? "N/A";
      this.to = response['TKRQ_END_LOC'] ?? "N/A";
      this.reqDate = response['TKRQ_INSR_DATE'] ?? "N/A";
      this.startDate = response['TKRQ_STRT_DATE'] ?? "N/A";
      this.chassis = response['TKRQ_CHSS'] ?? "N/A";
      this.model = response['TRMD_NAME'] ?? "N/A";
      this.km = response['TKRQ_KM'] ?? "N/A";
      this.comment = response['TKRQ_CMNT'] ?? "";
      this.status = response['TKRQ_STTS'] ?? "N/A";
      this.driverName = response['DRVR_NAME'] ?? "N/A";
      this.driverID = response['DRVR_ID'] ?? "N/A";
      this.startLong = (response['TKRQ_STRT_LONG'] != null) ?  double.parse(response['TKRQ_STRT_LONG']) : 0;
      this.startLatt = (response['TKRQ_STRT_LATT']!= null) ?  double.parse(response['TKRQ_STRT_LATT']) : 0;
      this.endLong = (response['TKRQ_END_LONG']!= null) ?  double.parse(response['TKRQ_END_LONG']) : 0;
      this.endLatt =(response['TKRQ_END_LATT']!= null) ?   double.parse(response['TKRQ_END_LATT']) : 0;
      if(this.startLong != 0 && this.startLatt!=0 && this.endLatt != 0 && this.endLong != 0)
        fillTimeDistance();
    } catch (e) {
      return;
    }
  }

  Future<void> fillTimeDistance() async {
    dynamic distanceTimeReqBodyJson;
    await GoogleDistanceTime.getResponse(startLatt, startLong, endLatt, endLong)
        .then((value) {
      if (value != "") {
        String cleanValue = Requests.cleanResponse(value);
        distanceTimeReqBodyJson = jsonDecode(cleanValue);

        this.timeStr.value = distanceTimeReqBodyJson["rows"][0]["elements"][0]
            ["distance"]["text"];
        this.distanceStr.value = distanceTimeReqBodyJson["rows"][0]["elements"][0]
            ["duration"]["text"];

        print("Time : ${this.timeStr.value}");
        print("Distance : ${this.distanceStr.value}");
      }
    });
  }
}
