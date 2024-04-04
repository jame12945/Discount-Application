import 'package:discount_app/features/discount/domain/items/item.dart';
import 'package:flutter/material.dart';

class DiscountModel extends ChangeNotifier {
  final List<Item> _selectedItems = [];

  List<Item> get selectedItems => _selectedItems;

  int get selectedItemsCount => _selectedItems.length;

  void addItem(Item item) {
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeItem(Item item) {
    _selectedItems.remove(item);
    notifyListeners();
  }
}
