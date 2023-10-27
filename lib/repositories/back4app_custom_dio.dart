import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lista_telefonica/repositories/back4app_dio_interceptor.dart';


class Back4AppCustomDio {
  final _dio = Dio();

  Dio get dio => _dio;

  Back4AppCustomDio() {
    _dio.options.headers["Content-Type"] = "application/json";
    _dio.options.baseUrl = dotenv.env['BACK4APPBASEURL']!;

    _dio.interceptors.add(Back4AppDioInterceptor());
  }
}
