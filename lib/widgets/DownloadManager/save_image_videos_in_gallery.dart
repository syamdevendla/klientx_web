//*************   © Copyrighted by aagama_it.

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Utils/utils.dart';

class GalleryDownloader {
  static void saveNetworkVideoInGallery(BuildContext context, String url,
      bool isFurtherOpenFile, String fileName, GlobalKey keyloader) async {
    String path = url + "&ext=.mp4";
    Dialogs.showLoadingDialog(context, keyloader);
    GallerySaver.saveVideo(path).then((success) async {
      if (success == true) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();

        Utils.toast(getTranslatedForCurrentUser(context, 'xxfolderxx'));
      } else {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
        Utils.toast("Failed to Download !");
      }
    }).catchError((err) {
      Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      Utils.toast(err.toString());
    });
  }

  static void saveNetworkImage(BuildContext context, String url,
      bool isFurtherOpenFile, String fileName, GlobalKey keyloader) async {
    // String path =
    //     'https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg';

    String path = url + "&ext=.jpg";
    Dialogs.showLoadingDialog(context, keyloader);
    GallerySaver.saveImage(path, toDcim: true).then((success) async {
      if (success == true) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
        Utils.toast(fileName == ""
            ? getTranslatedForCurrentUser(context, 'xxfolderxx')
            : "$fileName  " +
                getTranslatedForCurrentUser(context, 'xxfolderxx'));
      } else {
        Utils.toast("Failed to Download !");
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      }
    }).catchError((err) {
      Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      Utils.toast(err.toString());
    });
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 18,
                              ),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Mycolors.loadingindicator),
                              ),
                              SizedBox(
                                width: 23,
                              ),
                              Text(
                                getTranslatedForCurrentUser(
                                    context, 'xxdownloadingxx'),
                                style: TextStyle(color: Colors.black87),
                              )
                            ]),
                      ),
                    )
                  ]));
        });
  }
}
