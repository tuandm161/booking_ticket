# Project: CGV Cinema Ticket Booking App Upgrade

## Architecture Overview
Flutter application (`booking_ticket`) using Provider / Firestore / local state management.
- Source root: `lib/`
- Data models & services: `lib/models/` or `lib/features/*/models/`, `lib/core/services/seed_service.dart`
- User UI screens: `lib/features/*/presentation/screens/`
- Admin UI screens: `lib/features/*/presentation/screens/`
- Shared widgets: `lib/core/widgets/` or `lib/features/*/presentation/widgets/`, `lib/shared/widgets/`
- Unit / Widget test suite: `test/` (41 test cases)

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | Exploration & Analysis | Codebase map, screen audit, test analysis | None | DONE |
| 2 | Data & Seeding Upgrade (R1) | `seed_service.dart`, combo images, 4 Hanoi cinemas | M1 | DONE |
| 3 | Admin Tag Contrast & Layout Fixes (R2) | `AdminMovieListScreen` tags, User/Admin overflow fixes | M1 | DONE |
| 4 | Advanced User & Admin Filtering (R3) | User Showtimes city filter, Admin status/sort filters | M2, M3 | DONE |
| 5 | Micro-Animations & Interactions (R4) | Press scaling button, page transitions, dynamic feedback | M3, M4 | IN_PROGRESS |
| 6 | Verification & Compliance | `flutter analyze`, `flutter test`, Forensic Audit | M2, M3, M4, M5 | PLANNED |

## Code Layout
- `lib/core/services/seed_service.dart`: Initial data seeding for products, cinemas, showtimes, combos.
- `lib/features/movies/presentation/widgets/movie_status_chip.dart`: Status chip widget with WCAG AAA contrast ratio colors.
- `lib/features/showtimes/presentation/screens/user_showtimes_screen.dart`: User showtime selection screen with City filter (TP.HCM / Hà Nội).
- `lib/shared/widgets/admin_filter_sort_header.dart`: Reusable Admin filtering (Active/Hidden) & multi-field sorting widget header.
- `lib/shared/widgets/`: Shared buttons, tags, custom transition wrappers.
- `test/`: Test suite requiring 100% pass (41/41 tests).
