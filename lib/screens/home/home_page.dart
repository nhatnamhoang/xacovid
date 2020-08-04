import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infowindow/base/base_event.dart';
import 'package:infowindow/base/base_widget.dart';
import 'package:infowindow/data/remote/covid_service.dart';
import 'package:infowindow/data/repo/covid_repo.dart';
import 'package:infowindow/screens/home/home_bloc.dart';
import 'package:infowindow/shared/model/covid_data.dart';
import 'package:infowindow/shared/model/rest_error.dart';
import 'package:infowindow/shared/widget/bloc_listener.dart';
import 'package:infowindow/shared/widget/scale_animation.dart';
import 'package:infowindow/widget/list_place_covid.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      di: [
        Provider.value(
          value: CovidService(),
        ),
        ProxyProvider<CovidService, CovidRepo>(
          update: (context, covidService, previous) =>
              CovidRepo(covidService: covidService),
        ),
      ],
      bloc: [],
      child: PlaceCovidContiner(),
    );
  }
}

class PlaceCovidContiner extends StatelessWidget {
  handleEvent(BaseEvent event) {}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: HomeBloc.getInstance(
        covidRepo: Provider.of(context),
      ),
      child: Consumer<HomeBloc>(
        builder: (context, bloc, child) => BlocListener<HomeBloc>(
          listener: handleEvent,
          child: PlacesCovidListWidget(bloc),
        ),
      ),
    );
  }
}

class PlacesCovidListWidget extends StatefulWidget {
  HomeBloc homeBloc;
  PlacesCovidListWidget(this.homeBloc);

  @override
  _PlacesCovidListWidgetState createState() => _PlacesCovidListWidgetState();
}

class _PlacesCovidListWidgetState extends State<PlacesCovidListWidget> {
  Location location;
  double CAMERA_ZOOM = 13;
  double CAMERA_TILT = 60;
  double CAMERA_BEARING = 10;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _mapController;
  PanelController _pc = new PanelController();
  bool onFocus = false;
  LatLng SOURCE_LOCATION = LatLng(10.798945, 106.633615);
  BitmapDescriptor sourceIcon;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = Set<Polyline>();
  double zoomVal=5.0;

  @override
  void initState() {
    super.initState();
    // create an instance of Location
    location = new Location();
    widget.homeBloc.polylinePoints;
    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event


    // set custom marker pins
    widget.homeBloc.setDestinationsIcon();
    // set the initial location
    _checkPermisstionAndGetCurrentLocation();
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    widget.homeBloc.setSourceIcons();
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    var pinPosition =
    LatLng(widget.homeBloc.currentLocation.latitude, widget.homeBloc.currentLocation.longitude);

    // the trick is to remove the marker (by id)
    // and add it again at the updated location
    widget.homeBloc.markers.removeWhere((m) => m.markerId.value == 'sourcePin');
    widget.homeBloc.markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        onTap: () {
        },
        position: pinPosition, // updated position
        icon: widget.homeBloc.sourceIcon));
  }

  _checkPermisstionAndGetCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }


    location.onLocationChanged.listen((LocationData cLoc) {
      widget.homeBloc.setLocation(cLoc);
      print(cLoc);
      updatePinOnMap();
    });
    setInitialLocation();
  }

  void setInitialLocation() async {
    var currentLocation = await location.getLocation();
    widget.homeBloc.setCurrentLocation(currentLocation);
    widget.homeBloc.getListCovidData();
  }


  Widget _zoomminusfunction() {

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(top: 50),
        child: IconButton(
            icon: Icon(FontAwesomeIcons.searchMinus,color:Color(0xff6200ee)),
            onPressed: () {
              zoomVal--;
              _minus( zoomVal);
            }),
      ),
    );
  }

  Widget _zoomplusfunction() {

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.only(top: 50),
        child: IconButton(
            icon: Icon(FontAwesomeIcons.searchPlus,color:Color(0xff6200ee)),
            onPressed: () {
              zoomVal++;
              _plus(zoomVal);
            }),
      ),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(widget.homeBloc.currentLocation.latitude, widget.homeBloc.currentLocation.longitude), zoom: zoomVal)));
  }
  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(widget.homeBloc.currentLocation.latitude, widget.homeBloc.currentLocation.longitude), zoom: zoomVal)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }


  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Consumer<HomeBloc>(
        builder: (context, bloc, child) => Container(
          child: StreamProvider<Object>.value(
            value: bloc.covidListStream,
            initialData: null,
            catchError: (context, error) {
              return error;
            },
            child: Consumer<Object>(
              builder: (context, data, child) {
                if (data == null) {
                  return Center(
                    child: ScaleAnimation(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: new BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: SpinKitPouringHourglass(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }

                if (data is RestError) {
                  return Center(
                    child: Container(
                      child: Text(
                        data.message,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    SlidingUpPanel(
                        minHeight: onFocus == false ? h * 0.2 : 0,
                        maxHeight: MediaQuery.of(context).size.height * 0.80,
                        //parallaxEnabled: true,
                        // parallaxOffset: 0.5,
                        backdropEnabled: true,
                        backdropOpacity: 0.2,
                        backdropTapClosesPanel: true,
                        isDraggable: true,
                        controller: _pc,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey[400],
                              blurRadius: 4,
                              offset: Offset(1, 0))
                        ],
                        padding: EdgeInsets.only(
                            top: 15, left: 10, bottom: 0, right: 10),
                        panel: _renderPanelUI(data),
                        body: _renderMap()),
                    _zoomminusfunction(),
                    _zoomplusfunction(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ));
  }

  Widget _renderPanelUI(List<CovidData> data) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          child: Text(
            'Cảnh báo',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Color(0xffbe4442),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            child: Text(
              data[0].address,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff3f3f3f),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            child: Text(
              '${data[0].distance.toStringAsFixed(3)} km',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Color(0xffd9a953),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          color: Colors.grey[300],
        ),
        getDealListView(data)
      ],
    );
  }

  Widget getDealListView(List<CovidData> places) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
            child: Container(
              child: Text(
                'Danh sách các khu vực có Covid-19',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff3f3f3f),
                ),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return HotelListView(
                    callback: () {
                      widget.homeBloc.polylineCoordinates.clear();
                      widget.homeBloc.polylines.clear();
                      widget.homeBloc.setPolyline(places[index].latitude,
                          places[index].longitude, places[index].id.toString());
                      _pc.close();
                      _mapController.showMarkerInfoWindow(
                          MarkerId(places[index].id.toString()));
                      _gotoLocation(
                          places[index].latitude, places[index].longitude);
                    },
                    covidData: places[index],
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget _renderMap() {
    CameraPosition initialCameraPosition =
        CameraPosition(zoom: CAMERA_ZOOM, target: SOURCE_LOCATION);
    if (widget.homeBloc.currentLocation != null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(widget.homeBloc.currentLocation.latitude,
            widget.homeBloc.currentLocation.longitude),
        zoom: CAMERA_ZOOM,
      );
    }
    return GoogleMap(
        myLocationEnabled: true,
        //compassEnabled: true,
        //tiltGesturesEnabled: false,
        polylines: widget.homeBloc.polylines,
        markers: widget.homeBloc.markers,
        mapType: MapType.normal,
        initialCameraPosition: initialCameraPosition,
        onTap: (LatLng loc) {
          //pinPillPosition = -100;
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _mapController = controller;
          // my map has completed being created;
          // i'm ready to show the pins on the map
          widget.homeBloc.addListDestinationMarkder();
        });
  }
}
