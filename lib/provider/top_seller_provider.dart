import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/top_seller_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/repository/top_seller_repo.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

import '../utill/app_constants.dart';

class TopSellerProvider extends ChangeNotifier {
  final TopSellerRepo topSellerRepo;

  TopSellerProvider({@required this.topSellerRepo});

  List<TopSellerModel> _topSellerList = [];
  int _topSellerSelectedIndex;

  List<TopSellerModel> get topSellerList => _topSellerList;
  int get topSellerSelectedIndex => _topSellerSelectedIndex;

  Future<void> getTopSellerList(bool reload, BuildContext context) async {
    if (_topSellerList.length == 0 || reload) {
      ApiResponse apiResponse = await topSellerRepo.getTopSeller();
      if (apiResponse.response != null &&
          apiResponse.response.statusCode == 200 &&
          apiResponse.response.data.toString() != '{}') {
        _topSellerList.clear();
        List<dynamic> data = apiResponse.response.data;
        if (AppConstants.STATE.isNotEmpty) {
          for (var _element in data) {
            if (_element['address'] == AppConstants.STATE) {
              _topSellerList.add(TopSellerModel.fromJson(_element));
            }
          }
          _topSellerSelectedIndex = 0;
        } else if (AppConstants.STATE.isEmpty) {
          for (var element in data) {
            _topSellerList.add(TopSellerModel.fromJson(element));
          }
          _topSellerSelectedIndex = 0;
        }
      } else {
        ApiChecker.checkApi(context, apiResponse);
      }
      notifyListeners();
    }
  }

  void changeSelectedIndex(int selectedIndex) {
    _topSellerSelectedIndex = selectedIndex;
    notifyListeners();
  }
}
