import 'package:discount_app/core/theme/app_pallete.dart';
import 'package:discount_app/features/discount/data/discount_repository.dart';
import 'package:discount_app/features/discount/domain/discount_calculator.dart';
import 'package:discount_app/features/discount/domain/discount_campaign.dart';
import 'package:discount_app/features/discount/domain/items/item.dart';
import 'package:flutter/material.dart';

class DiscountPage extends StatefulWidget {
  @override
  _DiscountPageState createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final DiscountRepository _discountRepository = DiscountRepository();
  final DiscountCalculator _discountCalculator = DiscountCalculator();
  List<Item> _selectedItems = [];
  String _selectedCategory = '';
  String _selectedOnTopDiscount = '';
  double _percentageDiscount = 0.0;
  String _selectedItemCategory = '';
  String _appliedDiscountText = '';
  int _customerPoints = 0;
  int _everyXThb = 0;
  int? _hoveredIndex;
  int _discountYThb = 0;
  bool _isCouponSelected = false;
  bool _isOnTop1Selected = false;
  bool _isOnTop2Selected = false;
  bool _isSeasonalSelected = false;
  bool _isDropdownVisible = false;
  List<String> _appliedDiscountTexts = [];
  double _finalPrice = 0.0;
  double _newFinalPrice = 0.0;

  Set<Item> _disabledItems = {};

  Map<Item, int> _getSelectedItemsCount() {
    Map<Item, int> itemCountMap = {};
    for (var item in _selectedItems) {
      itemCountMap[item] = (itemCountMap[item] ?? 0) + 1;
    }
    return itemCountMap;
  }

  void _updateFinalPrice(List<DiscountCampaign> campaigns) {
    List<DiscountCampaign> selectedCampaigns = [];

    if (_isCouponSelected) {
      if (_isOnTop1Selected) {
        selectedCampaigns.add(campaigns
            .firstWhere((campaign) => campaign.name == 'Discount 120'));
      } else if (_isOnTop2Selected) {
        selectedCampaigns.add(campaigns
            .firstWhere((campaign) => campaign.name == 'Discount 20%'));
      }
    } else if (_selectedCategory == 'On Top') {
      if (_selectedOnTopDiscount == 'Percentage discount by item category') {
        selectedCampaigns.add(
          DiscountCampaign(
            id: 0,
            name: 'Percentage discount by item category',
            category: 'On Top',
            discountRules: DiscountRules(
              type: 'percentage',
              percentage: _percentageDiscount,
              itemCategory: _selectedItemCategory,
            ),
          ),
        );
      } else if (_selectedOnTopDiscount == 'Discount by points') {
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
    }

    double totalPrice = 0;
    for (var item in _selectedItems) {
      totalPrice += item.price;
    }

    double finalPrice = _discountCalculator.calculateFinalPrice(
      totalPrice,
      selectedCampaigns,
      _selectedItems,
    );

    setState(() {
      _newFinalPrice = finalPrice;
    });
  }

  void _showSelectedItemsModal() {
    Map<String, int> itemCountMap = {};
    for (var item in _selectedItems) {
      itemCountMap[item.name] = (itemCountMap[item.name] ?? 0) + 1;
    }

    double totalPrice = 0;
    for (var item in _selectedItems) {
      totalPrice += item.price;
    }

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
                                Item item = _selectedItems.firstWhere(
                                    (item) => item.name == itemName);
                                return count > 0
                                    ? ListTile(
                                        title: Text(itemName),
                                        subtitle:
                                            Text('Price: ${item.price} THB'),
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
                                                    _selectedItems.remove(item);
                                                  } else {
                                                    itemCountMap
                                                        .remove(itemName);
                                                    totalPrice -= item.price;
                                                    _selectedItems.remove(item);
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
                                                  itemCountMap[itemName] =
                                                      count + 1;
                                                  totalPrice += item.price;
                                                  _selectedItems.add(item);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink();
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
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
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
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color: Colors.white,
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
                              value: _selectedCategory.isNotEmpty
                                  ? _selectedCategory
                                  : null,
                              items: ['Coupon', 'On Top', 'Seasonal']
                                  .map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                  _isCouponSelected =
                                      _selectedCategory == 'Coupon';
                                  _isOnTop1Selected = false;
                                  _isOnTop2Selected = false;
                                  _isSeasonalSelected =
                                      _selectedCategory == 'Seasonal';
                                });
                              },
                              decoration:
                                  InputDecoration(labelText: 'Select Category'),
                            ),
                          ),
                          if (_isDropdownVisible && _isCouponSelected)
                            Column(
                              children: [
                                CheckboxListTile(
                                  title: Text('Discount 120'),
                                  value: _isOnTop1Selected,
                                  onChanged: (selected) {
                                    setState(() {
                                      _isOnTop1Selected = selected!;
                                      _isOnTop2Selected = false;
                                      _updateFinalPrice(
                                          campaigns); // Call the new method to update the final price
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: Text('Discount 20%'),
                                  value: _isOnTop2Selected,
                                  onChanged: (selected) {
                                    setState(() {
                                      _isOnTop2Selected = selected!;
                                      _isOnTop1Selected = false;
                                      _updateFinalPrice(
                                          campaigns); // Call the new method to update the final price
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
                                  _updateFinalPrice(campaigns);
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
                                          _updateFinalPrice(campaigns);
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
                                      items: _selectedItems
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
                                    _updateFinalPrice(campaigns);
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
                                          _updateFinalPrice(campaigns);
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
                          ElevatedButton(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              List<DiscountCampaign> selectedCampaigns = [];

                              if (_isCouponSelected) {
                                if (_isOnTop1Selected) {
                                  selectedCampaigns.add(campaigns.firstWhere(
                                      (campaign) =>
                                          campaign.name == 'Discount 120'));
                                } else if (_isOnTop2Selected) {
                                  selectedCampaigns.add(campaigns.firstWhere(
                                      (campaign) =>
                                          campaign.name == 'Discount 20%'));
                                }
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
                              }

                              double finalPrice =
                                  _discountCalculator.calculateFinalPrice(
                                _finalPrice != 0.0 ? _finalPrice : totalPrice,
                                selectedCampaigns,
                                _selectedItems,
                              );

                              setState(() {
                                _finalPrice = finalPrice;
                                _isDropdownVisible = !_isDropdownVisible;
                                if (_isCouponSelected) {
                                  _appliedDiscountTexts.add('Used Coupon');
                                } else if (_selectedCategory == 'On Top') {
                                  _appliedDiscountTexts
                                      .add('Used On Top Discount');
                                } else if (_isSeasonalSelected) {
                                  _appliedDiscountTexts
                                      .add('Used Seasonal Discount');
                                }
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
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discount Application'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_basket),
                onPressed: () {
                  _showSelectedItemsModal();
                },
              ),
              if (_selectedItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _selectedItems.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 6, right: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(
                left: 14,
                top: 10,
                bottom: 4,
              ),
              child: Text(
                'Select The Item',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            FutureBuilder<Map<String, List<dynamic>>>(
              future: _discountRepository.loadData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Item> allItems =
                      (snapshot.data?['items'] as List<dynamic>?)
                              ?.map((item) => Item.fromJson(item))
                              .toList() ??
                          [];
                  List<Item> availableItems = allItems
                      .where((item) => !_selectedItems.contains(item))
                      .toList();
                  List<DiscountCampaign> campaigns = (snapshot
                              .data?['discountCampaigns'] as List<dynamic>?)
                          ?.map(
                              (campaign) => DiscountCampaign.fromJson(campaign))
                          .toList() ??
                      [];
                  Set<String> itemCategories =
                      allItems.map((item) => item.category).toSet();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: availableItems.length,
                          itemBuilder: (context, index) {
                            Item item = availableItems[index];
                            bool isSelected = _selectedItems.contains(item);
                            return MouseRegion(
                              cursor: SystemMouseCursors
                                  .click, // Change the cursor to hand pointer
                              onHover: (event) {
                                // Change the background color on hover
                                setState(() {
                                  _hoveredIndex = index;
                                });
                              },
                              onExit: (event) {
                                setState(() {
                                  _hoveredIndex = null;
                                });
                              },
                              child: ListTile(
                                tileColor: index == _hoveredIndex
                                    ? Colors.green
                                    : null,
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    decoration: isSelected
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  'Price: ${item.price} THB',
                                  style: TextStyle(
                                    decoration: isSelected
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                onTap: isSelected
                                    ? null
                                    : () {
                                        setState(() {
                                          if (!isSelected) {
                                            _selectedItems.add(item);
                                          }
                                        });
                                      },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
