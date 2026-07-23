# Changes Summary

## Target File
- `lib/features/movies/presentation/widgets/movie_status_chip.dart`

## Modifications
- Updated text color for `MovieStatus.stopped` chip from `const Color(0xFFB71C1C)` to `const Color(0xFF8B0000)`.
- Background color remains `const Color(0xFFFFE0B2)`.

## Rationale
- Foreground `Color(0xFF8B0000)` against background `Color(0xFFFFE0B2)` provides a 7.89:1 contrast ratio, meeting the WCAG AAA requirement (minimum 7.0:1 contrast ratio).

## Verification
- `flutter analyze --no-fatal-infos`: 0 issues found.
- `flutter test`: 32/32 tests passed.
