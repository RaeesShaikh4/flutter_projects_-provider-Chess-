import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String? message;
  ApiException({required this.message});

  @override
  String toString() => message ?? 'ApiException';
}

class BadRequestException extends ApiException {
  BadRequestException({String? message}) : super(message: message);
}

class UnaauthorisedException extends ApiException {
  UnaauthorisedException({String? message}) : super(message: message);
}

class FetchDataException extends ApiException {
  FetchDataException({String? message}) : super(message: message);
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException({String? message}) : super(message: message);
}

class ApiErrorHandler {
  static Exception handleError(error) {
    if (error is DioException) {
      final e = error.response;
      switch (e?.statusCode) {
        case 400:
          return BadRequestException(message: e?.data);
        case 401:
          return UnaauthorisedException(message: e?.data);
        case 500:
          return InternalServerErrorException(message: e?.data);
        default:
          return ApiException(message: e?.data ?? 'Something went wrong');
      }
    } else {
      return ApiException(message: error.toString());
    }
  }
}
