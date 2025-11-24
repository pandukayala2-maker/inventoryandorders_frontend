import 'dart:io';
import 'package:dio/dio.dart';
import '../constants.dart';

class ApiService {
  final Dio _dio;

  ApiService({BaseOptions? options})
      : _dio = Dio(options ??
            BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  // Generic GET
  Future<dynamic> getRequest(String endpoint, {String? token}) async {
    final resp = await _dio.get(endpoint, options: Options(headers: _authHeader(token)));
    return _handleResponse(resp);
  }

  // Generic POST
  Future<dynamic> postRequest(String endpoint, Map data, {String? token}) async {
    final resp = await _dio.post(endpoint, data: data, options: Options(headers: _authHeader(token)));
    return _handleResponse(resp);
  }

  // Generic PUT
  Future<dynamic> putRequest(String endpoint, Map data, {String? token}) async {
    final resp = await _dio.put(endpoint, data: data, options: Options(headers: _authHeader(token)));
    return _handleResponse(resp);
  }

  // Generic DELETE
  Future<dynamic> deleteRequest(String endpoint, {String? token}) async {
    final resp = await _dio.delete(endpoint, options: Options(headers: _authHeader(token)));
    return _handleResponse(resp);
  }

  Map<String, String> _authHeader(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw Exception(response.data is Map ? (response.data['message'] ?? 'API Error') : 'API Error');
    }
  }

  /// Upload single file (image) via multipart/form-data.
  /// Returns parsed JSON response from the server.
  /// progressCallback: value from 0.0 to 1.0
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'image',
    String? token,
    void Function(double progress)? progressCallback,
  }) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final resp = await _dio.post(
      endpoint,
      data: formData,
      options: Options(headers: _authHeader(token), contentType: 'multipart/form-data'),
      onSendProgress: (sent, total) {
        if (total != 0 && progressCallback != null) {
          progressCallback(sent / total);
        }
      },
    );

    return _handleResponse(resp);
  }

  /// Upload multiple files (useful for gallery)
  Future<dynamic> uploadFiles(
    String endpoint,
    List<File> files, {
    String fieldName = 'images', // backend expects array like 'images'
    String? token,
    void Function(double progress)? progressCallback,
  }) async {
    final List<MultipartFile> mpFiles = [];
    for (var f in files) {
      final name = f.path.split(Platform.pathSeparator).last;
      mpFiles.add(await MultipartFile.fromFile(f.path, filename: name));
    }

    final formData = FormData.fromMap({
      fieldName: mpFiles,
    });

    final resp = await _dio.post(
      endpoint,
      data: formData,
      options: Options(headers: _authHeader(token), contentType: 'multipart/form-data'),
      onSendProgress: (sent, total) {
        if (total != 0 && progressCallback != null) {
          progressCallback(sent / total);
        }
      },
    );

    return _handleResponse(resp);
  }
}
