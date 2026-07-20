import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

final productFormControllerProvider =
    NotifierProvider<ProductFormController, ProductDraft>(
      ProductFormController.new,
    );

class ProductFormController extends Notifier<ProductDraft> {
  @override
  ProductDraft build() => const ProductDraft(
    name: '',
    category: ProductCategory.popcorn,
    description: '',
    imageUrl: '',
    price: 0,
  );
}
