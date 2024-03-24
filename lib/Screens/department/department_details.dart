//*************   © Copyrighted by aagama_it.

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/number_limits.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/DataModel.dart';
import 'package:aagama_it/Models/department_model.dart';
import 'package:aagama_it/Models/ticket_model.dart';
import 'package:aagama_it/Models/userapp_settings_model.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/ticket_chat_room.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:aagama_it/Screens/activity/filtered_activity_history.dart';
import 'package:aagama_it/Screens/department/add_agents_to_department.dart';
import 'package:aagama_it/Services/FirebaseServices/firebase_api.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Utils/getRolePermission.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:aagama_it/widgets/ImagePicker/image_picker.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_time_formatter.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/late_load.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:aagama_it/widgets/WarningWidgets/warning_tile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Models/user_registry_model.dart';
import 'package:aagama_it/Services/Providers/liveListener.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/Avatar.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/userrole_based_sticker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentDetails extends StatefulWidget {
  final String departmentID;
  final String currentuserid;
  final bool showOnlyWhereManager;
  final Function onrefreshPreviousPage;
  final SharedPreferences prefs;
  final DataModel cachedModel;
  const DepartmentDetails(
      {Key? key,
      required this.departmentID,
      required this.currentuserid,
      required this.cachedModel,
      required this.prefs,
      required this.showOnlyWhereManager,
      required this.onrefreshPreviousPage})
      : super(key: key);

  @override
  _DepartmentDetailsState createState() => _DepartmentDetailsState();
}

class _DepartmentDetailsState extends State<DepartmentDetails> {
  File? imageFile;
  String error = "";
  bool isloading = true;
  final GlobalKey<State> _keyLoader223 =
      new GlobalKey<State>(debugLabel: '272husd1');
  UserAppSettingsModel? userAppSettings;
  DepartmentModel? department;
  List<dynamic> departments = [];
  final TextEditingController _textEditingController =
      new TextEditingController();
  DocumentReference docRef = FirebaseFirestore.instance
      .collection(DbPaths.userapp)
      .doc(DbPaths.appsettings);
  bool issecondaryloaderon = false;
  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  fetchdata() async {
    await docRef.get().then((dc) async {
      if (dc.exists) {
        userAppSettings = UserAppSettingsModel.fromSnapshot(dc);
        departments = userAppSettings!.departmentList!;
        // departments.removeAt(0);
        department = DepartmentModel.fromJson(userAppSettings!.departmentList!
            .lastWhere((department) =>
                department[Dbkeys.departmentTitle].toString() ==
                widget.departmentID));
        setState(() {
          isloading = false;
          issecondaryloaderon = false;
        });
      } else {
        setState(() {
          error =
              "User App setup is not completed yet. Kindly complete the User App Setup & Installation process & Reload the app ";
        });
      }
    }).catchError((onError) {
      setState(() {
        error =
            "User App setup is not completed yet. Kindly complete the User App Setup & Installation process & Reload the app $onError";

        isloading = false;
      });
    });
  }

  getImage(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      setState(() {
        imageFile = image;
      });
    }
    return uploadFile(false);
  }

  int? uploadTimestamp;
  int? thumnailtimestamp;
  Future uploadFile(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = 'DEPARTMENT_ICON';
    Reference reference = FirebaseStorage.instance
        .ref("+00_DEPARTMENT_MEDIA/${widget.departmentID}/")
        .child(fileName);
    TaskSnapshot uploading = await reference.putFile(imageFile!);
    if (isthumbnail == false) {
      setState(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }

    return uploading.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    final observer = Provider.of<Observer>(this.context, listen: true);
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: true);

    var registry = Provider.of<UserRegistry>(this.context, listen: true);
    bool isready = livedata == null
        ? false
        : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
                livedata.docmap[Dbkeys.secondadminID] == '' ||
                livedata.docmap[Dbkeys.secondadminID] == null
            ? false
            : true;
    return PickupLayout(
        curentUserID: widget.currentuserid,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(Scaffold(
          backgroundColor: Mycolors.backgroundcolor,
          appBar: AppBar(
            elevation: 0.4,
            titleSpacing: -5,
            leading: Container(
              margin: EdgeInsets.only(right: 0),
              width: 10,
              child: IconButton(
                icon: Icon(LineAwesomeIcons.arrow_left,
                    size: 24, color: Mycolors.grey),
                onPressed: () {
                  Navigator.of(this.context).pop();
                },
              ),
            ),
            actions: <Widget>[
              isloading == true
                  ? SizedBox()
                  : department!.departmentIsShow == true
                      ? Chip(
                          backgroundColor: Mycolors.green.withOpacity(0.1),
                          label: Text(
                            getTranslatedForCurrentUser(
                                this.context, 'xxlivexx'),
                            style: TextStyle(color: Mycolors.green),
                          ))
                      : Chip(
                          backgroundColor: Mycolors.greytext.withOpacity(0.1),
                          label: Text(
                            getTranslatedForCurrentUser(
                                this.context, 'xxhiddenxx'),
                            style: TextStyle(color: Mycolors.grey),
                          )),
              SizedBox(
                width: 10,
              ),
            ],
            backgroundColor: Mycolors.white,
            title: InkWell(
              onTap: () {
                // Navigator.push(
                //     this.context,
                //     PageRouteBuilder(
                //         opaque: false,
                //         pageBuilder: (this.context, a1, a2) => ProfileView(peer)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MtCustomfontBoldSemi(
                    text: getTranslatedForCurrentUser(
                        this.context, 'xxdepartmentxx'),
                    fontsize: 17,
                    color: Mycolors.black,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${widget.departmentID}",
                    style: TextStyle(
                        color: Mycolors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          body: error != ""
              ? Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Mycolors.red),
                      )),
                )
              : isloading == true
                  ? circularProgress()
                  : Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: Stack(
                        children: [
                          ListView(
                            shrinkWrap: true,
                            children: [
                              Stack(
                                children: [
                                  CachedNetworkImage(
                                    fit: BoxFit.contain,
                                    imageUrl: department!.departmentLogoURL,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Mycolors.white),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(0.0),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: BoxDecoration(
                                        color: Utils
                                            .randomColorgenratorBasedOnFirstLetter(
                                                department!.departmentTitle),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Icon(Icons.location_city,
                                          color:
                                              Mycolors.white.withOpacity(0.7),
                                          size: 75),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    width: w,
                                    height: w / 1.2,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(
                                          department!.departmentLogoURL == ""
                                              ? 0.0
                                              : 0.4),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          userAppSettings!.departmentManagerCanEditAddAgentstodepartment ==
                                                      false &&
                                                  widget.showOnlyWhereManager ==
                                                      true
                                              ? SizedBox()
                                              : department!.departmentLogoURL ==
                                                      ""
                                                  ? IconButton(
                                                      onPressed:
                                                          observer.checkIfCurrentUserIsDemo(
                                                                      widget
                                                                          .currentuserid) ==
                                                                  true
                                                              ? () {
                                                                  Utils.toast(getTranslatedForCurrentUser(
                                                                      this.context,
                                                                      'xxxnotalwddemoxxaccountxx'));
                                                                }
                                                              : () {
                                                                  Navigator.push(
                                                                      this.context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => SingleImagePicker(
                                                                                recommendedsize: "200 X 200 px (.jpg or .png)",
                                                                                title: getTranslatedForCurrentUser(this.context, 'xxpickimagexx'),
                                                                                callback: getImage,
                                                                              ))).then((url) async {
                                                                    if (url !=
                                                                        null) {
                                                                      Utils.toast(getTranslatedForCurrentUser(
                                                                          this.context,
                                                                          'xxplswaitxx'));
                                                                      ShowLoading().open(
                                                                          context:
                                                                              this.context,
                                                                          key: _keyLoader223);
                                                                      await FirebaseApi.runUPDATEmapobjectinListField(
                                                                          compareKey: Dbkeys.departmentTitle,
                                                                          compareVal: department!.departmentTitle,
                                                                          docrefdata: docRef,
                                                                          replaceableMapObjectWithOnlyFieldsRequired: {
                                                                            Dbkeys.departmentLogoURL:
                                                                                url,
                                                                            Dbkeys.departmentLastEditedOn:
                                                                                DateTime.now().millisecondsSinceEpoch
                                                                          },
                                                                          context: this.context,
                                                                          listkeyname: Dbkeys.departmentList,
                                                                          onSuccessFn: () async {
                                                                            await FirebaseApi.runTransactionRecordActivity(
                                                                                isOnlyAlertNotSave: false,
                                                                                parentid: "DEPT--${widget.departmentID}",
                                                                                title: "Department ID:${department!.departmentCreatedby} Logo updated",
                                                                                plainDesc: "Department Logo has been updated by ${widget.currentuserid}",
                                                                                imageurl: url,
                                                                                styledDesc: "<bold>${department!.departmentTitle} </bold>Department <bold>Logo</bold> has been updated by ${widget.currentuserid}",
                                                                                onErrorFn: (e) {
                                                                                  ShowLoading().close(context: this.context, key: _keyLoader223);
                                                                                  _textEditingController.clear();
                                                                                  fetchdata();
                                                                                  widget.onrefreshPreviousPage();
                                                                                  Utils.toast("Failed to update department logo! ERROR: $e");
                                                                                },
                                                                                postedbyID: widget.currentuserid,
                                                                                onSuccessFn: () {
                                                                                  ShowLoading().close(context: this.context, key: _keyLoader223);
                                                                                  _textEditingController.clear();
                                                                                  fetchdata();
                                                                                  widget.onrefreshPreviousPage();
                                                                                });
                                                                          },
                                                                          onErrorFn: (String s) {
                                                                            ShowLoading().close(
                                                                                context: this.context,
                                                                                key: _keyLoader223);
                                                                            setState(() {
                                                                              isloading = false;
                                                                            });
                                                                            Utils.toast("Error occured!. Error log: $s");
                                                                          });
                                                                    }
                                                                  });
                                                                },
                                                      icon: Icon(
                                                          Icons
                                                              .camera_alt_rounded,
                                                          color: Mycolors.white,
                                                          size: 35),
                                                    )
                                                  : IconButton(
                                                      onPressed: () async {
                                                        ShowConfirmDialog()
                                                            .open(
                                                                context: this
                                                                    .context,
                                                                subtitle: getTranslatedForCurrentUser(
                                                                    this
                                                                        .context,
                                                                    'xxremovesurexx'),
                                                                title: getTranslatedForCurrentUser(
                                                                    this
                                                                        .context,
                                                                    'xxconfirmquesxx'),
                                                                rightbtnonpress:
                                                                    observer.checkIfCurrentUserIsDemo(widget.currentuserid) ==
                                                                            true
                                                                        ? () {
                                                                            Utils.toast(getTranslatedForCurrentUser(this.context,
                                                                                'xxxnotalwddemoxxaccountxx'));
                                                                          }
                                                                        : () async {
                                                                            Navigator.pop(this.context);
                                                                            ShowLoading().open(
                                                                                context: this.context,
                                                                                key: _keyLoader223);
                                                                            await FirebaseApi.deleteFirebaseMediaUsingURL(department!.departmentLogoURL).then((status) async {
                                                                              if (status is bool || status == null) {
                                                                                if (status == true || status == null) {
                                                                                  await FirebaseApi.runUPDATEmapobjectinListField(
                                                                                      compareKey: Dbkeys.departmentTitle,
                                                                                      compareVal: department!.departmentTitle,
                                                                                      docrefdata: docRef,
                                                                                      replaceableMapObjectWithOnlyFieldsRequired: {
                                                                                        Dbkeys.departmentLogoURL: "",
                                                                                        Dbkeys.departmentLastEditedOn: DateTime.now().millisecondsSinceEpoch
                                                                                      },
                                                                                      context: this.context,
                                                                                      listkeyname: Dbkeys.departmentList,
                                                                                      onSuccessFn: () async {
                                                                                        await FirebaseApi.runTransactionRecordActivity(
                                                                                            isOnlyAlertNotSave: false,
                                                                                            parentid: "DEPT--${widget.departmentID}",
                                                                                            title: "Department ID:${department!.departmentCreatedby} Logo removed",
                                                                                            plainDesc: "Department Logo has been removed by Agent ID: ${widget.currentuserid}",
                                                                                            imageurl: "",
                                                                                            styledDesc: "<bold>${department!.departmentTitle} </bold>Department <bold>Logo</bold> has been removed by Agent ID: ${widget.currentuserid}",
                                                                                            onErrorFn: (e) {
                                                                                              ShowLoading().close(context: this.context, key: _keyLoader223);
                                                                                              _textEditingController.clear();
                                                                                              fetchdata();
                                                                                              widget.onrefreshPreviousPage();
                                                                                              Utils.toast("Failed to remove department logo! ERROR: $e");
                                                                                            },
                                                                                            postedbyID: widget.currentuserid,
                                                                                            onSuccessFn: () {
                                                                                              ShowLoading().close(context: this.context, key: _keyLoader223);
                                                                                              _textEditingController.clear();
                                                                                              fetchdata();
                                                                                              widget.onrefreshPreviousPage();
                                                                                            });
                                                                                      },
                                                                                      onErrorFn: (String s) {
                                                                                        ShowLoading().close(context: this.context, key: _keyLoader223);
                                                                                        setState(() {
                                                                                          isloading = false;
                                                                                        });
                                                                                        Utils.toast("Error occured!. Error log: $s");
                                                                                      });
                                                                                } else {
                                                                                  ShowLoading().close(context: this.context, key: _keyLoader223);
                                                                                  Utils.toast("Failed to delete. Please try again.");
                                                                                }
                                                                              } else {
                                                                                ShowLoading().close(context: this.context, key: _keyLoader223);
                                                                                Utils.toast(status);
                                                                              }
                                                                            });
                                                                          });
                                                      },
                                                      icon: Icon(
                                                          Icons
                                                              .delete_outline_rounded,
                                                          color: Mycolors.white,
                                                          size: 35),
                                                    ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 25,
                                      left: 18,
                                      child: Container(
                                        width: w / 1.5,
                                        child: Text(
                                          department!.departmentTitle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                ],
                              ),
                              userAppSettings!.departmentManagerCanEditAddAgentstodepartment ==
                                          false &&
                                      widget.showOnlyWhereManager == true
                                  ? SizedBox()
                                  : Container(
                                      color: Colors.white,
                                      margin: EdgeInsets.only(bottom: 8),
                                      padding: EdgeInsets.fromLTRB(
                                          10,
                                          15,
                                          15,
                                          department!.departmentIsShow ==
                                                      false &&
                                                  issecondaryloaderon == false
                                              ? 3
                                              : 18),
                                      // decoration: boxDecoration(
                                      //     bgColor: Colors.white, radius: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              MtCustomfontBoldSemi(
                                                text:
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxstatusxx'),
                                                fontsize: 16,
                                              ),
                                              Container(
                                                width:
                                                    issecondaryloaderon == true
                                                        ? 25
                                                        : 55,
                                                child: issecondaryloaderon ==
                                                        true
                                                    ? minicircularProgress()
                                                    : FlutterSwitch(
                                                        activeColor:
                                                            Mycolors.green,
                                                        inactiveColor:
                                                            Mycolors.red,
                                                        toggleSize: 17,
                                                        width: 47,
                                                        height: 20,
                                                        value: department!
                                                            .departmentIsShow,
                                                        onToggle: (cv) async {
                                                          ShowConfirmDialog()
                                                              .open(
                                                                  context: this
                                                                      .context,
                                                                  subtitle: department!
                                                                              .departmentIsShow ==
                                                                          true
                                                                      ? getTranslatedForCurrentUser(this.context, 'xxareusurehidexx').replaceAll('(####)', getTranslatedForCurrentUser(this.context, 'xxagentsxx')).replaceAll(
                                                                          '(###)',
                                                                          getTranslatedForCurrentUser(
                                                                              this
                                                                                  .context,
                                                                              'xxcustomersxx'))
                                                                      : getTranslatedForCurrentUser(this.context, 'xxareusurelivexx').replaceAll('(####)', getTranslatedForCurrentUser(this.context, 'xxagentsxx')).replaceAll(
                                                                          '(###)',
                                                                          getTranslatedForCurrentUser(
                                                                              this
                                                                                  .context,
                                                                              'xxcustomersxx')),
                                                                  title: getTranslatedForCurrentUser(
                                                                      this
                                                                          .context,
                                                                      'xxconfirmquesxx'),
                                                                  rightbtnonpress:
                                                                      observer.checkIfCurrentUserIsDemo(widget.currentuserid) ==
                                                                              true
                                                                          ? () {
                                                                              Utils.toast(getTranslatedForCurrentUser(this.context, 'xxxnotalwddemoxxaccountxx'));
                                                                            }
                                                                          : () async {
                                                                              Navigator.pop(this.context);

                                                                              if (department!.departmentIsShow == false && department!.departmentAgentsUIDList.length < 1) {
                                                                                Utils.toast(getTranslatedForCurrentUser(this.context, 'xxaddxxtoxxtobexx').replaceAll('(####)', getTranslatedForCurrentUser(this.context, 'xxagentsxx')).replaceAll('(###)', getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')).replaceAll('(##)', getTranslatedForCurrentUser(this.context, 'xxcustomersxx')));
                                                                              } else {
                                                                                setState(() {
                                                                                  issecondaryloaderon = true;
                                                                                });
                                                                                await FirebaseApi.runUPDATEmapobjectinListField(
                                                                                    compareKey: Dbkeys.departmentTitle,
                                                                                    compareVal: department!.departmentTitle,
                                                                                    docrefdata: docRef,
                                                                                    replaceableMapObjectWithOnlyFieldsRequired: {
                                                                                      Dbkeys.departmentIsShow: !department!.departmentIsShow,
                                                                                      Dbkeys.departmentLastEditedOn: DateTime.now().millisecondsSinceEpoch
                                                                                    },
                                                                                    context: this.context,
                                                                                    listkeyname: Dbkeys.departmentList,
                                                                                    onSuccessFn: () async {
                                                                                      await FirebaseApi.runTransactionRecordActivity(
                                                                                          isOnlyAlertNotSave: false,
                                                                                          parentid: "DEPT--${widget.departmentID}",
                                                                                          title: "Department  status updated",
                                                                                          plainDesc: department!.departmentIsShow == true ? "Department ${department!.departmentTitle} status has been set to HIDDEN" : "Department ${department!.departmentTitle} status has been set to LIVE",
                                                                                          styledDesc: department!.departmentIsShow == true ? "<bold>${department!.departmentTitle}</bold> Department has been set to <bold>HIDDEN</bold> by Agent ID: ${widget.currentuserid}" : "<bold>${department!.departmentTitle}</bold> Department has been set to <bold>LIVE</bold> by Agent ID: ${widget.currentuserid}",
                                                                                          onErrorFn: (e) {
                                                                                            _textEditingController.clear();
                                                                                            fetchdata();
                                                                                            widget.onrefreshPreviousPage();
                                                                                            Utils.toast("Failed to update department status! ERROR: $e");
                                                                                          },
                                                                                          postedbyID: widget.currentuserid,
                                                                                          onSuccessFn: () {
                                                                                            _textEditingController.clear();
                                                                                            fetchdata();
                                                                                            widget.onrefreshPreviousPage();
                                                                                          });
                                                                                    },
                                                                                    onErrorFn: (String s) {
                                                                                      setState(() {
                                                                                        isloading = false;
                                                                                      });
                                                                                      Utils.toast("Error occured!. Error log: $s");
                                                                                    });
                                                                              }
                                                                            });
                                                        }),
                                              )
                                            ],
                                          ),
                                          department!.departmentIsShow ==
                                                      false &&
                                                  issecondaryloaderon == false
                                              ? warningTile(
                                                  title: getTranslatedForCurrentUser(
                                                          this.context,
                                                          'xxdeptnotvisiblexx')
                                                      .replaceAll(
                                                          '(####)',
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxdepartmentxx'))
                                                      .replaceAll(
                                                          '(###)',
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxagentsxx'))
                                                      .replaceAll(
                                                          '(##)',
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxcustomersxx'))
                                                      .replaceAll(
                                                          '(#)',
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxsupporttktxx')),
                                                  warningTypeIndex:
                                                      WarningType.error.index)
                                              : SizedBox(
                                                  width: 0,
                                                ),
                                        ],
                                      ),
                                    ),
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslatedForCurrentUser(
                                              this.context, 'xxdescxx'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Mycolors.secondary,
                                              fontSize: 15),
                                        ),
                                        userAppSettings!.departmentManagerCanEditAddAgentstodepartment ==
                                                    false &&
                                                widget.showOnlyWhereManager ==
                                                    true
                                            ? SizedBox()
                                            : IconButton(
                                                onPressed: () {
                                                  editDescription(
                                                      this.context,
                                                      department!
                                                          .departmentDesc);
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  size: 21,
                                                  color: Mycolors.primary,
                                                ))
                                      ],
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    MtCustomfontRegular(
                                      text: department!.departmentDesc == ""
                                          ? getTranslatedForCurrentUser(
                                              this.context, 'xxnodescxx')
                                          : department!.departmentDesc,
                                      fontsize: 14,
                                      isitalic:
                                          department!.departmentDesc == "",
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslatedForCurrentUser(
                                              this.context, 'xxxcreatedbyxx'),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Mycolors.secondary,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    department!.departmentCreatedby == "Admin"
                                        ? Text(getTranslatedForCurrentUser(
                                            this.context, 'xxadminxx'))
                                        : department!.departmentCreatedby ==
                                                "auto"
                                            ? Text(getTranslatedForCurrentUser(
                                                this.context, 'xxsystemxx'))
                                            : ListTile(
                                                leading: avatar(
                                                    imageUrl: registry
                                                        .getUserData(
                                                            this.context,
                                                            department!
                                                                .departmentCreatedby)
                                                        .photourl),
                                                title: Text(registry
                                                    .getUserData(
                                                        this.context,
                                                        department!
                                                            .departmentCreatedby)
                                                    .fullname),
                                                subtitle: Row(
                                                  children: [
                                                    MtCustomfontRegular(
                                                      fontsize: 13,
                                                      text: "${getTranslatedForCurrentUser(this.context, 'xxidxx')} " +
                                                          registry
                                                              .getUserData(
                                                                  this.context,
                                                                  department!
                                                                      .departmentCreatedby)
                                                              .id,
                                                    ),
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          department!.departmentAgentsUIDList
                                                      .length <
                                                  1
                                              ? getTranslatedForCurrentUser(
                                                  this.context, 'xxagentsxx')
                                              : department!
                                                      .departmentAgentsUIDList
                                                      .length
                                                      .toString() +
                                                  " ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Mycolors.secondary,
                                              fontSize: 15),
                                        ),
                                        userAppSettings!.departmentManagerCanEditAddAgentstodepartment ==
                                                    false &&
                                                widget.showOnlyWhereManager ==
                                                    true
                                            ? SizedBox()
                                            : IconButton(
                                                onPressed: () {
                                                  addNewAgentsToDepartment(
                                                      this.context,
                                                      department!
                                                          .departmentAgentsUIDList,
                                                      registry);
                                                },
                                                icon: Icon(
                                                  Icons.add,
                                                  size: 25,
                                                  color: Mycolors.primary,
                                                ))
                                      ],
                                    ),
                                    Divider(),
                                    department!.departmentAgentsUIDList
                                                .length ==
                                            0
                                        ? MtCustomfontRegular(
                                            fontsize: 14,
                                            isitalic: true,
                                            text: getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxnoaggentsassignedxx')
                                                .replaceAll(
                                                    '(####)',
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxagentsxx'))
                                                .replaceAll(
                                                    '(###)',
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxdepartmentxx')))
                                        : ListView.builder(
                                            padding: EdgeInsets.all(3),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: department!
                                                .departmentAgentsUIDList.length,
                                            itemBuilder:
                                                (BuildContext context, int i) {
                                              var agentid = department!
                                                  .departmentAgentsUIDList[i];
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    leading: avatar(
                                                        imageUrl: registry
                                                            .getUserData(
                                                                this.context,
                                                                agentid)
                                                            .photourl),
                                                    title: MtCustomfontRegular(
                                                        fontsize: 16,
                                                        color: Mycolors.black,
                                                        text: registry
                                                            .getUserData(
                                                                this.context,
                                                                agentid)
                                                            .fullname),
                                                    subtitle: Row(
                                                      children: [
                                                        MtCustomfontRegular(
                                                          fontsize: 13,
                                                          text: "${getTranslatedForCurrentUser(this.context, 'xxidxx')} " +
                                                              registry
                                                                  .getUserData(
                                                                      this.context,
                                                                      agentid)
                                                                  .id,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        isready == true
                                                            ? livedata!.docmap[
                                                                        Dbkeys
                                                                            .secondadminID] ==
                                                                    agentid
                                                                ? roleBasedSticker(
                                                                    this
                                                                        .context,
                                                                    Usertype
                                                                        .secondadmin
                                                                        .index)
                                                                : SizedBox()
                                                            : SizedBox(
                                                                width: 16,
                                                              ),
                                                        agentid ==
                                                                department!
                                                                    .departmentManagerID
                                                            ? Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: roleBasedSticker(
                                                                    this
                                                                        .context,
                                                                    Usertype
                                                                        .departmentmanager
                                                                        .index),
                                                              )
                                                            : SizedBox()
                                                      ],
                                                    ),
                                                    trailing: userAppSettings!
                                                                    .departmentManagerCanEditAddAgentstodepartment ==
                                                                false &&
                                                            widget
                                                                .showOnlyWhereManager
                                                        ? SizedBox()
                                                        : department!
                                                                    .departmentAgentsUIDList
                                                                    .length <
                                                                2
                                                            ? SizedBox()
                                                            : SizedBox(
                                                                width: 30,
                                                                child: PopupMenuButton<
                                                                        String>(
                                                                    color: agentid ==
                                                                            department!
                                                                                .departmentManagerID
                                                                        ? Mycolors
                                                                            .grey
                                                                        : Mycolors
                                                                            .primary,
                                                                    itemBuilder: (BuildContext context) => agentid ==
                                                                            department!
                                                                                .departmentManagerID
                                                                        ? <PopupMenuEntry<
                                                                            String>>[
                                                                            PopupMenuItem<String>(
                                                                              value: 'removemanager',
                                                                              child: Text(
                                                                                getTranslatedForCurrentUser(this.context, 'xxremovefromxxxxx').replaceAll('(####)', getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')),
                                                                                style: TextStyle(fontSize: 13, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          ]
                                                                        : <PopupMenuEntry<
                                                                            String>>[
                                                                            PopupMenuItem<String>(
                                                                              value: 'remove',
                                                                              child: Text(
                                                                                getTranslatedForCurrentUser(this.context, 'xxremovefromxxxxx').replaceAll('(####)', getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')),
                                                                                style: TextStyle(fontSize: 13, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                            PopupMenuItem<String>(
                                                                              value: "setmanager",
                                                                              child: Text(
                                                                                getTranslatedForCurrentUser(this.context, 'xxsetasxx').replaceAll('(####)', getTranslatedForCurrentUser(this.context, 'xxdepartmentmanagerxx')),
                                                                                style: TextStyle(fontSize: 13, color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                    onSelected:
                                                                        (String
                                                                            value) async {
                                                                      if (value ==
                                                                          "removemanager") {
                                                                        Utils.toast(
                                                                            "First assign any other agent as Department Manager to Remove ${registry.getUserData(this.context, agentid).fullname} ");
                                                                      } else if (value ==
                                                                          "setmanager") {
                                                                        await setAsManager(
                                                                          this.context,
                                                                          agentid,
                                                                          registry
                                                                              .getUserData(this.context, agentid)
                                                                              .fullname,
                                                                        );
                                                                      } else if (value ==
                                                                          "remove") {
                                                                        await removeAgentFromDepartment(
                                                                            this.context,
                                                                            registry.getUserData(this.context, agentid).id,
                                                                            registry.getUserData(this.context, agentid).fullname,
                                                                            department!.departmentAgentsUIDList);
                                                                      }
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .more_vert_outlined,
                                                                      size: 20,
                                                                      color: Mycolors
                                                                          .grey,
                                                                    ))),
                                                  ),
                                                  department!.departmentAgentsUIDList
                                                              .last ==
                                                          department!
                                                              .departmentAgentsUIDList[i]
                                                      ? SizedBox()
                                                      : Divider(
                                                          height: 1,
                                                        ),
                                                ],
                                              );
                                            }),
                                    SizedBox(
                                      height: 7,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                            this.context, 'xxlasteditedbyxx'),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: department!
                                                  .departmentLastEditedby ==
                                              "Admin"
                                          ? MtCustomfontRegular(
                                              text: getTranslatedForCurrentUser(
                                                  this.context, 'xxadminxx'),
                                              fontsize: 12.8,
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                MtCustomfontRegular(
                                                  color: Mycolors.grey,
                                                  text: registry
                                                          .getUserData(
                                                              this.context,
                                                              department!
                                                                  .departmentLastEditedby)
                                                          .shortname +
                                                      " (${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${registry.getUserData(this.context, department!.departmentLastEditedby).id})",
                                                  fontsize: 12.8,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                isready == true
                                                    ? livedata!.docmap[Dbkeys
                                                                .secondadminID] ==
                                                            department!
                                                                .departmentLastEditedby
                                                        ? roleBasedSticker(
                                                            this.context,
                                                            Usertype.secondadmin
                                                                .index)
                                                        : SizedBox()
                                                    : SizedBox(),
                                              ],
                                            ),
                                    ),
                                    leading: Icon(
                                      Icons.person,
                                      color: Mycolors.secondary,
                                    ),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                            this.context, 'xxlasteditedonxx'),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontRegular(
                                        color: Mycolors.grey,
                                        text: formatTimeDateCOMLPETEString(
                                            isdateTime: true,
                                            isshowutc: false,
                                            context: this.context,
                                            datetimetargetTime: DateTime
                                                .fromMillisecondsSinceEpoch(
                                              department!
                                                  .departmentLastEditedOn,
                                            )),
                                        fontsize: 12.8,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.access_time_rounded,
                                      color: Mycolors.secondary,
                                    ),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                              SizedBox(
                                height: 18,
                              ),
                              Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                            this.context, 'xxxcreatedbyxx'),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: department!
                                                  .departmentLastEditedby ==
                                              "Admin"
                                          ? MtCustomfontRegular(
                                              text: getTranslatedForCurrentUser(
                                                  this.context, 'xxadminxx'),
                                              fontsize: 12.8,
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                MtCustomfontRegular(
                                                  color: Mycolors.grey,
                                                  text: registry
                                                          .getUserData(
                                                              this.context,
                                                              department!
                                                                  .departmentLastEditedby)
                                                          .shortname +
                                                      " (${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${registry.getUserData(this.context, department!.departmentLastEditedby).id})",
                                                  fontsize: 12.8,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                isready == true
                                                    ? livedata!.docmap[Dbkeys
                                                                .secondadminID] ==
                                                            department!
                                                                .departmentLastEditedby
                                                        ? roleBasedSticker(
                                                            this.context,
                                                            Usertype.secondadmin
                                                                .index)
                                                        : SizedBox()
                                                    : SizedBox(),
                                              ],
                                            ),
                                    ),
                                    leading: Icon(
                                      Icons.person,
                                      color: Mycolors.secondary,
                                    ),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                                this.context, 'xxcreatedonxx')
                                            .replaceAll(
                                                '(####)',
                                                getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxdepartmentxx')),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontRegular(
                                        color: Mycolors.grey,
                                        text: formatTimeDateCOMLPETEString(
                                            isdateTime: true,
                                            isshowutc: false,
                                            context: this.context,
                                            datetimetargetTime: DateTime
                                                .fromMillisecondsSinceEpoch(
                                              department!.departmentCreatedTime,
                                            )),
                                        fontsize: 12.8,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.access_time_rounded,
                                      color: Mycolors.secondary,
                                    ),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                              SizedBox(
                                height: 18,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              observer.userAppSettingsDoc!
                                          .departmentmanagerCanviewDepartmentStatistics ==
                                      false
                                  ? SizedBox()
                                  : myinkwell(
                                      onTap: () {
                                        pageNavigator(
                                            this.context,
                                            FilteredActivityHistory(
                                              subtitle:
                                                  "${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} " +
                                                      widget.departmentID,
                                              isShowDesc: true,
                                              extrafieldid: "DEPT--" +
                                                  widget.departmentID,
                                            ));
                                      },
                                      child: Chip(
                                          backgroundColor: Mycolors.cyan,
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                EvaIcons.activity,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              MtCustomfontBoldSemi(
                                                fontsize: 13,
                                                text: getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxtrackxxactivityxx')
                                                    .replaceAll(
                                                        '(####)',
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxdepartmentxx')),
                                                color: Colors.white,
                                              )
                                            ],
                                          )),
                                    ),
                              widget.showOnlyWhereManager == true
                                  ? SizedBox()
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: myinkwell(
                                          onTap: () {
                                            ShowConfirmDialog().open(
                                                context: this.context,
                                                subtitle: getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxareusuredeletexx')
                                                    .replaceAll(
                                                        '(####)',
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxdepartmentxx'))
                                                    .replaceAll(
                                                        '(###)',
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxagentsxx'))
                                                    .replaceAll(
                                                        '(##)',
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxcustomersxx'))
                                                    .replaceAll(
                                                        '(#)',
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxagentchatsxx')),
                                                title:
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxconfirmquesxx'),
                                                rightbtnonpress:
                                                    observer.checkIfCurrentUserIsDemo(
                                                                widget
                                                                    .currentuserid) ==
                                                            true
                                                        ? () {
                                                            Utils.toast(
                                                                getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxxnotalwddemoxxaccountxx'));
                                                          }
                                                        : () async {
                                                            Navigator.pop(
                                                                context);
                                                            ShowLoading().open(
                                                                context: this
                                                                    .context,
                                                                key:
                                                                    _keyLoader223);

                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectiontickets)
                                                                .where(
                                                                    Dbkeys
                                                                        .tktdepartmentNameList,
                                                                    arrayContains:
                                                                        widget
                                                                            .departmentID)
                                                                .get()
                                                                .then(
                                                                    (tickets) async {
                                                              if (tickets.docs
                                                                      .length >
                                                                  0) {
                                                                tickets.docs
                                                                    .forEach(
                                                                        (tkt) async {
                                                                  await tkt
                                                                      .reference
                                                                      .update({
                                                                    Dbkeys.tktMEMBERSactiveList:
                                                                        [],
                                                                    Dbkeys.ticketDepartmentID:
                                                                        "",
                                                                    Dbkeys.tktdepartmentNameList:
                                                                        [],
                                                                  });
                                                                });
                                                              }
                                                            });
                                                            await FirebaseApi
                                                                .runDELETEmapobjectinListField(
                                                                    context: this
                                                                        .context,
                                                                    listkeyname:
                                                                        Dbkeys
                                                                            .departmentList,
                                                                    docrefdata:
                                                                        docRef,
                                                                    compareKey:
                                                                        Dbkeys
                                                                            .departmentTitle,
                                                                    compareVal:
                                                                        department!
                                                                            .departmentTitle,
                                                                    onErrorFn:
                                                                        (e) {
                                                                      ShowLoading().close(
                                                                          context:
                                                                              this.context,
                                                                          key: _keyLoader223);
                                                                      Utils.errortoast(
                                                                          "E_5002: Failed to delete. Please try again ! . $e");
                                                                    },
                                                                    onSuccessFn:
                                                                        () async {
                                                                      await Utils.sendDirectNotification(
                                                                          title:
                                                                              "Department Deleted by Agent ${widget.currentuserid}",
                                                                          parentID:
                                                                              "DEPT--${widget.departmentID}",
                                                                          styleddesc:
                                                                              "<bold>${widget.currentuserid}</bold> has deleted the department <bold>${department!.departmentTitle}</bold> (ID: ${department!.departmentTitle})",
                                                                          plaindesc:
                                                                              "${widget.currentuserid} has deleted the department ${department!.departmentTitle} (ID: ${department!.departmentTitle})",
                                                                          docRef: FirebaseFirestore
                                                                              .instance
                                                                              .collection(DbPaths.adminapp)
                                                                              .doc(DbPaths.collectionhistory),
                                                                          postedbyID: widget.currentuserid);
                                                                      await Utils.sendDirectNotification(
                                                                          title:
                                                                              "Department Deleted by Agent ID: ${widget.currentuserid}",
                                                                          parentID:
                                                                              "DEPT--${widget.departmentID}",
                                                                          styleddesc:
                                                                              "<bold>${widget.currentuserid}</bold> has deleted the department <bold>${department!.departmentTitle}</bold> (ID: ${department!.departmentTitle})",
                                                                          plaindesc:
                                                                              "${widget.currentuserid} has deleted the department ${department!.departmentTitle} (ID: ${department!.departmentTitle})",
                                                                          docRef: FirebaseFirestore
                                                                              .instance
                                                                              .collection(DbPaths.adminapp)
                                                                              .doc(DbPaths.adminnotifications),
                                                                          postedbyID: widget.currentuserid);
                                                                      ShowLoading().close(
                                                                          context:
                                                                              this.context,
                                                                          key: _keyLoader223);
                                                                      widget
                                                                          .onrefreshPreviousPage();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    });
                                                          });
                                          },
                                          child: Chip(
                                              backgroundColor:
                                                  Mycolors.red.withOpacity(0.2),
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      size: 17,
                                                      color: Mycolors.red),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    "${getTranslatedForCurrentUser(this.context, 'xxdeletexx')} ${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}",
                                                    style: TextStyle(
                                                        color: Mycolors.red),
                                                  ),
                                                ],
                                              )),
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                height: 18,
                              ),
                              Container(
                                // height: 130,
                                width: double.infinity,
                                child: futureLoadCollections(
                                    future: FirebaseFirestore.instance
                                        .collection(DbPaths.collectiontickets)
                                        .where(Dbkeys.tktdepartmentNameList,
                                            arrayContainsAny: [
                                              department!.departmentTitle
                                            ])
                                        .orderBy(Dbkeys.ticketlatestTimestampForAgents,
                                            descending: true)
                                        .get(),
                                    placeholder: minicircularProgress(),
                                    noDataWidget: noDataWidget(
                                        context: this.context,
                                        title: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxnoxxavailabletoaddxx')
                                            .replaceAll(
                                                '(####)',
                                                getTranslatedForCurrentUser(
                                                    this.context, 'xxtktssxx')),
                                        subtitle: getTranslatedForCurrentUser(
                                                this.context, 'xxnoaggentsassignedxx')
                                            .replaceAll('(####)', getTranslatedForCurrentUser(this.context, 'xxtktsxx'))
                                            .replaceAll('(###)', "${department!.departmentTitle}" + " " + getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')),
                                        iconData: LineAwesomeIcons.alternate_ticket,
                                        iconColor: Utils.randomColorgenratorBasedOnFirstLetter(department!.departmentTitle)),
                                    onfetchdone: (ticketDocList) {
                                      return ticketDocList.length == 0
                                          ? noDataWidget(
                                              context: this.context,
                                              title: getTranslatedForCurrentUser(
                                                      this.context,
                                                      'xxnoxxavailabletoaddxx')
                                                  .replaceAll(
                                                      '(####)',
                                                      getTranslatedForCurrentUser(
                                                          this.context,
                                                          'xxtktssxx')),
                                              subtitle: getTranslatedForCurrentUser(
                                                      this.context,
                                                      'xxnoaggentsassignedxx')
                                                  .replaceAll(
                                                      '(####)',
                                                      getTranslatedForCurrentUser(
                                                          this.context,
                                                          'xxtktsxx'))
                                                  .replaceAll(
                                                      '(###)',
                                                      "${department!.departmentTitle}" +
                                                          " " +
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxdepartmentxx')),
                                              iconData: LineAwesomeIcons
                                                  .alternate_ticket,
                                              iconColor: Utils
                                                  .randomColorgenratorBasedOnFirstLetter(
                                                      department!
                                                          .departmentTitle))
                                          : Column(
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                MtCustomfontBoldSemi(
                                                  textalign: TextAlign.left,
                                                  text: ticketDocList.length
                                                          .toString() +
                                                      " ${getTranslatedForCurrentUser(this.context, 'xxtktssxx')}",
                                                  color: Mycolors.getColor(
                                                      widget.prefs,
                                                      Colortype
                                                          .secondary.index),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        ticketDocList.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int i) {
                                                      return ticketWidgetForAgents(
                                                          context: this.context,
                                                          prefs: widget.prefs,
                                                          ontap: (ticketid,
                                                              customerUID) {
                                                            pageNavigator(
                                                                this.context,
                                                                TicketChatRoom(
                                                                  agentsListinParticularDepartment: observer
                                                                              .userAppSettingsDoc!
                                                                              .departmentBasedContent ==
                                                                          true
                                                                      ? observer.userAppSettingsDoc!.departmentList!.where((element) => element[Dbkeys.departmentTitle] == ticketDocList[i][Dbkeys.ticketDepartmentID]).toList().length >
                                                                              0
                                                                          ? observer
                                                                              .userAppSettingsDoc!
                                                                              .departmentList!
                                                                              .where((element) => element[Dbkeys.departmentTitle] == ticketDocList[i][Dbkeys.ticketDepartmentID])
                                                                              .toList()[0][Dbkeys.departmentAgentsUIDList]
                                                                          : []
                                                                      : [],
                                                                  ticketTitle:
                                                                      ticketDocList[
                                                                              i]
                                                                          [
                                                                          Dbkeys
                                                                              .ticketTitle],
                                                                  cuurentUserCanSeeAgentNamePhoto: iAmSecondAdmin(
                                                                          currentuserid: widget
                                                                              .currentuserid,
                                                                          context:
                                                                              context)
                                                                      ? observer
                                                                          .userAppSettingsDoc!
                                                                          .secondadmincanseeagentnameandphoto!
                                                                      : iAmDepartmentManager(
                                                                              currentuserid: widget
                                                                                  .currentuserid,
                                                                              context:
                                                                                  context)
                                                                          ? observer
                                                                              .userAppSettingsDoc!
                                                                              .departmentmanagercanseeagentnameandphoto!
                                                                          : customerUID == widget.currentuserid
                                                                              ? observer.userAppSettingsDoc!.customercanseeagentnameandphoto!
                                                                              : observer.userAppSettingsDoc!.agentcanseeagentnameandphoto!,
                                                                  cuurentUserCanSeeCustomerNamePhoto: iAmSecondAdmin(
                                                                          currentuserid: widget
                                                                              .currentuserid,
                                                                          context:
                                                                              context)
                                                                      ? observer
                                                                          .userAppSettingsDoc!
                                                                          .secondadmincanseecustomernameandphoto!
                                                                      : iAmDepartmentManager(
                                                                              currentuserid: widget
                                                                                  .currentuserid,
                                                                              context:
                                                                                  context)
                                                                          ? observer
                                                                              .userAppSettingsDoc!
                                                                              .departmentmanagercanseecustomernameandphoto!
                                                                          : observer
                                                                              .userAppSettingsDoc!
                                                                              .agentcanseecustomernameandphoto!,
                                                                  currentuserfullname: registry
                                                                      .getUserData(
                                                                          this
                                                                              .context,
                                                                          widget
                                                                              .currentuserid)
                                                                      .fullname,
                                                                  customerUID:
                                                                      customerUID,
                                                                  currentUserID:
                                                                      widget
                                                                          .currentuserid,
                                                                  isSharingIntentForwarded:
                                                                      false,
                                                                  ticketID:
                                                                      ticketid,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  model: widget
                                                                      .cachedModel,
                                                                ));
                                                          },
                                                          ticket: TicketModel
                                                              .fromSnapshot(
                                                                  ticketDocList[
                                                                      i]),
                                                          ticketdoc:
                                                              ticketDocList[i],
                                                          currentUserID: widget
                                                              .currentuserid);
                                                    }),
                                                SizedBox(
                                                  height: 50,
                                                ),
                                              ],
                                            );
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        )));
  }

  addNewAgentsToDepartment(BuildContext context, List<dynamic> alreadyaddedlist,
      UserRegistry registry) async {
    List<UserRegistryModel> availableAgents = registry.agents;
    final observer = Provider.of<Observer>(this.context, listen: false);
    availableAgents = availableAgents
        .where((agent) => !alreadyaddedlist.contains(agent.id))
        .toList();

    await pageOpenOnTop(
        this.context,
        AddAgentsToDepartment(
          currentuserid: widget.currentuserid,
          prefs: widget.prefs,
          isdepartmentalreadycreated: true,
          agents: availableAgents,
          onselectagents: (agentids, agentmodels) {
            ShowConfirmDialog().open(
                context: this.context,
                subtitle: getTranslatedForCurrentUser(
                        this.context, 'xxaddtocdeptxx')
                    .replaceAll('(####)',
                        '${agentids.length} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                    .replaceAll(
                        '(###)',
                        getTranslatedForCurrentUser(
                            this.context, 'xxdepartmentxx'))
                    .replaceAll(
                        '(##)',
                        getTranslatedForCurrentUser(
                            this.context, 'xxagentsxx')),
                title: getTranslatedForCurrentUser(
                    this.context, 'xxconfirmquesxx'),
                rightbtnonpress: observer
                            .checkIfCurrentUserIsDemo(widget.currentuserid) ==
                        true
                    ? () {
                        Utils.toast(getTranslatedForCurrentUser(
                            this.context, 'xxxnotalwddemoxxaccountxx'));
                      }
                    : () async {
                        Navigator.pop(this.context);
                        ShowLoading()
                            .open(context: this.context, key: _keyLoader223);
                        List<dynamic> agents = alreadyaddedlist;
                        agentids.forEach((userid) {
                          agents.add(userid);
                        });
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectiontickets)
                            .where(Dbkeys.tktdepartmentNameList,
                                arrayContains: widget.departmentID)
                            .get()
                            .then((tickets) async {
                          if (tickets.docs.length > 0) {
                            tickets.docs.forEach((tkt) async {
                              await tkt.reference.update(
                                  {Dbkeys.tktMEMBERSactiveList: agents});
                            });
                          }
                        });
                        await FirebaseApi.runUPDATEmapobjectinListField(
                            docrefdata: docRef,
                            compareKey: Dbkeys.departmentTitle,
                            context: this.context,
                            isshowloader: false,
                            listkeyname: Dbkeys.departmentList,
                            keyloader: _keyLoader223,
                            compareVal: department!.departmentTitle,
                            replaceableMapObjectWithOnlyFieldsRequired: {
                              Dbkeys.departmentAgentsUIDList: agents,
                              Dbkeys.departmentLastEditedOn:
                                  DateTime.now().millisecondsSinceEpoch
                            },
                            onErrorFn: (e) {
                              ShowLoading().close(
                                  context: this.context, key: _keyLoader223);
                              Utils.toast(
                                  "Error occured while updating. Please contact developer. ERROR: " +
                                      e.toString());
                            },
                            onSuccessFn: () async {
                              await FirebaseApi.runTransactionRecordActivity(
                                  parentid: "DEPT--${widget.departmentID}",
                                  title:
                                      "${agentids.length} Agent(s) assigned to the Department",
                                  plainDesc:
                                      "Agent(s): $agentids added to the department ${department!.departmentTitle} by ${widget.currentuserid}",
                                  postedbyID: widget.currentuserid,
                                  styledDesc:
                                      "Agent(s): <bold>$agentids</bold> added to the department <bold>${department!.departmentTitle}</bold> by ${widget.currentuserid}",
                                  context: this.context,
                                  onSuccessFn: () async {
                                    agentids.forEach((id) async {
                                      await Utils.sendDirectNotification(
                                          title:
                                              "You are added to a new Department",
                                          parentID:
                                              "DEPT--${widget.departmentID}",
                                          plaindesc:
                                              "${widget.currentuserid} has added you to the Department - ${department!.departmentTitle}",
                                          styleddesc:
                                              "${widget.currentuserid} has added you to the Department - <bold>${department!.departmentTitle}</bold>",
                                          docRef: FirebaseFirestore.instance
                                              .collection(
                                                  DbPaths.collectionagents)
                                              .doc(id)
                                              .collection(
                                                  DbPaths.agentnotifications)
                                              .doc(DbPaths.agentnotifications),
                                          postedbyID: widget.currentuserid);
                                    });
                                    ShowLoading().close(
                                        context: this.context,
                                        key: _keyLoader223);
                                    await fetchdata();
                                    widget.onrefreshPreviousPage();
                                  },
                                  onErrorFn: (e) {
                                    print(e.toString());
                                    ShowLoading().close(
                                        context: this.context,
                                        key: _keyLoader223);
                                    Utils.toast(
                                        "Error occured while runTransactionRecordActivity(). Please contact developer. ERROR: " +
                                            e.toString());
                                  });
                            });
                      });
          },
        ));
  }

  removeAgentFromDepartment(
    BuildContext context,
    String agentid,
    String agentname,
    List<dynamic> alreadyaddedlist,
  ) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    ShowConfirmDialog().open(
        context: this.context,
        subtitle: getTranslatedForCurrentUser(
                this.context, 'xxareyousureremovefromdeptxx')
            .replaceAll('(####)',
                '#$agentname (${getTranslatedForCurrentUser(this.context, 'xxidxx')} $agentid)')
            .replaceAll('(###)',
                '${department!.departmentTitle} ${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}'),
        title: getTranslatedForCurrentUser(this.context, 'xxconfirmquesxx'),
        rightbtnonpress: observer
                    .checkIfCurrentUserIsDemo(widget.currentuserid) ==
                true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    this.context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                Navigator.of(this.context).pop();

                ShowLoading().open(context: this.context, key: _keyLoader223);
                List<dynamic> agents = alreadyaddedlist;
                agents.remove(agentid);
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectiontickets)
                    .where(Dbkeys.tktdepartmentNameList,
                        arrayContains: widget.departmentID)
                    .get()
                    .then((tickets) async {
                  if (tickets.docs.length > 0) {
                    tickets.docs.forEach((tkt) async {
                      await tkt.reference
                          .update({Dbkeys.tktMEMBERSactiveList: agents});
                    });
                  }
                });
                await FirebaseApi.runUPDATEmapobjectinListField(
                    docrefdata: docRef,
                    compareKey: Dbkeys.departmentTitle,
                    context: this.context,
                    isshowloader: false,
                    listkeyname: Dbkeys.departmentList,
                    keyloader: _keyLoader223,
                    compareVal: department!.departmentTitle,
                    replaceableMapObjectWithOnlyFieldsRequired:
                        agents.length < 2
                            ? {
                                Dbkeys.departmentIsShow: false,
                                Dbkeys.departmentAgentsUIDList: agents,
                                Dbkeys.departmentLastEditedOn:
                                    DateTime.now().millisecondsSinceEpoch
                              }
                            : {
                                Dbkeys.departmentAgentsUIDList: agents,
                                Dbkeys.departmentLastEditedOn:
                                    DateTime.now().millisecondsSinceEpoch
                              },
                    onErrorFn: (e) {
                      ShowLoading()
                          .close(context: this.context, key: _keyLoader223);
                      Utils.toast(
                          "Error occured while updating. Please contact developer. ERROR: " +
                              e.toString());
                    },
                    onSuccessFn: () async {
                      await FirebaseApi.runTransactionRecordActivity(
                          parentid: "DEPT--${widget.departmentID}",
                          title: "1 Agent removed from the Department",
                          plainDesc:
                              "Agent $agentname (ID: $agentid) removed from the department ${department!.departmentTitle} by ${widget.currentuserid}",
                          postedbyID: widget.currentuserid,
                          styledDesc: agents.length < 2
                              ? "Agent <bold>$agentname</bold> (ID: $agentid) removed from the department <bold>${department!.departmentTitle}</bold> by ${widget.currentuserid}. The department status has also been set to HIDDEN because of no agent assigned."
                              : "Agent <bold>$agentname</bold> (ID: $agentid) removed from the department <bold>${department!.departmentTitle}</bold> by ${widget.currentuserid}",
                          context: this.context,
                          onSuccessFn: () async {
                            await Utils.sendDirectNotification(
                                title: "You are removed from the Department",
                                parentID: "DEPT--${widget.departmentID}",
                                plaindesc:
                                    "${widget.currentuserid} has removed you from the Department - ${department!.departmentTitle}",
                                styleddesc:
                                    "${widget.currentuserid} has removed you from Department - <bold>${department!.departmentTitle}</bold>",
                                docRef: FirebaseFirestore.instance
                                    .collection(DbPaths.collectionagents)
                                    .doc(agentid)
                                    .collection(DbPaths.agentnotifications)
                                    .doc(DbPaths.agentnotifications),
                                postedbyID: widget.currentuserid);

                            ShowLoading().close(
                                context: this.context, key: _keyLoader223);
                            await fetchdata();
                            widget.onrefreshPreviousPage();
                          },
                          onErrorFn: (e) {
                            print(e.toString());
                            ShowLoading().close(
                                context: this.context, key: _keyLoader223);
                            Utils.toast(
                                "Error occured while runTransactionRecordActivity(). Please contact developer. ERROR: " +
                                    e.toString());
                          });
                    });
              });
  }

  setAsManager(
    BuildContext context,
    String agentid,
    String agentname,
  ) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    ShowConfirmDialog().open(
        context: this.context,
        subtitle: getTranslatedForCurrentUser(this.context, 'xxareusurexx')
            .replaceAll('(####)',
                "$agentname (${getTranslatedForCurrentUser(this.context, 'xxidxx')}: $agentid")
            .replaceAll('(###)',
                getTranslatedForCurrentUser(this.context, 'xxmanagerxx'))
            .replaceAll(
                '(##)',
                "${department!.departmentTitle} " +
                    getTranslatedForCurrentUser(
                        this.context, 'xxdepartmentxx')),
        title: getTranslatedForCurrentUser(this.context, 'xxconfirmquesxx'),
        rightbtnonpress:
            observer.checkIfCurrentUserIsDemo(widget.currentuserid) == true
                ? () {
                    Utils.toast(getTranslatedForCurrentUser(
                        this.context, 'xxxnotalwddemoxxaccountxx'));
                  }
                : () async {
                    Navigator.of(this.context).pop();

                    ShowLoading()
                        .open(context: this.context, key: _keyLoader223);

                    await FirebaseApi.runUPDATEmapobjectinListField(
                        docrefdata: docRef,
                        compareKey: Dbkeys.departmentTitle,
                        context: this.context,
                        isshowloader: false,
                        listkeyname: Dbkeys.departmentList,
                        keyloader: _keyLoader223,
                        compareVal: department!.departmentTitle,
                        replaceableMapObjectWithOnlyFieldsRequired: {
                          Dbkeys.departmentManagerID: agentid,
                          Dbkeys.departmentLastEditedOn:
                              DateTime.now().millisecondsSinceEpoch
                        },
                        onErrorFn: (e) {
                          ShowLoading()
                              .close(context: this.context, key: _keyLoader223);
                          Utils.toast(
                              "Error occured while changing manager. Please contact developer. ERROR: " +
                                  e.toString());
                        },
                        onSuccessFn: () async {
                          await FirebaseApi.runTransactionRecordActivity(
                              parentid: "DEPT--${widget.departmentID}",
                              title: "Manager Changed",
                              plainDesc:
                                  "Agent $agentname (ID: $agentid) is assigned as the new Manager of ${department!.departmentTitle} department by ${widget.currentuserid}. Old manager was agent ID : ${department!.departmentManagerID}",
                              postedbyID: widget.currentuserid,
                              styledDesc:
                                  "Agent <bold>$agentname</bold> (ID: $agentid) is assigned as the new <bold>Manager</bold> of <bold>${department!.departmentTitle}</bold> department by ${widget.currentuserid}.  Old manager was agent ID : ${department!.departmentManagerID}",
                              context: this.context,
                              onSuccessFn: () async {
                                await Utils.sendDirectNotification(
                                    title: "You are assigned as a Manager",
                                    parentID: "DEPT--${widget.departmentID}",
                                    plaindesc:
                                        "${widget.currentuserid} has assigned you as the Manager for the Department - ${department!.departmentTitle}",
                                    styleddesc:
                                        "${widget.currentuserid} has assigned you as the <bold>Manager</bold> for the Department - <bold>${department!.departmentTitle}</bold>",
                                    docRef: FirebaseFirestore.instance
                                        .collection(DbPaths.collectionagents)
                                        .doc(agentid)
                                        .collection(DbPaths.agentnotifications)
                                        .doc(DbPaths.agentnotifications),
                                    postedbyID: widget.currentuserid);
                                await Utils.sendDirectNotification(
                                    title: "You are removed as a Manager",
                                    parentID: "DEPT--${widget.departmentID}",
                                    plaindesc:
                                        "${widget.currentuserid} has removed you as the Manager for the Department - ${department!.departmentTitle}",
                                    styleddesc:
                                        "${widget.currentuserid} has removed you as the <bold>Manager</bold> for the Department - <bold>${department!.departmentTitle}</bold>",
                                    docRef: FirebaseFirestore.instance
                                        .collection(DbPaths.collectionagents)
                                        .doc(department!.departmentManagerID)
                                        .collection(DbPaths.agentnotifications)
                                        .doc(DbPaths.agentnotifications),
                                    postedbyID: widget.currentuserid);

                                ShowLoading().close(
                                    context: this.context, key: _keyLoader223);
                                await fetchdata();
                                widget.onrefreshPreviousPage();
                              },
                              onErrorFn: (e) {
                                print(e.toString());
                                ShowLoading().close(
                                    context: this.context, key: _keyLoader223);
                                Utils.toast(
                                    "Error occured while runTransactionRecordActivity(). Please contact developer. ERROR: " +
                                        e.toString());
                              });
                        });
                  });
  }

  editDescription(BuildContext context, String existingdesc) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    _textEditingController.text = existingdesc;
    showModalBottomSheet(
        isScrollControlled: true,
        context: this.context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          var w = MediaQuery.of(this.context).size.width;
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(this.context).viewInsets.bottom),
            child: Container(
                padding: EdgeInsets.all(16),
                height: MediaQuery.of(this.context).size.height / 2,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        height: 219,
                        width: w / 1.24,
                        child: InpuTextBox(
                          controller: _textEditingController,
                          leftrightmargin: 0,
                          minLines: 8,
                          maxLines: 10,
                          showIconboundary: false,
                          maxcharacters: Numberlimits.maxdepartmentdescchar,
                          boxcornerradius: 5.5,
                          hinttext:
                              "${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')} ${getTranslatedForCurrentUser(this.context, 'xxdescxx')}",
                        ),
                      ),
                      SizedBox(height: 20),
                      MySimpleButton(
                        buttontext: getTranslatedForCurrentUser(
                            this.context, 'xxupdatexx'),
                        onpressed: observer.checkIfCurrentUserIsDemo(
                                    widget.currentuserid) ==
                                true
                            ? () {
                                Utils.toast(getTranslatedForCurrentUser(
                                    this.context, 'xxxnotalwddemoxxaccountxx'));
                              }
                            : () async {
                                if (_textEditingController.text.trim().length >
                                    Numberlimits.maxdepartmentdescchar) {
                                  Utils.toast(getTranslatedForCurrentUser(
                                          this.context, 'xxmaxxxcharxx')
                                      .replaceAll(
                                          '(####)',
                                          Numberlimits.maxdepartmentdescchar
                                              .toString()));
                                } else {
                                  Navigator.of(this.context).pop();
                                  ShowLoading().open(
                                      context: this.context,
                                      key: _keyLoader223);

                                  await FirebaseApi.runUPDATEmapobjectinListField(
                                      docrefdata: docRef,
                                      compareKey: Dbkeys.departmentTitle,
                                      context: this.context,
                                      isshowloader: false,
                                      listkeyname: Dbkeys.departmentList,
                                      keyloader: _keyLoader223,
                                      compareVal: department!.departmentTitle,
                                      replaceableMapObjectWithOnlyFieldsRequired: {
                                        Dbkeys.departmentDesc:
                                            _textEditingController.text.trim(),
                                        Dbkeys.departmentLastEditedOn:
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                      },
                                      onErrorFn: (e) {
                                        ShowLoading().close(
                                            context: this.context,
                                            key: _keyLoader223);
                                        Utils.toast(
                                            "Error occured while updating description. Please contact developer. ERROR: " +
                                                e.toString());
                                      },
                                      onSuccessFn: () async {
                                        await FirebaseApi
                                            .runTransactionRecordActivity(
                                                parentid:
                                                    "DEPT--${widget.departmentID}",
                                                title: _textEditingController
                                                            .text
                                                            .trim()
                                                            .length <
                                                        1
                                                    ? "Department Description Removed"
                                                    : "Department Description Updated",
                                                plainDesc: _textEditingController
                                                        .text.isEmpty
                                                    ? "Department Description Removed"
                                                    : "Department ${department!.departmentTitle} description updated by ${widget.currentuserid}",
                                                postedbyID:
                                                    widget.currentuserid,
                                                styledDesc: _textEditingController
                                                        .text.isEmpty
                                                    ? "Department <bold>${department!.departmentTitle}</bold> Description Removed by ${widget.currentuserid}"
                                                    : "Department <bold>${department!.departmentTitle}</bold> description updated by ${widget.currentuserid}",
                                                context: this.context,
                                                onSuccessFn: () async {
                                                  ShowLoading().close(
                                                      context: this.context,
                                                      key: _keyLoader223);
                                                  await fetchdata();
                                                  widget
                                                      .onrefreshPreviousPage();
                                                },
                                                onErrorFn: (e) {
                                                  print(e.toString());
                                                  ShowLoading().close(
                                                      context: this.context,
                                                      key: _keyLoader223);
                                                  Utils.errortoast(
                                                      "E_5001: Error occured while runTransactionRecordActivity(). Please contact developer. ERROR: " +
                                                          e.toString());
                                                });
                                      });
                                }
                              },
                      ),
                    ])),
          );
        });
  }
}

formatDate(DateTime timeToFormat) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final String formatted = formatter.format(timeToFormat);
  return formatted;
}
