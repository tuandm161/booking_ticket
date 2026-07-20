# AGENTS.md — Codex Project Guide

> Đặt file này tại **root của Flutter repository**, cùng cấp với `pubspec.yaml`.
> Đây là chỉ dẫn mặc định cho mọi coding agent làm việc trong repository này.

## 1. Project mission

Xây dựng ứng dụng Android đặt vé xem phim bằng Flutter/Dart cho **một rạp có nhiều phòng chiếu**. Đây là project cuối môn, vì vậy ưu tiên cao nhất là:

1. Luồng chính chạy hoàn chỉnh và ổn định.
2. Code dễ đọc, dễ demo, dễ sửa.
3. Hoàn thành đúng scope đã chốt.
4. Không tăng độ phức tạp bằng kiến trúc hoặc công nghệ không cần thiết.

Ứng dụng có hai role trong cùng một APK:

- `user`: xem phim, chọn suất, giữ ghế 10 phút, chọn bỏng nước/combo, áp voucher, thanh toán giả lập, nhận vé QR.
- `admin`: CRUD phòng, phim, suất chiếu, sản phẩm, combo, voucher; xem booking và dashboard.

## 2. Sources of truth and precedence

Trước khi code, luôn đọc các tài liệu sau:

1. `AGENTS.md` — quy tắc làm việc toàn repository.
2. `README.md` — bản đồ phase.
3. `00_PRODUCT_SCOPE.md` — phạm vi sản phẩm đã chốt.
4. `01_TECH_STACK_ARCHITECTURE.md` — kiến trúc và convention.
5. `02_FIRESTORE_SCHEMA.md` — schema dữ liệu chính thức.
6. `03_AGENT_EXECUTION_RULES.md` — quy trình và quality gate.
7. `IMPLEMENTATION_STATUS.md` — trạng thái thực tế.
8. File `PHASE_XX_*.md` đang được giao.

Nếu tài liệu có khác biệt, áp dụng thứ tự ưu tiên:

1. Yêu cầu hiện tại của user trong task đang giao.
2. `AGENTS.md`.
3. File phase hiện tại đối với chi tiết triển khai của phase đó.
4. `00_PRODUCT_SCOPE.md` và `02_FIRESTORE_SCHEMA.md` đối với nghiệp vụ/schema.
5. `01_TECH_STACK_ARCHITECTURE.md` và `03_AGENT_EXECUTION_RULES.md`.

Không âm thầm chọn một cách hiểu khi có xung đột thật sự. Ghi rõ xung đột trong báo cáo và thực hiện phương án ít thay đổi scope nhất.

## 3. Phase discipline

Chỉ triển khai **một phase được giao**.

Không được:

- Làm trước chức năng thuộc phase sau.
- Refactor diện rộng không cần cho phase hiện tại.
- Thêm feature “tiện thể”.
- Đánh dấu phase hoàn thành khi còn Acceptance Criteria chưa đạt.
- Bỏ qua test/analyze để chuyển phase.

Workflow bắt buộc:

1. Đọc file phase hiện tại.
2. Kiểm tra repository và code đã có.
3. So sánh code hiện tại với deliverables.
4. Viết kế hoạch thay đổi ngắn trong nội bộ task.
5. Triển khai theo danh sách file của phase; được điều chỉnh tên file nhỏ nếu code hiện tại đã có cấu trúc tương đương.
6. Viết hoặc cập nhật test.
7. Chạy format, analyze và test.
8. Tự sửa lỗi phát sinh.
9. Cập nhật `IMPLEMENTATION_STATUS.md`.
10. Trả báo cáo hoàn thành phase.

Không bắt đầu phase mới trong cùng task trừ khi user giao rõ nhiều phase.

## 4. Phase map

| Phase | Deliverable chính | Bắt buộc |
|---|---|---|
| 01 | Bootstrap, theme, router khung, core utilities | Có |
| 02 | Firebase Auth, user document, role routing | Có |
| 03 | Models, Firestore schema/rules, seed 6 phòng | Có |
| 04 | Admin CRUD phòng chiếu | Có |
| 05 | Admin CRUD phim, TMDB prefill | Có |
| 06 | Admin CRUD suất chiếu, kiểm tra trùng phòng | Có |
| 07 | Admin CRUD sản phẩm, combo, voucher | Có |
| 08 | User home, catalog, search, movie detail | Có |
| 09 | Chọn suất, ghế, giữ ghế 10 phút | Có |
| 10 | Bỏng nước, voucher, checkout, payment giả lập | Có |
| 11 | Vé QR, My Tickets, in-app notifications | Có |
| 12 | Admin bookings và dashboard | Có |
| 13 | QA, polish, security review, build APK | Có |
| 14 | Firebase Cloud Messaging | Tùy chọn cuối |

Phase 14 chỉ được triển khai sau khi Phase 13 ổn định hoặc khi user yêu cầu trực tiếp.

## 5. Hard product constraints

Các quyết định sau đã chốt và không được tự ý thay đổi:

- Android only.
- Một rạp duy nhất, nhiều phòng.
- Seed sẵn 6 phòng; Admin vẫn được CRUD phòng.
- User và Admin ở cùng một ứng dụng, giao diện tách theo role.
- Chỉ có hai role: `user`, `admin`.
- Admin có toàn quyền; không xây permission matrix.
- TMDB chỉ dùng trong Admin để tìm và tự điền form phim.
- User không xem dữ liệu trực tiếp từ TMDB.
- Mọi phim User thấy phải nằm trong Firestore và có suất chiếu tương lai.
- Không dùng SQLite hoặc `sqflite`.
- Không có backend riêng.
- Không dùng Cloud Functions trong phần bắt buộc.
- Không dùng Firebase Storage; ảnh lưu bằng URL.
- Không có thanh toán thật.
- Không thanh toán tại quầy.
- Không lưu thông tin thẻ.
- Không cho User hủy vé.
- Không hoàn tiền.
- Không QR scanner.
- Không quản lý tồn kho bỏng nước.
- Booking chỉ được tạo sau payment giả lập thành công.
- Ghế phải được giữ 10 phút trước checkout.
- Hold seat và checkout phải dùng Firestore transaction.

## 6. Tech stack

Chỉ sử dụng stack đã chốt:

- Flutter, Dart, null safety.
- `flutter_riverpod`.
- `go_router`.
- `dio`.
- `firebase_core`.
- `firebase_auth`.
- `cloud_firestore`.
- `shared_preferences`.
- `qr_flutter`.
- `cached_network_image`.
- `intl`.
- `url_launcher`.
- `firebase_messaging` chỉ ở Phase 14.

Không thêm package mới nếu chức năng có thể làm gọn bằng SDK hoặc package đã có. Khi thật sự cần package mới:

1. Giải thích lý do trong báo cáo.
2. Kiểm tra package còn duy trì và tương thích Flutter hiện tại.
3. Chỉ thêm package phục vụ phase đang làm.

Không dùng:

- Freezed.
- `json_serializable`.
- Riverpod code generation.
- BLoC/GetX/Provider song song với Riverpod.
- Một framework DI khác.

Model dùng `fromMap`, `toMap`, `copyWith` viết thủ công.

## 7. Repository architecture

Dùng feature-first architecture, repository nhẹ:

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── app_router.dart
│   ├── app_theme.dart
│   └── app_startup.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── rooms/
│   ├── movies/
│   ├── showtimes/
│   ├── concessions/
│   ├── vouchers/
│   ├── booking/
│   ├── notifications/
│   ├── profile/
│   ├── user_home/
│   └── admin_dashboard/
└── shared/
    ├── models/
    └── widgets/
```

Cấu trúc feature mặc định:

```text
feature_name/
├── data/
│   ├── feature_repository.dart
│   └── feature_api.dart
├── models/
├── providers/
└── presentation/
    ├── screens/
    └── widgets/
```

Quy tắc placement:

- Firestore/Dio access nằm trong `data/`.
- Model thuộc riêng feature nằm trong `models/` của feature.
- Model dùng chung thật sự mới đặt trong `shared/models/`.
- Provider/controller nằm trong `providers/`.
- Widget không truy cập Firestore/Dio trực tiếp.
- Pure helpers dùng chung đặt trong `core/utils/` hoặc `core/extensions/`.
- Không tạo `utils.dart`, `helpers.dart` tổng hợp thiếu ngữ nghĩa.

## 8. Naming and Dart conventions

- File: `snake_case.dart`.
- Class/enum: `UpperCamelCase`.
- Variable/function/provider: `lowerCamelCase`.
- Constants: `lowerCamelCase` với `const`, không dùng ALL_CAPS.
- Provider đặt hậu tố rõ nghĩa: `RepositoryProvider`, `StreamProvider`, `ControllerProvider` khi cần phân biệt.
- Screen: `...Screen`.
- Reusable UI: `...Card`, `...Tile`, `...Sheet`, `...Dialog`, `...View`.
- Repository interface không bắt buộc nếu chỉ có một implementation.

Code requirements:

- Null safety đầy đủ.
- Tránh `dynamic`; parse dữ liệu với type check.
- Không dùng `!` nếu chưa chứng minh non-null.
- Không dùng `catch (_) {}` để nuốt lỗi.
- Không để `print` hoặc log chứa token/card data.
- Không dùng `DateTime.now()` rải rác; dùng `ClockService` cho business logic.
- Tiền là `int` VND, không dùng `double`.
- Timestamp Firestore được chuyển đổi qua helper thống nhất.
- Collection path lấy từ `FirestorePaths`.
- Phụ thu ghế lấy từ `PricingConstants`.
- Role/status/category dùng enum hoặc constants, không hard-code rải rác.

## 9. Riverpod rules

Sử dụng Riverpod theo mục đích:

- `Provider`: Firebase instances, Dio, repositories, services, pure dependencies.
- `StreamProvider`: dữ liệu Firestore realtime.
- `FutureProvider`: đọc một lần hoặc dữ liệu tổng hợp.
- `NotifierProvider`/`StateNotifierProvider`: state đồng bộ như ghế chọn, order draft.
- `AsyncNotifierProvider`: login, CRUD mutation, hold seats, checkout.

Không đặt business logic trong widget.

Widget chỉ nên:

1. Watch/read provider.
2. Render state.
3. Gửi user intent vào controller.
4. Hiển thị navigation/snackbar/dialog phù hợp.

Mọi async state phải xử lý đủ:

- loading.
- success.
- empty khi có ý nghĩa.
- error với message thân thiện và retry khi có thể.

Không dùng `setState` cho business state. Chỉ dùng cho UI state rất cục bộ như ẩn/hiện password hoặc tab controller đơn giản.

## 10. Routing and authorization

Dùng `go_router`.

Redirect rules:

- Chưa đăng nhập chỉ vào auth routes.
- `role == user` không vào `/admin/*`.
- `role == admin` mặc định vào `/admin/dashboard`.
- Đã đăng nhập mà vào auth route thì redirect theo role.
- Splash/startup phải chờ Firebase init và user role resolution.

Không chỉ ẩn nút Admin ở UI. Firestore Security Rules phải bảo vệ dữ liệu Admin.

Không cho client tự thay đổi `users/{uid}.role`.

## 11. Firestore schema rules

Collections chính thức:

```text
users
movies
rooms
showtimes
products
combos
vouchers
bookings
notifications
```

Không đổi tên collection hoặc field chính thức mà không:

1. Cập nhật `02_FIRESTORE_SCHEMA.md`.
2. Cập nhật model/repository/rules/test liên quan.
3. Ghi deviation trong `IMPLEMENTATION_STATUS.md`.

Data rules:

- `users/{uid}` dùng Firebase UID; collection khác dùng auto ID.
- Tạo/sửa dữ liệu dùng server timestamp khi phù hợp.
- Không hard delete dữ liệu đã được booking/showtime tham chiếu.
- Dùng `isActive`/`isAvailable` để soft delete.
- Booking là immutable snapshot.
- Booking không update/delete từ User client.
- User chỉ đọc booking/notification của chính mình.
- Admin CRUD metadata theo rules.

## 12. Core domain invariants

### 12.1 Movie visibility

User chỉ thấy phim khi:

- `movie.isActive == true`.
- Có ít nhất một showtime active với `startTime > now`.

Sections trang chủ:

- Đang chiếu: `status == nowShowing`.
- Sắp chiếu: `status == comingSoon`.
- Phổ biến: featured trước, sau đó `bookingCount` giảm dần.

Không tạo section phim TMDB riêng.

### 12.2 Room and seats

- Seed 6 phòng ở Phase 03.
- `roomType`: `standard | vip | threeD`.
- Seat type: `standard | vip | couple`.
- Ghế couple nằm ở hàng cuối.
- Một ghế couple là một seat code, `capacity = 2`.
- Sơ đồ ghế được sinh tự động từ cấu hình phòng.

Không cho chỉnh layout phòng đã có dữ liệu phụ thuộc nếu thay đổi gây sai booking/showtime lịch sử.

### 12.3 Seat pricing

Pure function bắt buộc:

```text
Standard = basePrice
VIP      = basePrice + 20,000
Couple   = basePrice * 2 + 20,000
```

Không thêm phụ thu khác.

### 12.4 Showtime conflict

`endTime = startTime + movie.durationMinutes + 15 phút dọn phòng`.

Không cho tạo showtime trùng thời gian trong cùng phòng.

Conflict khi hai khoảng thời gian overlap:

```text
newStart < existingEnd && newEnd > existingStart
```

Khi edit, bỏ qua chính showtime đang sửa.

### 12.5 Seat hold

State seat theo thứ tự ưu tiên:

1. booked.
2. active hold của current reservation.
3. active hold của user/reservation khác.
4. expired hold được xem là available.
5. local selected.
6. available.

`selected` chỉ là local Riverpod state cho đến khi User nhấn tiếp tục.

Hold transaction phải:

1. Đọc showtime.
2. Lazy-clean hold hết hạn.
3. Kiểm tra seat tồn tại trong room.
4. Kiểm tra chưa booked.
5. Kiểm tra không active-held bởi người khác.
6. Ghi `userId`, `reservationId`, `expiresAt`.

Countdown luôn tính từ `holdExpiresAt - clock.now()`, không giảm một biến đếm độc lập.

Release chỉ xóa hold matching cả current `userId` và `reservationId`.

### 12.6 Checkout

Payment giả lập thành công **chưa đủ** để coi booking thành công. Sau payment simulation phải chạy final Firestore transaction.

Final transaction phải validate lại:

- Showtime active.
- Hold chưa hết hạn.
- Tất cả ghế thuộc current reservation.
- Không ghế nào booked.
- Seat code tồn tại trong room.
- Product/combo còn available.
- Voucher còn hợp lệ và còn lượt.

Transaction phải tự tính lại giá từ Firestore, không tin total từ client state.

Writes phải atomic:

1. Xóa held seats của reservation.
2. Thêm seat codes vào booked list.
3. Tăng `movie.bookingCount` theo tổng seat capacity.
4. Tăng `voucher.usedCount` đúng 1 nếu dùng voucher.
5. Tạo immutable booking snapshot.
6. Tạo notification.

Nếu bất kỳ validation nào fail, không được có partial write.

### 12.7 Voucher

Types:

- `percentage`.
- `fixedAmount`.

Voucher valid khi:

- active.
- `startDate <= now <= endDate`.
- `usedCount < usageLimit`.
- subtotal đạt `minOrderValue`.

Percentage discount phải tôn trọng `maxDiscount`.

Code voucher lưu uppercase. Không tăng `usedCount` khi chỉ apply; chỉ tăng trong checkout transaction.

### 12.8 Products and combos

Products là bỏng, nước, snack.

- Mỗi size là một product riêng.
- Không quản lý stock.
- Combo chứa snapshot tham chiếu product và quantity để Admin dễ quản lý.
- Booking lưu snapshot tên, số lượng, đơn giá, thành tiền.

### 12.9 Booking and tickets

Booking chỉ có sau thanh toán thành công:

- `paymentStatus = paid`.
- `bookingStatus = confirmed`.

Không hỗ trợ cancel/refund.

Phân loại vé:

- Sắp diễn ra: dựa trên `startTime` tương lai.
- Đã xem: dựa trên `startTime`/thời gian suất đã qua.

Không cần Admin đánh dấu `completed`.

QR chỉ encode dữ liệu giả lập như `booking:<bookingCode>`.

## 13. TMDB integration

TMDB chỉ hỗ trợ Admin prefill form.

Token phải đọc bằng:

```dart
const tmdbReadToken = String.fromEnvironment('TMDB_READ_TOKEN');
```

Run example:

```bash
flutter run --dart-define=TMDB_READ_TOKEN=<token>
```

Rules:

- Không commit token.
- Không ghi token trong source, test fixture hoặc log.
- Nếu token rỗng, manual movie CRUD vẫn phải hoạt động.
- Nút TMDB phải disable hoặc hiển thị hướng dẫn cấu hình.
- Chọn kết quả TMDB chỉ prefill form; không tự lưu Firestore.
- Admin được sửa mọi field trước khi save.
- TMDB age rating không được tin tuyệt đối; để Admin nhập.

## 14. UI and UX requirements

Target chính: Android portrait, width 360–430dp.

Mọi screen đọc dữ liệu phải có:

- loading.
- empty.
- error + retry.
- success.

Mọi CRUD form phải có:

- label rõ ràng.
- validation.
- keyboard type phù hợp.
- disable submit trong lúc xử lý.
- progress indicator.
- success/error snackbar.
- confirm dialog trước delete/deactivate khi cần.

General UI rules:

- List lớn dùng builder.
- Ảnh dùng placeholder/error state.
- Không để text overflow.
- Nút không được double-submit.
- Seat state không chỉ phân biệt bằng màu; dùng icon/legend/border.
- Hold countdown phải luôn nhìn thấy ở các màn sau khi hold.
- Checkout phải hiển thị rõ seat subtotal, concessions, discount, total.
- Card form giả lập không lưu card data sau khi rời screen.

## 15. Error handling

Repository map Firebase/Dio errors sang `AppException`.

Tối thiểu hỗ trợ:

- network.
- unauthorized.
- permission denied.
- validation.
- not found.
- seat unavailable.
- seat hold expired.
- voucher invalid.
- item unavailable.
- unknown.

UI không hiển thị raw stack trace hoặc Firebase exception code khó hiểu cho User.

Không nuốt lỗi. Khi lỗi không recover được, log an toàn ở debug và hiển thị message thân thiện.

## 16. Testing requirements

Ưu tiên test pure business logic và concurrency boundary.

Mỗi phase phải thêm test đúng file phase yêu cầu. Tối thiểu toàn project cần test:

- validators.
- model mapping.
- seat generator.
- seat pricing.
- showtime conflict.
- popular movie sorting.
- seat availability/expiry.
- voucher calculation.
- order totals.
- checkout validation.
- booking snapshot mapping.

Repository transaction test có thể dùng fake/mocks phù hợp với cấu trúc hiện tại. Không bỏ test chỉ vì Firebase khó mock; ít nhất tách pure validation/calculation để test độc lập.

Critical manual concurrency test:

1. Hai account hoặc hai emulator mở cùng showtime.
2. User A hold ghế A1.
3. User B không thể hold A1 khi hold còn hiệu lực.
4. Sau expiry, User B có thể hold A1.
5. Chỉ một checkout có thể book A1.

## 17. Commands and quality gates

Trước khi kết thúc mỗi phase, chạy:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Khi Phase 13/release:

```bash
flutter build apk --debug
flutter build apk --release
```

Nếu repository có Firebase rules test hoặc script seed riêng, chạy thêm lệnh được ghi trong phase/README.

Không báo “hoàn thành” khi:

- `flutter analyze` còn error.
- Test do phase tạo ra còn fail.
- App không compile.
- Acceptance Criteria chính chưa pass.
- Manual happy path bị crash.

Warning có thể giữ lại chỉ khi không do phase tạo ra và phải ghi rõ trong báo cáo.

## 18. Firebase and environment setup

Không commit secrets hoặc project-specific private configuration ngoài các file Firebase client config cần thiết cho Android app theo hướng dẫn chính thức.

TMDB token dùng `--dart-define`.

Agent không được giả vờ đã cấu hình Firebase Console nếu chưa thể thực hiện. Khi cần thao tác ngoài code:

- Ghi chính xác bước user phải làm.
- Giữ app fail-safe với thông báo cấu hình rõ ràng khi có thể.
- Không hard-code mock production data để che thiếu cấu hình.

Seed data phải idempotent hoặc có guard tránh seed trùng khi chạy lại.

## 19. Documentation maintenance

Sau mỗi phase, cập nhật `IMPLEMENTATION_STATUS.md`:

```text
### Phase XX

- Status: Completed | Blocked | In progress
- Started at:
- Completed at:
- Files created:
- Files modified:
- Commands run:
- Tests:
- Manual verification:
- Decisions/deviations:
- Remaining issues:
```

Nếu thay đổi schema hoặc invariant:

- Cập nhật tài liệu liên quan trong cùng change.
- Không để docs và code lệch nhau.

Không sửa Acceptance Criteria để hợp thức hóa implementation thiếu.

## 20. Git and change hygiene

- Không sửa file không liên quan.
- Không format hàng loạt ngoài phạm vi nếu gây diff lớn vô ích.
- Không xóa code đang hoạt động nếu chưa có replacement.
- Không commit generated build artifacts.
- Không commit `.dart_tool/`, `build/`, token hoặc thông tin thẻ demo.
- Giữ commit/patch theo phase và mục tiêu rõ ràng.

Commit message gợi ý:

```text
feat(phase-01): bootstrap flutter project
feat(phase-05): add admin movie CRUD and TMDB prefill
fix(phase-09): prevent checkout with expired seat hold
test(phase-10): cover voucher and checkout calculations
```

## 21. Definition of Done for a phase

Một phase chỉ hoàn thành khi:

- Deliverables trong file phase đã triển khai.
- Acceptance Criteria được check thực tế.
- Code tuân thủ architecture/conventions.
- Không mở rộng ngoài scope.
- Test mới đã viết và pass.
- `dart format .` đã chạy.
- `flutter analyze` pass không error.
- `flutter test` pass.
- Manual tests quan trọng đã thực hiện hoặc ghi rõ vì sao chưa thể.
- `IMPLEMENTATION_STATUS.md` đã cập nhật.
- Báo cáo cuối liệt kê file và lệnh đã chạy.

## 22. Required completion report

Khi kết thúc task/phase, trả về đúng các mục sau:

### Summary

Mô tả ngắn những gì đã hoàn thành.

### Files changed

Liệt kê file tạo mới và file sửa, nhóm theo feature.

### Validation

Liệt kê lệnh đã chạy và kết quả:

```text
dart format .       — pass
flutter analyze     — pass
flutter test        — pass, N tests
```

### Acceptance Criteria

Đánh dấu từng tiêu chí của phase là pass/fail/not verifiable.

### Manual verification

Ghi các luồng đã test thủ công.

### Remaining issues

Chỉ ghi issue thực tế, blocker ngoài code, technical debt hoặc bước Firebase Console còn thiếu.

Không nói chung chung “everything works” nếu chưa chạy kiểm tra.

## 23. Forbidden shortcuts

Tuyệt đối không:

- Dùng dữ liệu hard-code thay cho Firestore ở luồng hoàn chỉnh rồi coi là xong.
- Tạo booking trước payment success.
- Checkout bằng batch write không validate transaction.
- Tin `totalAmount` do client gửi mà không tính lại.
- Dùng local countdown làm nguồn sự thật cho hold expiry.
- Cho hai user book cùng ghế do thiếu transaction.
- Cho User tự set role Admin.
- Lưu card number/CVV vào provider lâu dài, logs hoặc Firestore.
- Hiển thị phim TMDB chưa được Admin lưu.
- Thêm cancellation/refund.
- Chuyển project thành multi-cinema.
- Thêm backend/Cloud Functions để né yêu cầu client-side đã chốt.
- Triển khai FCM trước khi core flow ổn định.

## 24. Default decision policy

Khi file phase không quy định một chi tiết nhỏ:

1. Chọn giải pháp đơn giản nhất đáp ứng scope.
2. Ưu tiên code rõ ràng hơn abstraction sớm.
3. Tái sử dụng component khi có ít nhất hai use case thực tế.
4. Tránh generic framework nội bộ.
5. Không thêm feature mới.
6. Ghi quyết định đáng chú ý trong phase log.

Nếu có blocker ngoài quyền truy cập như Firebase Console hoặc TMDB token, tiếp tục hoàn thành mọi phần code/test có thể làm được, sau đó ghi rõ bước còn lại. Không dừng toàn bộ phase chỉ vì một bước cấu hình bên ngoài.

## 25. First action for Codex

Khi bắt đầu repository này:

1. Xác nhận đang ở root có `pubspec.yaml` hoặc xác định project chưa bootstrap.
2. Đọc `IMPLEMENTATION_STATUS.md` để biết current phase.
3. Đọc đúng file phase được giao.
4. Inspect code trước khi tạo file.
5. Chỉ triển khai phase đó.

Phase mặc định nếu repository chưa bắt đầu: `PHASE_01_BOOTSTRAP.md`.
