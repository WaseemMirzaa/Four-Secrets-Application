import 'package:four_secrets_wedding_app/data/tanzschule_card_data.dart';
import 'package:four_secrets_wedding_app/model/card_front_widget.dart';
import 'package:flutter/material.dart';

class TanzschuleCardItems {
  static List getCardItems() {
    List<Widget> items = [
      // CardWidget(
      //   className: TanzschuleCardData,
      //   avatarImage: TanzschuleCardData.map1['avatar']!,
      //   vorname: TanzschuleCardData.map1['vorname']!,
      //   nachname: TanzschuleCardData.map1['nachname']!,
      //   bezeichnung: TanzschuleCardData.map1['bezeichnung']!,
      //   backCardTaetigkeit: TanzschuleCardData.map1['backCardTaetigkeit']!,
      //   slogan: TanzschuleCardData.map1['slogan']!,
      //   homepage: TanzschuleCardData.map1['homepage']!,
      //   email: TanzschuleCardData.map1['email']!,
      //   instagram: TanzschuleCardData.map1["instagram"]!,
      //   phoneNumber: TanzschuleCardData.map1["phoneNumber"]!,
      //   videoAsset: TanzschuleCardData.map1["videoAsset"]!,
      //   videoRatio: TanzschuleCardData.map1["videoRatio"]!,
      //   videoUri: TanzschuleCardData.map1["videoUri"]!,
      // ),
      CardWidget(
        className: TanzschuleCardData,
        avatarImage: TanzschuleCardData.map2['avatar']!,
        vorname: TanzschuleCardData.map2['vorname']!,
        nachname: TanzschuleCardData.map2['nachname']!,
        bezeichnung: TanzschuleCardData.map2['bezeichnung']!,
        backCardTaetigkeit: TanzschuleCardData.map2['backCardTaetigkeit']!,
        slogan: TanzschuleCardData.map2['slogan']!,
        homepage: TanzschuleCardData.map2['homepage']!,
        email: TanzschuleCardData.map2['email']!,
        instagram: TanzschuleCardData.map2["instagram"]!,
        phoneNumber: TanzschuleCardData.map2["phoneNumber"]!,
        videoAsset: TanzschuleCardData.map2["videoAsset"]!,
        videoRatio: TanzschuleCardData.map2["videoRatio"]!,
        videoUri: TanzschuleCardData.map2["videoUri"]!,
      ),
    ];
    return items;
  }
}
