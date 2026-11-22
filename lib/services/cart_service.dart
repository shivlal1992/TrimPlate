
import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(
    0.0,
        (sum, item) => sum + item.totalPrice,
  );

  double get totalAmount => subtotal;

  bool get isEmpty => _items.isEmpty;

  int quantityFor(int foodId) {
    for (final item in _items) {
      if (item.food.id == foodId) {
        return item.quantity;
      }
    }
    return 0;
  }

  void addItem(FoodItem food) {
    final index = _items.indexWhere(
          (item) => item.food.id == food.id,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(food: food));
    }

    notifyListeners();
  }

  void decreaseItem(int foodId) {
    final index = _items.indexWhere(
          (item) => item.food.id == foodId,
    );

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeItem(int foodId) {
    _items.removeWhere((item) => item.food.id == foodId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
