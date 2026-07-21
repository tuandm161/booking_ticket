// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../../../shared/widgets/cinema_decor.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/revenue_summary_card.dart';
import '../widgets/upcoming_showtime_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardMetricsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.local_movies_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            const Text('CineBook Admin'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(dashboardMetricsProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavigation(index: 0),
      body: CinemaBackdrop(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Không tải được số liệu.')),
          data: (m) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardMetricsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CinemaHero(
                  eyebrow: 'Bảng điều khiển vận hành',
                  title: 'Rạp chiếu luôn sáng đèn.',
                  subtitle:
                      'Theo dõi doanh thu, suất chiếu và nhịp đập CineBook.',
                  icon: Icons.insights_rounded,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 170,
                      child: MetricCard(
                        label: 'Tổng booking',
                        value: '${m.totalBookings}',
                        icon: Icons.receipt_long,
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: MetricCard(
                        label: 'Booking hôm nay',
                        value: '${m.todayBookings}',
                        icon: Icons.today,
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: MetricCard(
                        label: 'Vé/người đã bán',
                        value: '${m.ticketsSold}',
                        icon: Icons.people,
                      ),
                    ),
                  ],
                ),
                RevenueSummaryCard(
                  today: m.todayRevenue,
                  total: m.totalRevenue,
                ),
                UpcomingShowtimeCard(count: m.upcomingShowtimes24h),
                if (m.topMovie != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star),
                      title: Text('Phim bán chạy nhất: ${m.topMovie!.title}'),
                      subtitle: Text('${m.topMovie!.bookingCount} booking'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
