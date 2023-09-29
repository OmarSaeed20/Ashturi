import 'dart:convert';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/body/login_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/cart_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/textfield/custom_password_textfield.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/textfield/custom_textfield.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/forget_password_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/widget/mobile_verify_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/widget/social_login_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/model/response/product_model.dart';
import '../../../../helper/cache_helper.dart';
import '../../../../main.dart';
import '../../../../provider/featured_deal_provider.dart';
import '../../../../provider/flash_deal_provider.dart';
import '../../../../provider/home_category_product_provider.dart';
import '../../../../provider/product_provider.dart';
import '../../../../provider/top_seller_provider.dart';
import '../../../../utill/app_constants.dart';
import '../../home/home_screens.dart';
import '../../product/brand_and_category_product_screen.dart';
import '../../product/product_details_screen.dart';
import 'otp_verification_screen.dart';
import 'show_progress_indicator.dart';

class SignInWidget extends StatefulWidget {
  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  GlobalKey<FormState> _formKeyLogin;
  Future<void> initDynamicLinks() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    String token = _pref.getString(AppConstants.TOKEN);
    FirebaseDynamicLinks.instance.onLink.listen((event) async {
      String type = event.link.toString().split('?').last.split('=').first;
      String id = event.link.toString().split('=').last;
      if (type == 'id') {
        Map data = await handleApi(context,
            route: 'v1/products/get_one_product',
            data: {
              'id': id
            },
            header: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            });
        print(data);
        if (data['status'] == 1) {
          Product product = Product.fromJson(data['data']['product']);

          print(jsonEncode(product));
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => DashBoardScreen()),
              (route) => false);
          Navigator.push(
              MyApp.navigatorKey.currentContext,
              MaterialPageRoute(
                  builder: (_) => ProductDetails(
                        product: product,
                      )));
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => DashBoardScreen()),
            (route) => false);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BrandAndCategoryProductScreen(
                      isBrand: false,
                      id: id,
                      name: type,
                    )));
      }
    });
    FirebaseDynamicLinks.instance.getInitialLink().then((event) async {
      if (event != null) {
        if (event.link != null) {
          String type = event.link.toString().split('?').last.split('=').first;
          String id = event.link.toString().split('=').last;
          if (type == 'id') {
            Map data = await handleApi(context,
                route: 'v1/products/get_one_product',
                data: {
                  'id': id
                },
                header: {
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Authorization': 'Bearer $token',
                });
            print(data);
            if (data['status'] == 1) {
              Product product = Product.fromJson(data['data']['product']);

              print(jsonEncode(product));
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => DashBoardScreen()),
                  (route) => false);
              Navigator.push(
                  MyApp.navigatorKey.currentContext,
                  MaterialPageRoute(
                      builder: (_) => ProductDetails(
                            product: product,
                          )));
            }
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => DashBoardScreen()),
                (route) => false);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BrandAndCategoryProductScreen(
                          isBrand: false,
                          id: id,
                          name: type,
                        )));
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.text =
        Provider.of<AuthProvider>(context, listen: false).getUserEmail() ??
            null;
    _passwordController.text =
        Provider.of<AuthProvider>(context, listen: false).getUserPassword() ??
            null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initDynamicLinks();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  FocusNode _emailNode = FocusNode();
  FocusNode _passNode = FocusNode();
  LoginModel body = LoginModel();

  void signInUser() async {
    if (_formKeyLogin.currentState.validate()) {
      _formKeyLogin.currentState.save();

      String _email = _emailController.text.trim();
      String _password = _passwordController.text.trim();

      if (_email.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            getTranslated('EMAIL_MUST_BE_REQUIRED', context),
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
      } else {
        if (Provider.of<AuthProvider>(context, listen: false).isRemember) {
          Provider.of<AuthProvider>(context, listen: false)
              .saveUserEmail(_email, _password);
        } else {
          Provider.of<AuthProvider>(context, listen: false)
              .clearUserEmailAndPassword();
        }

        body.email = _email;
        body.password = _password;
        String state = AppConstants.STATE.isEmpty
            ? AppConstants.states[0]
            : AppConstants.STATE;
        CacheHelper.saveData(key: "STATE", value: state);
        AppConstants.STATE = await CacheHelper.getData(key: "STATE");
        await Provider.of<AuthProvider>(context, listen: false)
            .login(body, route, context);
      }
    }
  }

  route(bool isRoute, String token, String temporaryToken,
      String errorMessage) async {
    if (isRoute) {
      if (token == null || token.isEmpty) {
        if (Provider.of<SplashProvider>(context, listen: false)
            .configModel
            .emailVerification) {
          Provider.of<AuthProvider>(context, listen: false)
              .checkEmail(_emailController.text.toString(), temporaryToken)
              .then((value) async {
            if (value.isSuccess) {
              Provider.of<AuthProvider>(context, listen: false)
                  .updateEmail(_emailController.text.toString());
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VerificationScreen(temporaryToken, '',
                          _emailController.text.toString())),
                  (route) => false);
            }
          });
        } else if (Provider.of<SplashProvider>(context, listen: false)
            .configModel
            .phoneVerification) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => MobileVerificationScreen(temporaryToken)),
              (route) => false);
        }
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
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(fontFamily: "Ubuntu"),
          ),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).isRemember;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.MARGIN_SIZE_LARGE),
      child: Form(
        key: _formKeyLogin,
        child: ListView(
          padding:
              EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
          children: [
            Container(
                margin: EdgeInsets.only(bottom: Dimensions.MARGIN_SIZE_SMALL),
                child: CustomTextField(
                  hintText:
                      getTranslated('ENTER_YOUR_EMAIL_or_mobile', context),
                  focusNode: _emailNode,
                  nextNode: _passNode,
                  textInputType: TextInputType.emailAddress,
                  controller: _emailController,
                )),
            Container(
                margin: EdgeInsets.only(bottom: Dimensions.MARGIN_SIZE_DEFAULT),
                child: CustomPasswordTextField(
                  hintTxt: getTranslated('ENTER_YOUR_PASSWORD', context),
                  textInputAction: TextInputAction.done,
                  focusNode: _passNode,
                  controller: _passwordController,
                )),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    BorderRadius.circular(Dimensions.PADDING_SIZE_EXTRA_SMALL),
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
                  AppConstants.STATE = await CacheHelper.getData(key: "STATE");

                  setState(() {});
                },
                isExpanded: true,
                underline: SizedBox(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: Dimensions.MARGIN_SIZE_SMALL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) => Checkbox(
                          checkColor: ColorResources.WHITE,
                          activeColor: Theme.of(context).primaryColor,
                          value: authProvider.isRemember,
                          onChanged: authProvider.updateRemember,
                        ),
                      ),
                      Text(getTranslated('REMEMBER', context),
                          style: titilliumRegular),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ForgetPasswordScreen())),
                    child: Text(getTranslated('FORGET_PASSWORD', context),
                        style: titilliumRegular.copyWith(
                            color: ColorResources.getLightSkyBlue(context))),
                  ),
                ],
              ),
            ),
            /*
             
            * */
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 30),
              child: CustomButton(
                onTap: () {
                  showProgressIndicator(context);

                  signInUser();
                },
                buttonText: getTranslated('SIGN_IN', context),
              ),
            ),
            SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
            SocialLoginWidget(),
            SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
            Center(
                child: Text(getTranslated('OR', context),
                    style: titilliumRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT))),
            GestureDetector(
              onTap: () async {
                if (!Provider.of<AuthProvider>(context, listen: false)
                    .isLoading) {
                  CacheHelper.saveData(key: "STATE", value: '');
                  AppConstants.STATE = await CacheHelper.getData(key: "STATE");
                  setState(() {});

                  showProgressIndicator(context);

                  await Provider.of<HomeCategoryProductProvider>(context,
                          listen: false)
                      .getHomeCategoryProductList(true, context);
                  await Provider.of<TopSellerProvider>(context, listen: false)
                      .getTopSellerList(true, context);
                  await Provider.of<FlashDealProvider>(context, listen: false)
                      .getMegaDealList(true, context, true);
                  await Provider.of<ProductProvider>(context, listen: false)
                      .getLatestProductList(1, context, reload: true);
                  await Provider.of<ProductProvider>(context, listen: false)
                      .getFeaturedProductList('1', context, reload: true);
                  await Provider.of<FeaturedDealProvider>(context,
                          listen: false)
                      .getFeaturedDealList(true, context);
                  await Provider.of<ProductProvider>(context, listen: false)
                      .getLProductList('1', context, reload: true);
                  await Provider.of<ProductProvider>(context, listen: false)
                      .getRecommendedProduct(context);
                  Provider.of<CartProvider>(context, listen: false)
                      .getCartData();

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => DashBoardScreen()),
                      (route) => !true);
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    left: Dimensions.MARGIN_SIZE_AUTH,
                    right: Dimensions.MARGIN_SIZE_AUTH,
                    top: Dimensions.MARGIN_SIZE_AUTH_SMALL),
                width: double.infinity,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(getTranslated('CONTINUE_AS_GUEST', context),
                    style: titleHeader.copyWith(
                        color: ColorResources.getPrimary(context))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
