import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/home_category_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/repository/home_category_product_repo.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/product_model.dart';

import '../utill/app_constants.dart';

class HomeCategoryProductProvider extends ChangeNotifier {
  final HomeCategoryProductRepo homeCategoryProductRepo;
  HomeCategoryProductProvider({@required this.homeCategoryProductRepo});

  List<HomeCategoryProduct> _homeCategoryProductList = [];
  List<Product> _productList;
  int _productIndex;
  int get productIndex => _productIndex;
  List<HomeCategoryProduct> get homeCategoryProductList =>
      _homeCategoryProductList;
  List<Product> get productList => _productList;

  Future<void> getHomeCategoryProductList(
      bool reload, BuildContext context) async {
    if (_homeCategoryProductList.length == 0 || reload) {
      _productList = [];
      _homeCategoryProductList.clear();
      ApiResponse apiResponse =
          await homeCategoryProductRepo.getHomeCategoryProductList();
      if (apiResponse.response != null &&
          apiResponse.response.statusCode == 200) {
        _productList = [];
        _homeCategoryProductList.clear();
        List<dynamic> productList = apiResponse.response.data;

        if (AppConstants.STATE.isNotEmpty) {
          for (var product in productList) {
            for (var _element in product['products']) {
              for (var element in _element['choice_options']) {
                for (var element in element['options']) {
                  if (element == AppConstants.STATE) {
                    _homeCategoryProductList
                        .add(HomeCategoryProduct.fromJson(product));
                    _productList.add(Product.fromJson(_element));
                  }
                }
              }
            }
          }
        } else if (AppConstants.STATE.isEmpty) {
          for (var product in productList) {
            _homeCategoryProductList.add(HomeCategoryProduct.fromJson(product));
          }
          _homeCategoryProductList
              .map((product) => _productList.addAll(product.products))
              .toList();
        }
      } else {
        ApiChecker.checkApi(context, apiResponse);
      }
      notifyListeners();
    }
  }
}
