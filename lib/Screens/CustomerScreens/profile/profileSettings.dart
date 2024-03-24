//*************   © Copyrighted by aagama_it.

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Configs/number_limits.dart';
//import 'package:aagama_it/Services/Admob/admob.dart';
import 'package:aagama_it/Services/FirebaseServices/firebase_api.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/main.dart';
import 'package:aagama_it/widgets/ImagePicker/image_picker.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:aagama_it/widgets/WarningWidgets/warning_tile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/optional_constants.dart';

class CustomerProfileSetting extends StatefulWidget {
  final bool? biometricEnabled;
  final AuthenticationType? type;
  final SharedPreferences prefs;
  final String currentUserID;
  CustomerProfileSetting(
      {this.biometricEnabled,
      this.type,
      required this.prefs,
      required this.currentUserID});
  @override
  State createState() => new CustomerProfileSettingState();
}

class CustomerProfileSettingState extends State<CustomerProfileSetting> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;
  TextEditingController? controllerMobilenumber;
  TextEditingController? controlleremail;

  String phone = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  String email = '';

  bool isLoading = false;
  File? avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();
  AuthenticationType? _type;
  // final BannerAd myBanner = BannerAd(
  //   adUnitId: getBannerAdUnitId()!,
  //   size: AdSize.mediumRectangle,
  //   request: AdRequest(),
  //   listener: BannerAdListener(),
  // );
  //AdWidget? adWidget;
  var adWidget = null;
  String? uid;
  @override
  void initState() {
    super.initState();
    Utils.internetLookUp();
    readLocal();
    _type = widget.type;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        // myBanner.load();
        // adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  String savedname = "";
  String savedphoturl = "";
  String accountStatus = "";
  void readLocal() async {
    uid = widget.prefs.getString(Dbkeys.id);
    phone = widget.prefs.getString(Dbkeys.phone) ?? '';
    email = widget.prefs.getString(Dbkeys.email) ?? '';
    nickname = widget.prefs.getString(Dbkeys.nickname) ?? '';
    photoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';
    aboutMe = widget.prefs.getString(Dbkeys.aboutMe) ?? '';
    uid = widget.prefs.getString(Dbkeys.id);

    savedname = nickname;
    savedphoturl = photoUrl;
    controllerNickname = new TextEditingController(text: nickname);
    controllerAboutMe = new TextEditingController(text: aboutMe);
    controllerMobilenumber = new TextEditingController(text: phone);
    controlleremail = new TextEditingController(text: email);
    // Force refresh input
    setState(() {});
    FirebaseFirestore.instance
        .collection(DbPaths.collectioncustomers)
        .doc(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        widget.prefs.setString(Dbkeys.phone, doc[Dbkeys.phone]);
        widget.prefs.setString(Dbkeys.email, doc[Dbkeys.email]);
        phone = doc[Dbkeys.phone] ?? '';
        email = doc[Dbkeys.email] ?? '';
        widget.prefs.setString(Dbkeys.nickname, doc[Dbkeys.nickname]);
        nickname = doc[Dbkeys.nickname] ?? '';
        accountStatus = doc[Dbkeys.accountstatus];
        widget.prefs.setString(Dbkeys.photoUrl, doc[Dbkeys.photoUrl]);
        photoUrl = doc[Dbkeys.photoUrl] ?? '';

        widget.prefs.setString(Dbkeys.aboutMe, doc[Dbkeys.aboutMe]);
        aboutMe = doc[Dbkeys.aboutMe] ?? '';

        savedname = nickname;
        savedphoturl = photoUrl;
        controllerNickname = new TextEditingController(text: nickname);
        controllerAboutMe = new TextEditingController(text: aboutMe);
        controllerMobilenumber = new TextEditingController(text: phone);
        controlleremail = new TextEditingController(text: email);
        // Force refresh input
        setState(() {});
      }
    });
  }

  Future getImage(File image) async {
    setState(() {
      avatarImageFile = image;
    });

    return uploadFile();
  }

  Future uploadFile() async {
    String fileName = uid!;
    Reference reference = FirebaseStorage.instance
        .ref(widget.prefs.getInt(Dbkeys.userLoginType) ==
                    Usertype.customer.index ||
                widget.prefs.getInt(Dbkeys.userLoginType) == null
            ? 'CustomerProfilePics/'
            : 'AgentProfilePics/')
        .child(fileName);
    TaskSnapshot uploading = await reference.putFile(avatarImageFile!);

    return uploading.ref.getDownloadURL();
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();
    final observer = Provider.of<Observer>(this.context, listen: false);
    setState(() {
      isLoading = true;
    });
    nickname =
        controllerNickname!.text.isEmpty ? nickname : controllerNickname!.text;
    aboutMe =
        controllerAboutMe!.text.isEmpty ? aboutMe : controllerAboutMe!.text;

    if (observer.userAppSettingsDoc!.customerUnderReviewAfterEditProfile ==
            true &&
        accountStatus == Dbkeys.sTATUSallowed &&
        savedname != nickname) {
      accountStatus = Dbkeys.sTATUSpending;
      FirebaseFirestore.instance
          .collection(DbPaths.collectioncustomers)
          .doc(uid)
          .update({
        Dbkeys.accountstatus: Dbkeys.sTATUSpending,
        Dbkeys.actionmessage:
            getTranslatedForCurrentUser(this.context, 'xxaccountundereviewxx'),
        Dbkeys.nickname: nickname,
        Dbkeys.aboutMe: aboutMe,
        Dbkeys.authenticationType: _type!.index,
        Dbkeys.searchKey: nickname.trim().substring(0, 1).toUpperCase(),
      }).then((data) {
        FirebaseApi().runUPDATEincrementDecrementFieldInFirestoreDoc(
            docrefdata: FirebaseFirestore.instance
                .collection(DbPaths.userapp)
                .doc(DbPaths.docusercount),
            onErrorFn: (err) {
              setState(() {
                isLoading = false;
              });

              Utils.toast(err.toString());
            },
            onSuccessFn: () {
              widget.prefs.setString(Dbkeys.nickname, nickname);
              widget.prefs.setString(Dbkeys.aboutMe, aboutMe);

              FirebaseApi.runTransactionSendNotification(
                  plainDesc:
                      'Please check the latest profile of ${widget.prefs.getInt(Dbkeys.userLoginType) == Usertype.customer.index ? getTranslatedForCurrentUser(this.context, 'xxcustomerxx') : getTranslatedForCurrentUser(this.context, 'xxagentxx')} $nickname (ID:$uid) details like- Name, Photo of ${widget.prefs.getInt(Dbkeys.userLoginType) == Usertype.customer.index ? getTranslatedForCurrentUser(this.context, 'xxcustomerxx') : getTranslatedForCurrentUser(this.context, 'xxagentxx')} to verify & further APPROVE THE ACCOUNT. ${widget.prefs.getInt(Dbkeys.userLoginType) == Usertype.customer.index ? getTranslatedForCurrentUser(this.context, 'xxcustomerxx') : getTranslatedForCurrentUser(this.context, 'xxagentxx')} is waiting for your approval',
                  docRef: FirebaseFirestore.instance
                      .collection(DbPaths.adminapp)
                      .doc(DbPaths.adminnotifications),
                  title: widget.prefs.getInt(Dbkeys.userLoginType) ==
                          Usertype.customer.index
                      ? 'Customer Profile updated'
                      : 'Agent Profile updated',
                  postedbyID: uid!,
                  parentid: "PROFILE_VERIFY_CUSTOMER--$uid",
                  onErrorFn: (e) {},
                  onSuccessFn: () {});
              FirebaseApi.runTransactionSendNotification(
                  parentid: "PROFILE_VERIFY_AGENT--$uid",
                  plainDesc: getTranslatedForCurrentUser(
                      this.context, 'xxaccountundereviewxx'),
                  docRef: FirebaseFirestore.instance
                      .collection(DbPaths.collectioncustomers)
                      .doc(uid)
                      .collection(DbPaths.customernotifications)
                      .doc(DbPaths.customernotifications),
                  title: getTranslatedForCurrentUser(
                      this.context, 'xxprofileunderreviewxx'),
                  postedbyID: uid!,
                  onErrorFn: (e) {},
                  onSuccessFn: () {});

              Utils.toast(
                  getTranslatedForCurrentUser(this.context, 'xxsavedxx'));
              setState(() {
                isLoading = false;
              });
              Navigator.of(this.context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) => AppWrapper(
                    loadAttempt: 0,
                  ),
                ),
                (Route route) => false,
              );
            },
            incrementKey: Dbkeys.totalpendingcustomers,
            decrementkey: Dbkeys.totalapprovedcustomers,
            secondfn: () async {
              int tapproved = 0;
              int tblocked = 0;
              int tpending = 0;
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectioncustomers)
                  .get()
                  .then((value) {
                tapproved = value.docs
                    .where((element) =>
                        element[Dbkeys.accountstatus] == Dbkeys.sTATUSallowed)
                    .length;
                tblocked = value.docs
                    .where((element) =>
                        element[Dbkeys.accountstatus] == Dbkeys.sTATUSblocked)
                    .length;
                tpending = value.docs
                    .where((element) =>
                        element[Dbkeys.accountstatus] == Dbkeys.sTATUSpending)
                    .length;
              }).then((value) async {
                FirebaseFirestore.instance
                    .collection(DbPaths.userapp)
                    .doc(DbPaths.docusercount)
                    .update({
                  Dbkeys.totalapprovedcustomers: tapproved,
                  Dbkeys.totalblockedcustomers: tblocked,
                  Dbkeys.totalpendingcustomers: tpending,
                });
              });
            });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });

        Utils.toast(err.toString());
      });
    } else {
      String myname = nickname;
      var names = myname.trim().split(' ');

      String firstName = myname.trim();
      String lastName = "";
      if (names.length > 1) {
        firstName = names[0];
        lastName = names[1];
        if (firstName.length < 3) {
          firstName = lastName;
          if (lastName.length < 3) {
            firstName = myname;
          }
        }
      }

      FirebaseApi.runUPDATEmapobjectinListField(
          docrefdata: FirebaseFirestore.instance
              .collection(DbPaths.userapp)
              .doc(DbPaths.registry),
          compareKey: Dbkeys.rgstUSERID,
          compareVal: uid!,
          onErrorFn: (err) {
            setState(() {
              isLoading = false;
            });

            Utils.toast(err.toString());
          },
          replaceableMapObjectWithOnlyFieldsRequired: {
            Dbkeys.rgstUSERID: uid,
            Dbkeys.rgstFULLNAME: nickname,
            Dbkeys.rgstPHOTOURL: photoUrl,
            Dbkeys.rgstSHORTNAME: firstName,
          },
          onSuccessFn: () {
            FirebaseFirestore.instance
                .collection(DbPaths.collectioncustomers)
                .doc(uid)
                .update({
              Dbkeys.nickname: nickname,
              Dbkeys.aboutMe: aboutMe,
              Dbkeys.authenticationType: _type!.index,
              Dbkeys.searchKey: nickname.trim().substring(0, 1).toUpperCase(),
            }).then((data) {
              widget.prefs.setString(Dbkeys.nickname, nickname);
              widget.prefs.setString(Dbkeys.aboutMe, aboutMe);

              Utils.toast(
                  getTranslatedForCurrentUser(this.context, 'xxsavedxx'));
              setState(() {
                isLoading = false;
              });
              Navigator.of(this.context).pop();
            }).catchError((err) {
              setState(() {
                isLoading = false;
              });

              Utils.toast(err.toString());
            });
          });
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      //myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: true);
    return PickupLayout(
        curentUserID: widget.currentUserID,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(Scaffold(
            backgroundColor: Colors.white,
            appBar: new AppBar(
              elevation: 0.4,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(this.context).pop();
                },
                icon: Icon(
                  LineAwesomeIcons.arrow_left,
                  size: 24,
                  color:
                      Mycolors.getColor(widget.prefs, Colortype.primary.index),
                ),
              ),
              titleSpacing: 0,
              backgroundColor: Colors.white,
              title: new Text(
                getTranslatedForCurrentUser(this.context, 'xxeditprofilexx'),
                style: TextStyle(
                  fontSize: 17.0,
                  color: Mycolors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      observer.checkIfCurrentUserIsDemo(widget.currentUserID) ==
                              true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  this.context, 'xxxnotalwddemoxxaccountxx'));
                            }
                          : handleUpdateData,
                  child: Text(
                    getTranslatedForCurrentUser(this.context, 'xxsavexx'),
                    style: TextStyle(
                        fontSize: 16,
                        color: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // Avatar
                      observer.userAppSettingsDoc!
                                  .customerUnderReviewAfterEditProfile ==
                              true
                          ? warningTile(
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxeditprofilewarningxx'),
                              warningTypeIndex: WarningType.alert.index)
                          : SizedBox(
                              height: 0,
                            ),
                      Container(
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (photoUrl != ''
                                      ? Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                                    child: Padding(
                                                        padding: EdgeInsets.all(
                                                            50.0),
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Mycolors
                                                                      .secondary),
                                                        )),
                                                    width: 150.0,
                                                    height: 150.0),
                                            imageUrl: photoUrl,
                                            width: 150.0,
                                            height: 150.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(75.0)),
                                          clipBehavior: Clip.hardEdge,
                                        )
                                      : Icon(
                                          Icons.account_circle,
                                          size: 150.0,
                                          color: Mycolors.greylight,
                                        ))
                                  : Material(
                                      child: Image.file(
                                        avatarImageFile!,
                                        width: 150.0,
                                        height: 150.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(75.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: FloatingActionButton(
                                      backgroundColor: Mycolors.secondary,
                                      child: Icon(Icons.camera_alt,
                                          color: Colors.white),
                                      onPressed: observer
                                                  .checkIfCurrentUserIsDemo(
                                                      widget.currentUserID) ==
                                              true
                                          ? () {
                                              Utils.toast(
                                                  getTranslatedForCurrentUser(
                                                      this.context,
                                                      'xxxnotalwddemoxxaccountxx'));
                                            }
                                          : () {
                                              Navigator.push(
                                                  this.context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SingleImagePicker(
                                                              title: getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'xxpickimagexx'),
                                                              callback:
                                                                  getImage,
                                                              profile:
                                                                  true))).then(
                                                  (url) {
                                                if (url != null) {
                                                  photoUrl = url.toString();

                                                  if (observer.userAppSettingsDoc!
                                                              .customerUnderReviewAfterEditProfile ==
                                                          true &&
                                                      accountStatus ==
                                                          Dbkeys
                                                              .sTATUSallowed) {
                                                    accountStatus =
                                                        Dbkeys.sTATUSpending;
                                                    FirebaseFirestore.instance
                                                        .collection(DbPaths
                                                            .collectioncustomers)
                                                        .doc(uid)
                                                        .update({
                                                      Dbkeys.photoUrl: photoUrl,
                                                      Dbkeys.accountstatus:
                                                          Dbkeys.sTATUSpending,
                                                      Dbkeys.actionmessage:
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxaccountundereviewxx')
                                                    }).then((data) {
                                                      FirebaseApi()
                                                          .runUPDATEincrementDecrementFieldInFirestoreDoc(
                                                              docrefdata: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .userapp)
                                                                  .doc(DbPaths
                                                                      .docusercount),
                                                              onErrorFn: (err) {
                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                });

                                                                Utils.toast(err
                                                                    .toString());
                                                              },
                                                              onSuccessFn:
                                                                  () async {
                                                                await widget
                                                                    .prefs
                                                                    .setString(
                                                                        Dbkeys
                                                                            .photoUrl,
                                                                        photoUrl);

                                                                Utils.toast(getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxsavedxx'));
                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pushAndRemoveUntil(
                                                                  MaterialPageRoute(
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        AppWrapper(
                                                                      loadAttempt:
                                                                          0,
                                                                    ),
                                                                  ),
                                                                  (Route route) =>
                                                                      false,
                                                                );
                                                              },
                                                              incrementKey: Dbkeys
                                                                  .totalpendingcustomers,
                                                              decrementkey: Dbkeys
                                                                  .totalapprovedcustomers,
                                                              secondfn:
                                                                  () async {
                                                                FirebaseApi.runTransactionSendNotification(
                                                                    plainDesc:
                                                                        'Please check the profile of user to verify.',
                                                                    docRef: FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            DbPaths
                                                                                .adminapp)
                                                                        .doc(DbPaths
                                                                            .adminnotifications),
                                                                    title: widget.prefs.getInt(Dbkeys.userLoginType) ==
                                                                            Usertype
                                                                                .customer.index
                                                                        ? 'Customer Profile updated'
                                                                        : 'Agent Profile updated',
                                                                    postedbyID:
                                                                        uid!,
                                                                    parentid:
                                                                        "PROFILE_VERIFY_CUSTOMER--$uid",
                                                                    onErrorFn:
                                                                        (e) {},
                                                                    onSuccessFn:
                                                                        () {});
                                                              });
                                                    }).catchError((err) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });

                                                      Utils.toast(
                                                          err.toString());
                                                    });
                                                  } else {
                                                    FirebaseApi
                                                        .runUPDATEmapobjectinListField(
                                                            docrefdata:
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        DbPaths
                                                                            .userapp)
                                                                    .doc(DbPaths
                                                                        .registry),
                                                            compareKey: Dbkeys
                                                                .rgstUSERID,
                                                            compareVal: uid!,
                                                            onErrorFn: (err) {
                                                              setState(() {
                                                                isLoading =
                                                                    false;
                                                              });

                                                              Utils.toast(err
                                                                  .toString());
                                                            },
                                                            replaceableMapObjectWithOnlyFieldsRequired: {
                                                              Dbkeys.rgstUSERID:
                                                                  uid,
                                                              Dbkeys.rgstPHOTOURL:
                                                                  photoUrl,
                                                            },
                                                            onSuccessFn: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectioncustomers)
                                                                  .doc(uid)
                                                                  .update({
                                                                Dbkeys.photoUrl:
                                                                    photoUrl,
                                                              }).then(
                                                                      (data) async {
                                                                await widget
                                                                    .prefs
                                                                    .setString(
                                                                        Dbkeys
                                                                            .photoUrl,
                                                                        photoUrl);
                                                                Utils.toast(getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxsavedxx'));
                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }).catchError(
                                                                      (err) {
                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                });

                                                                Utils.toast(err
                                                                    .toString());
                                                              });
                                                            });
                                                  }
                                                }
                                              });
                                            })),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        margin: EdgeInsets.all(20.0),
                      ),
                      InpuTextBox(
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxfullnamexx'),
                        textCapitalization: TextCapitalization.sentences,
                        controller: controllerNickname,
                        focuscolor: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        maxcharacters: Numberlimits.userfullname,
                        validator: (v) {
                          return v!.isEmpty
                              ? getTranslatedForCurrentUser(
                                  this.context, 'xxvaliddetailsxx')
                              : null;
                        },
                      ),

                      SizedBox(
                        height: 4,
                      ),
                      InpuTextBox(
                        isboldinput: true,
                        title: email != ""
                            ? getTranslatedForCurrentUser(
                                this.context, 'xxemailxx')
                            : getTranslatedForCurrentUser(
                                this.context, 'xxenter_mobilenumberxx'),
                        controller: email != ""
                            ? controlleremail
                            : controllerMobilenumber,
                        disabled: true,
                        focuscolor: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      IsBannerAdShow == true &&
                              observer.isadmobshow == true &&
                              adWidget != null
                          ? Container(
                              height:
                                  MediaQuery.of(this.context).size.width - 20,
                              width: MediaQuery.of(this.context).size.width,
                              margin: EdgeInsets.only(
                                bottom: 5.0,
                                top: 2,
                              ),
                              child: adWidget!)
                          : SizedBox(
                              height: 0,
                            ),
                    ],
                  ),
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                ),
                // Loading
                Positioned(
                  child: isLoading
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Mycolors.secondary)),
                          ),
                          color: Colors.white.withOpacity(0.8))
                      : Container(),
                ),
              ],
            ))));
  }
}
