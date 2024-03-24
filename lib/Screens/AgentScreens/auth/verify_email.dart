import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/app_constants.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Configs/number_limits.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/agent_model.dart';
import 'package:aagama_it/Models/basic_settings_model_userapp.dart';
import 'package:aagama_it/Models/batch_write_component.dart';
import 'package:aagama_it/Models/department_model.dart';
import 'package:aagama_it/Models/user_registry_model.dart';
import 'package:aagama_it/Services/FirebaseServices/firebase_api.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Utils/backupUserTable.dart';
import 'package:aagama_it/Utils/batch_write.dart';
import 'package:aagama_it/Utils/error_codes.dart';
import 'package:aagama_it/Utils/unawaited.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/main.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';

class VerifyEmailForAgents extends StatefulWidget {
  final SharedPreferences prefs;
  final BasicSettingModelUserApp basicSettings;
  final String email;
  final String password;
  final Function(String title, String desc, String error) onError;
  const VerifyEmailForAgents(
      {Key? key,
      required this.prefs,
      required this.email,
      required this.basicSettings,
      required this.onError,
      required this.password})
      : super(key: key);

  @override
  State<VerifyEmailForAgents> createState() => _VerifyEmailForAgentsState();
}

class _VerifyEmailForAgentsState extends State<VerifyEmailForAgents> {
  bool isloading = true;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceid = "";
  var mapDeviceInfo = {};
  @override
  void initState() {
    super.initState();
    _email.text = widget.email;
    _password.text = widget.password;
    checkUser();
    setdeviceinfo();
  }

  setdeviceinfo() async {
    if (Platform.isAndroid == true) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setStateIfMounted(() {
        deviceid = androidInfo.id + androidInfo.androidId;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: androidInfo.model,
          Dbkeys.deviceInfoOS: 'android',
          Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: androidInfo.id,
          Dbkeys.deviceInfoOSID: androidInfo.androidId,
          Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
          Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
          Dbkeys.deviceInfoLOGINTIMESTAMP:
              DateTime.now().millisecondsSinceEpoch,
        };
      });
    } else if (Platform.isIOS == true) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setStateIfMounted(() {
        deviceid = iosInfo.systemName + iosInfo.model + iosInfo.systemVersion;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: iosInfo.model,
          Dbkeys.deviceInfoOS: 'ios',
          Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
          Dbkeys.deviceInfoOSID: iosInfo.name,
          Dbkeys.deviceInfoOSVERSION: iosInfo.name,
          Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
          Dbkeys.deviceInfoLOGINTIMESTAMP:
              DateTime.now().millisecondsSinceEpoch,
        };
      });
    }
  }

  createNewUser() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email, password: widget.password)
          .then((user) async {
        await checkUser();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.of(this.context).pop();
        showERRORSheet(this.context, "EM_114",
            message:
                "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n. ${getTranslatedForCurrentUser(this.context, 'xxpwdweakxx')}");
      } else if (e.code == 'email-already-in-use') {
        Navigator.of(this.context).pop();
        showERRORSheet(this.context, "EM_113",
            message:
                "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n. ${getTranslatedForCurrentUser(this.context, 'xxacalreadyexistsxx')}");
      }
    } catch (e) {
      Navigator.of(this.context).pop();
      showERRORSheet(this.context, "EM_102",
          message:
              "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n. Error: $e");
    }
  }

  checkUser({UserCredential? registereduserCredential}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: widget.email, password: widget.password);
      if (userCredential.user != null) {
        final observer = Provider.of<Observer>(this.context, listen: false);
        observer.fetchUserAppSettingsFromFirestore();
        await loginChecks(registereduserCredential: registereduserCredential);
      } else {
        Navigator.of(this.context).pop();
        Utils.toast("not found");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        Navigator.of(this.context).pop();
        showERRORSheet(this.context, "EM_115",
            message:
                getTranslatedForCurrentUser(this.context, 'xxinvalidemailxx'));
      } else if (e.code == 'user-disabled') {
        Navigator.of(this.context).pop();
        showERRORSheet(this.context, "EM_116",
            message:
                getTranslatedForCurrentUser(this.context, 'xxemaildisabledxx'));
      } else if (e.code == 'user-not-found') {
        if (widget.basicSettings.agentRegistartionEnabled == true) {
          await createNewUser();
        } else {
          Navigator.of(this.context).pop();
          showERRORSheet(
            this.context,
            "124",
            message: getTranslatedForCurrentUser(
                    this.context, 'xxemailnotfoundlxx')
                .replaceAll('(####)',
                    '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
          );
        }
      } else if (e.code == 'wrong-password') {
        Navigator.of(this.context).pop();
        showERRORSheet(this.context, "EM_112",
            message:
                "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} \n\n ${getTranslatedForCurrentUser(this.context, 'xxincorrectpwdxx')}");
      }
    } catch (e) {
      if (e.toString().contains("no user") ||
          e.toString().contains("user record") ||
          e.toString().contains("not-found")) {
        //---create a user if Allowed

        if (widget.basicSettings.agentRegistartionEnabled == true) {
          await createNewUser();
        } else {
          Navigator.of(this.context).pop();
          showERRORSheet(
            this.context,
            "EM_101",
            message: getTranslatedForCurrentUser(
                    this.context, 'xxemailnotfoundlxx')
                .replaceAll('(####)',
                    '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
          );
        }
      } else if (e.toString().contains("does not have a password") ||
          e.toString().contains("password is invalid") ||
          e.toString().contains("wrong-password")) {
        //---create a user if Allowed
        if (e.toString().contains("does not have a password")) {
          Navigator.of(this.context).pop();
          showERRORSheet(this.context, "EM_111",
              message:
                  "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} \n\n. ${getTranslatedForCurrentUser(this.context, 'xxcannotuseemailxx')}");
        } else if (e.toString().contains("password is invalid") ||
            e.toString().contains("wrong-password")) {
          Navigator.of(this.context).pop();
          showERRORSheet(this.context, "EM_120",
              message:
                  "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} \n\n ${getTranslatedForCurrentUser(this.context, 'xxincorrectpwdxx')}");
        } else {
          if (widget.basicSettings.agentRegistartionEnabled == true) {
            await createNewUser();
          } else {
            Navigator.of(this.context).pop();
            showERRORSheet(
              this.context,
              "EM_123",
              message: getTranslatedForCurrentUser(
                      this.context, 'xxemailnotfoundlxx')
                  .replaceAll('(####)',
                      '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
            );
          }
        }
      } else {
        Navigator.of(this.context).pop();
        showERRORSheet(this.context, "EM_100",
            message:
                "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n. Error: $e");
      }
    }
  }

  loginChecks({UserCredential? registereduserCredential}) async {
    //check user account after he has has verified email and password & is signed currently
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .where(Dbkeys.email, isEqualTo: widget.email)
        .get()
        .then((agents) async {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectioncustomers)
          .where(Dbkeys.email, isEqualTo: widget.email)
          .get()
          .then((customers) async {
        if (customers.docs.length > 0) {
          firebaseAuth.signOut();
          Navigator.of(this.context).pop();
          showERRORSheet(this.context, "EM_105",
              message:
                  "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n ${getTranslatedForCurrentUser(this.context, 'xxalreadyregistereddescemailxx').replaceAll('(###)', getTranslatedForCurrentUser(this.context, 'xxcustomerxx')).replaceAll('(##)', getTranslatedForCurrentUser(this.context, 'xxagentxx'))}");
        } else {
          if (agents.docs.length == 0) {
            if (widget.basicSettings.agentRegistartionEnabled == true) {
              String finalID1 = randomNumeric(Numberlimits.agentIDlength);
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionagents)
                  .doc(finalID1)
                  .get()
                  .then((value1) async {
                if (value1.exists) {
                  String finalID2 = randomNumeric(Numberlimits.agentIDlength);
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionagents)
                      .doc(finalID2)
                      .get()
                      .then((value2) async {
                    if (value2.exists) {
                      String finalID3 =
                          randomNumeric(Numberlimits.agentIDlength);
                      await FirebaseFirestore.instance
                          .collection(DbPaths.collectionagents)
                          .doc(finalID3)
                          .get()
                          .then((value3) async {
                        if (value3.exists) {
                          String finalID4 =
                              randomNumeric(Numberlimits.agentIDlength);
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionagents)
                              .doc(finalID4)
                              .get()
                              .then((value4) async {
                            if (value4.exists) {
                              Utils.toast(getTranslatedForCurrentUser(
                                      this.context, 'xxerroroccuredxx') +
                                  "ERR_54");
                            } else {
                              await createFreshNewAccountInFirebase(finalID4, 0,
                                  registereduserCredential:
                                      registereduserCredential);
                            }
                          });
                        } else {
                          await createFreshNewAccountInFirebase(finalID3, 0,
                              registereduserCredential:
                                  registereduserCredential);
                        }
                      });
                    } else {
                      await createFreshNewAccountInFirebase(finalID2, 0,
                          registereduserCredential: registereduserCredential);
                    }
                  });
                } else {
                  await createFreshNewAccountInFirebase(finalID1, 0,
                      registereduserCredential: registereduserCredential);
                }
              });
            } else {
              Navigator.of(this.context).pop();
              showERRORSheet(this.context, "EM_108",
                  message:
                      "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n  ${getTranslatedForCurrentUser(this.context, 'xxregistrationdisabledxx')}");
            }
          } else if (agents.docs.length == 1) {
            await updateExistingUser(agents.docs[0], 0,
                registereduserCredential: registereduserCredential);
          } else {
            firebaseAuth.signOut();
            Navigator.of(this.context).pop();
            showERRORSheet(this.context, "EM_104",
                message:
                    "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n${getTranslatedForCurrentUser(this.context, 'xxmultipleacxx')}");
          }
        }
      });
    }).catchError((err) {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      firebaseAuth.signOut();
      Navigator.of(this.context).pop();
      showERRORSheet(this.context, "EM_103",
          message:
              "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}\n\n. Error: $err");
    });
    // } else {
    //   //existing registered in firebase

    // }
  }

  subscribeToNotification(String currentUserID, bool isFreshNewAccount) async {
    await FirebaseMessaging.instance
        .subscribeToTopic('$currentUserID')
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Dbkeys.topicAGENTS)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentGroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserID)
          .get()
          .then((query) async {
        if (query.docs.length > 0) {
          query.docs.forEach((doc) async {
            await FirebaseMessaging.instance
                .subscribeToTopic(
                    "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                .catchError((err) {
              print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
            });
          });
        }
      });
    }
  }

  bool isAskName = false;
  String storedFinalID = "";
  UserCredential? storedregistereduserCredential;
  createFreshNewAccountInFirebase(String finalID, int tries,
      {UserCredential? registereduserCredential, String? name}) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (observer.userAppSettingsDoc == null) {
      if (tries > 5) {
        Navigator.of(this.context).pop();
        showERRORSheet(this.context, "EM_121",
            message:
                "Login failed !\n\n.Error occured while registering for new account. Please try again . Unable to fetch settings");
      } else {
        observer.fetchUserAppSettingsFromFirestore();
        await createFreshNewAccountInFirebase(finalID, tries + 1,
            registereduserCredential: registereduserCredential, name: name);
      }
    } else {
      if (name == null) {
        setStateIfMounted(() {
          isAskName = true;
          storedFinalID = finalID;
          storedregistereduserCredential = registereduserCredential;
        });
      } else {
        setStateIfMounted(() {
          isAskName = false;
        });
        final observer = Provider.of<Observer>(this.context, listen: false);
        // int id = DateTime.now().millisecondsSinceEpoch;

        String myname = name;
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          if (tries > 5) {
            Navigator.of(this.context).pop();
            showERRORSheet(this.context, "EM_109",
                message:
                    "Login failed !\n\n.Error occured while registering for Notification. Please try again  .Failed to get fCMtoken");
          } else {
            await createFreshNewAccountInFirebase(finalID, tries,
                name: name, registereduserCredential: registereduserCredential);
          }
        } else {
          var names = myname.trim().split(' ');

          String shortname = myname.trim();
          String lastName = "";
          if (names.length > 1) {
            shortname = names[0];
            lastName = names[1];
            if (shortname.length < 3) {
              shortname = lastName;
              if (lastName.length < 3) {
                shortname = myname;
              }
            }
          }

          //Add user to default ticket category for future new tickets

          DepartmentModel cat = DepartmentModel.fromJson(
              observer.userAppSettingsDoc!.departmentList![0]);

          List<dynamic> l = observer.userAppSettingsDoc!.departmentList![0]
              [Dbkeys.departmentAgentsUIDList];
          l.add((finalID));

          var modified = cat.copyWith(departmentAgentsUIDList: l);

          List<dynamic> list = observer.userAppSettingsDoc!.departmentList!;

          list[0] = modified.toMap();
          setStateIfMounted(() {});

          await batchwriteFirestoreData([
            BatchWriteComponent(
                    ref: FirebaseFirestore.instance
                        .collection(DbPaths.collectionagents)
                        .doc(finalID),
                    map: AgentModel(
                      rolesassigned: [],
                      platform: Platform.isAndroid
                          ? "android"
                          : Platform.isIOS
                              ? "ios"
                              : "",
                      id: finalID,
                      userLoginType: LoginType.email.index,
                      email: widget.email,
                      password: '',
                      firebaseuid: registereduserCredential == null
                          ? ""
                          : registereduserCredential.user == null
                              ? ""
                              : registereduserCredential.user!.uid,
                      nickname: name.trim(),
                      searchKey: name.trim().substring(0, 1).toUpperCase(),
                      phone: "",
                      phoneRaw: "",
                      countryCode: "",
                      photoUrl: registereduserCredential == null
                          ? ""
                          : registereduserCredential.user == null
                              ? ""
                              : registereduserCredential.user!.photoURL ?? "",
                      aboutMe: '',
                      actionmessage:
                          widget.basicSettings.accountapprovalmessage ?? '',
                      currentDeviceID: deviceid,
                      privateKey: "",
                      publicKey: "",
                      accountstatus:
                          widget.basicSettings.agentVerificationNeeded == true
                              ? Dbkeys.sTATUSpending
                              : Dbkeys.sTATUSallowed,
                      audioCallMade: 0,
                      videoCallMade: 0,
                      audioCallRecieved: 0,
                      videoCallRecieved: 0,
                      groupsCreated: 0,
                      authenticationType: 0,
                      passcode: '',
                      totalvisitsANDROID: 0,
                      totalvisitsIOS: 0,
                      lastLogin: DateTime.now().millisecondsSinceEpoch,
                      joinedOn: DateTime.now().millisecondsSinceEpoch,
                      lastOnline: DateTime.now().millisecondsSinceEpoch,
                      lastSeen: DateTime.now().millisecondsSinceEpoch,
                      lastNotificationSeen:
                          DateTime.now().millisecondsSinceEpoch,
                      isNotificationStringsMulitilanguageEnabled: false,
                      notificationStringsMap: {},
                      kycMap: {},
                      geoMap: {},
                      phonenumbervariants: [],
                      hidden: [],
                      locked: [],
                      notificationTokens: [fcmToken],
                      deviceDetails: mapDeviceInfo,
                      quickReplies: [],
                      lastVerified: 0,
                      ratings: [],
                      totalRepliesInTickets: 0,
                      twoFactorVerification: {},
                      userTypeIndex: Usertype.agent.index,
                    ).toMap())
                .toMap(),
            BatchWriteComponent(
                ref: FirebaseFirestore.instance
                    .collection(DbPaths.collectionagents)
                    .doc(finalID)
                    .collection(DbPaths.agentnotifications)
                    .doc(DbPaths.agentnotifications),
                map: {
                  Dbkeys.nOTIFICATIONisunseen: true,
                  Dbkeys.nOTIFICATIONxxtitle: '',
                  Dbkeys.nOTIFICATIONxxdesc: '',
                  Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionNOPUSH,
                  Dbkeys.nOTIFICATIONxximageurl: '',

                  Dbkeys.nOTIFICATIONxxlastupdateepoch:
                      DateTime.now().millisecondsSinceEpoch,
                  Dbkeys.nOTIFICATIONxxpagecomparekey: Dbkeys.docid,
                  Dbkeys.nOTIFICATIONxxpagecompareval: '',
                  Dbkeys.nOTIFICATIONxxparentid: '',
                  Dbkeys.nOTIFICATIONxxextrafield: '',
                  Dbkeys.nOTIFICATIONxxpagetype:
                      Dbkeys.nOTIFICATIONpagetypeSingleLISTinDOCSNAP,
                  Dbkeys.nOTIFICATIONxxpageID: DbPaths.agentnotifications,
                  //-----
                  Dbkeys.nOTIFICATIONpagecollection1: DbPaths.collectionagents,
                  Dbkeys.nOTIFICATIONpagedoc1: finalID,
                  Dbkeys.nOTIFICATIONpagecollection2:
                      DbPaths.agentnotifications,
                  Dbkeys.nOTIFICATIONpagedoc2: DbPaths.agentnotifications,
                  Dbkeys.nOTIFICATIONtopic: Dbkeys.topicAGENTS,
                  Dbkeys.list: [],
                }).toMap(),
            BatchWriteComponent(
              ref: FirebaseFirestore.instance
                  .collection(DbPaths.userapp)
                  .doc(DbPaths.docusercount),
              map: widget.basicSettings.agentVerificationNeeded == false
                  ? {
                      Dbkeys.totalapprovedagents: FieldValue.increment(1),
                    }
                  : {
                      Dbkeys.totalpendingagents: FieldValue.increment(1),
                    },
            ).toMap(),
            // BatchWriteComponent(
            //   ref: FirebaseFirestore.instance
            //       .collection(DbPaths.collectioncountrywiseAgentData)
            //       .doc(widget.onlyCode),
            //   map: {
            //     Dbkeys.totalusers: FieldValue.increment(1),
            //   },
            // ).toMap(),
            BatchWriteComponent(
                    ref: FirebaseFirestore.instance
                        .collection(DbPaths.collectionagents)
                        .doc(finalID)
                        .collection("backupTable")
                        .doc("backupTable"),
                    map: userbackuptable)
                .toMap(),
            BatchWriteComponent(
              ref: FirebaseFirestore.instance
                  .collection(DbPaths.userapp)
                  .doc(DbPaths.registry),
              map: {
                Dbkeys.lastupdatedepoch: DateTime.now().millisecondsSinceEpoch,
                Dbkeys.list: FieldValue.arrayUnion([
                  UserRegistryModel(
                      shortname: shortname,
                      fullname: name.trim(),
                      id: finalID,
                      phone: "",
                      photourl: registereduserCredential == null
                          ? ""
                          : registereduserCredential.user == null
                              ? ""
                              : registereduserCredential.user!.photoURL ?? "",
                      usertype: Usertype.agent.index,
                      email: widget.email,
                      extra1: "",
                      extra2: "",
                      us1: finalID,
                      extraMap: {}).toMap()
                ])
              },
            ).toMap(),
            // BatchWriteComponent(
            //   ref: FirebaseFirestore.instance
            //       .collection(DbPaths.adminapp)
            //       .doc(DbPaths.adminnotifications),
            //   map: {
            //     Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionPUSH,
            //     Dbkeys.nOTIFICATIONxxdesc: observer
            //                 .userAppSettingsDoc!.isaccountapprovalbyadminneeded ==
            //             true
            //         ? '${name.trim()} has Joined $Appname. APPROVE the agent account (ID:$finalID). You can view the agent profile from All Agents page.'
            //         : '${name.trim()} has Joined $Appname. You can view the agent profile from All Agents page.',
            //     Dbkeys.nOTIFICATIONxxtitle: 'New Agent Joined',
            //     Dbkeys.nOTIFICATIONxximageurl: registereduserCredential == null
            //         ? ""
            //         : registereduserCredential.user == null
            //             ? ""
            //             : registereduserCredential.user!.photoURL ?? "",
            //     Dbkeys.nOTIFICATIONxxlastupdateepoch:
            //         DateTime.now().millisecondsSinceEpoch,
            //   },
            // ).toMap(),
            // BatchWriteComponent(
            //   ref: FirebaseFirestore.instance
            //       .collection(DbPaths.collectionagents)
            //       .doc(finalID),
            //   map: {
            //     Dbkeys.notificationTokens: [fcmToken]
            //   },
            // ).toMap()
          ]).then((value) async {
            if (value == false) {
              //faild to write
              if (registereduserCredential != null) {
                final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                await firebaseAuth.signOut();
              }

              Navigator.of(this.context).pop();
              showERRORSheet(this.context, "EM_100",
                  message:
                      "Login failed !\n\n. Error occured while authentication. Please try again,  Failed to batch Write for Agent Doc");
            } else {
              if (observer.userAppSettingsDoc!.autoJoinNewAgentsToDefaultList ==
                  true) {
                FirebaseFirestore.instance
                    .collection(DbPaths.userapp)
                    .doc(DbPaths.appsettings)
                    .set(
                        {Dbkeys.departmentList: list}, SetOptions(merge: true));
              }
              // Write data to local
              await widget.prefs.setString(
                Dbkeys.firebaseuid,
                registereduserCredential == null
                    ? ""
                    : registereduserCredential.user == null
                        ? ""
                        : registereduserCredential.user!.uid,
              );
              await widget.prefs.setString(Dbkeys.id, finalID);
              await widget.prefs.setString(Dbkeys.id, finalID);
              await widget.prefs.setString(Dbkeys.nickname, name.trim());
              await widget.prefs.setString(
                Dbkeys.photoUrl,
                registereduserCredential == null
                    ? ""
                    : registereduserCredential.user == null
                        ? ""
                        : registereduserCredential.user!.photoURL ?? "",
              );
              await widget.prefs.setString(Dbkeys.phone, "");
              await widget.prefs.setString(Dbkeys.countryCode, "");
              await widget.prefs
                  .setInt(Dbkeys.userLoginType, Usertype.agent.index);

              unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
              await FirebaseApi.runTransactionRecordActivity(
                parentid: "AGENT_REGISTRATION--$finalID",
                title: "New Agent Joined",
                postedbyID: "sys",
                onErrorFn: (e) {},
                onSuccessFn: () {},
                styledDesc: widget.basicSettings.agentVerificationNeeded == true
                    ? '<bold>${name.trim()}</bold> has Joined $Appname. APPROVE the agent account <bold>(ID:$finalID)</bold>. You can view the agent profile from All Agents page.'
                    : '<bold>${name.trim()}</bold> has Joined $Appname. You can view the agent account <bold>(ID:$finalID)</bold> from <bold>All Agents</bold> page.',
                plainDesc: widget.basicSettings.agentVerificationNeeded == true
                    ? '${name.trim()} has Joined $Appname. APPROVE the agent account (ID:$finalID). You can view the agent profile from All Agents page.'
                    : '${name.trim()} has Joined $Appname. You can view the agent profile from All Agents page.',
              );
              // unawaited(Navigator.pushReplacement(
              //     this.context,
              //     MaterialPageRoute(
              //         builder: (newContext) => AgentHome(
              //               basicsettings: widget.basicsettings,
              //               currentUserID: finalID,
              //               prefs: widget.prefs,
              //             ))));

              // await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
              await subscribeToNotification(finalID, true);
              Navigator.pushAndRemoveUntil<dynamic>(
                this.context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => AppWrapper(
                          loadAttempt: 0,
                        )),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            }
          });
        }
      }
    }
  }

  updateExistingUser(DocumentSnapshot doc, int tries,
      {UserCredential? registereduserCredential}) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    if (registereduserCredential != null) {
      if (widget.basicSettings.agentLoginEnabled == false) {
        await firebaseAuth.signOut();

        Navigator.of(this.context).pop();
        widget.onError(
          getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
          getTranslatedForCurrentUser(this.context, 'xxxlogintempdisbaledxxx'),
          '',
        );
      } else {
        // freshly registered in firebase - need to update firebase UID & notifcation token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          if (tries > 5) {
            firebaseAuth.signOut();
            Navigator.of(this.context).pop();
            showERRORSheet(this.context, "EM_106",
                message:
                    "Login failed !\n\n. Error: After Multiple tries to fetch fcmTokens, failed to get token.");
          } else {
            await updateExistingUser(doc, tries + 1,
                registereduserCredential: registereduserCredential);
          }
        } else {
          if (registereduserCredential.user == null) {
            firebaseAuth.signOut();
            Navigator.of(this.context).pop();
            showERRORSheet(this.context, "EM_107",
                message: "Login failed !\n\n. Error: Unexpected error occured");
          } else {
            await doc.reference.update({
              Dbkeys.userLoginType: LoginType.email.index,
              Dbkeys.email: widget.email,
              Dbkeys.firebaseuid: registereduserCredential.user!.uid,
              Dbkeys.notificationTokens: [fcmToken],
              Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
              Dbkeys.currentDeviceID: deviceid,
              Dbkeys.deviceDetails: mapDeviceInfo
            });
            await widget.prefs.setString(
              Dbkeys.firebaseuid,
              registereduserCredential.user!.uid,
            );
            await widget.prefs.setString(Dbkeys.id, doc[Dbkeys.id]);
            await widget.prefs.setString(Dbkeys.nickname, doc[Dbkeys.nickname]);
            await widget.prefs
                .setString(Dbkeys.photoUrl, doc[Dbkeys.photoUrl] ?? '');
            await widget.prefs
                .setString(Dbkeys.aboutMe, doc[Dbkeys.aboutMe] ?? '');
            await widget.prefs.setString(Dbkeys.phone, doc[Dbkeys.phone] ?? '');
            await widget.prefs
                .setInt(Dbkeys.userLoginType, Usertype.agent.index);
            await subscribeToNotification(doc[Dbkeys.id], false);
            Utils.toast(
                getTranslatedForCurrentUser(this.context, 'xxwelcomebackxx'));
            Navigator.pushAndRemoveUntil<dynamic>(
              this.context,
              MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => AppWrapper(
                        loadAttempt: 0,
                      )),
              (route) =>
                  false, //if you want to disable back feature set to false
            );
          }
        }
      }
    } else {
      if (widget.basicSettings.agentLoginEnabled == false) {
        await firebaseAuth.signOut();

        Navigator.of(this.context).pop();
        widget.onError(
          getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
          getTranslatedForCurrentUser(this.context, 'xxxlogintempdisbaledxxx'),
          '',
        );
      } else {
        //only update notifcation token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          if (tries > 5) {
            firebaseAuth.signOut();
            Navigator.of(this.context).pop();
            showERRORSheet(this.context, "EM_106",
                message:
                    "Login failed !\n\n. Error: After Multiple tries to fetch fcmTokens, failed to get token.");
          } else {
            await updateExistingUser(doc, tries + 1,
                registereduserCredential: registereduserCredential);
          }
        } else {
          await doc.reference.update({
            Dbkeys.userLoginType: LoginType.email.index,
            Dbkeys.email: widget.email,
            Dbkeys.notificationTokens: [fcmToken],
            Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
            Dbkeys.currentDeviceID: deviceid,
            Dbkeys.deviceDetails: mapDeviceInfo
          });
          await widget.prefs.setString(
            Dbkeys.firebaseuid,
            doc[Dbkeys.firebaseuid],
          );
          var userData = doc.data();
          await widget.prefs.setString(Dbkeys.id, doc[Dbkeys.id]);
          await widget.prefs.setString(Dbkeys.nickname, doc[Dbkeys.nickname]);
          await widget.prefs.setString(
              Dbkeys.accountcreatedby, doc[Dbkeys.accountcreatedby]!);
          await widget.prefs
              .setString(Dbkeys.photoUrl, doc[Dbkeys.photoUrl] ?? '');
          await widget.prefs
              .setString(Dbkeys.aboutMe, doc[Dbkeys.aboutMe] ?? '');
          await widget.prefs.setString(Dbkeys.phone, doc[Dbkeys.phone] ?? '');
          await widget.prefs.setInt(Dbkeys.userLoginType, Usertype.agent.index);
          await subscribeToNotification(doc[Dbkeys.id], false);
          Utils.toast(
              getTranslatedForCurrentUser(this.context, 'xxwelcomebackxx'));
          Navigator.pushAndRemoveUntil<dynamic>(
            this.context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => AppWrapper(
                      loadAttempt: 0,
                    )),
            (route) => false, //if you want to disable back feature set to false
          );
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil<dynamic>(
                this.context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => AppWrapper(
                          loadAttempt: 0,
                        )),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            },
            icon: Icon(
              EvaIcons.arrowBack,
              size: 23,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index),
            )),
        title: MtCustomfontBoldSemi(
          text:
              "${getTranslatedForCurrentUser(this.context, 'xxagentxx')} ${getTranslatedForCurrentUser(this.context, 'xxaccountxx')}",
          fontsize: 17,
          color: Mycolors.black,
        ),
      ),
      body: isAskName == true
          ? ListView(
              padding: EdgeInsets.all(20),
              children: [
                Container(
                  margin: EdgeInsets.only(top: 0),
                  // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  // height: 63,
                  // height: 178,
                  width: w / 1.24,
                  child: Form(
                    child: Column(
                      children: [
                        // MtCustomfontBoldSemi(
                        //   text: 'Mobile Number',
                        //   fontsize: 14,
                        // ),
                        InpuTextBox(
                          controller: _name,
                          hinttext: getTranslatedForCurrentUser(
                              this.context, 'xxenterfullnamexx'),
                          title: getTranslatedForCurrentUser(
                              this.context, 'xxnamexx'),
                        ),
                        InpuTextBox(
                          isboldinput: true,
                          controller: _email,
                          disabled: true,
                          title: getTranslatedForCurrentUser(
                              this.context, 'xxemailxx'),
                        ),
                        InpuTextBox(
                          disabled: true,
                          obscuretext: true,
                          controller: _password,
                          title: getTranslatedForCurrentUser(
                              this.context, 'xxpasswordxx'),
                        ),

                        SizedBox(
                          height: 6,
                        ),
                        MtCustomfontLight(
                          text: getTranslatedForCurrentUser(
                                  this.context, 'xxplsremembercredxx')
                              .replaceAll('(####)',
                                  '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MySimpleButtonWithIcon(
                          buttoncolor: Mycolors.getColor(
                              widget.prefs, Colortype.primary.index),
                          onpressed: () async {
                            if (_name.text.trim().length < 2) {
                              Utils.toast(getTranslatedForCurrentUser(
                                  this.context, 'xxentervalidnamexx'));
                            } else {
                              await createFreshNewAccountInFirebase(
                                  storedFinalID, 0,
                                  registereduserCredential:
                                      storedregistereduserCredential,
                                  name: _name.text.trim());
                            }
                          },
                          buttontext: getTranslatedForCurrentUser(
                              this.context, 'xxcreateacxx'),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          : isloading == true
              ? Center(
                  child: circularProgress(),
                )
              : ListView(
                  children: [],
                ),
    );
  }
}
