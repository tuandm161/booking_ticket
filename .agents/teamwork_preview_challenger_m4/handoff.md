# Milestone 4 (R3) Empirical Verification Report

## Observation

1. **User Showtimes Screen City Filtering**:
   - Location: `lib/features/showtimes/presentation/screens/user_showtimes_screen.dart`
   - ChoiceChips for cities: `['Tất cả thành phố', 'TP.HCM', 'Hà Nội']` (Line 178).
   - City filtering logic:
     - `_visibleCinemas` filters `widget.cinemas` by `c.city == _selectedCity` (Lines 128-133).
     - `_filtered` filters showtimes by matching day, matching city (`_selectedCity == 'Tất cả thành phố' || cinema?.city == _selectedCity`), and matching cinema ID (Lines 135-148).
     - On selecting a new city, if current `_selectedCinemaId` does not belong to the selected city, `_selectedCinemaId` is reset to `null` (Lines 193-212).

2. **Admin Filter & Sort Header**:
   - Location: `lib/shared/widgets/admin_filter_sort_header.dart`
   - Defines reusable `AdminActiveStatusFilter` (`all`, `active`, `hidden`).
   - Renders 3 status ChoiceChips (`Tất cả`, activeLabel, hiddenLabel) and a flexible dropdown for sorting options.
   - Accepts custom `extraFilterWidget` for additional category/status filters.

3. **6 Admin Screens Status & Sort Filtering**:
   - `lib/features/movies/presentation/screens/admin_movie_list_screen.dart`:
     - Sort fields: `releaseDate` (desc), `title` (A-Z), `bookingCount` (desc).
     - Status filter: `AdminActiveStatusFilter` (isActive) + `MovieStatus` (nowShowing, comingSoon, endShowing).
   - `lib/features/showtimes/presentation/screens/admin_showtime_list_screen.dart`:
     - Sort fields: `startTime` (asc), `price` (desc), `movieTitle` (A-Z).
     - Status filter: `AdminActiveStatusFilter` (isActive) + `ShowtimeDateFilter` (day selection).
   - `lib/features/rooms/presentation/screens/admin_room_list_screen.dart`:
     - Sort fields: `name` (A-Z), `totalSeats` (desc), `createdAt` (desc).
     - Status filter: `AdminActiveStatusFilter` (isActive).
   - `lib/features/concessions/presentation/screens/admin_combo_list_screen.dart`:
     - Sort fields: `name` (A-Z), `price` (desc), `createdAt` (desc).
     - Status filter: `AdminActiveStatusFilter` (isAvailable: 'Đang bán' vs 'Tạm ẩn').
   - `lib/features/concessions/presentation/screens/admin_product_list_screen.dart`:
     - Sort fields: `name` (A-Z), `price` (desc), `createdAt` (desc).
     - Status filter: `AdminActiveStatusFilter` (isAvailable) + `ProductCategory` extra filter chips.
   - `lib/features/vouchers/presentation/screens/admin_voucher_list_screen.dart`:
     - Sort fields: `code` (A-Z), `discountValue` (desc), `endDate` (asc).
     - Status filter: `AdminActiveStatusFilter` (isActive: 'Đang bật' vs 'Tạm ẩn').

4. **Empirical Test Suite & Static Analysis Results**:
   - `flutter analyze --no-fatal-infos`:
     ```
     Analyzing booking_ticket...
     No issues found! (ran in 6.1s)
     ```
   - `flutter test`:
     ```
     00:07 +41: All tests passed!
     ```
   - Added unit tests:
     - `test/features/showtimes/user_showtimes_city_filter_test.dart` (2 passing tests for city & cinema filtering).
     - `test/shared/admin_filter_sort_header_test.dart` (7 passing tests covering `AdminFilterSortHeader` and filter/sort logic across all 6 admin domain models).

## Logic Chain

1. Direct inspection of `user_showtimes_screen.dart` verified that city selection correctly partitions visible cinemas and filters showtimes by matching cinema location. Resetting `_selectedCinemaId` when switching cities prevents orphaned selections.
2. Direct inspection of `admin_filter_sort_header.dart` verified standard UX encapsulation for active/hidden toggles and sort dropdowns.
3. Verification across the 6 admin list screens confirmed consistent implementation of `AdminFilterSortHeader` with appropriate domain-specific sort enums and active status filtering.
4. Execution of static analysis (`flutter analyze --no-fatal-infos`) produced 0 warnings or errors.
5. Execution of full unit and widget test suite (41/41 tests passing) confirms non-regression and correctness of filtering and sorting models.

## Caveats

- City selection in `user_showtimes_screen.dart` currently hardcodes `['Tất cả thành phố', 'TP.HCM', 'Hà Nội']`. If cinemas from other cities (e.g. 'Đà Nẵng') are added, they will be visible under 'Tất cả thành phố' but will not have a dedicated city chip unless the city list is dynamically generated or updated.

## Conclusion

- **VERDICT: PASSED**
- Milestone 4 (R3) requirements for user showtime city filtering, standard admin filter/sort header, and status/sorting across 6 admin screens are empirically verified, correctly implemented, fully analyzed with zero lint errors, and 100% test-backed.

## Verification Method

Run the following commands in `d:\prm\Project\booking_ticket`:
```bash
flutter analyze --no-fatal-infos
flutter test
```
Inspect files:
- `lib/features/showtimes/presentation/screens/user_showtimes_screen.dart`
- `lib/shared/widgets/admin_filter_sort_header.dart`
- `test/features/showtimes/user_showtimes_city_filter_test.dart`
- `test/shared/admin_filter_sort_header_test.dart`
