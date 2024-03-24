//*************   © Copyrighted by aagama_it. 

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/callhistory.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:aagama_it/Screens/initialization/initialization_constant.dart';
import 'package:aagama_it/Screens/notifications/user_notifications.dart';
import 'package:aagama_it/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:aagama_it/Services/FirebaseServices/firebase_api.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Services/Providers/liveListener.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Utils/custom_url_launcher.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_tiles.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/userrole_based_sticker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentProfile extends StatefulWidget {
  final bool biometricEnabled;
  final AuthenticationType type;
  final String currentUserID;
  final Function onTapEditProfile;
  final Function onTapLogout;
  final SharedPreferences prefs;
  const AgentProfile(
      {Key? key,
      required this.biometricEnabled,
      required this.prefs,
      required this.currentUserID,
      required this.onTapEditProfile,
      required this.onTapLogout,
      required this.type})
      : super(key: key);

  @override
  _AgentProfileState createState() => _AgentProfileState();
}

class _AgentProfileState extends State<AgentProfile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    final observer = Provider.of<Observer>(this.context, listen: false);
    // var currentUser =
    //     Provider.of<FirestoreDataProviderAGENT>(this.context, listen: true);
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: true);
    bool isready = livedata == null
        ? false
        : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
                livedata.docmap[Dbkeys.secondadminID] == '' ||
                livedata.docmap[Dbkeys.secondadminID] == null
            ? false
            : true;

    bool ismanager = isready == true
        ? livedata!.docmap[Dbkeys.secondadminID] ==
                widget.prefs.getString(Dbkeys.id)
            ? true
            : false
        : false;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.backgroundcolor, //or set color with: Color(0xFF0000FF)
    ));

    return PickupLayout(
        curentUserID: widget.currentUserID,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(Scaffold(
          appBar: AppBar(
            actions: [],
            centerTitle: true,
            title: MtCustomfontBold(
              text: getTranslatedForCurrentUser(this.context, 'xxmyacccountxx'),
              fontsize: 18,
              color: Mycolors.blackDynamic,
            ),
            backgroundColor: Mycolors.backgroundcolor,
            elevation: 0,
          ),
          backgroundColor: Mycolors.backgroundcolor,
          body: ListView(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            children: [
              Container(
                decoration:
                    boxDecoration(showShadow: false, bgColor: Colors.white),
                padding: EdgeInsets.fromLTRB(7, 9, 7, 9),
                child: Container(
                  width: w,
                  child: ListTile(
                    trailing:
                        Icon(EvaIcons.edit, size: 20, color: Mycolors.grey),
                    tileColor: Colors.red,
                    contentPadding: EdgeInsets.fromLTRB(7, 3, 20, 3),
                    onTap: () {
                      widget.onTapEditProfile();
                    },
                    leading: customCircleAvatar(
                      radius: 30,
                      url: widget.prefs.getString(Dbkeys.photoUrl) ?? '',
                    ),
                    title: MtCustomfontBold(
                      text: widget.prefs.getString(Dbkeys.nickname) ??
                          'name not found',
                      fontsize: 18.6,
                      lineheight: 1.4,
                      color: Mycolors.blackDynamic,
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MtCustomfontBoldSemi(
                          text: widget.prefs.getString(Dbkeys.phone) ?? '',
                          lineheight: 1.4,
                          fontsize: 14.6,
                          color: Mycolors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        roleBasedSticker(
                            this.context,
                            ismanager == true
                                ? Usertype.secondadmin.index
                                : Usertype.agent.index)
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: MtCustomfontBoldSemi(
                    text:
                        "${getTranslatedForCurrentUser(this.context, 'xxaccountidxx')}  ${widget.currentUserID}",
                    color: Mycolors.grey.withOpacity(0.7),
                    fontsize: 12,
                  ),
                ),
              ),
              observer.checkIfCurrentUserIsDemo(widget.currentUserID) == true
                  ? Chip(
                      label: Text(
                        getTranslatedForCurrentUser(
                            this.context, 'xxxdemoxxaccountxx'),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Mycolors.orange,
                    )
                  : SizedBox(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                child: Column(
                  children: [
                    profileTile(
                      title: getTranslatedForCurrentUser(
                          this.context, 'xxeditprofilexx'),
                      subtitle: getTranslatedForCurrentUser(
                          this.context, 'xxchangednpxx'),
                      ontap: () {
                        widget.onTapEditProfile();
                      },
                      iconsize: 23,
                      leadingicondata: EvaIcons.personOutline,
                      margin: 0,
                    ),
                    profileTile(
                      title:
                          getTranslatedForCurrentUser(this.context, 'xxtncxx'),
                      subtitle: getTranslatedForCurrentUser(
                          this.context, 'xxabiderulesxx'),
                      ontap: () {
                        final observer =
                            Provider.of<Observer>(this.context, listen: false);
                        if (observer.basicSettingDoc!.tncTYPE == 'url') {
                          if (observer.basicSettingDoc!.tnc == null) {
                            Utils.toast("TNC URL is not valid");
                          } else {
                            custom_url_launcher(observer.basicSettingDoc!.tnc!);
                          }
                        } else if (observer.basicSettingDoc!.tncTYPE ==
                            'file') {
                          Navigator.push(
                            this.context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                currentUserID: widget.currentUserID,
                                prefs: widget.prefs,
                                title: getTranslatedForCurrentUser(
                                    this.context, 'xxtncxx'),
                                url: observer.basicSettingDoc!.tnc,
                                isregistered: true,
                              ),
                            ),
                          );
                        }
                      },
                      iconsize: 23,
                      leadingicondata: EvaIcons.bookOutline,
                      margin: 0,
                    ),
                    profileTile(
                      title:
                          getTranslatedForCurrentUser(this.context, 'xxppxx'),
                      subtitle: getTranslatedForCurrentUser(
                          this.context, 'xxprocessdataxx'),
                      ontap: () {
                        final observer =
                            Provider.of<Observer>(this.context, listen: false);

                        if (observer.basicSettingDoc!.privacypolicyTYPE ==
                            'url') {
                          if (observer.basicSettingDoc!.privacypolicy == null) {
                            Utils.toast("Privacy policy URL is not valid");
                          } else {
                            custom_url_launcher(
                                observer.basicSettingDoc!.privacypolicy!);
                          }
                        } else if (observer
                                .basicSettingDoc!.privacypolicyTYPE ==
                            'file') {
                          Navigator.push(
                            this.context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                currentUserID: widget.currentUserID,
                                prefs: widget.prefs,
                                title: getTranslatedForCurrentUser(
                                    this.context, 'xxppxx'),
                                url: observer.basicSettingDoc!.privacypolicy,
                                isregistered: true,
                              ),
                            ),
                          );
                        }
                      },
                      iconsize: 23,
                      leadingicondata: EvaIcons.lockOutline,
                      margin: 0,
                    ),
                    profileTile(
                      title: getTranslatedForCurrentUser(
                          this.context, 'xxallnotificationsxx'),
                      subtitle: getTranslatedForCurrentUser(
                          this.context, 'xxpmteventsxx'),
                      ontap: () {
                        pageNavigator(
                            this.context,
                            UsersNotifiaction(
                                docRef1: FirebaseFirestore.instance
                                    .collection(DbPaths.collectionagents)
                                    .doc(widget.currentUserID)
                                    .collection(DbPaths.agentnotifications)
                                    .doc(DbPaths.agentnotifications),
                                docRef2: FirebaseFirestore.instance
                                    .collection(DbPaths.userapp)
                                    .doc(DbPaths.agentnotifications),
                                isbackbuttonhide: false));
                      },
                      iconsize: 23,
                      leadingicondata: EvaIcons.bellOutline,
                      margin: 0,
                    ),
                    profileTile(
                      title: getTranslatedForCurrentUser(
                          this.context, 'xxfeedbackxx'),
                      subtitle: getTranslatedForCurrentUser(
                          this.context, 'xxgivesuggestionsxx'),
                      ontap: () async {
                        if (observer.userAppSettingsDoc!.feedbackEmail!
                            .contains('@')) {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: observer.userAppSettingsDoc!.feedbackEmail,
                          );

                          await launchUrl(emailLaunchUri,
                              mode: LaunchMode.platformDefault);
                        } else {
                          custom_url_launcher(
                              observer.userAppSettingsDoc!.feedbackEmail!);
                        }
                      },
                      iconsize: 23,
                      leadingicondata: EvaIcons.messageSquareOutline,
                      margin: 0,
                    ),
                    profileTile(
                      title: getTranslatedForCurrentUser(
                          this.context, 'xxdeleteaccountxx'),
                      subtitle: getTranslatedForCurrentUser(
                          this.context, 'xxraiserequestxx'),
                      ontap: observer.checkIfCurrentUserIsDemo(
                                  widget.currentUserID) ==
                              true
                          ? () {}
                          : () async {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25.0)),
                                  ),
                                  builder: (BuildContext context) {
                                    // return your layout
                                    var w = MediaQuery.of(context).size.width;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      child: Container(
                                          padding: EdgeInsets.all(16),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.6,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Icon(
                                                  Icons.delete_outline_outlined,
                                                  size: 30,
                                                  color: Mycolors.red,
                                                ),
                                                SizedBox(
                                                  height: 7,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 12, right: 12),
                                                  child: Text(
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxraiserequestdescxx'),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16.5),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  height: w / 10,
                                                ),
                                                myElevatedButton(
                                                    color: Mycolors.secondary,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 15, 10, 15),
                                                      child: Text(
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxraiserequestxx'),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();

                                                      await FirebaseApi
                                                          .runTransactionRecordActivity(
                                                              isOnlyAlertNotSave:
                                                                  false,
                                                              parentid:
                                                                  "AGENT--${widget.currentUserID}",
                                                              title:
                                                                  'Account Deletion Request by Agent',
                                                              plainDesc:
                                                                  'Agent ID: ${widget.currentUserID} has requested to Delete account. Delete it from Agent Profile page. User Chats, Profile Details will be deleted.',
                                                              onErrorFn: (e) {
                                                                showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    context: this
                                                                        .context,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.vertical(
                                                                              top: Radius.circular(25.0)),
                                                                    ),
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return Container(
                                                                        height:
                                                                            220,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(28.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                              SizedBox(
                                                                                height: 30,
                                                                              ),
                                                                              Text(
                                                                                getTranslatedForCurrentUser(this.context, 'xxrequestsubmittedxx'),
                                                                                textAlign: TextAlign.center,
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                              },
                                                              postedbyID: widget
                                                                  .currentUserID,
                                                              onSuccessFn: () {
                                                                showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    context: this
                                                                        .context,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.vertical(
                                                                              top: Radius.circular(25.0)),
                                                                    ),
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return Container(
                                                                        height:
                                                                            220,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(28.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                              SizedBox(
                                                                                height: 30,
                                                                              ),
                                                                              Text(
                                                                                getTranslatedForCurrentUser(this.context, 'xxrequestsubmittedxx'),
                                                                                textAlign: TextAlign.center,
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                              });
                                                    }),
                                              ])),
                                    );
                                  });
                            },
                      iconsize: 23,
                      leadingicondata: Icons.delete_outline_outlined,
                      margin: 0,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MySimpleButtonWithIcon(
                  iconData: EvaIcons.powerOutline,
                  buttontext:
                      getTranslatedForCurrentUser(this.context, 'xxlogoutxx'),
                  onpressed: () {
                    widget.onTapLogout();
                  },
                  buttoncolor: Mycolors.red,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25),
                child: MtCustomfontBoldSemi(
                    color: Mycolors.grey.withOpacity(0.7),
                    textalign: TextAlign.center,
                    fontsize: 13.7,
                    text:
                        '${getTranslatedForCurrentUser(this.context, 'xxappversionxx')} ' +
                            (widget.prefs.getString('app_version') ?? "") +
                            '  |  Build v${InitializationConstant.k4}'),
              ),
            ],
          ),
        )));
  }

  onTapRateApp() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    showDialog(
        context: this.context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              ListTile(
                  contentPadding: EdgeInsets.only(top: 20),
                  subtitle: Padding(padding: EdgeInsets.only(top: 10.0)),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                      ]),
                  onTap: () {
                    Navigator.of(this.context).pop();
                    Platform.isAndroid
                        ? custom_url_launcher(
                            observer.basicSettingDoc!.newapplinkandroid!)
                        : custom_url_launcher(
                            observer.basicSettingDoc!.newapplinkios!);
                  }),
              Divider(),
              Padding(
                  child: Text(
                    getTranslatedForCurrentUser(this.context, 'xxlovedxx'),
                    style: TextStyle(fontSize: 14, color: Mycolors.black),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              Center(
                  child: myElevatedButton(
                      color: Mycolors.primary,
                      child: Text(
                        getTranslatedForCurrentUser(this.context, 'xxratexx'),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(this.context).pop();
                        Platform.isAndroid
                            ? custom_url_launcher(
                                observer.basicSettingDoc!.newapplinkandroid!)
                            : custom_url_launcher(
                                observer.basicSettingDoc!.newapplinkios!);
                      }))
            ],
          );
        });
  }
}
