import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/provider/home_category_product_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/title_row.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/product/brand_and_category_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/product/product_details_screen.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/response/product_model.dart';
import '../../../../utill/app_constants.dart';

class HomeCategoryProductView extends StatelessWidget {
  final bool isHomePage;
  HomeCategoryProductView({@required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeCategoryProductProvider>(
      builder: (context, homeCategoryProductProvider, child) {
        return homeCategoryProductProvider.homeCategoryProductList.length != 0
            ? ListView.builder(
                itemCount:
                    homeCategoryProductProvider.homeCategoryProductList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, index) {
                  List<Product> _products = [];
                  List<Product> _productList = [];
                  _products = homeCategoryProductProvider
                      .homeCategoryProductList[index].products;
                  if (AppConstants.STATE.isNotEmpty) {
                    for (var product in _products) {
                      for (var element in product.choiceOptions) {
                        for (var element in element.options) {
                          if (element == AppConstants.STATE) {
                            _productList.add(product);
                          }
                        }
                      }
                    }
                  } else if (AppConstants.STATE.isEmpty) {
                    _productList.addAll(_products);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isHomePage
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(
                                  5,
                                  Dimensions.PADDING_SIZE_DEFAULT,
                                  Dimensions.PADDING_SIZE_SMALL,
                                  Dimensions.PADDING_SIZE_SMALL),
                              child: TitleRow(
                                title: homeCategoryProductProvider
                                    .homeCategoryProductList[index].name,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              BrandAndCategoryProductScreen(
                                                isBrand: false,
                                                id: homeCategoryProductProvider
                                                    .homeCategoryProductList[
                                                        index]
                                                    .id
                                                    .toString(),
                                                name: homeCategoryProductProvider
                                                    .homeCategoryProductList[
                                                        index]
                                                    .name,
                                              )));
                                },
                              ),
                            )
                          : SizedBox(),
                      ConstrainedBox(
                        constraints: homeCategoryProductProvider
                                    .homeCategoryProductList[index]
                                    .products
                                    .length >
                                0
                            ? BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.38,
                              )
                            : BoxConstraints(maxHeight: 0),

                        /// TODO:
                        child: ListView.builder(
                            itemCount: _productList.length,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int i) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          Duration(milliseconds: 1000),
                                      pageBuilder: (context, anim1, anim2) =>
                                          ProductDetails(
                                        product: _productList[i],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                          20,
                                  child: ProductWidget(
                                    productModel: _productList[i],
                                  ),
                                ),
                              );
                            }),
                      )
                    ],
                  );
                })
            : SizedBox();
      },
    );
  }
}
