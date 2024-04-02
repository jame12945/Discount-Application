import 'dart:convert';
import 'package:flutter/services.dart';

class DiscountRepository {
  Future<Map<String, List<dynamic>>> loadData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data.json');
      print('JSON String: $jsonString');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      return {
        'items': jsonData['items'] ?? [],
        'discountCampaigns': jsonData['discountCampaigns'] ?? [],
      };
    } catch (e) {
      print('Error loading data: $e');
      // Return an empty map with empty lists
      return {'items': [], 'discountCampaigns': []};
    }
  }
}
