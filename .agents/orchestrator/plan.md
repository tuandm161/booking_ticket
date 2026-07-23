# Execution Plan: CGV Cinema Flutter App Upgrade Project

## Overview
Comprehensive upgrade of the CGV Cinema Flutter ticket booking app according to requirements R1 to R4 and Acceptance Criteria.

## Milestones Breakdown

### Milestone 1: Exploration & Codebase Analysis
- **Goal**: Perform comprehensive code exploration, map models, data seeders, admin/user screens, widgets, animation patterns, and existing test suite (32 unit/widget tests).
- **Subagents**: Explorer 1, 2, 3
- **Deliverables**: Detailed analysis report on current codebase structure, state management, UI issues, seed data, and test harness.

### Milestone 2: Data Seeding & Hanoi Cinema Clusters Upgrade (R1)
- **Goal**:
  1. Add realistic high-resolution image URLs for all products & popcorn/beverage combos in `seed_service.dart` and Firestore structure.
  2. Add 4 Hanoi CGV cinema clusters (*CGV Vincom Bà Triệu*, *CGV Royal City*, *CGV Lotte Center Hà Nội*, *CGV Aeon Mall Hà Đông*) with respective screening rooms & showtimes.
- **Verification**: `flutter test` must pass all test cases (including existing and any updated seeding tests).
- **Subagents**: Worker, Reviewer, Challenger, Auditor

### Milestone 3: Admin Status Tags Contrast & Layout Overflow Fixes (R2)
- **Goal**:
  1. Fix low-contrast white text bug on status tags (`nowShowing`, `comingSoon`, `stopped`) in `AdminMovieListScreen` to ensure high contrast and sharp chip background.
  2. Review and fix layout overflow, alignment issues, and font inconsistency across ALL User screens (Home, Detail, Showtimes, Seats, Concessions, Checkout, Payment, Profile) and Admin screens (Dashboard, Movies, Rooms, Showtimes, Products, Combos, Vouchers).
- **Verification**: Zero yellow-black overflow indicators, `flutter analyze --no-fatal-infos` clean.
- **Subagents**: Worker, Reviewer, Challenger, Auditor

### Milestone 4: Advanced Filtering UX for User & Admin (R3)
- **Goal**:
  1. User Showtimes Screen: Add City filter (TP.HCM / Hà Nội) that dynamically filters available cinema clusters and showtimes.
  2. Admin Screens: Add status filter (Active / Hidden) and multi-field sorting (by date / name / revenue) for Movies, Rooms, Showtimes, Products, Combos, and Vouchers.
- **Verification**: City switching correctly displays 4 Hanoi cinemas vs TP.HCM cinemas; Admin filtering works cleanly without state bugs.
- **Subagents**: Worker, Reviewer, Challenger, Auditor

### Milestone 5: Micro-Animations & Premium Interactions (R4)
- **Goal**:
  1. Createpress scale animation widget (`Transform.scale(scale: 0.96)`) for all primary buttons (FilledButton, FloatingActionButton, Card taps).
  2. Implement smooth transition animations between screens and tabs (`PageTransitionsBuilder` / `AnimatedSwitcher`).
  3. Enhance dynamic glow/shadow and color transitions when selecting seats, combos, or showtimes.
- **Verification**: Tactile bounce feedback on main button taps, smooth transition animation on screen/tab switch.
- **Subagents**: Worker, Reviewer, Challenger, Auditor

### Milestone 6: Final Integration, Quality Audit & Release Verification
- **Goal**:
  1. Run `flutter analyze --no-fatal-infos` -> confirm `No issues found!`.
  2. Run `flutter test` -> confirm `32/32 tests pass (100%)`.
  3. Run Forensic Auditor for final integrity check.
  4. Handoff final report to Sentinel.
- **Subagents**: Worker, Reviewer, Challenger, Auditor
