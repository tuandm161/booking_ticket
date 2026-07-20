import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';

const tmdbReadToken = String.fromEnvironment('TMDB_READ_TOKEN');
final dioProvider = Provider<Dio>(
  (_) => Dio(
    BaseOptions(
      baseUrl: ApiConstants.tmdbBaseUrl,
      headers: tmdbReadToken.isEmpty
          ? const {}
          : {
              'Authorization': 'Bearer $tmdbReadToken',
              'accept': 'application/json',
            },
    ),
  ),
);
