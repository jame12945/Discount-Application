import 'package:discount_app/features/discount/domain/items/item.dart';

import '../domain/discount_campaign.dart';

class DiscountCalculator {
  double calculateFinalPrice(
    double totalPrice,
    List<DiscountCampaign> campaigns,
    List<Item> items,
  ) {
    List<DiscountCampaign> sortedCampaigns = _sortCampaignByPriority(campaigns);
    for (var campaign in sortedCampaigns) {
      if (campaign.category == 'Coupon') {
        totalPrice = _applyCouponDiscount(
          totalPrice,
          campaign,
        );
      } else if (campaign.category == 'On Top') {
        totalPrice = _applyOnTopDiscount(
          totalPrice,
          campaign,
          items,
        );
      } else if (campaign.category == 'Seasonal') {
        totalPrice = _applySeasonalDiscount(
          totalPrice,
          campaign,
        );
      }
    }
    return totalPrice;
  }

  List<DiscountCampaign> _sortCampaignByPriority(
      List<DiscountCampaign> campaigns) {
    return campaigns.toList()
      ..sort((a, b) {
        const order = ['Coupon', 'On Top', 'Seasonal'];
        return order.indexOf(a.category).compareTo(order.indexOf(b.category));
      });
  }

  double _applyCouponDiscount(double price, DiscountCampaign campaign) {
    if (campaign.discountRules.type == 'fixed') {
      return price - campaign.discountRules.amount!.toDouble();
    } else if (campaign.discountRules.type == 'percentage') {
      return price -
          (price * campaign.discountRules.percentage!.toDouble() / 100);
    }
    return price;
  }

  double _applyOnTopDiscount(
      double price, DiscountCampaign campaign, List<Item> items) {
    if (campaign.discountRules.type == 'percentage') {
      double disCountAmount = 0.0;
      for (var item in items) {
        if (item.category == campaign.discountRules.itemCategory) {
          disCountAmount += item.price *
              (campaign.discountRules.percentage!.toDouble() / 100);
        }
      }
      return price - disCountAmount;
    } else if (campaign.discountRules.type == 'fixed') {
      double disCountAmount = campaign.discountRules.amount!.toDouble();
      double maxDiscount = price * 0.2;
      return price -
          (disCountAmount <= maxDiscount ? disCountAmount : maxDiscount);
    }
    return price;
  }

  double _applySeasonalDiscount(double price, DiscountCampaign campaign) {
    final everyX = campaign.discountRules.everyX!;
    final discount = campaign.discountRules.discount!;

    int multiplier = (price / everyX).floor();
    int discountAmount = multiplier * discount;
    double finalPrice = price - discountAmount;

    return finalPrice;
  }
}
