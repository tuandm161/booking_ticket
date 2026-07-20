// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
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
      appBar: AppBar(title: const Text('Admin Dashboard')),
      bottomNavigationBar: const AdminBottomNavigation(index: 0),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Không tải được số liệu.')),
        data: (m) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardMetricsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
              RevenueSummaryCard(today: m.todayRevenue, total: m.totalRevenue),
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
    );
  }
}
