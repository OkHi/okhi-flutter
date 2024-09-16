import 'package:okhi_flutter/models/okhi_verification_types.dart';

import './okhi_constant.dart';

/// The OkHiLocationManagerConfiguration exposes configurations that you can use to customise it's functionality and appearance.
class OkHiLocationManagerConfiguration {
  late String color;
  late String logoUrl;
  late bool withAppBar;
  late bool withStreetView;
  late bool withHomeAddressType;
  late bool withWorkAddressType;
  late bool withCreateMode;
  late bool withPermissionsOnboarding;
  List<VerificationTypes> verificationTypes = [];

  OkHiLocationManagerConfiguration({
    String? color,
    String? logoUrl,
    bool? withAppBar,
    bool? withStreetView,
    bool? withHomeAddressType,
    bool? withWorkAddressType,
    bool? withCreateMode,
    bool? withPermissionsOnboarding,
    List<VerificationTypes>? verificationTypes,
  }) {
    this.color = color ?? "#005d67";
    this.withCreateMode = withCreateMode ?? false;
    this.logoUrl = logoUrl ?? OkHiConstant.okhiLogoUrl;
    this.withAppBar = withAppBar ?? true;
    this.withStreetView = withStreetView ?? true;
    this.withHomeAddressType = withHomeAddressType ?? true;
    this.withWorkAddressType = withWorkAddressType ?? true;
    this.withPermissionsOnboarding = withPermissionsOnboarding ?? true;
    this.verificationTypes = verificationTypes ?? [];
  }
}
