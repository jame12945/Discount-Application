import 'package:discount_app/core/theme/app_pallete.dart';
import 'package:discount_app/features/discount/data/discount_repository.dart';
import 'package:discount_app/features/discount/domain/discount_calculator.dart';
import 'package:discount_app/features/discount/domain/discount_campaign.dart';
import 'package:discount_app/features/discount/domain/items/item.dart';
import 'package:discount_app/features/discount/presentation/widgets/discount_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscountAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DiscountRepository _discountRepository = DiscountRepository();
  final DiscountCalculator _discountCalculator = DiscountCalculator();
  String _selectedCategory = '';
  String _selectedOnTopDiscount = '';
  double _percentageDiscount = 0.0;
  String _selectedItemCategory = '';
  int _customerPoints = 0;
  int _everyXThb = 0;
  int _discountYThb = 0;
  bool _isCouponSelected = false;
  bool _isOnTop1Selected = false;
  bool _isOnTop2Selected = false;
  bool _isSeasonalSelected = false;
  bool _isDropdownVisible = false;
  List<String> _appliedDiscountTexts = [];
  double _finalPrice = 0.0;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Discount App'),
      actions: [
        Consumer<DiscountModel>(
          builder: (context, discountModel, child) {
            return Stack(
              children: [
                IconButton(
                  onPressed: () {
                    _showSelectedItemsModal(context, discountModel);
                  },
                  icon: Icon(Icons.shopping_basket),
                ),
                if (discountModel.selectedItemsCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppPallete.countItemColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: 16.0,
                        minHeight: 16.0,
                      ),
                      child: Text(
                        discountModel.selectedItemsCount.toString(),
                        style: TextStyle(
                          color: AppPallete.whiteColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showSelectedItemsModal(
      BuildContext context, DiscountModel discountModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FutureBuilder<Map<String, List<dynamic>>>(
              future: _discountRepository.loadData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DiscountCampaign> campaigns = (snapshot
                              .data?['discountCampaigns'] as List<dynamic>?)
                          ?.map(
                              (campaign) => DiscountCampaign.fromJson(campaign))
                          .toList() ??
                      [];
                  double totalPrice = 0;
                  for (var item in discountModel.selectedItems) {
                    totalPrice += item.price;
                  }
                  Map<String, int> itemCountMap = {};
                  for (var item in discountModel.selectedItems) {
                    itemCountMap[item.name] =
                        (itemCountMap[item.name] ?? 0) + 1;
                  }

                  return SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Selected Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: 200,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: itemCountMap.length,
                              itemBuilder: (context, index) {
                                String itemName =
                                    itemCountMap.keys.elementAt(index);
                                int count = itemCountMap[itemName] ?? 0;
                                Item item = discountModel.selectedItems[index];
                                return ListTile(
                                  title: Text(item.name),
                                  subtitle: Text('Price: ${item.price} THB'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (count > 1) {
                                              itemCountMap[itemName] =
                                                  count - 1;
                                              totalPrice -= item.price;
                                              discountModel.removeItem(item);
                                            } else {
                                              itemCountMap.remove(itemName);
                                              totalPrice -= item.price;
                                              discountModel.removeItem(item);
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        '$count',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppPallete.positiveText,
                                          fontSize: 14,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            discountModel.addItem(item);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select Discount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: _appliedDiscountTexts.length == 3
                                            ? AppPallete.greyColor
                                            : AppPallete.positiveText,
                                      ),
                                      onPressed:
                                          _appliedDiscountTexts.length == 3
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _isDropdownVisible =
                                                        !_isDropdownVisible;
                                                  });
                                                },
                                    ),
                                  ],
                                ),
                                if (_appliedDiscountTexts.isNotEmpty)
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: _appliedDiscountTexts
                                        .map(
                                          (text) => Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: AppPallete.tagColor,
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color: AppPallete.whiteColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _isDropdownVisible,
                            child: DropdownButtonFormField<String>(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 4,
                              ),
                              value: _selectedCategory.isNotEmpty &&
                                      !_appliedDiscountTexts
                                          .contains('Used $_selectedCategory')
                                  ? _selectedCategory
                                  : null,
                              items: ['Coupon', 'On Top', 'Seasonal']
                                  .where((category) => !_appliedDiscountTexts
                                      .contains('Used $category'))
                                  .map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null &&
                                    !_appliedDiscountTexts
                                        .contains('Used $value')) {
                                  setState(() {
                                    _selectedCategory = value;
                                    _isCouponSelected =
                                        _selectedCategory == 'Coupon';
                                    _isOnTop1Selected = false;
                                    _isOnTop2Selected = false;
                                    _isSeasonalSelected =
                                        _selectedCategory == 'Seasonal';
                                  });
                                }
                              },
                              decoration:
                                  InputDecoration(labelText: 'Select Category'),
                            ),
                          ),
                          if (_isDropdownVisible && _isCouponSelected)
                            Column(
                              children: [
                                CheckboxListTile(
                                  title: Text('Discount 50'),
                                  value: _isOnTop1Selected,
                                  onChanged: (selected) {
                                    setState(() {
                                      _isOnTop1Selected = selected!;
                                      _isOnTop2Selected = false;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: Text('Discount 10%'),
                                  value: _isOnTop2Selected,
                                  onChanged: (selected) {
                                    setState(() {
                                      _isOnTop2Selected = selected!;
                                      _isOnTop1Selected = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          if (_isDropdownVisible &&
                              _selectedCategory == 'On Top')
                            DropdownButtonFormField<String>(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                              ),
                              value: _selectedOnTopDiscount.isNotEmpty
                                  ? _selectedOnTopDiscount
                                  : null,
                              items: [
                                'Percentage discount by item category',
                                'Discount by points'
                              ].map((discount) {
                                return DropdownMenuItem<String>(
                                  value: discount,
                                  child: Text(discount),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedOnTopDiscount = value!;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'Select On Top Discount'),
                            ),
                          if (_isDropdownVisible &&
                              _selectedCategory == 'On Top' &&
                              _selectedOnTopDiscount ==
                                  'Percentage discount by item category')
                            Container(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'Discount Percentage'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _percentageDiscount =
                                              double.parse(value);
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedItemCategory.isNotEmpty
                                          ? _selectedItemCategory
                                          : null,
                                      items: discountModel.selectedItems
                                          .map((item) => item.category)
                                          .toSet()
                                          .map((category) {
                                        return DropdownMenuItem<String>(
                                          value: category,
                                          child: Text(category),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedItemCategory = value!;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          labelText: 'Item Category'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isDropdownVisible &&
                              _selectedCategory == 'On Top' &&
                              _selectedOnTopDiscount == 'Discount by points')
                            Container(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Customer Points'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _customerPoints = int.parse(value);
                                  });
                                },
                              ),
                            ),
                          if (_isDropdownVisible &&
                              _selectedCategory == 'Seasonal' &&
                              _isSeasonalSelected)
                            Container(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'Discount Y THB'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _discountYThb = int.parse(value);
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'Every X THB'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _everyXThb = int.parse(value);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isDropdownVisible)
                            ElevatedButton(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: AppPallete.positiveText,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.whiteColor,
                              ),
                              onPressed: () {
                                List<DiscountCampaign> selectedCampaigns = [];

                                if (_isCouponSelected) {
                                  if (_isOnTop1Selected) {
                                    selectedCampaigns.add(campaigns.firstWhere(
                                        (campaign) =>
                                            campaign.name == 'Discount 50'));
                                  } else if (_isOnTop2Selected) {
                                    selectedCampaigns.add(campaigns.firstWhere(
                                        (campaign) =>
                                            campaign.name == 'Discount 10%'));
                                  }
                                  _appliedDiscountTexts.add('Used Coupon');
                                } else if (_selectedCategory == 'On Top') {
                                  if (_selectedOnTopDiscount ==
                                      'Percentage discount by item category') {
                                    selectedCampaigns.add(
                                      DiscountCampaign(
                                        id: 0,
                                        name:
                                            'Percentage discount by item category',
                                        category: 'On Top',
                                        discountRules: DiscountRules(
                                          type: 'percentage',
                                          percentage: _percentageDiscount,
                                          itemCategory: _selectedItemCategory,
                                        ),
                                      ),
                                    );
                                  } else if (_selectedOnTopDiscount ==
                                      'Discount by points') {
                                    selectedCampaigns.add(
                                      DiscountCampaign(
                                        id: 0,
                                        name: 'Discount by points',
                                        category: 'On Top',
                                        discountRules: DiscountRules(
                                          type: 'fixed',
                                          amount: _customerPoints.toDouble(),
                                        ),
                                      ),
                                    );
                                  }
                                  _appliedDiscountTexts.add('Used On Top');
                                } else if (_isSeasonalSelected) {
                                  selectedCampaigns.add(
                                    DiscountCampaign(
                                      id: 0,
                                      name: 'Seasonal',
                                      category: 'Seasonal',
                                      discountRules: DiscountRules(
                                        type: 'fixed',
                                        everyX: _everyXThb,
                                        discount: _discountYThb,
                                      ),
                                    ),
                                  );
                                  _appliedDiscountTexts.add('Used Seasonal');
                                }

                                double finalPrice =
                                    _discountCalculator.calculateFinalPrice(
                                  _finalPrice != 0.0 ? _finalPrice : totalPrice,
                                  selectedCampaigns,
                                  discountModel.selectedItems,
                                );

                                setState(() {
                                  _finalPrice = finalPrice;
                                  _isDropdownVisible = !_isDropdownVisible;
                                  _selectedCategory = '';
                                  _isCouponSelected = false;
                                });
                              },
                            ),
                          SizedBox(height: 16),
                          Text(
                            _finalPrice != 0.0
                                ? 'Final Price: ${_finalPrice.toStringAsFixed(2)} THB'
                                : 'Final Price: ${totalPrice.toStringAsFixed(2)} THB',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        );
      },
    ).then((_) {
      discountModel.notifyListeners();
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
