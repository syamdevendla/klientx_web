//*************   © Copyrighted by aagama_it. 

import 'dart:io';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Utils/open_settings.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/widgets/VideoPicker/VideoPicker.dart';

class MultiImagePicker extends StatefulWidget {
  MultiImagePicker(
      {Key? key,
      required this.title,
      required this.callback,
      this.writeMessage,
      this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;
  final Future<void> Function(String url, int timestamp)? writeMessage;

  @override
  _MultiImagePickerState createState() => new _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  String mode = 'single';
  List<XFile> selectedImages = [];
  int currentUploadingIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  bool checkTotalNoOfFilesIfExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (selectedImages.length > observer.maxNoOfFilesInMultiSharing) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfAnyFileSizeExceeded() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    int index = selectedImages.indexWhere((file) =>
        File(file.path).lengthSync() / 1000000 >
        observer.maxFileSizeAllowedInMB);
    if (index >= 0) {
      return true;
    } else {
      return false;
    }
  }

  void captureSingleImage(ImageSource captureMode) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        if (File(pickedImage.path).lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              '${getTranslatedForCurrentUser(this.context, 'xxmaxfilesizexx')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslatedForCurrentUser(this.context, 'xxselectedfilesizexx')} ${(File(pickedImage.path).lengthSync() / 1000000).round()}MB';
          print('errrror');
          setState(() {
            mode = "single";
            selectedImages = [];
          });
        } else {
          setState(() {
            mode = "single";
            selectedImages.add(pickedImage);
          });
        }
      }
    } catch (e) {}
  }

  void captureMultiPageImage(bool isAddOnly) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      if (isAddOnly) {
        //--- Is adding to already selected images list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images!.length > 0) {
          images.forEach((image) {
            if (!selectedImages.contains(image)) {
              selectedImages.add(image);
            }
          });

          mode = 'multi';
          error = null;
          setState(() {});
        }
      } else {
        //--- Is adding to empty selected image list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images!.length > 1) {
          selectedImages = images;
          mode = 'multi';
          error = null;
          setState(() {});
        } else if (images.length == 1) {
          if (File(images[0].path).lengthSync() / 1000000 >
              observer.maxFileSizeAllowedInMB) {
            error =
                '${getTranslatedForCurrentUser(this.context, 'xxmaxfilesizexx')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslatedForCurrentUser(this.context, 'xxselectedfilesizexx')} ${(File(images[0].path).lengthSync() / 1000000).round()}MB';

            setState(() {
              mode = "single";
            });
          } else {
            setState(() {
              mode = "single";
              selectedImages = images;
            });
          }
        }
      }
    } catch (e) {}
  }

  Widget _buildSingleImage({File? file}) {
    if (file != null) {
      return new Image.file(file);
    } else {
      return new Text(getTranslatedForCurrentUser(context, 'xxtakeimagexx'),
          style: new TextStyle(
            fontSize: 18.0,
            color: Mycolors.black,
          ));
    }
  }

  Widget _buildMultiImageLoading() {
    return Container(
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${currentUploadingIndex + 1}/${selectedImages.length}',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: Mycolors.secondary),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            getTranslatedForCurrentUser(this.context, 'xxsendingxx'),
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Mycolors.black),
          )
        ],
      )),
      color: Colors.white.withOpacity(0.8),
    );
  }

  Widget _buildMultiImage() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (selectedImages.length > 0) {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7),
          itemCount: selectedImages.length,
          itemBuilder: (BuildContext context, i) {
            return Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    height: (MediaQuery.of(this.context).size.width / 2) - 20,
                    width: (MediaQuery.of(this.context).size.width / 2) - 20,
                    color: Mycolors.grey.withOpacity(0.4),
                  ),
                  new Image.file(
                    File(selectedImages[i].path),
                    fit: BoxFit.cover,
                    height: (MediaQuery.of(this.context).size.width / 2) - 20,
                    width: (MediaQuery.of(this.context).size.width / 2) - 20,
                  ),
                  File(selectedImages[i].path).lengthSync() / 1000000 >
                          observer.maxFileSizeAllowedInMB
                      ? Container(
                          height:
                              (MediaQuery.of(this.context).size.width / 2) - 20,
                          width:
                              (MediaQuery.of(this.context).size.width / 2) - 20,
                          color: Colors.white70,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsetsDirectional.all(10),
                              child: Text(
                                '${getTranslatedForCurrentUser(this.context, 'xxmaxfilesizexx')} ${observer.maxFileSizeAllowedInMB}MB\n${getTranslatedForCurrentUser(this.context, 'xxselectedfilesizexx')} ${(File(selectedImages[i].path).lengthSync() / 1000000).round()}MB',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 6,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedImages.removeAt(i);
                          if (selectedImages.length <= 1) {
                            mode = "single";
                          }
                        });
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: new BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: new Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // decoration: BoxDecoration(
              //     color: Colors.amber, borderRadius: BorderRadius.circular(15)),
            );
          });
    } else {
      return new Text(getTranslatedForCurrentUser(context, 'xxtakeimagexx'),
          style: new TextStyle(
            fontSize: 18.0,
            color: Mycolors.black,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Utils.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
            elevation: 0.4,
            leading: IconButton(
              onPressed: () {
                if (!isLoading) {
                  Navigator.of(this.context).pop();
                }
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: Mycolors.black,
              ),
            ),
            title: new Text(
              selectedImages.length > 0
                  ? '${selectedImages.length} ${getTranslatedForCurrentUser(this.context, 'xxselectedxx')}'
                  : widget.title,
              style: TextStyle(
                fontSize: 18,
                color: Mycolors.black,
              ),
            ),
            backgroundColor: Colors.white,
            actions: selectedImages.length != 0 && !isLoading
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: Mycolors.black,
                        ),
                        onPressed: checkTotalNoOfFilesIfExceeded() == false
                            ? (checkIfAnyFileSizeExceeded() == false
                                ? () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    uploadEach(0);
                                  }
                                : () {
                                    final observer = Provider.of<Observer>(
                                        this.context,
                                        listen: false);
                                    Utils.toast(getTranslatedForCurrentUser(
                                            context, 'xxilesizeexceededxx') +
                                        ': ${observer.maxFileSizeAllowedInMB}MB');
                                  })
                            : () {
                                Utils.toast(
                                    '${getTranslatedForCurrentUser(this.context, 'xxmaxnooffilesxx')}: ${observer.maxNoOfFilesInMultiSharing}');
                              }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            mode == 'single'
                ? new Expanded(
                    child: new Center(
                        child: error != null
                            ? fileSizeErrorWidget(error!)
                            : _buildSingleImage(
                                file: selectedImages.length > 0
                                    ? File(selectedImages[0].path)
                                    : null)))
                : new Expanded(child: new Center(child: _buildMultiImage())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? mode == "multi" && selectedImages.length > 1
                    ? _buildMultiImageLoading()
                    : Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Mycolors.secondary)),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  uploadEach(int index) async {
    if (index > selectedImages.length) {
      Navigator.of(this.context).pop();
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await widget
          .callback(File(selectedImages[index].path),
              timestamp: messagetime, totalFiles: selectedImages.length)
          .then((imageUrl) async {
        await widget.writeMessage!(imageUrl, messagetime).then((value) {
          if (selectedImages.last == selectedImages[index]) {
            Navigator.of(this.context).pop();
          } else {
            uploadEach(currentUploadingIndex + 1);
          }
        });
      });
    }
  }

  Widget _buildButtons() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                  new Key('multi'),
                  Icons.photo_library,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Utils.checkAndRequestPermission(Permission.storage)
                              .then((res) {
                            if (res == true) {
                              captureMultiPageImage(false);
                            } else if (res == false) {
                              Utils.showRationale(getTranslatedForCurrentUser(
                                  context, 'xxpgixx'));
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => OpenSettings()));
                            } else {}
                          });
                        }
                      : () {
                          Utils.toast(
                              '${getTranslatedForCurrentUser(this.context, 'xxmaxnooffilesxx')}: ${observer.maxNoOfFilesInMultiSharing}');
                        }),
              selectedImages.length < 1
                  ? SizedBox()
                  : _buildActionButton(
                      new Key('multi'),
                      Icons.add,
                      checkTotalNoOfFilesIfExceeded() == false
                          ? () {
                              Utils.checkAndRequestPermission(
                                      Permission.storage)
                                  .then((res) {
                                if (res == true) {
                                  captureMultiPageImage(true);
                                } else if (res == false) {
                                  Utils.showRationale(
                                      getTranslatedForCurrentUser(
                                          context, 'xxpgixx'));
                                  Navigator.pushReplacement(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              OpenSettings()));
                                } else {}
                              });
                            }
                          : () {
                              Utils.toast(
                                  '${getTranslatedForCurrentUser(this.context, 'xxmaxnooffilesxx')}: ${observer.maxNoOfFilesInMultiSharing}');
                            }),
              _buildActionButton(
                  new Key('upload'),
                  Icons.photo_camera,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Utils.checkAndRequestPermission(Permission.camera)
                              .then((res) {
                            if (res == true) {
                              captureSingleImage(ImageSource.camera);
                            } else if (res == false) {
                              getTranslatedForCurrentUser(context, 'xxpcixx');
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => OpenSettings()));
                            } else {}
                          });
                        }
                      : () {
                          Utils.toast(
                              '${getTranslatedForCurrentUser(this.context, 'xxmaxnooffilesxx')}: ${observer.maxNoOfFilesInMultiSharing}');
                        }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      child: new IconButton(
          key: key,
          icon: Icon(
            icon,
            size: 30.0,
          ),
          color: Mycolors.primary,
          onPressed: onPressed as void Function()?),
    );
  }
}
