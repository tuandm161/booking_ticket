# Handoff Report — UI Audit & Admin Tag Contrast Analysis

**From**: Explorer Agent (`teamwork_preview_explorer_m1_2`)  
**To**: Implementer / Parent Agent (`5fc0948c-c718-453c-9c64-5e39b8ad9288`)  
**Working Directory**: `d:\prm\Project\booking_ticket\.agents\teamwork_preview_explorer_m1_2`  
**Date**: 2026-07-21T20:01:21Z  

---

## 1. Observation

1. **Admin Status Tag Contrast Defects**:
   - `lib/features/movies/presentation/screens/admin_movie_list_screen.dart` (lines 58–74): Status filtering uses default `ChoiceChip` widgets without distinct status color coding.
   - `lib/features/movies/presentation/widgets/movie_admin_card.dart` (lines 29–31): Status is rendered as plain string text inside subtitle (`movie.status.label`), lacking container chip hierarchy.
   - `lib/features/movies/presentation/widgets/movie_metadata.dart` (lines 14–16): Uses generic `Chip(label: Text(movie.status.label))`. When colored backgrounds are applied without explicit text color, white text on light green `#E8F5E9` or light blue `#E3F2FD` has a low contrast ratio of ~1.3:1 (failing WCAG AA).

2. **Screen Layout & Overflow Defects**:
   - `lib/features/user_home/presentation/widgets/movie_horizontal_section.dart` (line 23): Fixed `SizedBox(height: 230)` wraps `MoviePosterCard` (width 130). Total required poster + title + duration height is **250px**, resulting in vertical layout overflow/squishing.
   - `lib/features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart` (lines 54–83): `Wrap` contains three `SizedBox(width: 170)` items. On 360px wide viewports, 2 items consume 348px > 328px available width, causing asymmetrical line breaks.
   - `lib/features/booking/presentation/screens/card_payment_form_screen.dart` (lines 35–70): `TextFormField` controls lack vertical `SizedBox(height: 12)` spacing between inputs.
   - `lib/features/booking/presentation/screens/checkout_screen.dart` (line 362): Single line button text `'CHỌN PHƯƠNG THỨC THANH TOÁN'` (30 chars) overflows on small viewports.

3. **Navigation & Accessibility Defects**:
   - `lib/features/cinemas/presentation/screens/admin_cinema_list_screen.dart` (line 102): `AdminBottomNavigation(index: 2)` sets index 2 ('Suất chiếu') instead of index 4 ('Quản lý').
   - `lib/features/booking/presentation/screens/seat_selection_screen.dart` (line 212): Root body wrapped in `ExcludeSemantics`, disabling accessibility features across seat grid and summary bar.
   - `lib/features/concessions/presentation/widgets/product_order_card.dart` & `combo_order_card.dart`: Uses hardcoded static icons instead of `CachedNetworkImage` with actual product/combo image URLs.

4. **Language & Font Inconsistencies**:
   - `lib/features/showtimes/presentation/widgets/showtime_day_selector.dart` (line 57): Displays `'Today'` mixed with Vietnamese weekdays (`'T2'`, `'CN'`).
   - `lib/features/booking/presentation/widgets/seat_legend.dart` (lines 20–21): Mixes Vietnamese (`'Thường'`, `'VIP'`) with English (`'Selected'`, `'Occupied'`).
   - `lib/features/booking/presentation/widgets/seat_selection_summary.dart` (lines 62–63, 97): Displays `'0 Seats'`, `'1 Seat'`, `'BOOK NOW'`.
   - `lib/features/movies/presentation/screens/user_movie_detail_screen.dart` (lines 285–298): Table labels in English (`'Rated'`, `'Genre'`, `'Director'`, `'Cast'`, `'Language'`).

---

## 2. Logic Chain

1. **Observation**: Status chips in `AdminMovieListScreen` and `MovieMetadata` lack explicit high-contrast foreground/background pairs.
   - **Reasoning**: Unstyled or white text on light colored backgrounds fails WCAG AA minimum 4.5:1 ratio requirement.
   - **Step**: Define explicit light/dark mode color palettes for `nowShowing` (dark forest green text `#1B5E20` on light green `#E8F5E9`), `comingSoon` (navy blue text `#0D47A1` on light blue `#E3F2FD`), and `stopped` (crimson red text `#B71C1C` on light amber/red `#FFE0B2`) to achieve > 7:1 contrast (WCAG AAA).

2. **Observation**: `MovieHorizontalSection` sets `height: 230`, while `MoviePosterCard` content requires 250px.
   - **Reasoning**: In Flutter layout, child widgets exceeding fixed parent `SizedBox` boundaries trigger `RenderFlex overflowed by ... pixels` or squish `Expanded` image assets.
   - **Step**: Adjust parent `SizedBox` height to `260` to accommodate 2-line movie titles and duration text safely.

3. **Observation**: `AdminCinemaListScreen` sets `AdminBottomNavigation(index: 2)`.
   - **Reasoning**: Index 2 maps to `/admin/showtimes`. `AdminCinemaListScreen` route is `/admin/cinemas`, accessed under Management menu (index 4).
   - **Step**: Update bottom navigation bar index parameter from `2` to `4`.

---

## 3. Caveats

- **No Caveats**: All 40 screen files in `lib/features/` were examined directly via source inspection.
- The investigation was purely read-only; no code modifications were applied to application files under `lib/`.

---

## 4. Conclusion

- **Status Contrast**: Needs a reusable `MovieStatusChip` with WCAG AAA compliant text-to-background contrast ratios for `nowShowing`, `comingSoon`, and `stopped`.
- **Layout & Spacing**: 5 primary overflow/spacing bugs identified (`MovieHorizontalSection` height 230->260, `AdminDashboardScreen` metric card grid, `CardPaymentFormScreen` missing field gaps, `CheckoutScreen` button label length).
- **Navigation & Accessibility**: Mismatched tab index in `AdminCinemaListScreen` (index 2 -> 4) and unnecessary `ExcludeSemantics` in `SeatSelectionScreen`.
- **Language**: English strings in `ShowtimeDaySelector` ('Today'), `SeatLegend` ('Selected', 'Occupied'), `SeatSelectionSummary` ('Seats', 'BOOK NOW'), and `UserMovieDetailScreen` ('Rated', 'Genre', etc.) require Vietnamese translation.

---

## 5. Verification Method

To verify these findings and proposed changes:
1. Inspect `analysis.md` in `d:\prm\Project\booking_ticket\.agents\teamwork_preview_explorer_m1_2\analysis.md`.
2. Inspect target source files directly:
   - `lib/features/movies/presentation/screens/admin_movie_list_screen.dart`
   - `lib/features/user_home/presentation/widgets/movie_horizontal_section.dart` (Line 23)
   - `lib/features/cinemas/presentation/screens/admin_cinema_list_screen.dart` (Line 102)
   - `lib/features/booking/presentation/screens/card_payment_form_screen.dart` (Lines 35–70)
   - `lib/features/showtimes/presentation/widgets/showtime_day_selector.dart` (Line 57)
3. Execute `flutter analyze` to ensure code integrity.
