import './okhi_constant.dart';

/// The OkHiLocationManagerConfiguration exposes configurations that you can use to customise it's functionality and appearance.
class OkHiLocationManagerConfiguration {
  late String color;
  late String logoUrl;
  late bool withAppBar;
  late bool withStreetView;

  OkHiLocationManagerConfiguration({
    String? color,
    String? logoUrl,
    bool? withAppBar,
    bool? withStreetView,
  }) {
    this.color = color ?? "#005d67";
    this.logoUrl = logoUrl ?? OkHiConstant.okhiLogoUrl;
    this.withAppBar = withAppBar ?? true;
    this.withStreetView = withStreetView ?? true;
  }
}
