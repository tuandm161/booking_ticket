// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../providers/user_showtime_providers.dart';

class UserShowtimesScreen extends ConsumerWidget {
  const UserShowtimesScreen({super.key, required this.movieId});
  final String movieId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userShowtimesProvider(movieId));
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn suất chiếu')),
      bottomNavigationBar: const UserBottomNavigation(index: 0),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Không tải được suất chiếu.')),
        data: (items) {
          if (items.isEmpty)
            return const Center(child: Text('Chưa có suất chiếu sắp tới.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final showtime = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.theaters_outlined),
                  title: Text(
                    '${showtime.startTime.day}/${showtime.startTime.month} • ${showtime.startTime.hour.toString().padLeft(2, '0')}:${showtime.startTime.minute.toString().padLeft(2, '0')}',
                  ),
                  subtitle: Text(
                    '${showtime.roomName} • ${showtime.basePrice} đ',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chọn ghế sẽ có trong phase tiếp theo.'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
