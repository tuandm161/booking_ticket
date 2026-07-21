// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_underscores, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firebase_providers.dart';
import '../../../movies/data/movie_repository.dart';
import '../../../movies/models/movie.dart';
import '../../../rooms/data/room_repository.dart';
import '../../../rooms/models/cinema_room.dart';
import '../../../showtimes/data/showtime_repository.dart';
import '../../../showtimes/models/showtime.dart';
import '../../models/order_draft.dart';
import '../../models/seat_hold.dart';
import '../../providers/order_draft_provider.dart';
import '../../providers/seat_hold_controller.dart';
import '../../providers/seat_hold_countdown_provider.dart';
import '../../providers/seat_selection_provider.dart';
import '../widgets/seat_legend.dart';
import '../widgets/seat_map.dart';
import '../widgets/seat_selection_summary.dart';

class SeatSelectionArgs {
  const SeatSelectionArgs({
    required this.showtime,
    required this.room,
    required this.movie,
  });

  final Showtime showtime;
  final CinemaRoom room;
  final Movie movie;
}

class SeatSelectionScreen extends ConsumerStatefulWidget {
  const SeatSelectionScreen({
    super.key,
    required this.showtimeId,
    this.initialData,
  });
  final String showtimeId;
  final SeatSelectionArgs? initialData;
  @override
  ConsumerState<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  String? reservationId;
  DateTime? holdExpiresAt;
  Future<List<Object?>>? _loadFuture;
  @override
  void initState() {
    super.initState();
    if (widget.initialData == null) _loadFuture = _load();
  }

  Future<List<Object?>> _load() async {
    // Let the route transition finish before replacing the loading subtree.
    // Flutter 3.38's Android semantics pipeline can assert when a large,
    // interactive seat grid is inserted during the push transition.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final firestore = ref.read(firestoreProvider);
    final showtime = await ShowtimeRepository(
      firestore,
    ).getShowtime(widget.showtimeId);
    if (showtime == null) return [null, null, null];
    final room = await RoomRepository(firestore).getRoom(showtime.roomId);
    final movie = await MovieRepository(firestore).getMovie(showtime.movieId);
    return [showtime, room, movie];
  }

  Future<void> _releaseIfNeeded() async {
    if (reservationId != null)
      await ref
          .read(seatHoldControllerProvider.notifier)
          .release(
            showtimeId: widget.showtimeId,
            reservationId: reservationId!,
          );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCodes = ref.watch(seatSelectionProvider);
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
    if (holdExpiresAt != null) {
      ref.listen(seatHoldCountdownProvider(holdExpiresAt!), (previous, next) {
        if (next.hasValue && next.value == Duration.zero && mounted) {
          final old = reservationId;
          setState(() {
            holdExpiresAt = null;
            reservationId = null;
          });
          ref.read(seatSelectionProvider.notifier).clear();
          if (old != null)
            ref
                .read(seatHoldControllerProvider.notifier)
                .release(showtimeId: widget.showtimeId, reservationId: old);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thời gian giữ ghế đã hết. Vui lòng chọn lại.'),
            ),
          );
        }
      });
    }
    return WillPopScope(
      onWillPop: () async {
        await _releaseIfNeeded();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Chọn ghế')),
        body: FutureBuilder<List<Object?>>(
          future: _loadFuture,
          initialData: widget.initialData == null
              ? null
              : [
                  widget.initialData!.showtime,
                  widget.initialData!.room,
                  widget.initialData!.movie,
                ],
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Không tải được sơ đồ ghế.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => setState(() => _loadFuture = _load()),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final showtime = snapshot.data![0] as Showtime?;
            final room = snapshot.data![1] as CinemaRoom?;
            final movie = snapshot.data![2];
            if (showtime == null || room == null || movie == null)
              return const Center(
                child: Text('Không tìm thấy suất chiếu hoặc sơ đồ phòng.'),
              );
            final seats = room.seats
                .where((s) => selectedCodes.contains(s.code))
                .toList();
            final holds = showtime.heldSeats.map(
              (key, value) => MapEntry(
                key,
                SeatHold(
                  userId: value.userId,
                  reservationId: value.reservationId,
                  expiresAt: value.expiresAt,
                ),
              ),
            );
            final countdown = holdExpiresAt == null
                ? null
                : ref.watch(seatHoldCountdownProvider(holdExpiresAt!));
            return ExcludeSemantics(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    if (countdown != null)
                      countdown.when(
                        data: (duration) => Container(
                          width: double.infinity,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: .18),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đang giữ ghế: ${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () async {
                                  await _releaseIfNeeded();
                                  ref
                                      .read(seatSelectionProvider.notifier)
                                      .clear();
                                  if (mounted)
                                    setState(() {
                                      reservationId = null;
                                      holdExpiresAt = null;
                                    });
                                },
                                child: const Text('Đổi ghế'),
                              ),
                            ],
                          ),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    SeatMap(
                      room: room,
                      selectedCodes: selectedCodes,
                      bookedCodes: showtime.bookedSeatCodes.toSet(),
                      holds: holds,
                      userId: userId,
                      reservationId: reservationId,
                      now: ref.read(clockServiceProvider).now(),
                      onToggle: (seat) {
                        final message = ref
                            .read(seatSelectionProvider.notifier)
                            .toggle(seat);
                        if (message != null && context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    const SeatLegend(),
                    const SizedBox(height: 18),
                    SeatSelectionSummary(
                      seats: seats,
                      basePrice: showtime.basePrice,
                      onContinue: () async {
                        final holdController = ref.read(
                          seatHoldControllerProvider.notifier,
                        );
                        final id = await holdController.hold(
                          showtimeId: showtime.id,
                          seatCodes: seats.map((s) => s.code).toList(),
                          reservationId: reservationId,
                        );
                        final holdState = ref.read(seatHoldControllerProvider);
                        final expires = holdState is AsyncData<DateTime?>
                            ? holdState.value
                            : null;
                        if (id == null || expires == null) {
                          if (holdState.hasError && context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(holdState.error.toString()),
                              ),
                            );
                          return;
                        }
                        setState(() {
                          reservationId = id;
                          holdExpiresAt = expires;
                        });
                        final seatTotal = seats.fold<int>(
                          0,
                          (sum, seat) =>
                              sum + seatPrice(seat.type, showtime.basePrice),
                        );
                        ref
                            .read(orderDraftProvider.notifier)
                            .setDraft(
                              OrderDraft(
                                movie: movie as dynamic,
                                showtime: showtime,
                                room: room,
                                selectedSeats: seats,
                                reservationId: id,
                                holdExpiresAt: expires,
                                seatSubtotal: seatTotal,
                                total: seatTotal,
                              ),
                            );
                        if (context.mounted) context.push('/user/concessions');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
