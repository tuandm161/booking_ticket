# Changes Made for Milestone 4 (Requirement R3 Advanced Filtering UX)

## Summary of Changes
1. **User Showtimes Screen City Filtering**:
   - `lib/features/showtimes/presentation/screens/user_showtimes_screen.dart`:
     - Added City selector ChoiceChips (`'Tất cả thành phố'`, `'TP.HCM'`, `'Hà Nội'`) at the top of `_ShowtimeDays`.
     - Filtered `_visibleCinemas` based on selected city.
     - Updated `_filtered` showtime getter to match selected city and reset selected cinema if it does not belong to the selected city.
     - Selecting 'Hà Nội' filters for 4 Hanoi CGV cinema clusters (`CGV Vincom Bà Triệu`, `CGV Royal City`, `CGV Lotte Center Hà Nội`, `CGV Aeon Mall Hà Đông`) and their showtimes.

2. **Admin Filter & Sort Header Component**:
   - Created reusable component `lib/shared/widgets/admin_filter_sort_header.dart`:
     - Provides status filtering ChoiceChips (All / Active / Hidden with custom labels per screen context) and a Dropdown menu for sort fields.

3. **Admin Screens Status & Sort Filtering**:
   - **Admin Movies** (`lib/features/movies/presentation/screens/admin_movie_list_screen.dart`):
     - Added active status filter (All, Active, Hidden) & MovieStatus filter (All, nowShowing, comingSoon, stopped).
     - Added sorting dropdown for `releaseDate` (newest first), `title` (A-Z), `bookingCount` (highest first).
   - **Admin Rooms** (`lib/features/rooms/presentation/screens/admin_room_list_screen.dart`):
     - Added status filter (All, Active, Hidden).
     - Added sorting dropdown for `name` (A-Z), `totalSeats` (seat count desc), `createdAt` (newest first).
   - **Admin Showtimes** (`lib/features/showtimes/presentation/screens/admin_showtime_list_screen.dart`):
     - Added status filter (All, Active, Hidden).
     - Added sorting dropdown for `startTime` (chronological), `basePrice` (price desc), `movieTitle` (A-Z).
   - **Admin Products** (`lib/features/concessions/presentation/screens/admin_product_list_screen.dart`):
     - Added status filter (All, Đang bán, Tạm ẩn) and preserved category filter.
     - Added sorting dropdown for `name` (A-Z), `price` (highest first), `createdAt` (newest first).
   - **Admin Combos** (`lib/features/concessions/presentation/screens/admin_combo_list_screen.dart`):
     - Added status filter (All, Đang bán, Tạm ẩn).
     - Added sorting dropdown for `name` (A-Z), `price` (highest first), `createdAt` (newest first).
   - **Admin Vouchers** (`lib/features/vouchers/presentation/screens/admin_voucher_list_screen.dart`):
     - Added status filter (All, Đang bật, Tạm ẩn).
     - Added sorting dropdown for `code` (A-Z), `discountValue` (highest first), `endDate` (earliest expiry first).

## Verification Results
- `flutter analyze --no-fatal-infos`: 0 issues found.
- `flutter test`: 32/32 tests pass.
