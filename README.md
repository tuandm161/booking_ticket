# Movie Booking

Ứng dụng đặt vé xem phim Android bằng Flutter và Firebase. Gồm catalog phim, chọn suất/ghế, giữ ghế 10 phút, combo/voucher, thanh toán mô phỏng, vé QR, thông báo và dashboard quản trị.

## Tính năng

- Email/password auth và phân quyền user/admin.
- Admin CRUD phòng, phim (TMDB prefill), suất chiếu, sản phẩm, combo, voucher.
- User tìm phim, chọn ghế Standard/VIP/Couple, checkout atomic.
- Vé bất biến có QR, notifications realtime, admin booking viewer/dashboard.
- Theme sáng/tối lưu bằng SharedPreferences.
- FCM tùy chọn: token lưu trong `users/{uid}.fcmTokens`, foreground local banner và deep-link booking khi tap.

## Công nghệ

Flutter/Dart, Riverpod, go_router, Firebase Auth/Firestore, Dio/TMDB, qr_flutter. Code tổ chức theo feature trong `lib/features`, shared widgets trong `lib/shared`.

## Firebase setup

1. Tạo Firebase project, bật Email/Password và Firestore.
2. Chạy `flutterfire configure` để tạo `lib/firebase_options.dart` thật (file hiện tại là placeholder an toàn cho local build).
3. Deploy rules/indexes: `firebase deploy --only firestore:rules,firestore:indexes`.
4. Tạo tài khoản admin, đặt `users/{uid}.role = "admin"`; tài khoản đăng ký mới mặc định là `user`.
5. Trong Admin Rooms, chạy seed để tạo 6 phòng demo; seed chỉ chạy khi chưa có phòng.

## TMDB

Không commit token. Truyền token lúc chạy/build:

```bash
flutter run --dart-define=TMDB_READ_TOKEN=<token>
flutter build apk --release --dart-define=TMDB_READ_TOKEN=<token>
```

Không có token thì CRUD phim thủ công vẫn hoạt động.

Để giữ token ngoài source code trên PowerShell, lưu một dòng token mới trong `secrets/tmdb_token.txt` (thư mục này đã được `.gitignore` bỏ qua), rồi chạy:

```powershell
$tmdbToken = (Get-Content secrets/tmdb_token.txt -Raw).Trim()
flutter run "--dart-define=TMDB_READ_TOKEN=$tmdbToken"
Remove-Variable tmdbToken
```

## FCM tùy chọn

Android notification permission và FCM token được xử lý sau khi Firebase khởi động. Token refresh được lưu bằng `arrayUnion`; foreground message hiển thị local notification, còn background/initial message đọc `bookingId` để mở chi tiết vé. Booking vẫn dùng notification Firestore làm source of truth. Gửi thử push từ Firebase Console; client không chứa server key và không tự gửi push.

## Kiểm tra và build

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

APK nằm tại `build/app/outputs/flutter-apk/`.

## Demo accounts/data

Tạo một user thường và một admin trong Firebase Console. Seed rooms, thêm phim/suất chiếu, rồi dùng user đặt vé; dùng admin xem booking/dashboard. Không có tài khoản/token production trong repository.

## Known limitations

- Thanh toán mô phỏng, không lưu dữ liệu thẻ và không tích hợp cổng thật.
- Checkout client-side transaction; nên kiểm thử race hai người bằng Firebase Emulator.
- Hold ghế hết hạn được dọn lazy.
- Chưa có cancel/refund/completed workflow, FCM và quản lý tồn kho.
- Firebase project thật và Android signing key phải cấu hình riêng.
