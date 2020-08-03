import 'package:dio/dio.dart';
import 'package:infowindow/network/covid_client.dart';

class CovidService {
  Future<Response> getPlaceCovid() {
    return CovidClient.instance.dio.get(
      '/?status=1/',
    );
  }
}
