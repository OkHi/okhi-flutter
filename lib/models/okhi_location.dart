import 'dart:convert';

import 'package:okhi_flutter/utils/utilities.dart';

/// Defines the structure of the OkHi location object once an address has been successfully created by the user.
class OkHiLocation {
  String? id;
  double? lat;
  double? lng;
  String? city;
  String? country;
  String? directions;
  String? displayTitle;
  String? otherInformation;
  String? photoUrl;
  String? placeId;
  String? plusCode;
  String? propertyName;
  String? propertyNumber;
  String? state;
  String? streetName;
  String? streetViewPanoId;
  String? streetViewPanoUrl;
  String? subtitle;
  String? title;
  String? url;
  String? userId;
  String? neighborhood;
  String? countryCode;
  List<dynamic>? usageTypes = [];
  String? ward;
  String? formattedAddress;
  String? postCode;
  String? lga;
  String? lgaCode;
  String? unit;
  String? gpsAccuracy;
  String? businessName;
  String? type;
  String? district;
  String? addressLine;

  OkHiLocation({
    this.id,
    this.lat,
    this.lng,
    this.city,
    this.country,
    this.directions,
    this.displayTitle,
    this.otherInformation,
    this.photoUrl,
    this.placeId,
    this.plusCode,
    this.propertyName,
    this.propertyNumber,
    this.state,
    this.streetName,
    this.streetViewPanoId,
    this.streetViewPanoUrl,
    this.subtitle,
    this.title,
    this.url,
    this.userId,
    this.neighborhood,
    this.countryCode,
    this.usageTypes,
    this.ward,
    this.formattedAddress,
    this.postCode,
    this.lga,
    this.lgaCode,
    this.unit,
    this.gpsAccuracy,
    this.businessName,
    this.type,
    this.district,
    this.addressLine,
  });

  OkHiLocation.fromMap(Map<String, dynamic> data) {
    id = data["id"];
    // Native plugins send flat lat/lng; backend API nests them under geo_point
    if (data.containsKey("lat") || data.containsKey("lng")) {
      lat = data["lat"] != null ? (data["lat"] as num).toDouble() : null;
      lng = data["lng"] != null ? (data["lng"] as num).toDouble() : null;
    } else if (data["geo_point"] != null) {
      lat = data["geo_point"]["lat"] != null
          ? (data["geo_point"]["lat"] as num).toDouble()
          : null;
      lng = data["geo_point"]["lng"] != null
          ? (data["geo_point"]["lng"] as num).toDouble()
          : null;
    }
    city = data["city"];
    country = data["country"];
    directions = data["directions"];
    displayTitle = data["displayTitle"] ?? data["display_title"];
    otherInformation = data["otherInformation"] ?? data["other_information"];
    photoUrl = data["photoUrl"] ?? data["photo"];
    placeId = data["placeId"] ?? data["place_id"];
    plusCode = data["plusCode"] ?? data["plus_code"];
    propertyName = data["propertyName"] ?? data["property_name"];
    propertyNumber = data["propertyNumber"] ?? data["property_number"];
    state = data["state"];
    streetName = data["streetName"] ?? data["street_name"];
    // Native plugins send flat keys; backend API nests under street_view
    if (data.containsKey("streetViewPanoId") ||
        data.containsKey("streetViewPanoUrl")) {
      streetViewPanoId = data["streetViewPanoId"];
      streetViewPanoUrl = data["streetViewPanoUrl"];
    } else if (data["street_view"] != null) {
      streetViewPanoId = data["street_view"]["pano_id"];
      streetViewPanoUrl = data["street_view"]["url"];
    }
    subtitle = data["subtitle"];
    title = data["title"];
    url = data["url"];
    userId = data["userId"] ?? data["user_id"];
    neighborhood = data["neighborhood"];
    countryCode = data["countryCode"] ?? data["country_code"];
    final rawUsageTypes = data["usageTypes"] ?? data["usage_types"];
    appDebugPrint("RawUsageTypes : $rawUsageTypes");
    usageTypes = rawUsageTypes != null ? (rawUsageTypes as List) : [];
    ward = data["ward"];
    formattedAddress = data["formattedAddress"] ?? data["formatted_address"];
    postCode = data["postCode"] ?? data["post_code"];
    lga = data["lga"];
    lgaCode = data["lgaCode"] ?? data["lga_code"];
    unit = data["unit"];
    final rawAccuracy = data["gpsAccuracy"] ?? data["gps_accuracy"];
    gpsAccuracy = rawAccuracy?.toString();
    businessName = data["businessName"] ?? data["business_name"];
    type = data["type"];
    district = data["district"];
    addressLine = data["addressLine"] ?? data["address_line_1"];
  }

  @override
  String toString() {
    return jsonEncode({
      "id": id,
      "lat": lat,
      "lng": lng,
      "city": city,
      "country": country,
      "directions": directions,
      "displayTitle": displayTitle,
      "otherInformation": otherInformation,
      "photoUrl": photoUrl,
      "placeId": placeId,
      "plusCode": plusCode,
      "propertyName": propertyName,
      "propertyNumber": propertyNumber,
      "state": state,
      "streetName": streetName,
      "streetViewPanoId": streetViewPanoId,
      "streetViewPanoUrl": streetViewPanoUrl,
      "subtitle": subtitle,
      "title": title,
      "url": url,
      "userId": userId,
      "neighborhood": neighborhood,
      "countryCode": countryCode,
      "usageTypes": usageTypes,
      "ward": ward,
      "formattedAddress": formattedAddress,
      "postCode": postCode,
      "lga": lga,
      "lgaCode": lgaCode,
      "unit": unit,
      "gpsAccuracy": gpsAccuracy,
      "businessName": businessName,
      "type": type,
      "district": district,
      "addressLine": addressLine,
    });
  }
}
