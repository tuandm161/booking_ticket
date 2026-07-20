// ignore_for_file: unnecessary_underscores, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/user_bottom_navigation.dart';
import '../../providers/user_showtime_providers.dart';
import '../widgets/showtime_day_selector.dart';
import '../widgets/showtime_chip.dart';

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
          final days = <DateTime>[];
          for (final item in items) {
            final day = DateTime(
              item.startTime.year,
              item.startTime.month,
              item.startTime.day,
            );
            if (!days.any((d) => d == day)) days.add(day);
          }
          return _ShowtimeDays(
            items: items,
            days: days,
            onSelect: (showtime) => context.push('/user/seats/${showtime.id}'),
          );
        },
      ),
    );
  }
}

class _ShowtimeDays extends StatefulWidget {
  const _ShowtimeDays({
    required this.items,
    required this.days,
    required this.onSelect,
  });
  final List items;
  final List<DateTime> days;
  final ValueChanged<dynamic> onSelect;
  @override
  State<_ShowtimeDays> createState() => _ShowtimeDaysState();
}

class _ShowtimeDaysState extends State<_ShowtimeDays> {
  late DateTime selected;
  @override
  void initState() {
    super.initState();
    selected = widget.days.first;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where(
          (s) =>
              s.startTime.year == selected.year &&
              s.startTime.month == selected.month &&
              s.startTime.day == selected.day,
        )
        .toList();
    return ListView(
      children: [
        const SizedBox(height: 12),
        ShowtimeDaySelector(
          days: widget.days,
          selected: selected,
          onSelected: (day) => setState(() => selected = day),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filtered
                .map<Widget>(
                  (s) => ShowtimeChip(
                    showtime: s,
                    onTap: () => widget.onSelect(s),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
