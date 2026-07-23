## 2026-07-22T03:07:04Z
Your working directory is d:\prm\Project\booking_ticket\.agents\teamwork_preview_worker_m3.
Your objective is to implement Milestone 3 (Requirement R2) in d:\prm\Project\booking_ticket:

1. Read Explorer 2 handoff report at d:\prm\Project\booking_ticket\.agents\teamwork_preview_explorer_m1_2\handoff.md and analysis report at d:\prm\Project\booking_ticket\.agents\teamwork_preview_explorer_m1_2\analysis.md.
2. Admin Status Tag Contrast Fix:
   - In lib/features/movies/presentation/widgets/movie_admin_card.dart, lib/features/movies/presentation/widgets/movie_metadata.dart, and lib/features/movies/presentation/screens/admin_movie_list_screen.dart: update status tag/chip widgets for nowShowing, comingSoon, and stopped status.
   - Use high-contrast, WCAG AAA compliant text and background colors:
     * nowShowing: dark green (#1B5E20) text on light green (#E8F5E9) background chip
     * comingSoon: navy blue (#0D47A1) text on light blue (#E3F2FD) background chip
     * stopped: dark red (#B71C1C) text on light amber (#FFE0B2) background chip
   - Ensure text is 100% sharp and readable on all backgrounds.
3. UI Layout & Overflow Fixes:
   - lib/features/user_home/presentation/widgets/movie_horizontal_section.dart: Increase height from 230 to 260 to prevent movie poster / title overflow.
   - lib/features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart: Fix Wrap/card sizing so metric cards fit responsively without line break overflow on narrow screens.
   - lib/features/booking/presentation/screens/card_payment_form_screen.dart: Add vertical SizedBox(height: 12) spacing between text form fields.
   - lib/features/booking/presentation/screens/checkout_screen.dart: Ensure button label does not overflow on small screens (e.g. using FittedBox or flexible text).
   - lib/features/cinemas/presentation/screens/admin_cinema_list_screen.dart: Update bottom navigation index parameter from 2 to 4.
   - Translate English UI text to Vietnamese in ShowtimeDaySelector ('Today' -> 'Hôm nay'), SeatLegend ('Selected' -> 'Đã chọn', 'Occupied' -> 'Đã bán'), SeatSelectionSummary ('Seats' -> 'ghế', 'BOOK NOW' -> 'ĐẶT VÉ NGAY'), and UserMovieDetailScreen ('Rated', 'Genre', 'Director', 'Cast', 'Language').
4. Run `flutter analyze --no-fatal-infos` using run_command to verify 0 issues found.
5. Run `flutter test` using run_command to verify all tests pass (32/32 tests pass).
6. Document all changes in changes.md and handoff.md in your working directory. Update progress.md.
7. Send a message to parent with your handoff path.
