import 'package:url_launcher/url_launcher.dart';

class UrlEmailInstagram {
// Method for connection with i. e. HomePage
  static void getLaunchHomepage(
      {required String url, required String modeString}) async {
    final finalUrl = Uri.parse(url);

    try {
      if (await canLaunchUrl(finalUrl)) {}
      await launchUrl(finalUrl,
          mode: helperLaunchMode(modeString)); // Show in Browser
    } catch (e) {
      print("$e" + ", " + "Cannot launch to: $url ( 404 not found )");
    }
  }

// Method for sending E-Mails with debug info
  static void sendEmail(
      {required String toEmail, String subject = "", String body = ""}) async {
    try {
      print("Original email: $toEmail");

      // Option 1: Use Uri constructor (recommended)
      final emailUri = Uri(
        scheme: 'mailto',
        path: toEmail,
        queryParameters: {
          'subject': subject,
          'body': body,
        },
      );

      print("Formatted URI: ${emailUri.toString()}");

      // Check which apps can handle this URI
      final canLaunch = await canLaunchUrl(emailUri);
      print("Can launch URL: $canLaunch");

      if (canLaunch) {
        // Try different modes to see which one works
        try {
          await launchUrl(emailUri, mode: LaunchMode.platformDefault);
          print("Launched with platformDefault");
        } catch (e) {
          print("platformDefault failed: $e");
          await launchUrl(emailUri, mode: LaunchMode.externalApplication);
          print("Launched with externalApplication");
        }
      } else {
        print("No app can handle this URI");

        // Try Gmail-specific URI as fallback (for Android)
        if (toEmail.contains('gmx.de')) {
          final gmailUri = Uri.parse(
              'https://mail.google.com/mail/?view=cm&fs=1&to=$toEmail&su=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');

          if (await canLaunchUrl(gmailUri)) {
            await launchUrl(gmailUri);
            print("Opened in Gmail web");
          }
        }
      }
    } catch (e) {
      print("Complete failure: $e");
    }
  }

  static void getlaunchInstagram(
      {required String url, required String modeString}) async {
    final finalUrl = Uri.parse(url);

    try {
      if (await canLaunchUrl(finalUrl)) {}
      await launchUrl(finalUrl, mode: helperLaunchMode(modeString));
    } catch (e) {
      print("$e" + ", " + "Cannot launch to: $url ( 404 not found )");
    }
  }

  // Dial Phonenumber
  static void openDialPad(String phoneNumber) async {
    Uri url = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Can't open dial pad.");
    }
  }

  static LaunchMode helperLaunchMode(String modeString) {
    var mode = LaunchMode.platformDefault;
    switch (modeString) {
      case "default":
        mode = LaunchMode.platformDefault;
        break;
      case "appWeb":
        mode = LaunchMode.inAppWebView;
        break;
      case "external":
        mode = LaunchMode.externalApplication;
        break;
      case "appBrowser":
        mode = LaunchMode.inAppBrowserView;
        break;
      default:
        mode = LaunchMode.platformDefault;
        break;
    }
    return mode;
  }
}
