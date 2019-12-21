import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'dart:async';

const GOOGLE_API_KEY = 'AIzaSyBr2lVmpumJPZLCk3VffDODha5TPZ_4H9k';
GoogleMapController controller;
String from = "From";
String to = "To";
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

class MapScreen extends StatefulWidget {
  static String routeName = "MapScreen";

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
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
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/track_icon.png', 70);
    // BitmapDescriptor truckIcon;

    // BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
    //         'assets/images/track_icon.png')
    //     .then((onValue) {
    //   truckIcon = onValue;
    // });
    MarkerId markerIdFrom = MarkerId(from);
    LatLng fromPosition = LatLng(30.017278, 31.455757);
    Marker marker1 = Marker(
      markerId: markerIdFrom,
      position: fromPosition,
      infoWindow: InfoWindow(
        title: from,
        snippet: 'AAA a AA ',
      ),
    );

    MarkerId markerIdTo = MarkerId(to);
    LatLng toPosition = LatLng(30.025459, 31.495579);
    Marker marker2 = Marker(
      markerId: markerIdTo,
      position: toPosition,
      infoWindow: InfoWindow(
        title: to,
        snippet: 'BB BBBBB  BB B ',
      ),
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );

    setState(() {
      markers[markerIdFrom] = marker1;
      markers[markerIdTo] = marker2;
    });

    LatLngBounds bound =
        LatLngBounds(southwest: fromPosition, northeast: toPosition);
    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    controller.animateCamera(u2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: Text('Name'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text('From'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Place From'),
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
                    child: Text('To'),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Place To'),
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