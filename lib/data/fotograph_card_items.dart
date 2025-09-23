import 'package:four_secrets_wedding_app/data/fotograph_card_data.dart';
import 'package:four_secrets_wedding_app/model/card_front_widget.dart';
import 'package:flutter/material.dart';

class FotographCardItems {
  static List getCardItems() {
    List<Widget> items = [
      CardWidget(
        className: FotographCardData,
        avatarImage: FotographCardData.map1['avatar']!,
        vorname: FotographCardData.map1['vorname']!,
        nachname: FotographCardData.map1['nachname']!,
        bezeichnung: FotographCardData.map1['bezeichnung']!,
        backCardTaetigkeit: FotographCardData.map1['backCardTaetigkeit']!,
        slogan: FotographCardData.map1['slogan']!,
        homepage: FotographCardData.map1['homepage']!,
        email: FotographCardData.map1['email']!,
        instagram: FotographCardData.map1["instagram"]!,
        phoneNumber: FotographCardData.map1["phoneNumber"]!,
        videoAsset: FotographCardData.map1["videoAsset"]!,
        videoRatio: FotographCardData.map1["videoRatio"]!,
        videoUri: FotographCardData.map1["videoUri"]!,
      ),
      CardWidget(
        className: FotographCardData,
        avatarImage: FotographCardData.map2['avatar']!,
        vorname: FotographCardData.map2['vorname']!,
        nachname: FotographCardData.map2['nachname']!,
        bezeichnung: FotographCardData.map2['bezeichnung']!,
        backCardTaetigkeit: FotographCardData.map2['backCardTaetigkeit']!,
        slogan: FotographCardData.map2['slogan']!,
        homepage: FotographCardData.map2['homepage']!,
        email: FotographCardData.map2['email']!,
        instagram: FotographCardData.map2["instagram"]!,
        phoneNumber: FotographCardData.map2["phoneNumber"]!,
        videoAsset: FotographCardData.map2["videoAsset"]!,
        videoRatio: FotographCardData.map2["videoRatio"]!,
        videoUri: FotographCardData.map2["videoUri"]!,
      ),
      CardWidget(
        className: FotographCardData,
        avatarImage: FotographCardData.map3['avatar']!,
        vorname: FotographCardData.map3['vorname']!,
        nachname: FotographCardData.map3['nachname']!,
        bezeichnung: FotographCardData.map3['bezeichnung']!,
        backCardTaetigkeit: FotographCardData.map3['backCardTaetigkeit']!,
        slogan: FotographCardData.map3['slogan']!,
        homepage: FotographCardData.map3['homepage']!,
        email: FotographCardData.map3['email']!,
        instagram: FotographCardData.map3["instagram"]!,
        phoneNumber: FotographCardData.map3["phoneNumber"]!,
        videoAsset: FotographCardData.map3["videoAsset"]!,
        videoRatio: FotographCardData.map3["videoRatio"]!,
        videoUri: FotographCardData.map3["videoUri"]!,
      ),
    ];
    return items;
  }
}
