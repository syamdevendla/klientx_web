//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Configs/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:styled_text/styled_text.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Utils/custom_url_launcher.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/dynamic_modal_bottomsheet.dart';

void notificationViwer(BuildContext context, String desc, String title,
    String postedby, String imageurl, String timeString) {
  var w = MediaQuery.of(context).size.width;

  showDynamicModalBottomSheet(
      title: "",
      padding: 16,
      isCentre: false,
      context: context,
      widgetList: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeString,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.25,
                fontSize: 12.9,
                color: Mycolors.yellow.withOpacity(0.9),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.close_rounded,
                color: Mycolors.greytext,
              ),
              alignment: Alignment.centerRight,
            ),
          ],
        ),
        // Divider(),
        SizedBox(height: 10),
        imageurl == ""
            ? SizedBox(
                height: 0,
              )
            : Align(
                alignment: Alignment.center,
                child: Image.network(
                  imageurl,
                  height: (w * 0.62),
                  width: w,
                  fit: BoxFit.contain,
                ),
              ),
        SizedBox(height: 30),
        SelectableText(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 18, color: Mycolors.black, fontWeight: FontWeight.w800),
        ),

        Divider(),
        SizedBox(height: 10),
        desc.contains("bold")
            ? StyledText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Mycolors.grey,
                  height: 1.4,
                ),
                text: desc,
                tags: {
                  'bold': StyledTextTag(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Mycolors.grey,
                          height: 1.4)),
                },
              )
            : SelectableLinkify(
                style: TextStyle(fontSize: 15, height: 1.4),
                text: desc,
                onOpen: (link) async {
                  custom_url_launcher(link.url);
                },
              ),
        SizedBox(
          height: 40,
        ),
        SelectableText(
          "${getTranslatedForCurrentUser(context, 'xxidxx')} " + '$postedby',
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 12, color: Mycolors.black, fontWeight: FontWeight.w400),
        ),
      ]);
}
