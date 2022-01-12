import 'package:url_launcher/url_launcher.dart';

class MapsLauncher {
  static String getUrl(double lat, double lng) {
    var url =
        'https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}';
    return url;
  }

  static void launchGoogleMaps(double lat, double lng) async {
    var url = 'google.navigation:q=${lat.toString()},${lng.toString()}';
    var fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }
}
