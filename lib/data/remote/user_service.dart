import 'package:dio/dio.dart';
import 'package:infowindow/network/covid_client.dart';

class UserService {
  Future<Response> signIn(String phone, String pass) {
    return CovidClient.instance.dio.post(
      '/user/sign-in',
      data: {
        'phone': phone,
        'password': pass,
      },
    );
  }

  Future<Response> signUp(String displayName, String phone, String pass) {
    return CovidClient.instance.dio.post(
      '/user/sign-up',
      data: {
        'displayName': displayName,
        'phone': phone,
        'password': pass,
      },
    );
  }
}
