import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/body/register_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/email_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/textfield/custom_password_textfield.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/textfield/custom_textfield.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/widget/social_login_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../../../../helper/cache_helper.dart';
import '../../../../provider/featured_deal_provider.dart';
import '../../../../provider/flash_deal_provider.dart';
import '../../../../provider/home_category_product_provider.dart';
import '../../../../provider/product_provider.dart';
import '../../../../provider/top_seller_provider.dart';
import '../../../../utill/app_constants.dart';
import 'code_picker_widget.dart';
import 'otp_verification_screen.dart';
import 'show_progress_indicator.dart';

class SignUpWidget extends StatefulWidget {
  static bool isSelect = false;

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  GlobalKey<FormState> _formKey;

  FocusNode _fNameFocus = FocusNode();
  FocusNode _lNameFocus = FocusNode();
  FocusNode _emailFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  FocusNode _confirmPasswordFocus = FocusNode();

  RegisterModel register = RegisterModel();
  bool isEmailVerified = false;

  Future<void> signUpUser() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      isEmailVerified = true;

      String _firstName = _firstNameController.text.trim();
      String _lastName = _lastNameController.text.trim();
      String _email = _emailController.text.trim();
      String _phone = _phoneController.text.trim();
      String _phoneNumber = _countryDialCode + _phoneController.text.trim();
      String _password = _passwordController.text.trim();
      String _confirmPassword = _confirmPasswordController.text.trim();

      if (_firstName.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('first_name_field_is_required', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else if (_lastName.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('last_name_field_is_required', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else if (_email.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('EMAIL_MUST_BE_REQUIRED', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else if (EmailChecker.isNotValid(_email)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('enter_valid_email_address', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else if (_phone.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('PHONE_MUST_BE_REQUIRED', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else if (_password.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('PASSWORD_MUST_BE_REQUIRED', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else if (_confirmPassword.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('CONFIRM_PASSWORD_MUST_BE_REQUIRED', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else if (_password != _confirmPassword) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('PASSWORD_DID_NOT_MATCH', context),
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
        ));
      } else {
        register.fName = '${_firstNameController.text}';
        register.lName = _lastNameController.text ?? " ";
        register.email = _emailController.text;
        register.phone = _phoneNumber;
        register.password = _passwordController.text;
        String state = AppConstants.STATE.isEmpty
            ? AppConstants.states[0]
            : AppConstants.STATE;
        CacheHelper.saveData(key: "STATE", value: state);
        AppConstants.STATE = await CacheHelper.getData(key: "STATE");
        await Provider.of<AuthProvider>(context, listen: false)
            .registration(register, route, context);
      }
    } else {
      isEmailVerified = false;
    }
  }

  route(
      bool isRoute, String token, String tempToken, String errorMessage) async {
    String _phone = _countryDialCode + _phoneController.text.trim();
    if (isRoute) {
      if (Provider.of<SplashProvider>(context, listen: false)
          .configModel
          .emailVerification) {
        Provider.of<AuthProvider>(context, listen: false)
            .checkEmail(_emailController.text.toString(), tempToken)
            .then((value) async {
          if (value.isSuccess) {
            Provider.of<AuthProvider>(context, listen: false)
                .updateEmail(_emailController.text.toString());
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => VerificationScreen(
                        tempToken, '', _emailController.text.toString())),
                (route) => false);
          }
        });
      } else if (Provider.of<SplashProvider>(context, listen: false)
          .configModel
          .phoneVerification) {
        Provider.of<AuthProvider>(context, listen: false)
            .checkPhone(_phone, tempToken)
            .then((value) async {
          if (value.isSuccess) {
            Provider.of<AuthProvider>(context, listen: false)
                .updatePhone(_phone);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => VerificationScreen(tempToken, _phone, '')),
                (route) => false);
          }
        });
      } else {
        await Provider.of<ProfileProvider>(context, listen: false)
            .getUserInfo(context);

        Provider.of<HomeCategoryProductProvider>(context, listen: false)
            .getHomeCategoryProductList(true, context);
        Provider.of<TopSellerProvider>(context, listen: false)
            .getTopSellerList(true, context);
        Provider.of<FlashDealProvider>(context, listen: false)
            .getMegaDealList(true, context, true);
        Provider.of<ProductProvider>(context, listen: false)
            .getLatestProductList(1, context, reload: true);
        await Provider.of<ProductProvider>(context, listen: false)
            .getFeaturedProductList('1', context, reload: true);
        await Provider.of<FeaturedDealProvider>(context, listen: false)
            .getFeaturedDealList(true, context);
        Provider.of<ProductProvider>(context, listen: false)
            .getLProductList('1', context, reload: true);
        Provider.of<ProductProvider>(context, listen: false)
            .getRecommendedProduct(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => DashBoardScreen()),
            (route) => false);
        _emailController.clear();
        _passwordController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
        _phoneController.clear();
        _confirmPasswordController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          errorMessage,
          style: TextStyle(fontFamily: "Ubuntu"),
        ),
      ));
    }
  }

  String _countryDialCode = "+20";
  @override
  void initState() {
    super.initState();
    Provider.of<SplashProvider>(context, listen: false).configModel;
    _countryDialCode = CountryCode.fromCountryCode(
            Provider.of<SplashProvider>(context, listen: false)
                .configModel
                .countryCode)
        .dialCode;

    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // for first and last name
              Container(
                margin: EdgeInsets.only(
                    left: Dimensions.MARGIN_SIZE_DEFAULT,
                    right: Dimensions.MARGIN_SIZE_DEFAULT),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomTextField(
                      hintText: getTranslated('FIRST_NAME', context),
                      textInputType: TextInputType.name,
                      focusNode: _fNameFocus,
                      nextNode: _lNameFocus,
                      isPhoneNumber: false,
                      capitalization: TextCapitalization.words,
                      controller: _firstNameController,
                    )),
                    SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                    Expanded(
                        child: CustomTextField(
                      hintText: getTranslated('LAST_NAME', context),
                      focusNode: _lNameFocus,
                      nextNode: _emailFocus,
                      capitalization: TextCapitalization.words,
                      controller: _lastNameController,
                    )),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(
                  left: Dimensions.MARGIN_SIZE_DEFAULT,
                  right: Dimensions.MARGIN_SIZE_DEFAULT,
                  top: Dimensions.MARGIN_SIZE_SMALL,
                  bottom: Dimensions.MARGIN_SIZE_SMALL,
                ),
                child: CustomTextField(
                  hintText: getTranslated('ENTER_YOUR_EMAIL', context),
                  focusNode: _emailFocus,
                  nextNode: _phoneFocus,
                  textInputType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_SMALL,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: Dimensions.MARGIN_SIZE_DEFAULT,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(
                      Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ) // changes position of shadow
                  ],
                ),
                child: DropdownButton<String>(
                  value: AppConstants.STATE.isEmpty
                      ? AppConstants.states[0]
                      : AppConstants.STATE,
                  items: AppConstants.states.map((String element) {
                    return DropdownMenuItem<String>(
                      value: element,
                      child: Text(
                        getTranslated(element, context),
                        style: robotoRegular.copyWith(
                          color: ColorResources.getTextTitle(context),
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String value) async {
                    AppConstants.STATE = value;
                    CacheHelper.saveData(key: "STATE", value: value);
                    AppConstants.STATE =
                        await CacheHelper.getData(key: "STATE");

                    setState(() {});
                  },
                  isExpanded: true,
                  underline: SizedBox(),
                ),
              ),

              Container(
                margin: EdgeInsets.only(
                    left: Dimensions.MARGIN_SIZE_DEFAULT,
                    right: Dimensions.MARGIN_SIZE_DEFAULT,
                    top: Dimensions.MARGIN_SIZE_SMALL),
                child: Row(children: [
                  CodePickerWidget(
                    onChanged: (CountryCode countryCode) {
                      _countryDialCode = countryCode.dialCode;
                    },
                    initialSelection: _countryDialCode,
                    favorite: [_countryDialCode],
                    showDropDownButton: true,
                    padding: EdgeInsets.zero,
                    showFlagMain: true,
                    textStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1.color),
                  ),
                  Expanded(
                      child: CustomTextField(
                    hintText: getTranslated('ENTER_MOBILE_NUMBER', context),
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    nextNode: _passwordFocus,
                    isPhoneNumber: true,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.phone,
                  )),
                ]),
              ),

              Container(
                margin: EdgeInsets.only(
                    left: Dimensions.MARGIN_SIZE_DEFAULT,
                    right: Dimensions.MARGIN_SIZE_DEFAULT,
                    top: Dimensions.MARGIN_SIZE_SMALL),
                child: CustomPasswordTextField(
                  hintTxt: getTranslated('PASSWORD', context),
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  nextNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.next,
                ),
              ),

              Container(
                margin: EdgeInsets.only(
                    left: Dimensions.MARGIN_SIZE_DEFAULT,
                    right: Dimensions.MARGIN_SIZE_DEFAULT,
                    top: Dimensions.MARGIN_SIZE_SMALL),
                child: CustomPasswordTextField(
                  hintTxt: getTranslated('RE_ENTER_PASSWORD', context),
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.only(
              left: Dimensions.MARGIN_SIZE_LARGE,
              right: Dimensions.MARGIN_SIZE_LARGE,
              bottom: Dimensions.MARGIN_SIZE_LARGE,
              top: Dimensions.MARGIN_SIZE_LARGE),
          child: CustomButton(
            onTap: () async {
              showProgressIndicator(context);

              signUpUser();
            },
            buttonText: getTranslated('SIGN_UP', context),
          ),
        ),

        SocialLoginWidget(),

        // for skip for now
        Provider.of<AuthProvider>(context).isLoading
            ? SizedBox()
            : Center(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async {
                        CacheHelper.saveData(key: "STATE", value: '');
                        AppConstants.STATE =
                            await CacheHelper.getData(key: "STATE");
                        setState(() {});
                        // loading
                        showProgressIndicator(context);
                        // get all data
                        await Provider.of<HomeCategoryProductProvider>(context,
                                listen: false)
                            .getHomeCategoryProductList(true, context);
                        await Provider.of<TopSellerProvider>(context,
                                listen: false)
                            .getTopSellerList(true, context);
                        await Provider.of<FlashDealProvider>(context,
                                listen: false)
                            .getMegaDealList(true, context, true);
                        await Provider.of<ProductProvider>(context,
                                listen: false)
                            .getLatestProductList(1, context, reload: true);
                        await Provider.of<ProductProvider>(context,
                                listen: false)
                            .getFeaturedProductList('1', context, reload: true);
                        await Provider.of<FeaturedDealProvider>(context,
                                listen: false)
                            .getFeaturedDealList(true, context);
                        await Provider.of<ProductProvider>(context,
                                listen: false)
                            .getLProductList('1', context, reload: true);
                        await Provider.of<ProductProvider>(context,
                                listen: false)
                            .getRecommendedProduct(context);

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DashBoardScreen()));
                      },
                      child: Text(getTranslated('SKIP_FOR_NOW', context),
                          style: titilliumRegular.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: ColorResources.getPrimary(context)))),
                  Icon(
                    Icons.arrow_forward,
                    size: 15,
                    color: Theme.of(context).primaryColor,
                  )
                ],
              )),
      ],
    );
  }
}
