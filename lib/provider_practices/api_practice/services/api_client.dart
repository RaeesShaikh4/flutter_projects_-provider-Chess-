import 'package:classic_chess/provider_practices/api_practice/utils/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

const authToken = '';

class ApiClient {
  final Dio dio = Dio(BaseOptions(baseUrl: ''));

  final Map<String, String>? headers;

  ApiClient({this.headers}) {
    dio.options.headers = headers;
  }

  Future<Either<Exception, T>> _handleResponse<T>(
    Future<Response> request,
  ) async {
    try {
      final response = await request;
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;
        return right(data);
      } else {
        return Left(ApiErrorHandler.handleError(response.data));
      }
    } catch (e) {
      return Left(ApiErrorHandler.handleError(e));
    }
  }

  Future<Either<Exception, T>> get<T>(String url,
      {Map<String, dynamic>? queryParameters}) async {
    final request = dio.get(url,
        options: Options(headers: headers, validateStatus: (status) => true),
        queryParameters: {if (queryParameters != null) ...queryParameters});
    return _handleResponse<T>(request);
  }

  Future<Either<Exception, T>> post<T>(
    String url,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final request = dio.post(
      url,
      data: data,
      options: Options(headers: headers, validateStatus: (status) => true),
      queryParameters: {if (queryParameters != null) ...queryParameters},
    );
    return _handleResponse<T>(request);
  }
}
