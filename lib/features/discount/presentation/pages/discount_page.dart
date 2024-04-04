import 'package:discount_app/features/discount/presentation/widgets/discoun_bar.dart';
import 'package:discount_app/features/discount/presentation/widgets/discount_body.dart';
import 'package:discount_app/features/discount/presentation/widgets/discount_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscountPage extends StatefulWidget {
  @override
  _DiscountPageState createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscountModel(),
      child: Scaffold(
        appBar: DiscountAppBar(),
        body: DiscountBody(),
      ),
    );
  }
}
