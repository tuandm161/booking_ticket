## 2026-07-22T03:11:57Z
Your working directory is d:\prm\Project\booking_ticket\.agents\teamwork_preview_worker_m4.
Your objective is to implement Milestone 4 (Requirement R3 Advanced Filtering UX) in d:\prm\Project\booking_ticket:

1. Read Explorer 3 handoff report at d:\prm\Project\booking_ticket\.agents\teamwork_preview_explorer_m1_3\handoff.md and analysis report at d:\prm\Project\booking_ticket\.agents\teamwork_preview_explorer_m1_3\analysis.md.
2. User Showtimes Screen City Filtering:
   - In lib/features/showtimes/presentation/screens/user_showtimes_screen.dart:
   - Add a City selector (e.g. ChoiceChips or Dropdown for 'TP.HCM', 'Hà Nội', 'Tất cả thành phố') at the top.
   - Filter active cinemas list by selected city. Selecting 'Hà Nội' shows 4 Hanoi CGV cinema clusters (Vincom Bà Triệu, Royal City, Lotte Center Hà Nội, Aeon Mall Hà Đông) and their showtimes. Selecting 'TP.HCM' shows TP.HCM cinemas.
3. Admin Screens Status & Sort Filtering:
   - Implement status filtering (Active/Hidden/All) and sorting (by date/name/revenue/price/code) across Admin list screens:
     * Admin Movies (lib/features/movies/presentation/screens/admin_movie_list_screen.dart): Status filter (All, nowShowing, comingSoon, stopped) & Sorting (releaseDate, title, bookingCount).
     * Admin Rooms (lib/features/rooms/presentation/screens/admin_room_list_screen.dart): Status filter (All, Active, Hidden) & Sorting (name, totalSeats, createdAt).
     * Admin Showtimes (lib/features/showtimes/presentation/screens/admin_showtime_list_screen.dart): Status filter (All, Active, Hidden) & Sorting (startTime, price, movieTitle).
     * Admin Products (lib/features/concessions/presentation/screens/admin_product_list_screen.dart): Status filter (All, Active, Hidden) & Sorting (name, price, createdAt).
     * Admin Combos (lib/features/concessions/presentation/screens/admin_combo_list_screen.dart): Status filter (All, Active, Hidden) & Sorting (name, price, createdAt).
     * Admin Vouchers (lib/features/vouchers/presentation/screens/admin_voucher_list_screen.dart): Status filter (All, Active, Hidden) & Sorting (code, discountValue, endDate).
4. Run `flutter analyze --no-fatal-infos` using run_command to verify 0 issues found.
5. Run `flutter test` using run_command to verify all tests pass (32/32 tests pass).
6. Document all changes in changes.md and handoff.md in your working directory. Update progress.md.
7. Send a message to parent with your handoff path.
