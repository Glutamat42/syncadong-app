import 'package:dio/dio.dart';

class RequestHelper {
  static Dio initDio({String contentType = 'application/json'}) {
    BaseOptions options = new BaseOptions(
        baseUrl: 'http://192.168.110.245:8000/',
        connectTimeout: 5000,
        receiveTimeout: 5000,
        validateStatus: (status) {
          return status <= 599;
        });
    Dio _dio = Dio(options);
    _dio.interceptors
      ..add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        options.headers = {
          'Content-Type': contentType,
        };
        return options;
      }, onResponse: (Response response) {
        return response;
      }));
    return _dio;
  }
}
