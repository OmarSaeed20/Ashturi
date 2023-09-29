import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/auth_screen.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/response/product_model.dart';
import '../../../../helper/cache_helper.dart';
import '../../../../provider/cart_provider.dart';
import '../../../../provider/localization_provider.dart';
import '../../../../provider/wishlist_provider.dart';
import '../../../../utill/app_constants.dart';

class SignOutConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_LARGE, vertical: 50),
          child: Text(getTranslated('want_to_sign_out', context),
              style: robotoBold, textAlign: TextAlign.center),
        ),
        Divider(height: 0, color: ColorResources.HINT_TEXT_COLOR),
        Row(children: [
          Expanded(
              child: InkWell(
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .clearSharedData()
                  .then((_) async {
                Navigator.pop(context);
                Provider.of<ProfileProvider>(context, listen: false)
                    .clearHomeAddress();
                Provider.of<ProfileProvider>(context, listen: false)
                    .clearOfficeAddress();
                Provider.of<AuthProvider>(context, listen: false)
                    .clearSharedData();

                CacheHelper.saveData(key: "state", value: '');
                AppConstants.STATE = await CacheHelper.getData(key: "state");
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                    (route) => false);
              });
            },
            child: Container(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(10))),
              child: Text(getTranslated('YES', context),
                  style: titilliumBold.copyWith(
                      color: Theme.of(context).primaryColor)),
            ),
          )),
          Expanded(
              child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ColorResources.RED,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(10))),
              child: Text(getTranslated('NO', context),
                  style: titilliumBold.copyWith(color: ColorResources.WHITE)),
            ),
          )),
        ]),
      ]),
    );
  }
}