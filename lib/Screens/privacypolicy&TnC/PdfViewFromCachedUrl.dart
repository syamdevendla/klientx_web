//*************   © Copyrighted by aagama_it. 

import 'package:aagama_it/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aagama_it/Configs/my_colors.dart';

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl(
      {Key? key,
      required this.url,
      required this.title,
      required this.prefs,
      required this.currentUserID,
      required this.isregistered})
      : super(key: key);

  final String? url;
  final String title;
  final String? currentUserID;
  final SharedPreferences prefs;
  final bool isregistered;

  @override
  Widget build(BuildContext context) {
    return isregistered == false || currentUserID == null
        ? Scaffold(
            appBar: AppBar(
              elevation: 0.4,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  size: 30,
                  color: Mycolors.black,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(color: Mycolors.black, fontSize: 18),
              ),
              backgroundColor: Colors.white,
            ),
            body: const PDF().cachedFromUrl(
              url!,
              placeholder: (double progress) =>
                  Center(child: Text('$progress %')),
              errorWidget: (dynamic error) =>
                  Center(child: Text(error.toString())),
            ),
          )
        : PickupLayout(
            curentUserID: currentUserID!,
            prefs: prefs,
            scaffold: Utils.getNTPWrappedWidget(Scaffold(
              appBar: AppBar(
                elevation: 0.4,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: 30,
                    color: Mycolors.black,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(color: Mycolors.black, fontSize: 18),
                ),
                backgroundColor: Colors.white,
              ),
              body: const PDF().cachedFromUrl(
                url!,
                placeholder: (double progress) =>
                    Center(child: Text('$progress %')),
                errorWidget: (dynamic error) =>
                    Center(child: Text(error.toString())),
              ),
            )));
  }
}
