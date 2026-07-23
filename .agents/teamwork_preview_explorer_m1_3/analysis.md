# Technical Analysis & Audit Report — Booking Ticket Upgrade (M1_3)

**Working Directory**: `d:\prm\Project\booking_ticket\.agents\teamwork_preview_explorer_m1_3`  
**Date**: 2026-07-21  
**Author**: Explorer Subagent M1_3  

---

## 1. Baseline System & Test Status Audit

### 1.1 Static Code Analysis (`flutter analyze --no-fatal-infos`)
- **Command Executed**: `flutter analyze --no-fatal-infos` in `d:\prm\Project\booking_ticket`
- **Result**: `No issues found! (ran in 6.8s)`
- **Status**: **PASS** (Zero warnings, lints, or fatal errors).

### 1.2 Automated Unit & Widget Test Suite (`flutter test`)
- **Command Executed**: `flutter test` in `d:\prm\Project\booking_ticket`
- **Result**: **32 / 32 tests passed!** (Execution time ~6 seconds)
- **Status**: **PASS** (100% test pass baseline verified).

#### Breakdown of Test Suite (32 Tests across 18 Test Files):
1. `test/core/utils/seat_generator_test.dart` (3 tests: VIP rows/couple seats, no VIP, invalid input)
2. `test/core/utils/validators_test.dart` (2 tests: required/email/password, positive integer/URL/voucher code)
3. `test/features/admin_dashboard/dashboard_metrics_test.dart` (1 test: revenue and couple capacity calculation)
4. `test/features/auth/auth_controller_test.dart` (2 tests: unknown role fallback, admin role mapping)
5. `test/features/booking/checkout_validation_test.dart` (1 test: checkout missing/expired hold validation)
6. `test/features/booking/order_totals_test.dart` (2 tests: seat/product/combo/voucher totals, invalid voucher revalidation)
7. `test/features/booking/seat_availability_test.dart` (2 tests: availability priority, expired hold release)
8. `test/features/booking/seat_hold_repository_test.dart` (3 tests: hold cleanup, reservation collision rejection, release matching)
9. `test/features/booking/seat_price_calculator_test.dart` (1 test: standard/VIP/couple price calculation)
10. `test/features/booking/ticket_grouping_test.dart` (1 test: start time grouping & upcoming/past sorting)
11. `test/features/concessions/combo_form_controller_test.dart` (1 test: combo draft item quantities preservation)
12. `test/features/movies/movie_form_controller_test.dart` (1 test: movie draft manual source & fields)
13. `test/features/movies/tmdb_mapping_test.dart` (1 test: TMDB details mapping)
14. `test/features/rooms/room_form_controller_test.dart` (2 tests: layout preview regeneration, copyWith preservation)
15. `test/features/showtimes/showtime_form_controller_test.dart` (1 test: draft copyWith preservation)
16. `test/features/showtimes/showtime_overlap_test.dart` (1 test: interval overlap detection)
17. `test/features/user_home/user_catalog_filter_test.dart` (3 tests: popular sort, active without showtime hidden, bookable title/director/genre search)
18. `test/features/vouchers/voucher_calculation_test.dart` (2 tests: percentage max discount, fixed amount & rejection)
19. `test/features/vouchers/voucher_form_controller_test.dart` (1 test: percentage constraints support)
20. `test/widget_test.dart` (1 test: login placeholder startup)

---

## 2. User Showtimes Screen Audit & City Filtering Architecture

### 2.1 File Location & Inspection
- **File**: `lib/features/showtimes/presentation/screens/user_showtimes_screen.dart`
- **Model**: `lib/features/cinemas/models/cinema.dart`
- **Data Service**: `lib/core/services/seed_service.dart`

### 2.2 Findings
1. **Cinema Model Data Structure**:
   `Cinema` (`lib/features/cinemas/models/cinema.dart:8`) already contains `final String city;`.
   In `seed_service.dart:54,62,70,78`, existing cinemas are initialized with `city: 'TP.HCM'`.
   Milestone 2 will add 4 Hanoi cinemas (`CGV Vincom Bà Triệu`, `CGV Royal City`, `CGV Lotte Center Hà Nội`, `CGV Aeon Mall Hà Đông`) with `city: 'Hà Nội'`.

2. **Current Screen Implementation**:
   - `UserShowtimesScreen` watches `activeCinemasProvider` (`lines 24, 67-70`).
   - `_ShowtimeDaysState` filters showtimes using `_selectedCinemaId` (`lines 127-136`).
   - The cinema chip bar (`lines 158-204`) displays horizontal `ChoiceChip`s for cinemas. Currently, it has no higher-level City selector.

### 2.3 City Filtering Integration Proposal (Requirement R3)
1. **City Selection Bar**:
   - Add a City filter tab/segmented control above or within the cinema selector bar in `_ShowtimeDaysState`.
   - City options: `['Tất cả', 'TP.HCM', 'Hà Nội']` (or dynamic unique cities derived from active cinemas list via `widget.cinemas.map((c) => c.city).where((c) => c.isNotEmpty).toSet()`).
   - Default city selection: `'TP.HCM'` or `'Tất cả'`.

2. **Cascading Cinema Chips & Showtime Filter Logic**:
   - `_selectedCity`: String? (e.g. `'TP.HCM'`, `'Hà Nội'`, or `null` for All).
   - Filter cinemas presented in cinema chips:
     `final visibleCinemas = widget.cinemas.where((c) => _selectedCity == null || c.city == _selectedCity).toList();`
   - Reset `_selectedCinemaId = null` if selected cinema is no longer in `visibleCinemas`.
   - Showtime filtering (`_filtered`):
     ```dart
     final cinemaMap = {for (final c in widget.cinemas) c.id: c};
     return widget.items.where((s) {
       final matchesDay = s.startTime.year == _selected.year &&
           s.startTime.month == _selected.month &&
           s.startTime.day == _selected.day;
       final cinema = cinemaMap[s.cinemaId];
       final matchesCity = _selectedCity == null || cinema?.city == _selectedCity;
       final matchesCinema = _selectedCinemaId == null || s.cinemaId == _selectedCinemaId;
       return matchesDay && matchesCity && matchesCinema;
     }).toList();
     ```

---

## 3. Admin Screens Status Filtering & Sorting Audit

### 3.1 Screen-by-Screen Audit Matrix

| Screen | File Path | Current Status Filter | Current Sorting | Proposed Status Filter | Proposed Sorting Options |
|---|---|---|---|---|---|
| **Movies** | `lib/features/movies/presentation/screens/admin_movie_list_screen.dart` | `MovieStatus` chips + `_includeInactive` chip (`l.59-80`) | Hardcoded order | `[Tất cả, Đang hoạt động, Tạm ẩn]` + `MovieStatus` | Ngày phát hành (`releaseDate`), Tên phim (`title`), Doanh thu/Lượt đặt (`bookingCount`) |
| **Rooms** | `lib/features/rooms/presentation/screens/admin_room_list_screen.dart` | `SegmentedButton` (`Tất cả` vs `Đang hoạt động`) (`l.38-46`) | Default list order | `[Tất cả, Đang hoạt động, Tạm ẩn]` + query search | Tên phòng (`name`), Sức chứa (`totalSeats`), Ngày tạo (`createdAt`) |
| **Showtimes** | `lib/features/showtimes/presentation/screens/admin_showtime_list_screen.dart` | `FilterChip` (`_onlyActive`) (`l.51-55`) | `sort((a,b) => startTime.compareTo(startTime))` | `[Tất cả, Đang hoạt động, Tạm ẩn]` | Giờ chiếu (`startTime`), Giá vé (`price`), Tên phim (`movieTitle`) |
| **Products** | `lib/features/concessions/presentation/screens/admin_product_list_screen.dart` | `FilterChip` (`_onlyAvailable`) (`l.73-77`) | Default list order | `[Tất cả, Đang bán, Tạm ẩn]` + Category filter | Tên sản phẩm (`name`), Giá tiền (`price`), Ngày tạo (`createdAt`) |
| **Combos** | `lib/features/concessions/presentation/screens/admin_combo_list_screen.dart` | `FilterChip` (`_onlyAvailable`) (`l.51-56`) | Default list order | `[Tất cả, Đang bán, Tạm ẩn]` | Tên combo (`name`), Giá tiền (`price`), Ngày tạo (`createdAt`) |
| **Vouchers** | `lib/features/vouchers/presentation/screens/admin_voucher_list_screen.dart` | `FilterChip` (`_onlyActive`) (`l.54-59`) | Default list order | `[Tất cả, Đang bật, Tạm ẩn/Hết hạn]` | Mã voucher (`code`), Giá trị giảm (`discountValue`), Ngày hết hạn (`endDate`) |

### 3.2 Standardized Admin Filter & Sort Bar Architecture
To ensure high UX consistency and clean code, implement a shared reusable widget `AdminFilterSortHeader` in `lib/shared/widgets/admin_filter_sort_header.dart` with:
1. `SegmentedButton` or `ChoiceChip` group for Status: `[Tất cả, Đang hoạt động (Active), Tạm ẩn (Hidden)]`.
2. `DropdownButton` or Popup Menu for Sort Field and Sort Order (Ascending / Descending toggle).
3. Live reactive filtering in `setState()` or Riverpod providers.

---

## 4. UI Interactive Feedback, Press Scale Widget & Page Transitions Audit

### 4.1 Press Scale Widget Recommendation (`Transform.scale(scale: 0.96)`)
- **Objective**: Provide tactile micro-interaction feedback on tap for all primary buttons (`FilledButton`, `FloatingActionButton`, cards, chips).
- **Implementation Pattern (`AppPressScale` / `PressScaleWidget`)**:
  ```dart
  class AppPressScale extends StatefulWidget {
    const AppPressScale({
      super.key,
      required this.child,
      this.onTap,
      this.scale = 0.96,
      this.duration = const Duration(milliseconds: 100),
    });

    final Widget child;
    final VoidCallback? onTap;
    final double scale;
    final Duration duration;

    @override
    State<AppPressScale> createState() => _AppPressScaleState();
  }

  class _AppPressScaleState extends State<AppPressScale> {
    bool _isPressed = false;

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? widget.scale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      );
    }
  }
  ```
- **Targets for Integration**:
  - `FilledButton` / `ElevatedButton` primary submit buttons across Checkout, Payment, Login, Seat Selection.
  - `FloatingActionButton` across Admin list screens.
  - `ShowtimeChip` in user showtimes screen.
  - `ProductOrderCard` & `ComboOrderCard` stepper controls and cards.
  - Movie cards & Cinema selection cards.

### 4.2 Dynamic Feedback Enhancements (Glow / Shadow / Color Transitions)
1. **Seat Selection (`SeatWidget` in `lib/features/booking/presentation/widgets/seat_widget.dart`)**:
   - Currently: Static background colors (`Colors.green` for selected, `Colors.orange` for heldByMe, `Colors.blueGrey` for available) inside a flat `Material` widget.
   - Upgrade: Replace `Material` with `AnimatedContainer`:
     - When `status == SeatAvailability.selected`: Add green glow shadow `BoxShadow(color: Colors.green.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)`.
     - When `status == SeatAvailability.heldByMe`: Add orange glow shadow `BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)`.
     - Scale up slightly (scale 1.05) when selected for clear visual feedback.

2. **Showtimes (`ShowtimeChip` in `lib/features/showtimes/presentation/widgets/showtime_chip.dart`)**:
   - Currently: `AnimatedContainer` with `AppTheme.cgvRed` border when `isSelected`.
   - Upgrade: Add ambient red glow when selected (`BoxShadow(color: AppTheme.cgvRed.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)`), wrapped with `AppPressScale`.

3. **Concessions & Combos (`ProductOrderCard` / `ComboOrderCard`)**:
   - Upgrade: When `quantity > 0`, apply active red elevation glow (`BoxShadow(color: AppTheme.cgvRed.withValues(alpha: 0.18), blurRadius: 12, offset: Offset(0, 4))`), and animated scale on step buttons (`+` / `-`).

### 4.3 Smooth Page & Screen Transitions Architecture
1. **Theme-Level Transition Theme (`app_theme.dart`)**:
   Add `pageTransitionsTheme` to `ThemeData`:
   ```dart
   pageTransitionsTheme: const PageTransitionsTheme(
     builders: {
       TargetPlatform.android: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
       TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
       TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
     },
   )
   ```
2. **GoRouter Transition Customization (`app_router.dart`)**:
   Define `CustomTransitionPage` helper for seamless horizontal slide + fade transitions between key user/admin screens.

---

## 5. Summary & Handoff Readiness

All baseline requirements and verification checks for M1_3 have been completed in read-only mode:
- Codebase integrity verified (32/32 tests pass, zero lint issues).
- Clear, actionable implementation designs documented for User showtimes city filtering, Admin status filtering & sorting, and UI micro-animations/press scaling feedback.
