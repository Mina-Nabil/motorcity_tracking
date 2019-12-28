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
const GOOGLE_API_KEY =
    'AIzaSyDvOMFh-AzpZJP-knXdYq551uNO_19Zp2A<'; //AIzaSyAledESPK4L-85edzOdydEohODjWgqZd2Q

GoogleMapController controller;

//Request Variables
TruckRequest _truckRequest;
String _id;
String _driverID = "1";

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

class MapScreen extends StatefulWidget {
  static String routeName = "MapScreen";

  MapScreen() {
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
    _id = ModalRoute.of(context).settings.arguments;
    _truckRequest = await Provider.of<Requests>(context).getFullRequest(_id);

    // BitmapDescriptor truckIcon;

    // BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
    //         'assets/images/track_icon.png')
    //     .then((onValue) {
    //   truckIcon = onValue;
    // });

    fromLat = _truckRequest.startLatt;
    fromLng = _truckRequest.startLong;
    LatLng fromPosition = LatLng(fromLat, fromLng);
    Marker markerFrom = Marker(
      markerId: fromMarkerID,
      position: fromPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: _truckRequest.from,
      ),
    );

    toLat = _truckRequest.endLatt;
    toLng = _truckRequest.endLong;
    LatLng toPosition = LatLng(toLat, toLng);
    Marker markerTo = Marker(
      markerId: toMarkerID,
      position: toPosition,
      infoWindow: InfoWindow(
        title: _truckRequest.to,
      ),
    );

    setState(() {
      markers[fromMarkerID] = markerFrom;
      markers[toMarkerID] = markerTo;
      animateCamera();
    });
  }

  void intializeTruckMarker() async {
    final Uint8List trackIcon =
        await getBytesFromAsset('assets/images/track_icon.png', 70);

    truckMarker = Marker(
      markerId: truckMarkerID,
      position: truckMarkerPosition,
      infoWindow: InfoWindow(
        title: "Truck Pos.",
      ),
      icon: BitmapDescriptor.fromBytes(trackIcon),
    );
  }

  @override
  void initState() {
    super.initState();
    intializeTruckMarker();
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
      setState(() {
        truckLat = parseDouble(event.snapshot.value.toString());

        if (truckLat != null) {
          truckMarkerPosition = LatLng(truckLat, truckLng);

          Marker truckMarker2 =
              truckMarker.copyWith(positionParam: truckMarkerPosition);

          markers[truckMarkerID] = truckMarker2;
          // print("Lat : $truckLat");
        }
      });
    });

    DatabaseReference dbrLng = fbdb
        .reference()
        .child('locations')
        .reference()
        .child('$_driverID')
        .reference()
        .child('lng');
    dbrLng.onValue.listen((Event event) {
      setState(() {
        truckLng = parseDouble(event.snapshot.value.toString());
        if (truckLng != null) {
          truckMarkerPosition = LatLng(truckLat, truckLng);
          Marker truckMarker2 =
              truckMarker.copyWith(positionParam: truckMarkerPosition);

          markers[truckMarkerID] = truckMarker2;
          // print("Lng : $truckLng");
        }
      });
    });
  }

  //build bottom sheet

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
                trackCarLocation();
                setMarkers();
              },
              markers: Set<Marker>.of(markers.values),
              myLocationButtonEnabled: false,
            )),
      ]),
      bottomSheet: SolidBottomSheet(
        controller: SolidController(),
        maxHeight: 200,
        showOnAppear: false,
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
                    flex: 3,
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
                        ),
                      ),
                    ), Expanded(flex: 5,
                    child: Text('${_truckRequest.model} - ${_truckRequest.chassis}', style: TextStyle(fontSize: 14) ))
                  ],
                ),
              ),
            )
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
