import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart' as Foundation;

class mainUtil {
  static Widget anuncio;

  static BehaviorSubject<bool> refreshAnuncio = new BehaviorSubject<bool>();

  static void gerarAnuncio(double width) {
    if (Foundation.kReleaseMode) {
      anuncio =
          AdmobBanner(adUnitId: getBannerAdUnitId(), adSize: sizeBanner(width));
    } else {
      anuncio = Container(
        height: 1,
        width: 1,
      );
    }
    refreshAnuncio.add(true);
  }

  static sizeBanner(double width) {
    return AdmobBannerSize(
        width: width.floor(), height: 60, name: 'CUSTOM_SIZE_BANNER');
  }

  static String getAppId() {
    return "";
  }

  static String getBannerAdUnitId() {
    return "";
  }
}
