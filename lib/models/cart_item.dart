import 'package:billing_app/models/product_model.dart';

/// Cart item class used in invoice creation
class CartItem {
  final ProductModel product;
  int qty;

  CartItem({required this.product, this.qty = 1});
}
