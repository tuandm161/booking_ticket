// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_press_scale.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../../../shared/widgets/admin_bottom_navigation.dart';
import '../../models/cinema.dart';
import '../../providers/cinema_providers.dart';

class AdminCinemaListScreen extends ConsumerWidget {
  const AdminCinemaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cinemasState = ref.watch(cinemasProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Cụm Rạp'),
      ),
      body: AppAsyncValueWidget<List<Cinema>>(
        value: cinemasState,
        onRetry: () => ref.invalidate(cinemasProvider),
        data: (cinemas) {
          if (cinemas.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có cụm rạp nào. Hãy bấm + để thêm mới.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cinemas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cinema = cinemas[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252525) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cgvRed.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.movie_creation_rounded,
                      color: AppTheme.cgvRed,
                    ),
                  ),
                  title: Text(
                    cinema.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '${cinema.address}, ${cinema.city}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: cinema.isActive,
                        activeThumbColor: AppTheme.cgvRed,
                        onChanged: (val) {
                          ref
                              .read(cinemaRepositoryProvider)
                              .setCinemaActive(cinema.id, val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            context.push('/admin/cinemas/${cinema.id}/edit'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNavigation(index: 4),
      floatingActionButton: AppPressScale(
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/cinemas/new'),
          backgroundColor: AppTheme.cgvRed,
          icon: const Icon(Icons.add),
          label: const Text('Thêm cụm rạp'),
        ),
      ),
    );
  }
}
