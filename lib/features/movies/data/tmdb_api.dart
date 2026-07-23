import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../models/tmdb_movie_details.dart';
import '../models/tmdb_movie_summary.dart';

class TmdbApi {
  const TmdbApi(this._dio, {this.token = tmdbReadToken});
  final Dio _dio;
  final String token;
  static const tmdbReadToken = String.fromEnvironment('TMDB_READ_TOKEN');
  bool get isConfigured => token.isNotEmpty;
  Future<List<TmdbMovieSummary>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    if (!isConfigured)
      throw const AppException(
        code: 'tmdb_not_configured',
        message: 'TMDB chưa được cấu hình. Hãy truyền TMDB_READ_TOKEN.',
      );
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'page': page,
          'include_adult': false,
          'language': 'vi-VN',
        },
      );
      final data = response.data as Map;
      final results = data['results'] is Iterable
          ? data['results'] as Iterable
          : const [];
      return results
          .whereType<Map>()
          .map(
            (item) => TmdbMovieSummary.fromMap(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Future<TmdbMovieDetails> getMovieDetails(int tmdbId) async {
    if (!isConfigured)
      throw const AppException(
        code: 'tmdb_not_configured',
        message: 'TMDB chưa được cấu hình.',
      );
    try {
      final response = await _dio.get(
        '/movie/$tmdbId',
        queryParameters: {
          'language': 'vi-VN',
          'append_to_response': 'credits,videos',
        },
      );
      return TmdbMovieDetails.fromMap(
        Map<String, Object?>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  AppException _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return AppException(
        code: 'tmdb_auth',
        message: 'TMDB token không hợp lệ hoặc đã hết quyền truy cập.',
        cause: error,
      );
    }
    if (status != null) {
      return AppException(
        code: 'tmdb_http_$status',
        message: 'TMDB trả về lỗi HTTP $status.',
        cause: error,
      );
    }
    return AppException.network(error);
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures
