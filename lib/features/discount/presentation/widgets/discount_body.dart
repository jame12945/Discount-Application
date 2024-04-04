import 'package:discount_app/core/theme/app_pallete.dart';
import 'package:discount_app/features/discount/data/discount_repository.dart';
import 'package:discount_app/features/discount/domain/items/item.dart';
import 'package:discount_app/features/discount/presentation/widgets/discount_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscountBody extends StatefulWidget {
  @override
  State<DiscountBody> createState() => _DiscountBodyState();
}

class _DiscountBodyState extends State<DiscountBody> {
  final DiscountRepository _discountRepository = DiscountRepository();
  List<Item> _selectedItems = [];
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Provider.of<DiscountModel>(context, listen: false),
        child: Consumer<DiscountModel>(builder: (
          context,
          discountModel,
          child,
        ) {
          return Container(
            padding: EdgeInsets.only(left: 6, right: 6),
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(left: 14),
                    child: Text(
                      'Select The Item',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppPallete.positiveText,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                SizedBox(height: 4),
                FutureBuilder<Map<String, List<dynamic>>>(
                  future: _discountRepository.loadData(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      List<Item> allItems =
                          (snapshot.data?['items'] as List<dynamic>?)
                                  ?.map((item) => Item.fromJson(item))
                                  .toList() ??
                              [];
                      List<Item> availableItems = allItems
                          .where((item) => !_selectedItems.contains(item))
                          .toList();

                      return SingleChildScrollView(
                          child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: availableItems.length,
                            itemBuilder: (context, index) {
                              Item item = availableItems[index];
                              bool isSelected = _selectedItems.contains(item);
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onHover: (event) {
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
                                      ? AppPallete.positiveText
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
                                          discountModel.addItem(item);
                                        },
                                ),
                              );
                            },
                          )
                        ],
                      ));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
                ),
              ],
            ),
          );
        }));
  }
}
