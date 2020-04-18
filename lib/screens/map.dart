import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../providers/requests.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:motorcity_tracking/models/truckrequest.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

//Map Configuration Variables
const GOOGLE_API_KEY = 'AIzaSyBr2lVmpumJPZLCk3VffDODha5TPZ_4H9k';
const DISTANCE_TIME_GOOGLE_API_KEY = 'AIzaSyAN3Ba5-MW6y8g2eyL57Ls9IFDDC9mwf8E';
GoogleMapController controller;

//Request Variables
TruckRequest _truckRequest;
String _id;
String _driverID;

//Tracking Variables
double truckLat = 0;
double truckLng = 0;
double fromLat = 0;
double fromLng = 0;
double toLat = 0;
double toLng = 0;
String truckMarkerStr = "truck";
LatLng truckMarkerPosition = LatLng(truckLat, truckLng);
Marker truckMarker;
MarkerId truckMarkerID = MarkerId('$truckMarkerStr');
MarkerId fromMarkerID = MarkerId("from");
MarkerId toMarkerID = MarkerId("to");
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

//bottom sheet flag
bool _bottomSheetVisible = false;
bool firstOpen = true;

class MapScreen extends StatefulWidget {
  static String routeName = "MapScreen";

  MapScreen(String id) {
    _id = id;
    _truckRequest = new TruckRequest();
  }

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  double parseDouble(dynamic value) {
    try {
      if (value is String) {
        return double.parse(value);
      } else if (value is double) {
        return value;
      } else {
        return 0.0;
      }
    } catch (e) {
      //print(e.toString());
      // return null if double.parse fails
      return null;
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void animateCamera() {
    double southWestLat = 100000;
    double southWestLng = 100000;
    double northEastLat = -100000;
    double northEastLng = -100000;

    markers.forEach((key, value) {
      double lat = value.position.latitude;
      if (lat != null && lat != 0) {
        if (lat < southWestLat) {
          southWestLat = lat;
        }
        if (lat > northEastLat) {
          northEastLat = lat;
        }
      }

      double lng = value.position.longitude;
      if (lng != null && lng != 0) {
        if (lng < southWestLng) {
          southWestLng = lng;
        }
        if (lng > northEastLng) {
          northEastLng = lng;
        }
      }
    });

    if (southWestLat != 100000 &&
        southWestLng != 100000 &&
        northEastLat != -100000 &&
        northEastLng != -100000) {
      LatLng southWestLatLng = LatLng(southWestLat, southWestLng);
      LatLng northEastLatLng = LatLng(northEastLat, northEastLng);
      LatLngBounds bound =
          LatLngBounds(southwest: southWestLatLng, northeast: northEastLatLng);
      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
      controller.animateCamera(u2);
    }
  }

  void setMarkers() async {
    //Initializing Request Object
    //_id = ModalRoute.of(context).settings.arguments;
    _truckRequest =
        await Provider.of<Requests>(context, listen: false).getFullRequest(_id);
    if (_truckRequest != null) {
      _driverID = _truckRequest.driverID;
      intializeTruckMarker();

      trackCarLocation();

      // BitmapDescriptor truckIcon;

      // BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
      //         'assets/images/track_icon.png')
      //     .then((onValue) {
      //   truckIcon = onValue;
      // });
      try {
        fromLat = _truckRequest.startLatt;
      } catch (e) {
        fromLat = 0;
      }

      try {
        fromLng = _truckRequest.startLong;
      } catch (e) {
        fromLng = 0;
      }
      String fromTitle = "";
      try {
        fromTitle = _truckRequest.from;
      } catch (e) {
        fromTitle = "";
      }
      LatLng fromPosition;
      try {
        fromPosition = LatLng(fromLat, fromLng);
      } catch (e) {
        fromPosition = LatLng(0, 0);
      }
      Marker markerFrom = Marker(
        markerId: fromMarkerID,
        position: fromPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: fromTitle,
        ),
      );

      try {
        toLat = _truckRequest.endLatt;
      } catch (e) {
        toLat = 0;
      }
      try {
        toLng = _truckRequest.endLong;
      } catch (e) {
        toLng = 0;
      }
      String toTitle = "";
      try {
        toTitle = _truckRequest.to;
      } catch (e) {
        toTitle = "";
      }
      LatLng toPosition;
      try {
        toPosition = LatLng(toLat, toLng);
      } catch (e) {
        toPosition = LatLng(0, 0);
      }
      Marker markerTo = Marker(
        markerId: toMarkerID,
        position: toPosition,
        infoWindow: InfoWindow(
          title: toTitle,
        ),
      );

      setState(() {
        try {
          markers[fromMarkerID] = markerFrom;
        } catch (e) {}
        try {
          markers[toMarkerID] = markerTo;
        } catch (e) {}

        try {
          animateCamera();
        } catch (e) {}
      });
    }
  }

  void intializeTruckMarker() async {
    final Uint8List trackIcon =
        await getBytesFromAsset('assets/images/track_icon.png', 70);
    try {
      truckMarker = Marker(
        markerId: truckMarkerID,
        position: truckMarkerPosition,
        infoWindow: InfoWindow(
          title: "${_truckRequest.driverName}",
        ),
        icon: BitmapDescriptor.fromBytes(trackIcon),
      );
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    markers.clear();
  }

  void trackCarLocation() {
    FirebaseDatabase fbdb = FirebaseDatabase.instance;
    DatabaseReference dbrLat = fbdb
        .reference()
        .child('locations')
        .reference()
        .child('$_driverID')
        .reference()
        .child('lat');
    dbrLat.onValue.listen((Event event) {
      truckLat = parseDouble(event.snapshot.value.toString());
      if (truckLat != null) {
        truckMarkerPosition = LatLng(truckLat, truckLng);
        Marker truckMarker2 =
            truckMarker.copyWith(positionParam: truckMarkerPosition);
        if (mounted) {
          updateDistanceAndTime(truckLat, truckLng);
          setState(() {
            markers[truckMarkerID] = truckMarker2;
          });
        }
      }
    });

    DatabaseReference dbrLng = fbdb
        .reference()
        .child('locations')
        .reference()
        .child('$_driverID')
        .reference()
        .child('lng');
    dbrLng.onValue.listen((Event event) {
      truckLng = parseDouble(event.snapshot.value.toString());
      if (truckLng != null) {
        truckMarkerPosition = LatLng(truckLat, truckLng);
        Marker truckMarker2 =
            truckMarker.copyWith(positionParam: truckMarkerPosition);
        if (mounted) {
          updateDistanceAndTime(truckLat, truckLng);
          setState(() {
            markers[truckMarkerID] = truckMarker2;
          });
        }
      }
    });
  }

  void updateDistanceAndTime(double truckLat, double truckLng) {
    if (_bottomSheetVisible && firstOpen) {
      if (truckLat != 0 && truckLng != 0) {
        _truckRequest.fillTimeDistance(truckLat, truckLng);
        firstOpen = false;
      }
    }
  }

  //build bottom sheet
  void showBottomSheet() {
    _bottomSheetVisible = true;
    firstOpen = true;
  }

  void hideBottomSheet() {
    _bottomSheetVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request In Progress'),
      ),
      body: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Expanded(
            child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(30.0355, 31.2230),
            zoom: 14.4746,
          ),
          onMapCreated: (googleMapController) {
            controller = googleMapController;
            setMarkers();
          },
          markers: Set<Marker>.of(markers.values),
          myLocationButtonEnabled: false,
        )),
      ]),
      bottomSheet: SolidBottomSheet(
        onShow: showBottomSheet,
        onHide: hideBottomSheet,
        maxHeight: MediaQuery.of(context).size.height / 4,
        showOnAppear: _bottomSheetVisible,
        toggleVisibilityOnTap: true,
        headerBar: Container(
          decoration: new BoxDecoration(
              color: Color.fromRGBO(3, 45, 69, .9),
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20))),
          height: 70,
          child: Center(
            child: Text(
              "details..",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        body: Container(
          color: Color.fromRGBO(3, 45, 69, .1),
          padding: EdgeInsets.all(10),
          child: Column(children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.person_pin,
                        size: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_truckRequest.driverName}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.pin_drop,
                          size: 40,
                          color: Color.fromRGBO(0, 72, 26, 1),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${_truckRequest.from}',
                          style: TextStyle(fontSize: 15),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.pin_drop,
                          size: 40,
                          color: Color.fromRGBO(122, 0, 10, 1),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('${_truckRequest.to}',
                            style: TextStyle(fontSize: 15)),
                      )
                    ],
                  ),
                ),
              ]),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.directions_car,
                          size: 40,
                          color: Color.fromRGBO(3, 45, 69, .9),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 5,
                        child: Text(
                            '${_truckRequest.model} - ${_truckRequest.chassis}',
                            style: TextStyle(fontSize: 14)))
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.timer,
                          size: 40,
                          color: Color.fromRGBO(3, 45, 69, .9),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ValueListenableBuilder(
                          valueListenable: _truckRequest.timeStr,
                          builder: (context, value, child) {
                            return Container(
                                padding: EdgeInsets.only(top: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${_truckRequest.timeStr.value}',
                                  style: TextStyle(fontSize: 16),
                                ));
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.straighten,
                          size: 40,
                          color: Color.fromRGBO(3, 45, 69, .9),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ValueListenableBuilder(
                          valueListenable: _truckRequest.distanceStr,
                          builder: (context, value, child) {
                            return Container(
                                padding: EdgeInsets.only(top: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${_truckRequest.distanceStr.value}',
                                  style: TextStyle(fontSize: 16),
                                ));
                          },
                        ),
                      )
                    ],
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Expanded(
                //     flex: 1,
                //     child: ValueListenableBuilder(
                //       valueListenable: _truckRequest.distanceStr,
                //       builder: (context, value, child) {
                //         return Container(
                //             padding: EdgeInsets.only(top: 5),
                //             alignment: Alignment.centerLeft,
                //             child: Text(
                //               '${_truckRequest.timeStr.value}',
                //               style: TextStyle(fontSize: 16),
                //             ));
                //       },
                //     ),
                //   ),
                // )
              ],
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: animateCamera,
        backgroundColor: Color.fromRGBO(0, 46, 72, 0.8),
        label: Text('Re-center'),
        icon: Icon(Icons.location_on),
      ),
    );
  }
}
//  Completer<GoogleMapController> _controller = Completer();

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   static final CameraPosition _kLake = CameraPosition(
//       bearing: 192.8334901395799,
//       target: LatLng(37.43296265331129, -122.08832357078792),
//       tilt: 59.440717697143555,
//       zoom: 19.151926040649414);

// return new Scaffold(
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: _kGooglePlex,
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _goToTheLake,
//         label: Text('To the lake!'),
//         icon: Icon(Icons.directions_boat),
//       ),
//     );
//   }
