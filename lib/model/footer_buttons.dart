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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            child: Icon(
              FontAwesomeIcons.earthAmericas,
              size: iconSize,
            ),
            onPressed: () {
              if (urlHomepage?.isNotEmpty == true && urlHomepage != "null") {
                UrlEmailInstagram.getLaunchHomepage(
                  url: urlHomepage,
                  modeString: urlMode,
                );
              }
            },
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: Color.fromARGB(255, 107, 69, 106),
                fixedSize: Size(buttonSize, buttonSize),
                elevation: 2.5),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            child: Icon(
              Icons.mail,
              size: iconSize,
            ),
            onPressed: () {
              if (mailAdress?.isNotEmpty == true && mailAdress != "null") {
                UrlEmailInstagram.sendEmail(toEmail: mailAdress);
              }
            },
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: Color.fromARGB(255, 107, 69, 106),
                fixedSize: Size(buttonSize, buttonSize),
                elevation: 2.5),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            child: Icon(
              Icons.play_circle,
              size: iconSize,
            ),
            onPressed: () => _handleVideoPress(context),
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: isVideoAvailable
                    ? Color.fromARGB(255, 107, 69, 106)
                    : Colors.grey, // Grey out if no video
                fixedSize: Size(buttonSize, buttonSize),
                elevation: 2.5),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            child: Icon(
              FontAwesomeIcons.squareInstagram,
              size: iconSize,
            ),
            onPressed: () {
              if (urlInstagram?.isNotEmpty == true && urlInstagram != "null") {
                UrlEmailInstagram.getlaunchInstagram(
                    url: urlInstagram, modeString: urlMode);
              }
            },
            style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: Color.fromARGB(255, 107, 69, 106),
                fixedSize: Size(buttonSize, buttonSize),
                elevation: 2.5),
          ),
        ),
      ],
    );
  }
}
