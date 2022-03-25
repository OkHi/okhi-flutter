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
    });
  }
}
