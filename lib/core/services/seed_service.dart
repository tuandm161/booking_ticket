import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_paths.dart';
import '../utils/seat_generator.dart';
import '../../features/rooms/models/cinema_room.dart';
import '../../features/concessions/models/product.dart';
import '../../features/concessions/models/combo.dart';
import '../../features/vouchers/models/voucher.dart';

class SeedResult {
  const SeedResult({required this.createdCount, required this.skipped});
  final int createdCount;
  final bool skipped;
}

class SeedService {
  const SeedService(this._firestore);
  final FirebaseFirestore _firestore;

  Future<SeedResult> seedDefaultRooms() async {
    final rooms = _firestore.collection(FirestorePaths.rooms);
    final existing = await rooms.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }
    const definitions = [
      ('Phòng 1', RoomType.standard, 8, 10, 6, 4),
      ('Phòng 2', RoomType.standard, 7, 10, 5, 4),
      ('Phòng 3', RoomType.vip, 7, 8, 3, 4),
      ('Phòng 4', RoomType.threeD, 8, 10, 5, 4),
    ];
    final now = Timestamp.now();
    final batch = _firestore.batch();
    for (final item in definitions) {
      final ref = rooms.doc();
      final seats = generateSeats(
        rowCount: item.$3,
        seatsPerRow: item.$4,
        vipRowStart: item.$5,
        coupleSeatCount: item.$6,
      );
      final room = CinemaRoom(
        name: item.$1,
        roomType: item.$2,
        rowCount: item.$3,
        seatsPerRow: item.$4,
        vipRowStart: item.$5,
        coupleSeatCount: item.$6,
        seats: seats,
        isActive: true,
        createdAt: now.toDate(),
        updatedAt: now.toDate(),
      );
      batch.set(ref, room.toMap());
    }
    await batch.commit();
    return const SeedResult(createdCount: 4, skipped: false);
  }

  Future<SeedResult> seedDefaultProducts() async {
    final products = _firestore.collection(FirestorePaths.products);
    if ((await products.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }
    final now = DateTime.now();
    final definitions = [
      const Product(
        name: 'Bắp rang bơ',
        category: ProductCategory.popcorn,
        description: 'Bắp rang bơ caramel thơm giòn.',
        imageUrl: '',
        price: 45000,
        isAvailable: true,
      ),
      const Product(
        name: 'Coca Cola',
        category: ProductCategory.drink,
        description: 'Nước ngọt mát lạnh.',
        imageUrl: '',
        price: 30000,
        isAvailable: true,
      ),
      const Product(
        name: 'Nước suối',
        category: ProductCategory.drink,
        description: 'Nước suối tinh khiết.',
        imageUrl: '',
        price: 20000,
        isAvailable: true,
      ),
      const Product(
        name: 'Nachos phô mai',
        category: ProductCategory.snack,
        description: 'Nachos giòn kèm sốt phô mai.',
        imageUrl: '',
        price: 55000,
        isAvailable: true,
      ),
    ];
    final batch = _firestore.batch();
    for (final product in definitions) {
      final ref = products.doc();
      batch.set(ref, product.copyWith(createdAt: now, updatedAt: now).toMap());
    }
    await batch.commit();
    return const SeedResult(createdCount: 4, skipped: false);
  }

  Future<SeedResult> seedDefaultCombos() async {
    final combos = _firestore.collection(FirestorePaths.combos);
    if ((await combos.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }
    var productSnapshot = await _firestore
        .collection(FirestorePaths.products)
        .get();
    if (productSnapshot.docs.isEmpty) {
      await seedDefaultProducts();
      productSnapshot = await _firestore
          .collection(FirestorePaths.products)
          .get();
    }
    final byName = {
      for (final doc in productSnapshot.docs)
        (doc.data()['name'] as String? ?? ''): doc,
    };
    final popcorn = byName['Bắp rang bơ'];
    final cola = byName['Coca Cola'];
    final water = byName['Nước suối'];
    final nachos = byName['Nachos phô mai'];
    if (popcorn == null || cola == null || water == null || nachos == null) {
      throw StateError('Hãy tạo sản phẩm mẫu trước khi tạo combo.');
    }
    final now = DateTime.now();
    Combo make(
      String name,
      String description,
      int price,
      List<ComboItem> items,
    ) => Combo(
      name: name,
      description: description,
      imageUrl: '',
      price: price,
      items: items,
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    );
    final definitions = [
      make('Combo Couple', 'Hai người cùng xem, đủ bắp và nước.', 130000, [
        ComboItem(
          productId: popcorn.id,
          productName: popcorn.data()['name'] as String,
          quantity: 2,
        ),
        ComboItem(
          productId: cola.id,
          productName: cola.data()['name'] as String,
          quantity: 2,
        ),
      ]),
      make(
        'Combo Family',
        'Combo gia đình cho một buổi chiếu thật vui.',
        190000,
        [
          ComboItem(
            productId: popcorn.id,
            productName: popcorn.data()['name'] as String,
            quantity: 1,
          ),
          ComboItem(
            productId: cola.id,
            productName: cola.data()['name'] as String,
            quantity: 2,
          ),
          ComboItem(
            productId: water.id,
            productName: water.data()['name'] as String,
            quantity: 2,
          ),
          ComboItem(
            productId: nachos.id,
            productName: nachos.data()['name'] as String,
            quantity: 1,
          ),
        ],
      ),
    ];
    final batch = _firestore.batch();
    for (final combo in definitions) {
      batch.set(combos.doc(), combo.toMap());
    }
    await batch.commit();
    return const SeedResult(createdCount: 2, skipped: false);
  }

  Future<SeedResult> seedDefaultVouchers() async {
    final vouchers = _firestore.collection(FirestorePaths.vouchers);
    if ((await vouchers.limit(1).get()).docs.isNotEmpty) {
      return const SeedResult(createdCount: 0, skipped: true);
    }
    final now = DateTime.now();
    final end = now.add(const Duration(days: 90));
    final definitions = [
      Voucher(
        code: 'CINEMA10',
        description: 'Giảm 10% cho đơn từ 100.000đ.',
        discountType: DiscountType.percentage,
        discountValue: 10,
        minOrderValue: 100000,
        maxDiscount: 50000,
        startDate: now,
        endDate: end,
        usageLimit: 100,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Voucher(
        code: 'WELCOME50',
        description: 'Giảm 50.000đ cho khách mới.',
        discountType: DiscountType.fixedAmount,
        discountValue: 50000,
        minOrderValue: 200000,
        maxDiscount: 50000,
        startDate: now,
        endDate: end,
        usageLimit: 50,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Voucher(
        code: 'TUESDAY20',
        description: 'Giảm 20% cho ngày hội điện ảnh.',
        discountType: DiscountType.percentage,
        discountValue: 20,
        minOrderValue: 150000,
        maxDiscount: 60000,
        startDate: now,
        endDate: end,
        usageLimit: 80,
        usedCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final batch = _firestore.batch();
    for (final voucher in definitions) {
      batch.set(vouchers.doc(), voucher.toMap());
    }
    await batch.commit();
    return const SeedResult(createdCount: 3, skipped: false);
  }
}
