# Milestone 2 Code Changes & Implementation Summary

## 1. File Modified
- `lib/core/services/seed_service.dart`

## 2. Detailed Modifications

### a. Products Unsplash Image URLs (9 Products)
Updated `imageUrl` for all 9 concession items in `seedDefaultProducts()`:
1. `Bắp rang bơ Caramel (L)`: `https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=800`
2. `Bắp rang bơ Phô mai (L)`: `https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=800`
3. `Bắp rang bơ Truyền thống (M)`: `https://images.unsplash.com/photo-1512149177596-f817c7ef5d4c?w=800`
4. `Coca Cola (L)`: `https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800`
5. `Pepsi Zero (L)`: `https://images.unsplash.com/photo-1554866585-cd94860890b7?w=800`
6. `Trà Sữa Đào CGV (L)`: `https://images.unsplash.com/photo-1558857563-b371033873b8?w=800`
7. `Nước suối Dasani`: `https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=800`
8. `Nachos Phô Mai Thượng Hạng`: `https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=800`
9. `Xúc Xích Đức Nướng`: `https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=800`

### b. Combos Unsplash Image URLs (6 Combos)
Updated `imageUrl` parameter in `make()` helper and assigned URLs for all 6 combos in `seedDefaultCombos()`:
1. `Combo Solo My CGV`: `https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=800`
2. `Combo Couple CGV`: `https://images.unsplash.com/photo-1512149177596-f817c7ef5d4c?w=800`
3. `Combo Family Ngon Mê`: `https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=800`
4. `Combo Premium Gold Class`: `https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=800`
5. `Combo Học Sinh Sinh Viên`: `https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8?w=800`
6. `Combo Party Bạn Bè`: `https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=800`

### c. Hanoi CGV Cinema Clusters (4 Cinemas)
Added 4 Hanoi cinemas with `city: 'Hà Nội'` in `seedDefaultCinemas()`:
1. `CGV Vincom Bà Triệu` (191 Bà Triệu, Q. Hai Bà Trưng, Hà Nội)
2. `CGV Royal City` (72A Nguyễn Trãi, Q. Thanh Xuân, Hà Nội)
3. `CGV Lotte Center Hà Nội` (54 Liễu Giai, Q. Ba Đình, Hà Nội)
4. `CGV Aeon Mall Hà Đông` (KĐT Dương Nội, Q. Hà Đông, Hà Nội)

### d. Hanoi Cinema Rooms (8 Rooms)
Added 8 rooms (2 rooms per Hanoi cinema) in `seedDefaultRooms()`:
1. `Phòng 11 (IMAX Bà Triệu)` (`RoomType.threeD`, 10x12) -> CGV Vincom Bà Triệu
2. `Phòng 12 (Gold Class Bà Triệu)` (`RoomType.vip`, 6x8) -> CGV Vincom Bà Triệu
3. `Phòng 13 (4DX Royal)` (`RoomType.threeD`, 8x10) -> CGV Royal City
4. `Phòng 14 (Standard Royal)` (`RoomType.standard`, 8x10) -> CGV Royal City
5. `Phòng 15 (Lotte Lounge)` (`RoomType.vip`, 6x8) -> CGV Lotte Center Hà Nội
6. `Phòng 16 (Standard Lotte)` (`RoomType.standard`, 8x10) -> CGV Lotte Center Hà Nội
7. `Phòng 17 (Starium Hà Đông)` (`RoomType.threeD`, 10x14) -> CGV Aeon Mall Hà Đông
8. `Phòng 18 (Cinema 2 Hà Đông)` (`RoomType.standard`, 8x10) -> CGV Aeon Mall Hà Đông

---

## 3. Verification Results

- **`flutter analyze --no-fatal-infos`**:
  Result: `Analyzing booking_ticket... No issues found! (ran in 6.0s)`
- **`flutter test`**:
  Result: `32/32 tests passed (100% pass rate)`
