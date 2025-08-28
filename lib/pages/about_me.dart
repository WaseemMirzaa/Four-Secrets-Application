import 'package:four_secrets_wedding_app/data/about_me_data.dart';
import 'package:four_secrets_wedding_app/model/url_email_instagram.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/gestures.dart';
import 'package:four_secrets_wedding_app/menue.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutMe extends StatefulWidget {
  const AboutMe({super.key});

  @override
  State<AboutMe> createState() => _AboutMeState();
}

class _AboutMeState extends State<AboutMe> {
  int activeIndex = 0;
  String modeUrl = "default";
  var videoAsset = AboutMeData.map["videoAsset"] != null
      ? AboutMeData.map["videoAsset"]!
      : "";
  var videoUri =
      AboutMeData.map["videoUri"] != null ? AboutMeData.map["videoUri"]! : "";
  var videoRatio = AboutMeData.map["videoRatio"] != null
      ? AboutMeData.map["videoRatio"]!
      : "";
  var urlHomepage =
      AboutMeData.map["topHair"] != null ? AboutMeData.map["topHair"]! : "";

  final colorizeColors = [
    Colors.black,
    Colors.purple,
    Colors.grey.shade700,
    const Color.fromARGB(255, 229, 229, 229),
  ];

  final colorizeTextStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'Horizon',
  );

  TextStyle? _textStyleBlack() {
    return const TextStyle(
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Menue.getInstance(),
        appBar: AppBar(
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          title: const Text('Über mich'),
          backgroundColor: const Color.fromARGB(255, 107, 69, 106),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we're on a small screen
            bool isSmallScreen = constraints.maxWidth < 600;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with gradient
                  Container(
                    width: double.infinity,
                    height: isSmallScreen ? 60 : 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromARGB(255, 107, 69, 106),
                          Color.fromARGB(255, 173, 101, 170),
                          Color.fromARGB(255, 210, 159, 208),
                        ],
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),

                        // Header image and text section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            Container(
                              width: isSmallScreen ? 100 : 120,
                              height: isSmallScreen ? 130 : 158,
                              child: Image.asset(
                                'assets/images/about_me/about_me_header.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 20),

                            // Text content next to image
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                padding:
                                    EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 4.0 : 8.0,
                                        vertical: isSmallScreen ? 8.0 : 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.grey.shade100,
                                            Colors.grey.shade200,
                                            Colors.grey.shade300,
                                            Colors.grey.shade400,
                                          ],
                                        ),
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: false,
                                        totalRepeatCount: 2,
                                        animatedTexts: [
                                          ColorizeAnimatedText(
                                            'Hi! Ich bin Elena',
                                            textStyle:
                                                colorizeTextStyle.copyWith(
                                              fontSize:
                                                  isSmallScreen ? 16.0 : 20.0,
                                            ),
                                            colors: colorizeColors,
                                            speed: const Duration(
                                                milliseconds: 500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.openSans(
                                          color: Colors.black,
                                          height: 1.5,
                                          fontSize: isSmallScreen ? 14 : 16,
                                        ),
                                        children: [
                                          TextSpan(text: 'Die '),
                                          TextSpan(
                                            text: 'Gründerin',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(text: ' der '),
                                          TextSpan(
                                            text:
                                                '4secrets - Wedding Planner App',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(text: ' und des '),
                                          TextSpan(
                                            text: '4secrets Studios',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // First text section
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.openSans(
                                color: Colors.black,
                                fontSize: isSmallScreen ? 14 : 16,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "Wer steckt hinter der 4secrets - Wedding Planner App?\n\n",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      "Mit über 18 Jahren Berufserfahrung bin ich eine "
                                      "erfahrene Friseurmeisterin und Make-up Artistin. "
                                      "Im Jahr 2012 eröffnete ich mein Friseur- "
                                      "und Make-up-Studio mit einem klaren Fokus auf "
                                      "Hochzeiten. Heute findet ihr mich "
                                      "im malerischen Glockenbachviertel in München. "
                                      "Im Verlauf meiner Karriere habe ich mit renommierten "
                                      "Zeitschriften und zahlreichen Fotografen zusammengearbeitet. "
                                      "Mein 4Secrets Studio erhielt schon mehrfach Anerkennung",
                                ),
                                TextSpan(
                                  text: ' von',
                                  style: _textStyleBlack(),
                                ),
                                TextSpan(
                                  text: ' Top Hair',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 107, 69, 106),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      if (urlHomepage.isNotEmpty) {
                                        UrlEmailInstagram.getLaunchHomepage(
                                            url: urlHomepage,
                                            modeString: modeUrl);
                                      }
                                    },
                                ),
                                TextSpan(
                                  text:
                                      " als eines der 15 besten Studios in Deutschland, Österreich und der Schweiz.",
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Main image
                        Center(
                          child: Image.asset(
                            'assets/images/about_me/about_me_main.jpg',
                            width: double.infinity,
                            height: isSmallScreen ? 250 : 350,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Expandable text section
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: ExpandableText(
                            "Bereits seit über 15 Jahren begleite ich Paare an einem der wichtigsten Tage ihres Lebens. "
                            "Ich durfte Freudentränen sehen, Nervosität lindern - und dabei immer wieder "
                            "hautnah miterleben, wie viel Organisation, Zeit und Stress hinter einer Hochzeit steckt. "
                            "Eins viel mir dabei besonders auf: Viele Paare verlieren sich in der Planung "
                            "und vergessen dabei, den Moment zu genießen. "
                            "Aus dem Wunsch heraus, Brautpaare nicht nur am Hochzeitstag, sondern schon während "
                            "der gesamten Planung zur Seite zu stehen, entstand 4secrets - Wedding Planner App - eine liebevoll gestaltete App, "
                            "die euch Klarheit, Struktur und Ruhe schenkt. "
                            "Jede Braut, jede Freundin, jede Begegnung ist für mich mehr als ein Job - "
                            "es ist Teil einer Herzensgeschichte, die ich mitschreiben darf. ",
                            maxLines: 3,
                            expandText: 'show more',
                            collapseText: 'show less',
                            collapseOnTextTap: true,
                            linkStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 107, 69, 106),
                            ),
                            style: GoogleFonts.openSans(
                              color: Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                              height: 1.5,
                            ),
                            animation: true,
                            animationDuration: Duration(milliseconds: 600),
                            animationCurve: Curves.easeInOut,
                          ),
                        ),

                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
