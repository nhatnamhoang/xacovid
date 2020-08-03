
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infowindow/data/remote/covid_service.dart';
import 'package:infowindow/shared/model/covid_data.dart';

class CovidRepo {
  CovidService _covidService;

  CovidRepo({@required CovidService covidService}) : _covidService = covidService;

  Future<List<CovidData>> getPlaceHaveCovid() async {
    var c = Completer<List<CovidData>>();
    try {
      var response = await _covidService.getPlaceCovid();
      var productList = CovidData.parsePlacesList(response.data);
      c.complete(productList);
    } on DioError {
      c.completeError('Lấy dữ liệu covid không thành công ');
    } catch (e) {
      c.completeError(e);
    }
    return c.future;
  }

}
