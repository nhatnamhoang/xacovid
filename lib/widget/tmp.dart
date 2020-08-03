import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infowindow/shared/model/pin_pill_info.dart';
import 'package:infowindow/widget/list_place_covid.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:async';

const double CAMERA_ZOOM = 18;
const double CAMERA_TILT = 60;
const double CAMERA_BEARING = 10;
const LatLng SOURCE_LOCATION = LatLng(10.798945, 106.633615);
const LatLng DEST_LOCATION = LatLng(10.798945, 106.633615);

void main() =>
    runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MapPage()));

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = 'AIzaSyDjyy02-1tkbG8oXa38zzdpb00jjOYxF_8';
// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;
  bool onFocus = false;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();

    // create an instance of Location
    location = new Location();
    polylinePoints = PolylinePoints();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      updatePinOnMap();
    });
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0), 'assets/current.png')
        .then((onValue) {
      sourceIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
        'assets/covid.png')
        .then((onValue) {
      destinationIcon = onValue;
    });
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": DEST_LOCATION.latitude,
      "longitude": DEST_LOCATION.longitude
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
              minHeight: onFocus == false ? h * 0.2 : 0,
              maxHeight: MediaQuery.of(context).size.height * 0.80,
              //parallaxEnabled: true,
              // parallaxOffset: 0.5,
              backdropEnabled: true,
              backdropOpacity: 0.2,
              backdropTapClosesPanel: true,
              isDraggable: true,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[400], blurRadius: 4, offset: Offset(1, 0))
              ],
              padding: EdgeInsets.only(top: 15, left: 10, bottom: 0, right: 10),
              panel: _renderPanelUI(),
              body: _renderMap()),
        ],
      ),
    );
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
    LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
    LatLng(destinationLocation.latitude, destinationLocation.longitude);

    sourcePinInfo = PinInformation(
        locationName: "Start Location",
        location: SOURCE_LOCATION,
        pinPath: "assets/covid.png",
        avatarPath: "assets/friend1.jpg",
        labelColor: Colors.blueAccent);

    destinationPinInfo = PinInformation(
        locationName: "End Location",
        location: DEST_LOCATION,
        pinPath: "assets/covid.png",
        avatarPath: "assets/friend2.jpg",
        labelColor: Colors.purple);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    //  setPolylines();
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        currentLocation.latitude,
        currentLocation.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude);

    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color(0xffbe4442),
            points: polylineCoordinates));
      });
    }
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
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

      sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }

  Widget getDealListView() {
    var hotelList = HotelListData.hotelList;
    List<Widget> list = List<Widget>();
    hotelList.forEach((f) {
      list.add(
        HotelListView(
          callback: () {

          },
        //  hotelData: f,
        ),
      );
    });
    return Container(
      height: MediaQuery.of(context).size.height*0.6,
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
            child: Container(
              child: Text('Danh sách các khu vực có Covid-19', style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff3f3f3f),
              ),),
            ),
          ),
          Column(
            children: list,
          ),
        ],
      ),
    );
  }


  Widget _renderPanelUI() {
    return Column(
      children: [
        Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
        ),
        SizedBox(height: 15,),
        Container(
          child: Text('Cảnh báo', style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Color(0xffbe4442),
          ),),
        ),
        SizedBox(height: 10,),
        Container(
          child: Text('Chung cư Lạc Long Quân Quận 11 .. ' , style: TextStyle(
            fontSize: 16,
            color: Color(0xff3f3f3f),
            fontWeight: FontWeight.w400,
          ),),
        ),
        SizedBox(height: 10,),
        Container(
          child: Text('2,4 KM ', style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Color(0xffd9a953),
          ),),
        ),
        SizedBox(height: 10,),
        Divider(
          color: Colors.grey[300],
        ),
        getDealListView()
      ],
    );
  }

  Widget _renderMap() {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        tiltGesturesEnabled: false,
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
        initialCameraPosition: initialCameraPosition,
        onTap: (LatLng loc) {
          pinPillPosition = -100;
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          // my map has completed being created;
          // i'm ready to show the pins on the map
          showPinsOnMap();
        });
  }
}

//class Utils {
//  static String mapStyles = '''[
//  {
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#f5f5f5"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.icon",
//    "stylers": [
//      {
//        "visibility": "off"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#616161"
//      }
//    ]
//  },
//  {
//    "elementType": "labels.text.stroke",
//    "stylers": [
//      {
//        "color": "#f5f5f5"
//      }
//    ]
//  },
//  {
//    "featureType": "administrative.land_parcel",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#bdbdbd"
//      }
//    ]
//  },
//  {
//    "featureType": "poi",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#eeeeee"
//      }
//    ]
//  },
//  {
//    "featureType": "poi",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#757575"
//      }
//    ]
//  },
//  {
//    "featureType": "poi.park",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#e5e5e5"
//      }
//    ]
//  },
//  {
//    "featureType": "poi.park",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  },
//  {
//    "featureType": "road",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#ffffff"
//      }
//    ]
//  },
//  {
//    "featureType": "road.arterial",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#757575"
//      }
//    ]
//  },
//  {
//    "featureType": "road.highway",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#dadada"
//      }
//    ]
//  },
//  {
//    "featureType": "road.highway",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#616161"
//      }
//    ]
//  },
//  {
//    "featureType": "road.local",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  },
//  {
//    "featureType": "transit.line",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#e5e5e5"
//      }
//    ]
//  },
//  {
//    "featureType": "transit.station",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#eeeeee"
//      }
//    ]
//  },
//  {
//    "featureType": "water",
//    "elementType": "geometry",
//    "stylers": [
//      {
//        "color": "#c9c9c9"
//      }
//    ]
//  },
//  {
//    "featureType": "water",
//    "elementType": "labels.text.fill",
//    "stylers": [
//      {
//        "color": "#9e9e9e"
//      }
//    ]
//  }
//]''';
//}
