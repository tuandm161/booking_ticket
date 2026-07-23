// ignore_for_file: unnecessary_underscores
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/services/firebase_providers.dart';
import '../../../booking/presentation/screens/seat_selection_screen.dart';
import '../../../movies/data/movie_repository.dart';
import '../../../rooms/data/room_repository.dart';
import '../../../cinemas/models/cinema.dart';
import '../../../cinemas/providers/cinema_providers.dart';
import '../../models/showtime.dart';
import '../../providers/user_showtime_providers.dart';
import '../widgets/showtime_day_selector.dart';
import '../widgets/showtime_chip.dart';
import '../../../../shared/widgets/app_press_scale.dart';

class UserShowtimesScreen extends ConsumerWidget {
  const UserShowtimesScreen({super.key, required this.movieId});
  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userShowtimesProvider(movieId));
    final cinemasState = ref.watch(activeCinemasProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        foregroundColor: Colors.white,
        title: state.maybeWhen(
          data: (items) => items.isNotEmpty
              ? Text(
                  items.first.movieTitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : const Text('Chọn suất chiếu',
                  style: TextStyle(color: Colors.white)),
          orElse: () => const Text('Chọn suất chiếu',
              style: TextStyle(color: Colors.white)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: state.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.cgvRed)),
        error: (_, __) =>
            const Center(child: Text('Không tải được suất chiếu.')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có suất chiếu sắp tới.'));
          }
          // Collect unique days
          final days = <DateTime>[];
          for (final item in items) {
            final day = DateTime(
              item.startTime.year,
              item.startTime.month,
              item.startTime.day,
            );
            if (!days.any((d) => d == day)) days.add(day);
          }

          final cinemas = cinemasState.maybeWhen(
            data: (cList) => cList,
            orElse: () => <Cinema>[],
          );

          return _ShowtimeDays(
            items: items,
            days: days,
            cinemas: cinemas,
            onSelect: (showtime) async {
              final firestore = ref.read(firestoreProvider);
              final results = await Future.wait([
                RoomRepository(firestore).getRoom(showtime.roomId),
                MovieRepository(firestore).getMovie(showtime.movieId),
              ]);
              final room = results[0];
              final movie = results[1];
              if (room == null || movie == null || !context.mounted) return;
              context.push(
                '/user/seats/${showtime.id}',
                extra: SeatSelectionArgs(
                  showtime: showtime,
                  room: room as dynamic,
                  movie: movie as dynamic,
                ),
              );
            },
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
    required this.cinemas,
    required this.onSelect,
  });
  final List<Showtime> items;
  final List<DateTime> days;
  final List<Cinema> cinemas;
  final ValueChanged<Showtime> onSelect;

  @override
  State<_ShowtimeDays> createState() => _ShowtimeDaysState();
}

class _ShowtimeDaysState extends State<_ShowtimeDays> {
  late DateTime _selected;
  String? _selectedCinemaId;
  String _selectedCity = 'Tất cả thành phố';

  @override
  void initState() {
    super.initState();
    _selected = widget.days.first;
  }

  List<Cinema> get _visibleCinemas {
    if (_selectedCity == 'Tất cả thành phố') {
      return widget.cinemas;
    }
    return widget.cinemas.where((c) => c.city == _selectedCity).toList();
  }

  List<Showtime> get _filtered {
    final cinemaMap = {for (final c in widget.cinemas) c.id: c};
    return widget.items.where((s) {
      final matchesDay = s.startTime.year == _selected.year &&
          s.startTime.month == _selected.month &&
          s.startTime.day == _selected.day;
      final cinema = cinemaMap[s.cinemaId];
      final matchesCity = _selectedCity == 'Tất cả thành phố' ||
          cinema?.city == _selectedCity;
      final matchesCinema =
          _selectedCinemaId == null || s.cinemaId == _selectedCinemaId;
      return matchesDay && matchesCity && matchesCinema;
    }).toList();
  }

  /// Group showtimes by roomName for accordion display.
  Map<String, List<Showtime>> _groupByRoom(List<Showtime> items) {
    final map = <String, List<Showtime>>{};
    for (final item in items) {
      final header = item.cinemaName.isNotEmpty
          ? '${item.cinemaName} - ${item.roomName}'
          : item.roomName;
      map.putIfAbsent(header, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final visibleCinemas = _visibleCinemas;
    final filtered = _filtered;
    final grouped = _groupByRoom(filtered);

    return Column(
      children: [
        // ── City Selector (Horizontal ChoiceChips) ────────────
        Container(
          color: const Color(0xFF141414),
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: ['Tất cả thành phố', 'TP.HCM', 'Hà Nội'].map((city) {
              final isSelected = _selectedCity == city;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppPressScale(
                  child: ChoiceChip(
                    label: Text(city),
                    selected: isSelected,
                    selectedColor: AppTheme.cgvRed,
                    backgroundColor: const Color(0xFF2A2A2A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCity = city;
                        if (_selectedCinemaId != null) {
                          final selCinema = widget.cinemas.firstWhere(
                            (c) => c.id == _selectedCinemaId,
                            orElse: () => const Cinema(
                              name: '',
                              address: '',
                              city: '',
                              imageUrl: '',
                              isActive: false,
                            ),
                          );
                          if (city != 'Tất cả thành phố' &&
                              selCinema.city != city) {
                            _selectedCinemaId = null;
                          }
                        }
                      });
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Cinema Selector (Horizontal Chips) ───────────────
        if (visibleCinemas.isNotEmpty)
          Container(
            color: const Color(0xFF1A1A1A),
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppPressScale(
                    child: ChoiceChip(
                      label: const Text('Tất cả cụm rạp'),
                      selected: _selectedCinemaId == null,
                      selectedColor: AppTheme.cgvRed,
                      backgroundColor: const Color(0xFF2A2A2A),
                      labelStyle: TextStyle(
                        color: _selectedCinemaId == null
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedCinemaId = null),
                    ),
                  ),
                ),
                ...visibleCinemas.map((cinema) {
                  final isSelected = _selectedCinemaId == cinema.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppPressScale(
                      child: ChoiceChip(
                        label: Text(cinema.name),
                        selected: isSelected,
                        selectedColor: AppTheme.cgvRed,
                        backgroundColor: const Color(0xFF2A2A2A),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedCinemaId = cinema.id),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

        // ── Date Selector (dark background) ─────────────────
        ShowtimeDaySelector(
          days: widget.days,
          selected: _selected,
          onSelected: (day) => setState(() => _selected = day),
        ),

        // ── Room list with showtimes ─────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Không có suất chiếu tại rạp này vào ngày đã chọn.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView(
                  children: grouped.entries.map((entry) {
                    return _RoomShowtimeSection(
                      roomName: entry.key,
                      showtimes: entry.value,
                      onSelect: widget.onSelect,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

/// CGV-style ExpansionTile: room name đỏ, khung giờ dạng chip bên dưới.
class _RoomShowtimeSection extends StatefulWidget {
  const _RoomShowtimeSection({
    required this.roomName,
    required this.showtimes,
    required this.onSelect,
  });

  final String roomName;
  final List<Showtime> showtimes;
  final ValueChanged<Showtime> onSelect;

  @override
  State<_RoomShowtimeSection> createState() => _RoomShowtimeSectionState();
}

class _RoomShowtimeSectionState extends State<_RoomShowtimeSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Room header row
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF2E2E2E)
                      : const Color(0xFFE0E0E0),
                ),
              ),
            ),
            child: Row(
              children: [
                // CGV prefix in red
                const Text(
                  'CGV ',
                  style: TextStyle(
                    color: AppTheme.cgvRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.roomName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        // Showtimes chips
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.showtimes
                      .map(
                        (s) => ShowtimeChip(
                          showtime: s,
                          onTap: () => widget.onSelect(s),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
