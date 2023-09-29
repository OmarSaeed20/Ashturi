import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

void showProgressIndicator(BuildContext context) {
  AlertDialog dialog = AlertDialog(
    backgroundColor: Color(0xFFFFFFFF),
    elevation: 4,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
        Text(
          getTranslated('PLEASE_WAIT', context),
          style: titleRegular.copyWith(
            fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
          ),
        ),
      ],
    ),
  );

  showDialog(
    barrierDismissible: false,
    useSafeArea: false,
    context: context,
    builder: (context) {
      return dialog;
    },
  );
}
