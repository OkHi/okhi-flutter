import 'dart:convert';

/// Defines the structure of the OkHi location object once an address has been successfully created by the user.
class OkHiLocation {
  String? id;
  double? lat;
  double? lon;
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
  List<String>? usageTypes = [];
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
    this.lon,
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
    id = data.containsKey("id") ? data["id"] : null;
    lat = data.containsKey("geo_point") ? data["geo_point"]["lat"] : null;
    lon = data.containsKey("geo_point") ? data["geo_point"]["lon"] : null;
    city = data.containsKey("city") ? data["city"] : null;
    country = data.containsKey("country") ? data["country"] : null;
    directions = data.containsKey("directions") ? data["directions"] : null;
    displayTitle =
        data.containsKey("display_title") ? data["display_title"] : null;
    otherInformation = data.containsKey("other_information")
        ? data["other_information"]
        : null;
    photoUrl = data.containsKey("photo") ? data["photo"] : null;
    placeId = data.containsKey("place_id") ? data["place_id"] : null;
    plusCode = data.containsKey("plus_code") ? data["plus_code"] : null;
    propertyName =
        data.containsKey("property_name") ? data["property_name"] : null;
    propertyNumber =
        data.containsKey("property_number") ? data["property_number"] : null;
    state = data.containsKey("state") ? data["state"] : null;
    streetName = data.containsKey("street_name") ? data["street_name"] : null;
    streetViewPanoId =
        data.containsKey("street_view") ? data["street_view"]["pano_id"] : null;
    streetViewPanoUrl =
        data.containsKey("street_view") ? data["street_view"]["url"] : null;
    subtitle = data.containsKey("subtitle") ? data["subtitle"] : null;
    title = data.containsKey("title") ? data["title"] : null;
    url = data.containsKey("url") ? data["url"] : null;
    userId = data.containsKey("user_id") ? data["user_id"] : null;
    neighborhood =
        data.containsKey("neighborhood") ? data["neighborhood"] : null;
    countryCode =
        data.containsKey("country_code") ? data["country_code"] : null;
    usageTypes =
        (data.containsKey("usage_types") ? data["usage_types"] as List : [])
            .cast<String>();
    ward = data.containsKey("ward") ? data["ward"] : null;
    formattedAddress = data.containsKey("formatted_address")
        ? data["formatted_address"]
        : null;
    postCode = data.containsKey("post_code") ? data["post_code"] : null;
    lga = data.containsKey("lga") ? data["lga"] : null;
    lgaCode = data.containsKey("lga_code") ? data["lga_code"] : null;
    unit = data.containsKey("unit") ? data["unit"] : null;
    gpsAccuracy = data.containsKey("gps_accuracy")
        ? data["gps_accuracy"].toString()
        : null;
    businessName =
        data.containsKey("business_name") ? data["business_name"] : null;
    type = data.containsKey("type") ? data["type"] : null;
    district = data.containsKey("district") ? data["district"] : null;
    addressLine =
        data.containsKey("address_line_1") ? data["address_line_1"] : null;
  }

  @override
  String toString() {
    return jsonEncode({
      "id": id,
      "lat": lat,
      "lon": lon,
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
