// ignore_for_file: curly_braces_in_flow_control_structures
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../booking/providers/admin_booking_providers.dart';
import '../../movies/providers/movie_providers.dart';
import '../../showtimes/providers/showtime_providers.dart';
import '../models/dashboard_metrics.dart';

final dashboardMetricsProvider =
    Provider.autoDispose<AsyncValue<DashboardMetrics>>((ref) {
      final bookings = ref.watch(allBookingsProvider);
      final movies = ref.watch(moviesProvider);
      final showtimes = ref.watch(showtimesProvider);
      if (bookings.hasError)
        return AsyncValue.error(bookings.error!, bookings.stackTrace!);
      if (movies.hasError)
        return AsyncValue.error(movies.error!, movies.stackTrace!);
      if (showtimes.hasError)
        return AsyncValue.error(showtimes.error!, showtimes.stackTrace!);
      if (!bookings.hasValue || !movies.hasValue || !showtimes.hasValue)
        return const AsyncValue.loading();
      return AsyncValue.data(
        calculateDashboardMetrics(
          bookings: bookings.value!,
          movies: movies.value!,
          showtimes: showtimes.value!,
          now: DateTime.now(),
        ),
      );
    });
