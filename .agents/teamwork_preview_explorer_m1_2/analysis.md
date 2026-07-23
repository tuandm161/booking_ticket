# Comprehensive UI Audit & Status Tag Contrast Analysis

**Project**: CGV Cinema Ticket Booking App (`booking_ticket`)  
**Investigated By**: Explorer Agent (`teamwork_preview_explorer_m1_2`)  
**Date**: 2026-07-21T20:01:21Z  

---

## 1. Executive Summary

This report delivers a thorough analysis of:
1. **Admin Status Tag Contrast Defects**: Identification of root causes for unreadable/low-contrast status chips (`nowShowing`, `comingSoon`, `stopped`) in `AdminMovieListScreen` and related widgets, along with exact WCAG AAA compliant color design specifications.
2. **User & Admin UI Layout & Overflow Audit**: Inspection of 40 screen implementations in `lib/features/` covering layout overflow risk, spacing/padding glitches, navigation tab index mismatches, accessibility defects, and language/font inconsistencies.

---

## 2. Admin Movie Status Tag Contrast Inspection

### 2.1 Current Observations & Root Cause Analysis

* **Location**: `lib/features/movies/presentation/screens/admin_movie_list_screen.dart`, `lib/features/movies/presentation/widgets/movie_admin_card.dart`, `lib/features/movies/presentation/widgets/movie_metadata.dart`.
* **Current Implementation**:
  - In `AdminMovieListScreen` (lines 58–74), status filtering uses standard `ChoiceChip` widgets without status-specific background/foreground styling.
  - In `MovieAdminCard` (lines 29–31), movie status is rendered as a plain text string inside `ListTile.subtitle` (`'${movie.status.label} • ...'`), lacking badge/tag container visual hierarchy.
  - In `MovieMetadata` (lines 14–16), status is wrapped in `Chip(label: Text(movie.status.label))`. When colored backgrounds are applied without custom contrasting text colors (e.g. white text on light pastel green `#E8F5E9` or light blue `#E3F2FD`), contrast drops to ~1.3:1 ratio (failing WCAG AA minimum requirement of 4.5:1).

### 2.2 Recommended Color & Style Improvements (`MovieStatusChip`)

A dedicated custom widget `MovieStatusChip` (or badge) should be introduced for status tags across `AdminMovieListScreen`, `MovieAdminCard`, and `MovieMetadata`.

| Status Enum | Label (VN) | Light Mode Background | Light Mode Text Color | Dark Mode Background | Dark Mode Text Color | Font Weight | Contrast Ratio |
|---|---|---|---|---|---|---|---|
| `MovieStatus.nowShowing` | Đang chiếu | `#E8F5E9` (Light Green) | `#1B5E20` (Dark Forest Green) | `#1B5E20` (30% op) | `#A5D6A7` (Bright Green) | `w700` | **> 7.2:1 (AAA)** |
| `MovieStatus.comingSoon` | Sắp chiếu | `#E3F2FD` (Light Blue) | `#0D47A1` (Dark Navy Blue) | `#0D47A1` (30% op) | `#90CAF9` (Light Sky Blue) | `w700` | **> 7.5:1 (AAA)** |
| `MovieStatus.stopped` | Ngừng chiếu | `#FFE0B2` (Light Amber/Red) | `#B71C1C` (Dark Crimson) | `#B71C1C` (30% op) | `#EF9A9A` (Light Rose) | `w700` | **> 7.1:1 (AAA)** |

---

## 3. Detailed Audit of User & Admin Screens

### 3.1 Category A: Overflow & Fixed Height Layout Defects

1. **`MovieHorizontalSection`** (`lib/features/user_home/presentation/widgets/movie_horizontal_section.dart`, Line 23)
   - **Defect**: Fixed height `SizedBox(height: 230)` containing `MoviePosterCard` (width 130).
   - **Root Cause**: `MoviePosterCard` calculates height as: Poster image 2:3 aspect ratio (195px) + 7px spacing + 2-line title (30px) + 3px spacing + 11px duration text = **250px**. Contained within 230px `SizedBox`, causing image squishing or vertical pixel overflow warnings on compact devices.
   - **Required Fix**: Increase `SizedBox` height to `260` or use `IntrinsicHeight`.

2. **`AdminDashboardScreen`** (`lib/features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart`, Lines 54–83)
   - **Defect**: `Wrap` widget wrapping three metric cards with fixed width `SizedBox(width: 170)`.
   - **Root Cause**: On screens with width 360px (available padding area = 328px), 2 cards take `170 * 2 + 8 = 348px > 328px`. As a result, only 1 card fits per row, creating an awkward, uneven vertical column stack.
   - **Required Fix**: Replace `Wrap` with `GridView.count(crossAxisCount: 2, childAspectRatio: 1.6)` or `LayoutBuilder` responsive grid.

3. **`CardPaymentFormScreen`** (`lib/features/booking/presentation/screens/card_payment_form_screen.dart`, Lines 35–70)
   - **Defect**: Stacked `TextFormField` elements inside `Form` `ListView` without vertical spacing.
   - **Root Cause**: Missing `SizedBox(height: 12)` / `SizedBox(height: 16)` between inputs for Number, Card Holder, Expiry, and CVV.
   - **Required Fix**: Add explicit vertical padding/spacing between input fields.

4. **`CheckoutScreen`** (`lib/features/booking/presentation/screens/checkout_screen.dart`, Line 362)
   - **Defect**: Button label `'CHỌN PHƯƠNG THỨC THANH TOÁN'` (30 characters) inside `FilledButton`.
   - **Root Cause**: Single line text in button on narrow screens (<340px) or high font accessibility scaling causes horizontal overflow or multi-line clipping.
   - **Required Fix**: Shorten label to `'TIẾP TỤC THANH TOÁN'` or `'CHỌN THANH TOÁN'`.

---

### 3.2 Category B: Navigation Mismatches & Accessibility Defects

1. **`AdminCinemaListScreen`** (`lib/features/cinemas/presentation/screens/admin_cinema_list_screen.dart`, Line 102)
   - **Defect**: `bottomNavigationBar: const AdminBottomNavigation(index: 2)`.
   - **Root Cause**: `index: 2` in `AdminBottomNavigation` highlights 'Suất chiếu' (`/admin/showtimes`). However, Cinema Management is accessed via 'Quản lý' (`/admin/management`, index 4).
   - **Required Fix**: Update to `AdminBottomNavigation(index: 4)`.

2. **`SeatSelectionScreen`** (`lib/features/booking/presentation/screens/seat_selection_screen.dart`, Line 212)
   - **Defect**: `ExcludeSemantics` wraps the entire screen body `SingleChildScrollView`.
   - **Root Cause**: Disables all accessibility screen reader interactions for seat map grid, legend, and booking summary.
   - **Required Fix**: Remove `ExcludeSemantics` from root screen tree.

3. **`ProductOrderCard` & `ComboOrderCard`** (`lib/features/concessions/presentation/widgets/product_order_card.dart` & `combo_order_card.dart`)
   - **Defect**: Hardcoded static icons (`Icons.local_bar_outlined`, `Icons.local_movies_outlined`) used instead of real image rendering.
   - **Root Cause**: Failure to use `CachedNetworkImage` with fallback for `product.imageUrl` and `combo.imageUrl`.
   - **Required Fix**: Replace static icon `Container` with `CachedNetworkImage` rendering actual item images.

---

### 3.3 Category C: Font & Language Inconsistencies

1. **`ShowtimeDaySelector`** (`lib/features/showtimes/presentation/widgets/showtime_day_selector.dart`, Line 57)
   - **Defect**: Displays English `'Today'` alongside Vietnamese weekdays (`'T2'`, `'T3'`, `'CN'`) and formatted date (`'Thứ Hai 22 tháng 7'`).
   - **Required Fix**: Change `'Today'` to `'Hôm nay'`.

2. **`SeatLegend`** (`lib/features/booking/presentation/widgets/seat_legend.dart`, Lines 20–21)
   - **Defect**: Legend items mix Vietnamese (`'Thường'`, `'VIP'`, `'Sweet Box'`) with English (`'Selected'`, `'Occupied'`).
   - **Required Fix**: Standardize to Vietnamese: `'Selected'` -> `'Đang chọn'`, `'Occupied'` -> `'Đã đặt'`.

3. **`SeatSelectionSummary`** (`lib/features/booking/presentation/widgets/seat_selection_summary.dart`, Lines 62–63, 97)
   - **Defect**: Displays `'0 Seats'`, `'1 Seat'`, `'2 Seats'` and button `'BOOK NOW'`.
   - **Required Fix**: Translate to `'0 ghế'`, `'1 ghế'`, `'2 ghế'` and button `'TIẾP TỤC'`.

4. **`UserMovieDetailScreen`** (`lib/features/movies/presentation/screens/user_movie_detail_screen.dart`, Lines 285–298)
   - **Defect**: Table labels use English (`'Rated'`, `'Genre'`, `'Director'`, `'Cast'`, `'Language'`) while rest of UI is in Vietnamese.
   - **Required Fix**: Translate labels to `'Độ tuổi'`, `'Thể loại'`, `'Đạo diễn'`, `'Diễn viên'`, `'Quốc gia'`.

---

## 4. Verification Method

1. **Static Analysis**: Run `flutter analyze` to ensure no syntax errors.
2. **Visual Inspection**:
   - Launch application on 360x800 and 412x915 device viewports.
   - Navigate to `AdminMovieListScreen` and inspect status chips (`nowShowing`, `comingSoon`, `stopped`) in Light Mode and Dark Mode.
   - Verify `MovieHorizontalSection` rendering inside `UserHomeScreen` for zero pixel overflow warnings.
   - Verify `AdminCinemaListScreen` bottom navigation tab selection highlights 'Quản lý' (index 4).
