//*************   © Copyrighted by aagama_it. 

import 'package:aagama_it/Configs/optional_constants.dart';
import 'package:flutter/material.dart';

Widget avatar(
    {String? imageUrl, double radius = 22.5, String? backgroundColor}) {
  if (imageUrl == null || imageUrl == "") {
    return CircleAvatar(
      backgroundImage: Image.network(Defaultprofilepicfromnetworklink).image,
      radius: radius,
    );
  }
  return CircleAvatar(
      backgroundImage: Image.network(imageUrl).image, radius: radius);
}
