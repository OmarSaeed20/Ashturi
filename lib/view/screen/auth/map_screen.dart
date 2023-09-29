import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/widget/sign_up_widget.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../helper/cache_helper.dart';
import '../../../localization/language_constrants.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({Key key}) : super(key: key);

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition cameraPosition;
  Set<Marker> markers = {};
  @override
  void initState() {
    getMyCurrentLocation();
    super.initState();
  }

  Future<void> getMyCurrentLocation() async {
    await getCurrentLocation().then((val) {
      cameraPosition = CameraPosition(
        target: LatLng(val.latitude, val.longitude),
        bearing: 0.0,
        tilt: 0.0,
        zoom: 16,
      );
      markers.add(Marker(
        markerId: const MarkerId("1"),
        position: LatLng(val.latitude, val.longitude),
        infoWindow: const InfoWindow(
          title: 'My Current Location',
        ),
      ));
      setState(() {});
    });
  }

  Future<Position> getCurrentLocation() async {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isServiceEnabled) {
      await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getAddressFromLatLang(
      Position position, BuildContext context) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemark[0];

    String state = place.administrativeArea.toString();
    //'${place.street},${place.locality},${place.administrativeArea},${place.country}';
    CacheHelper.saveData(key: "state", value: state);
    AppConstants.STATE = await CacheHelper.getData(key: "state");
  }

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((_) {}).catchError((error) async {
      await Geolocator.requestPermission();
      debugPrint("----------------> $error");
    });
    return await Geolocator.getCurrentPosition();
  }

  var latitude = 'Getting Latitude..';
  var longitude = 'Getting Longitude..';
  // ignore: cancel_subscriptions
  StreamSubscription<Position> streamSubscription;
  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cameraPosition != null
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: !true,
                  zoomControlsEnabled: !true,
                  initialCameraPosition: cameraPosition,
                  mapType: MapType.normal,
                  markers: markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Positioned(
                  bottom: Dimensions.PADDING_SIZE_LARGE,
                  left: Dimensions.PADDING_SIZE_LARGE,
                  right: Dimensions.PADDING_SIZE_LARGE,
                  child: CustomButton(
                      onTap: () {
                        streamSubscription = Geolocator.getPositionStream()
                            .listen((Position position) {
                          getAddressFromLatLang(position, context);
                          Navigator.maybePop(context);
                        });
                        // SignUpWidget.isSelect = true;
                        setState(() {});
                      },
                      buttonText: getTranslated('SELECT_LOCATION', context)),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on),
        onPressed: () {
          getUserCurrentLocation().then((val) async {
            markers.add(Marker(
              markerId: const MarkerId("2"),
              position: LatLng(val.latitude, val.longitude),
              infoWindow: const InfoWindow(
                title: 'My Current Location',
              ),
            ));

            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(val.latitude, val.longitude),
              zoom: 15,
            );

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          });
        },
      ),
    );
  }
}
