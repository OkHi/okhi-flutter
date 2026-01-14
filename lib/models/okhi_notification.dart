/// Defines the structure of the foreground notification that will be used during verification.
class OkHiAndroidNotification {
  String title = "Verification in progress";
  String text = "Your address is being verified";
  String channelId = "okhi";
  String channelName = "OkHi";
  String channelDescription = "Address verification alerts";

  OkHiAndroidNotification({
    required this.title,
    required this.text,
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
  });

  OkHiAndroidNotification.withDefaults();

  Map<String, String> toMap() {
    return {
      "title": title,
      "text": text,
      "channelId": channelId,
      "channelName": channelName,
      "channelDescription": channelDescription
    };
  }
}
