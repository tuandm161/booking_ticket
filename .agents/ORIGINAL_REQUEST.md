# Original User Request

## Initial Request — 2026-07-22T03:00:46Z

# Teamwork Project Prompt

Nâng cấp toàn diện giao diện & dữ liệu ứng dụng Đặt vé CGV Cinema: Bổ sung hình ảnh thực tế chất lượng cao cho tất cả Combo bắp nước, thêm các Cụm rạp CGV lớn tại Hà Nội (Vincom Bà Triệu, Royal City, Lotte Center, Aeon Mall Hà Đông), sửa lỗi tương phản chữ trắng khó đọc ở thẻ tag Admin, hoàn thiện layout toàn bộ màn hình, thêm các bộ lọc User/Admin nâng cao, và bổ sung hiệu ứng chuyển động mượt mà (micro-animations, press scaling button, smooth card transitions).

Working directory: d:\prm\Project\booking_ticket
Integrity mode: development

## Requirements

### R1. Bổ sung Hình ảnh Bắp Nước & Cụm Rạp Hà Nội
- Bổ sung URL hình ảnh thực tế chất lượng cao (Unsplash/CGV assets) cho tất cả Sản phẩm & Combo bắp nước trong `seed_service.dart` và cơ sở dữ liệu Firestore.
- Bổ sung thêm 4 Cụm rạp CGV lớn tại Hà Nội (*CGV Vincom Bà Triệu*, *CGV Royal City*, *CGV Lotte Center Hà Nội*, *CGV Aeon Mall Hà Đông*) kèm danh sách phòng chiếu & suất chiếu tương ứng.

### R2. Sửa lỗi Tương phản Tag & Layout UI
- Sửa lỗi tương phản chữ màu trắng khó đọc ở các thẻ tag status (`nowShowing`, `comingSoon`, `stopped`) trong màn hình Quản lý Phim Admin (`AdminMovieListScreen`) -> sử dụng màu chữ tương phản cao, nền chip sắc nét.
- Rà soát toàn bộ các màn hình User (Home, Detail, Showtimes, Seats, Concessions, Checkout, Payment, Profile) và Admin (Dashboard, Movies, Rooms, Showtimes, Products, Combos, Vouchers) để khắc phục triệt me các lỗi overflow, căn chỉnh lệch, font chữ chưa nhất quán.

### R3. Bộ Lọc Nâng Cao Cho User & Admin (Advanced Filtering UX)
- Màn hình chọn suất chiếu User: Thêm bộ lọc theo **Thành phố** (TP.HCM / Hà Nội), tự động cập nhật danh sách Cụm rạp tương ứng.
- Màn hình Quản lý Admin: Bổ sung bộ lọc trạng thái (Đang hoạt động / Tạm ẩn), sắp xếp theo ngày/tên/doanh thu cho Phim, Phòng chiếu, Suất chiếu, Sản phẩm & Voucher.

### R4. Hiệu ứng Chuyển Động Mượt Mà (Micro-Animations & Premium Interactions)
- Tích hợp widget phản hồi bấm nút nảy mượt mà (Press scale animation `Transform.scale(scale: 0.96)`) cho tất cả các nút bấm chính (FilledButton, FloatingActionButton, Card taps).
- Bổ sung hiệu ứng chuyển cảnh mượt mà giữa các tab và màn hình (`PageTransitionsBuilder` / AnimatedSwitcher).
- Tăng cường hiệu ứng glow/shadow và chuyển màu khi di chuyển hoặc chọn ghế/combo/suất chiếu.

## Acceptance Criteria

### Objective Verification Criteria
- [ ] 100% Sản phẩm & Combo bắp nước hiển thị hình ảnh minh họa thực tế sắc nét, không có ảnh trống.
- [ ] Chọn được Thành phố Hà Nội trên màn hình chọn suất chiếu và xem danh sách suất chiếu của 4 rạp Hà Nội (Vincom Bà Triệu, Royal City, Lotte Center, Aeon Mall Hà Đông).
- [ ] Mọi thẻ tag/badge trong Admin Quản lý Phim hiển thị chữ rõ ràng, độ tương phản cao, đọc được 100%.
- [ ] Không còn bất kỳ lỗi vỡ layout, overflow (yellow-black lines) nào trên toàn bộ các màn hình.
- [ ] `flutter analyze --no-fatal-infos` trả về `No issues found!`.
- [ ] `flutter test` pass 100% (32/32 tests).
- [ ] Tất cả nút bấm chính có phản hồi hiệu ứng chạm/nảy mượt mà khi người dùng tương tác.
