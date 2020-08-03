import 'package:dio/dio.dart';
import 'package:infowindow/data/spref/spref.dart';
import 'package:infowindow/shared/constant.dart';

class CovidClient {
  static BaseOptions _options = new BaseOptions(
    baseUrl: "http://gohiyo.com/api/ncovids",
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );
  static Dio _dio = Dio(_options);

  CovidClient._internal() {
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options myOption) async {
      var token = await SPref.instance.get(SPrefCache.KEY_TOKEN);
      if (token != null) {
        myOption.headers["Authorization"] = "Bearer " + token;
      }

      return myOption;
    }));
  }
  static final CovidClient instance = CovidClient._internal();

  Dio get dio => _dio;
}
