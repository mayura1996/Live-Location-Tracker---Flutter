import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';


const double CAMERA_ZOOM = 20;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

void main() =>
    runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MapPage()));

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();


  String googleAPIKey = '<Please enter your API>';

  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

  LocationData currentLocation;

  Location location;
  double pinPillPosition = -100;

  @override
  void initState() {
    super.initState();

    location = new Location();



    location.onLocationChanged().listen((LocationData cLoc) {

      currentLocation = cLoc;
      updatePinOnMap();
    });
    setSourceAndDestinationIcons();
    setInitialLocation();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void setInitialLocation() async {

    currentLocation = await location.getLocation();

  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onTap: (LatLng loc) {
                pinPillPosition = -100;
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                showPinsOnMap();
              }),
        ],
      ),
    );
  }

  void showPinsOnMap() {

    var pinPosition =
    LatLng(currentLocation.latitude, currentLocation.longitude);

    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        //position: destPosition,
        onTap: () {
          setState(() {
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon));
  }



  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,

      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
      LatLng(currentLocation.latitude, currentLocation.longitude);

      //sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.toString() == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
             // currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }
}
