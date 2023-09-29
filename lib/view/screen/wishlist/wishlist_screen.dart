import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/localization_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/wishlist_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_app_bar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/no_internet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/not_loggedin_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/wishlist/widget/wishlist_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/model/response/product_model.dart';
import '../../../utill/app_constants.dart';

class WishListScreen extends StatefulWidget {
  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  bool isGuestMode;

  Future<void> _removeProductFromWishList() async {
    if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
      await Provider.of<WishListProvider>(context, listen: false).initWishList(
        context,
        Provider.of<LocalizationProvider>(context, listen: false)
            .codeLocale
            .countryCode,
      );
      List<Product> wishList =
          Provider.of<WishListProvider>(context, listen: false).wishList;

      for (var product in wishList) {
        for (var element in product.choiceOptions) {
          for (var element in element.options) {
            if (element != AppConstants.STATE) {
              wishList.removeWhere((element) => product.id == element.id);
              Provider.of<WishListProvider>(context, listen: false)
                  .removeWishList(product.id);
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    _removeProductFromWishList();
    super.initState();

    isGuestMode =
        !Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          CustomAppBar(title: getTranslated('wishList', context)),
          Expanded(
            child: isGuestMode
                ? NotLoggedInWidget()
                : Consumer<WishListProvider>(
                    builder: (context, wishListProvider, child) {
                      return !wishListProvider.isLoading
                          ? wishListProvider.wishList.isNotEmpty
                              ? RefreshIndicator(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  onRefresh: () async {
                                    await Provider.of<WishListProvider>(context,
                                            listen: false)
                                        .initWishList(
                                      context,
                                      Provider.of<LocalizationProvider>(context,
                                              listen: false)
                                          .codeLocale
                                          .countryCode,
                                    );
                                  },
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Dimensions
                                            .PADDING_SIZE_EXTRA_SMALL),
                                    itemCount: wishListProvider.wishList.length,
                                    itemBuilder: (context, index) =>
                                        WishListWidget(
                                      product: wishListProvider.wishList[index],
                                      index: index,
                                    ),
                                  ),
                                )
                              : NoInternetOrDataScreen(isNoInternet: false)
                          : Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 3.0),
                            );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class WishListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      padding: EdgeInsets.all(0),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          enabled: Provider.of<WishListProvider>(context).wishList == null,
          child: ListTile(
            leading:
                Container(height: 50, width: 50, color: ColorResources.WHITE),
            title: Container(height: 20, color: ColorResources.WHITE),
            subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 10, width: 70, color: ColorResources.WHITE),
                  Container(height: 10, width: 20, color: ColorResources.WHITE),
                  Container(height: 10, width: 50, color: ColorResources.WHITE),
                ]),
            trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: ColorResources.WHITE)),
                  SizedBox(height: 10),
                  Container(height: 10, width: 50, color: ColorResources.WHITE),
                ]),
          ),
        );
      },
    );
  }
}
