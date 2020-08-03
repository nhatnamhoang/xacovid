import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:infowindow/base/base_event.dart';
import 'package:infowindow/base/base_widget.dart';
import 'package:infowindow/data/remote/covid_service.dart';
import 'package:infowindow/data/repo/covid_repo.dart';
import 'package:infowindow/screens/home/home_bloc.dart';
import 'package:infowindow/shared/widget/bloc_listener.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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
      child: SplashScreenContainer(),
    );;
  }
}


class SplashScreenContainer extends StatefulWidget {
  @override
  _SplashScreenContainerState createState() => _SplashScreenContainerState();
}

class _SplashScreenContainerState extends State<SplashScreenContainer> {
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
          child: SplashScreenWidget(bloc),
        ),
      ),
    );
  }
}


class SplashScreenWidget extends StatefulWidget {
  HomeBloc homeBloc;
  SplashScreenWidget(this.homeBloc);

  @override
  _SplashScreenWidgetState createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  Location location;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void setInitialLocation() async {
    var currentLocation = await location.getLocation();
    widget.homeBloc.setCurrentLocation(currentLocation);
  }


  _checkPermisstionAndGetCurrentLocation() async {
    Location _locationService = new Location();
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    bool serviceStatus = await _locationService.serviceEnabled();
    _permissionGranted = await _locationService.hasPermission();
    if (serviceStatus && _permissionGranted == PermissionStatus.granted) {
      _locationData = await location.getLocation();
      widget.homeBloc.setCurrentLocation(_locationData);
      _startApp();
    } else {
      AppSettings.openLocationSettings();
    }
  }


  _startApp() {
    Future.delayed(
      Duration(seconds: 3),
          () async {
//        var token = await SPref.instance.get(SPrefCache.KEY_TOKEN);
//        if (token != null) {
//          Navigator.pushReplacementNamed(context, '/home');
//          return;
//        }
//        Navigator.pushReplacementNamed(context, '/sign-in');
        Navigator.pushReplacementNamed(context, '/login');

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
            ),],
        ),
      ),
    );
  }
}

