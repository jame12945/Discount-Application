class DiscountRules {
  final String type;
  final double? amount;
  final double? percentage;
  final String? itemCategory;
  final int? everyX;
  final int? discount;

  DiscountRules({
    required this.type,
    double? amount,
    double? percentage,
    this.itemCategory,
    this.everyX,
    this.discount,
  })  : amount = amount != null ? amount.toDouble() : null,
        percentage = percentage != null ? percentage.toDouble() : null;
}

class DiscountCampaign {
  final int id;
  final String name;
  final String category;
  final DiscountRules discountRules;

  DiscountCampaign({
    required this.id,
    required this.name,
    required this.category,
    required this.discountRules,
  });

  factory DiscountCampaign.fromJson(Map<String, dynamic> json) {
    final discountRules = json['discountRules'] != null
        ? DiscountRules(
            type: json['discountRules']['type'] ?? '',
            amount: (json['discountRules']['amount'] as num?)?.toDouble(),
            percentage:
                (json['discountRules']['percentage'] as num?)?.toDouble(),
            itemCategory: json['discountRules']['itemCategory'],
            everyX: json['discountRules']['everyX']?.toInt(),
            discount: json['discountRules']['discount']?.toInt(),
          )
        : DiscountRules(type: '');

    return DiscountCampaign(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      discountRules: discountRules,
    );
  }
}
