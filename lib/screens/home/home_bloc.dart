import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:infowindow/base/base_bloc.dart';
import 'package:infowindow/base/base_event.dart';
import 'package:infowindow/data/repo/covid_repo.dart';
import 'package:infowindow/shared/model/covid_data.dart';
import 'package:infowindow/shared/model/pin_pill_info.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class Validation {
  static isEmptyValid(String name) {
    return name.length > 0;
  }
}


class HomeBloc extends BaseBloc with ChangeNotifier {
  LocationData _locationData;
  Set<Marker> _markers = Set<Marker>();
  PinInformation _sourcePinInfo;
  LocationData _currentLocation;
  BitmapDescriptor _sourceIcon;
  BitmapDescriptor _destinationIcon;
  List<CovidData> _listCovidData;
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> _polylineCoordinates = [];
  PolylinePoints _polylinePoints = new PolylinePoints();
  String googleAPIKey = 'AIzaSyDjyy02-1tkbG8oXa38zzdpb00jjOYxF_8';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();


  PinInformation _currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  double _pinPillPosition = -100;

  final _covidListStreamController = BehaviorSubject<List<CovidData>>();
  Stream<List<CovidData>> get covidListStream => _covidListStreamController.stream;
  Sink<List<CovidData>> get covidListSink => _covidListStreamController.sink;

  @override
  void dispose() {
    super.dispose();
    _covidListStreamController.close();
  }


  PolylinePoints get polylinePoints => _polylinePoints;
  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  List<CovidData> get listCovidData => _listCovidData;
  Set<Polyline> get polylines => _polylines;
  LocationData get currentLocation => _currentLocation;
  LocationData get locationData => _locationData;
  Set<Marker> get markers => _markers;
  PinInformation get sourcePinInfo => _sourcePinInfo;


  void setSourceIcons() async {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0), 'assets/current.png')
        .then((onValue) {
      _sourceIcon = onValue;
    });
  }


  void setDestinationsIcon() async {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(30,30)), 'assets/covid.png')
        .then((onValue) {
      _destinationIcon = onValue;
    });
  }

  void setCovidData(value) {
    _listCovidData = value;
  }

  void setCurrentLocation(value) {
    _currentLocation = value;
  }


  void setPolyline(latitude, longitude, polyID) async {
    List<PointLatLng> result = await _polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        _currentLocation.latitude,
        _currentLocation.longitude,
        latitude,
        longitude);

    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        _polylineCoordinates
            .add(LatLng(point.latitude, point.longitude));
      });

      _polylines.add(Polyline(
          width: 5, // set the width of the polylines
          polylineId: PolylineId(polyID),
          color: Color(0xffbe4442),
          points: _polylineCoordinates));
    }
    notifyListeners();
  }

  void addListDestinationMarkder() {
    _listCovidData.forEach((element) {
      _markers.add(Marker(
          markerId: MarkerId(element.id.toString()),
          position: LatLng(element.latitude, element.longitude),
          infoWindow: InfoWindow(
              title: element.address,
              snippet: element.province
          ),
          onTap: () {
          },
          icon: _destinationIcon));
    });
    notifyListeners();
  }

  void setLocation(LocationData value) {
    _locationData = value;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getListCovidData() async {
    if(_currentLocation.latitude != null) {
      Stream<List<CovidData>>.fromFuture(_covidRepo.getPlaceHaveCovid()).listen(
              (listCovidData) {
            listCovidData.forEach((element) {
              double distanceKM = _coordinateDistance(
                _currentLocation.latitude,
                _currentLocation.longitude,
                element.latitude,
                element.longitude,
              );
              element.distance = distanceKM;
              print(element.distance);
            });
            listCovidData.sort((a, b) {
              return a.distance.compareTo(b.distance);
            });
            _listCovidData = listCovidData;
            covidListSink.add(listCovidData);
          }, onError: (err) {
        print(err);
      });
    }
  }

  static HomeBloc _instance;
  CovidRepo _covidRepo;

  static HomeBloc getInstance({
    @required CovidRepo covidRepo,
  }) {
    if (_instance == null) {
      _instance = HomeBloc._internal(
        covidRepo: covidRepo,
      );
    }
    return _instance;
  }

  HomeBloc._internal({
    @required CovidRepo covidRepo,
  })  : _covidRepo = covidRepo;



  @override
  void dispatchEvent(BaseEvent event) {
    switch (event.runtimeType) {

    }
  }

}
