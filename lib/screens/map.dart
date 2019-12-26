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

//Map Configuration Variables
const GOOGLE_API_KEY = 'AIzaSyDvOMFh-AzpZJP-knXdYq551uNO_19Zp2A<'; //AIzaSyAledESPK4L-85edzOdydEohODjWgqZd2Q

GoogleMapController controller;

//Request Variables
TruckRequest _truckRequest; 
String _id ; 
String _driverID;


//Tracking Variables
double truckLat = 0;
double truckLng = 0;
String truckMarkerStr = "truck";
LatLng truckMarkerPosition = LatLng(truckLat, truckLng);
Marker truckMarker;
MarkerId truckMarkerID = MarkerId('$truckMarkerStr');
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};


class MapScreen extends StatefulWidget {
  static String routeName = "MapScreen";

  MapScreen() {
    _truckRequest = new TruckRequest();
  }

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {

  //Initializing truck request object holding all the request data

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void setMarkers() async {
      //Initializing Request Object
    _id = ModalRoute.of(context).settings.arguments;
    _truckRequest = await Provider.of<Requests>(context).getFullRequest(_id);
    _driverID = "1";

    final Uint8List trackIcon =
        await getBytesFromAsset('assets/images/track_icon.png', 70);
    // BitmapDescriptor truckIcon;

    // BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
    //         'assets/images/track_icon.png')
    //     .then((onValue) {
    //   truckIcon = onValue;
    // });
    MarkerId markerIdFrom = MarkerId(_truckRequest.from);

    LatLng fromPosition = LatLng(_truckRequest.startLatt, _truckRequest.startLong);
    Marker marker1 = Marker(
      markerId: markerIdFrom,
      position: fromPosition,
      infoWindow: InfoWindow(
        title: _truckRequest.from,
      ),
    );

    MarkerId markerIdTo = MarkerId(_truckRequest.to);
    LatLng toPosition = LatLng(_truckRequest.endLatt, _truckRequest.endLong);
    Marker marker2 = Marker(
      markerId: markerIdTo,
      position: toPosition,
      infoWindow: InfoWindow(
        title: _truckRequest.to,
      ),
    );

    truckMarker = Marker(
      markerId: truckMarkerID,
      position: truckMarkerPosition,
      infoWindow: InfoWindow(
        title: "Truck Pos.",
      ),
      icon: BitmapDescriptor.fromBytes(trackIcon),
    );

    setState(() {
      markers[markerIdFrom] = marker1;
      markers[markerIdTo] = marker2;
      markers[truckMarkerID] = truckMarker;
    });

    LatLngBounds bound =
        LatLngBounds(southwest: toPosition, northeast: fromPosition);
    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    controller.animateCamera(u2);
  }

  void trackCarLocation() {
    FirebaseDatabase fbdb = FirebaseDatabase.instance;
    DatabaseReference dbr = fbdb
        .reference()
        .child('locations')
        .reference()
        .child('$_driverID')
        .reference()
        .child('lat');
    dbr.onValue.listen((Event event) {
      setState(() {
        truckLat = double.parse(event.snapshot.value.toString());
        LatLng truckMarkerPosition = LatLng(truckLat, truckLng);
        Marker truckMarker2 =
            truckMarker.copyWith(positionParam: truckMarkerPosition);

        // print("lat : $truckLat");
        markers[truckMarkerID] = truckMarker2;
      });
    });

    DatabaseReference dbr2 = fbdb
        .reference()
        .child('locations')
        .reference()
        .child('$_driverID')
        .reference()
        .child('lng');
    dbr2.onValue.listen((Event event) {
      setState(() {
        truckLng = double.parse(event.snapshot.value.toString());
        // print("lng : $truckLng");
        LatLng truckMarkerPosition = LatLng(truckLat, truckLng);
        Marker truckMarker2 =
            truckMarker.copyWith(positionParam: truckMarkerPosition);

        markers[truckMarkerID] = truckMarker2;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request In Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: Text('${_truckRequest.driverName}'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text('Start:', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('${_truckRequest.from}'),
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
                    child: Text('End:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('${_truckRequest.to}'),
                  )
                ],
              ),
            ),
            Expanded(
                flex: 8,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(30.0355, 31.2230),
                    zoom: 14.4746,
                  ),
                  onMapCreated: (googleMapController) {
                    controller = googleMapController;
                    setMarkers();
                    trackCarLocation();
                  },
                  markers: Set<Marker>.of(markers.values),
                ))
          ],
        ),
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
