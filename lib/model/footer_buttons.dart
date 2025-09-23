import 'package:four_secrets_wedding_app/model/url_email_instagram.dart';
import 'package:four_secrets_wedding_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:four_secrets_wedding_app/utils/snackbar_helper.dart';

// ignore: must_be_immutable
class FooterButtons extends StatelessWidget {
  var urlHomepage;
  var urlMode;
  var mailAdress;
  var videoUri;
  var videoAsset;
  var videoRatio;
  var urlInstagram;
  double buttonSize;
  double iconSize;

  FooterButtons({
    super.key,
    required this.urlHomepage,
    required this.urlMode,
    required this.mailAdress,
    required this.videoUri,
    required this.videoAsset,
    required this.videoRatio,
    required this.urlInstagram,
    required this.buttonSize,
    required this.iconSize,
  });

  // Helper method to check if video is available
  bool get isVideoAvailable {
    return (videoAsset?.isNotEmpty == true && videoAsset != "null") ||
        (videoUri?.isNotEmpty == true && videoUri != "null");
  }

  bool get isHomepageAvailable {
    return urlHomepage?.isNotEmpty == true && urlHomepage != "null";
  }

  // Helper method to check if mail is available
  bool get isMailAvailable {
    return mailAdress?.isNotEmpty == true && mailAdress != "null";
  }

  // Helper method to check if Instagram is available
  bool get isInstagramAvailable {
    return urlInstagram?.isNotEmpty == true && urlInstagram != "null";
  }

  void _handleHomepagePress(BuildContext context) {
    if (isHomepageAvailable) {
      UrlEmailInstagram.getLaunchHomepage(
        url: urlHomepage,
        modeString: urlMode,
      );
    } else {
      SnackBarHelper.showErrorSnackBar(
        context,
        "Homepage noch nicht verfügbar",
      );
    }
  }

  void _handleMailPress(BuildContext context) {
    if (isMailAvailable) {
      UrlEmailInstagram.sendEmail(toEmail: mailAdress);
    } else {
      SnackBarHelper.showErrorSnackBar(
        context,
        "E-Mail Adresse noch nicht verfügbar",
      );
    }
  }

  void _handleVideoPress(BuildContext context) {
    if (isVideoAvailable) {
      Navigator.of(context).pushNamed(
        RouteManager.videoPlayer2,
        arguments: {
          'asset': videoAsset,
          'uri': videoUri?.trim(),
          'ratio': videoRatio,
        },
      );
    } else {
      SnackBarHelper.showErrorSnackBar(context, "Video noch nicht verfügbar");
    }
  }

  void _handleInstagramPress(BuildContext context) {
    if (isInstagramAvailable) {
      UrlEmailInstagram.getlaunchInstagram(
        url: urlInstagram,
        modeString: urlMode,
      );
    } else {
      SnackBarHelper.showErrorSnackBar(
        context,
        "Instagram noch nicht verfügbar",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            child: Icon(FontAwesomeIcons.earthAmericas, size: iconSize),
            onPressed: () => _handleHomepagePress(context),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: isHomepageAvailable
                  ? Colors.white
                  : Colors.grey[300],
              foregroundColor: isHomepageAvailable
                  ? Color.fromARGB(255, 107, 69, 106)
                  : Colors.grey[600],
              fixedSize: Size(buttonSize, buttonSize),
              elevation: 2.5,
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            child: Icon(Icons.mail, size: iconSize),
            onPressed: () => _handleMailPress(context),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: isMailAvailable
                  ? Colors.white
                  : Colors.grey[300],
              foregroundColor: isMailAvailable
                  ? Color.fromARGB(255, 107, 69, 106)
                  : Colors.grey[600],
              fixedSize: Size(buttonSize, buttonSize),
              elevation: 2.5,
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            child: Icon(Icons.play_circle, size: iconSize),
            onPressed: () => _handleVideoPress(context),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: isVideoAvailable
                  ? Colors.white
                  : Colors.grey[300],
              foregroundColor: isVideoAvailable
                  ? Color.fromARGB(255, 107, 69, 106)
                  : Colors.grey[600],
              fixedSize: Size(buttonSize, buttonSize),
              elevation: 2.5,
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            child: Icon(FontAwesomeIcons.squareInstagram, size: iconSize),
            onPressed: () => _handleInstagramPress(context),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              backgroundColor: isInstagramAvailable
                  ? Colors.white
                  : Colors.grey[300],
              foregroundColor: isInstagramAvailable
                  ? Color.fromARGB(255, 107, 69, 106)
                  : Colors.grey[600],
              fixedSize: Size(buttonSize, buttonSize),
              elevation: 2.5,
            ),
          ),
        ),
      ],
    );
  }
}
