//*************   © Copyrighted by aagama_it.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:random_string/random_string.dart';
import 'package:aagama_it/Configs/MyRegisteredFonts.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Configs/app_constants.dart';
import 'package:aagama_it/Configs/number_limits.dart';
import 'package:aagama_it/Configs/optional_constants.dart';
import 'package:aagama_it/Models/customer_model.dart';
import 'package:aagama_it/Models/basic_settings_model_userapp.dart';
import 'package:aagama_it/Models/batch_write_component.dart';
import 'package:aagama_it/Models/role_management.dart';
import 'package:aagama_it/Models/user_registry_model.dart';
import 'package:aagama_it/Models/userapp_settings_model.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:aagama_it/Services/FirebaseServices/firebase_api.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Services/Providers/TimerProvider.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Utils/backupUserTable.dart';
import 'package:aagama_it/Utils/batch_write.dart';
import 'package:aagama_it/Utils/phonenumberVariantsGenerator.dart';
import 'package:aagama_it/Utils/unawaited.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/main.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:aagama_it/Models/E2EE/e2ee.dart' as e2ee;
import 'package:flutter/foundation.dart' show kIsWeb;

class VerifyPhoneForCustomers extends StatefulWidget {
  final Function(String title, String desc, String error) onError;
  final String onlyPhone;
  final String onlyCode;
  final SharedPreferences prefs;
  final bool issecutitysetupdone;
  final BasicSettingModelUserApp basicsettings;
  VerifyPhoneForCustomers({
    Key? key,
    required this.onlyPhone,
    required this.issecutitysetupdone,
    required this.onlyCode,
    required this.onError,
    required this.prefs,
    required this.basicsettings,
  }) : super(key: key);

  @override
  _VerifyPhoneForCustomersState createState() =>
      _VerifyPhoneForCustomersState();
}

class _VerifyPhoneForCustomersState extends State<VerifyPhoneForCustomers> {
  int currentStatus = LoginStatus.sendingSMScode.index;
  bool isShowCompletedLoading = false;
  bool isVerifyingCode = false;
  bool isCodeSent = false;
  String _code = '';
  int attempt = 1;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final _name = TextEditingController();
  final storage = new FlutterSecureStorage();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String? verificationId;
  dynamic isLoggedIn = false;
  User? currentUser;
  String? deviceid;
  var mapDeviceInfo = {};
  @override
  void initState() {
    super.initState();
    setdeviceinfo();

    verifyPhoneNumber();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final timerProvider =
          Provider.of<TimerProvider>(this.context, listen: false);
      timerProvider.resetTimer();
    });
  }

  setdeviceinfo() async {
    if (kIsWeb) {
    } else {
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
  }

  subscribeToNotification(String currentUserID, bool isFreshNewAccount) async {
    await FirebaseMessaging.instance
        .subscribeToTopic('$currentUserID')
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Dbkeys.topicCUSTOMERS)
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
      ///-- subscrive to own tickets
      // await FirebaseFirestore.instance
      //     .collection(DbPaths.collectionAgentGroups)
      //     .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserID)
      //     .get()
      //     .then((query) async {
      //   if (query.docs.length > 0) {
      //     query.docs.forEach((doc) async {
      //       await FirebaseMessaging.instance
      //           .subscribeToTopic(
      //               "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
      //           .catchError((err) {
      //         print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
      //       });
      //     });
      //   }
      // });
    }
  }

  createNewUser(String finalID) async {
    print("syam prints: createNewUser() - entered");

    var phoneNo = (widget.onlyCode + widget.onlyPhone).trim();
    // final observer = Provider.of<Observer>(this.context, listen: false);
    // int id = DateTime.now().millisecondsSinceEpoch;

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      Navigator.of(this.context).pop();
      widget.onError(
        getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
        'Error occured while registering for Notification. Please try again',
        'Failed to get fCMtoken',
      );
    } else {
      String myname = _name.text;
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
      var currentPlatform = "";
      if (kIsWeb) {
        currentPlatform = "web";
      } else {
        currentPlatform = Platform.isAndroid
            ? "android"
            : Platform.isIOS
                ? "ios"
                : "web";
      }
      final pair = await e2ee.X25519().generateKeyPair();
      await storage.write(
          key: Dbkeys.privateKey, value: pair.secretKey.toBase64());
      // Update data to server if new user
      await batchwriteFirestoreData([
        BatchWriteComponent(
                ref: FirebaseFirestore.instance
                    .collection(DbPaths.collectioncustomers)
                    .doc(finalID),
                map: CustomerModel(
                  rolesassigned: defaultCustomerRoles,
                  platform: currentPlatform,
                  id: finalID,
                  userLoginType: LoginType.phone.index,
                  email: '',
                  password: '',
                  firebaseuid: currentUser!.uid,
                  nickname: _name.text.trim(),
                  searchKey: _name.text.trim().substring(0, 1).toUpperCase(),
                  phone: phoneNo,
                  phoneRaw: widget.onlyPhone,
                  countryCode: widget.onlyCode,
                  photoUrl: currentUser!.photoURL ?? '',
                  aboutMe: '',
                  actionmessage:
                      widget.basicsettings.accountapprovalmessage ?? '',
                  currentDeviceID: deviceid ?? '',
                  privateKey: pair.secretKey.toBase64(),
                  publicKey: pair.publicKey.toBase64(),
                  accountstatus:
                      widget.basicsettings.customerVerificationNeeded == true
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
                  lastNotificationSeen: DateTime.now().millisecondsSinceEpoch,
                  isNotificationStringsMulitilanguageEnabled: false,
                  notificationStringsMap: {},
                  kycMap: {},
                  geoMap: {},
                  phonenumbervariants: phoneNumberVariantsList(
                      countrycode: widget.onlyCode,
                      phonenumber: widget.onlyPhone),
                  hidden: [],
                  locked: [],
                  notificationTokens: [],
                  deviceDetails: mapDeviceInfo,
                  quickReplies: [],
                  lastVerified: 0,
                  ratings: [],
                  totalRepliesInTickets: 0,
                  twoFactorVerification: {},
                  userTypeIndex: Usertype.customer.index,
                ).toMap())
            .toMap(),
        BatchWriteComponent(
            ref: FirebaseFirestore.instance
                .collection(DbPaths.collectioncustomers)
                .doc(finalID)
                .collection(DbPaths.customernotifications)
                .doc(DbPaths.customernotifications),
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
              Dbkeys.nOTIFICATIONxxpageID: DbPaths.customernotifications,
              //-----
              Dbkeys.nOTIFICATIONpagecollection1: DbPaths.collectioncustomers,
              Dbkeys.nOTIFICATIONpagedoc1: phoneNo,
              Dbkeys.nOTIFICATIONpagecollection2: DbPaths.customernotifications,
              Dbkeys.nOTIFICATIONpagedoc2: DbPaths.customernotifications,
              Dbkeys.nOTIFICATIONtopic: Dbkeys.topicCUSTOMERS,
              Dbkeys.list: [],
            }).toMap(),
        BatchWriteComponent(
          ref: FirebaseFirestore.instance
              .collection(DbPaths.userapp)
              .doc(DbPaths.docusercount),
          map: widget.basicsettings.customerVerificationNeeded == false
              ? {
                  Dbkeys.totalapprovedcustomers: FieldValue.increment(1),
                }
              : {
                  Dbkeys.totalpendingcustomers: FieldValue.increment(1),
                },
        ).toMap(),

        BatchWriteComponent(
                ref: FirebaseFirestore.instance
                    .collection(DbPaths.collectioncustomers)
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
                  fullname: _name.text.trim(),
                  id: finalID,
                  phone: phoneNo,
                  photourl: currentUser!.photoURL ?? "",
                  usertype: Usertype.customer.index,
                  email: "",
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
        //         ? '${_name.text.trim()} has Joined $Appname. APPROVE the customer account (ID:$finalID). You can view the customer profile from All Customers page.'
        //         : '${_name.text.trim()} has Joined $Appname. You can view the customer profile from All Customers page.',
        //     Dbkeys.nOTIFICATIONxxtitle: 'New Customer Joined',
        //     Dbkeys.nOTIFICATIONxximageurl: currentUser!.photoURL ?? "",
        //     Dbkeys.nOTIFICATIONxxlastupdateepoch:
        //         DateTime.now().millisecondsSinceEpoch,
        //   },
        // ).toMap(),
        BatchWriteComponent(
          ref: FirebaseFirestore.instance
              .collection(DbPaths.collectioncustomers)
              .doc(finalID),
          map: {
            Dbkeys.notificationTokens: [fcmToken]
          },
        ).toMap()
      ]).then((value) async {
        if (value == false) {
          print("syam prints: CreateNewUser() - value == false");
          //faild to write
          if (currentUser != null) {
            final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
            await firebaseAuth.signOut();
          }

          Navigator.of(this.context).pop();
          widget.onError(
            'Login Failed !',
            'Error occured while authentication. Please try again',
            'Failed to batch Write for Customer Doc',
          );
        } else {
          // Write data to local
          await widget.prefs.setString(Dbkeys.firebaseuid, currentUser!.uid);
          await widget.prefs.setString(Dbkeys.id, finalID);
          await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
          await widget.prefs
              .setString(Dbkeys.photoUrl, currentUser!.photoURL ?? '');
          await widget.prefs.setString(Dbkeys.phone, phoneNo);
          await widget.prefs.setString(Dbkeys.countryCode, widget.onlyCode);
          await widget.prefs
              .setInt(Dbkeys.userLoginType, Usertype.customer.index);

          unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
          await FirebaseApi.runTransactionRecordActivity(
            parentid: "CUSTOMER_REGISTRATION--$finalID",
            title: "New Customer Joined",
            postedbyID: "sys",
            onErrorFn: (e) {},
            onSuccessFn: () {},
            styledDesc: widget.basicsettings.customerVerificationNeeded == true
                ? '<bold>${_name.text.trim()}</bold> has Joined $Appname. APPROVE the customer account <bold>(ID:$finalID)</bold>. You can view the customer profile from All Customers page.'
                : '<bold>${_name.text.trim()}</bold> has Joined $Appname. You can view the customer account <bold>(ID:$finalID)</bold> from <bold>All Customers</bold> page.',
            plainDesc: widget.basicsettings.customerVerificationNeeded == true
                ? '${_name.text.trim()} has Joined $Appname. APPROVE the customer account (ID:$finalID). You can view the customer profile from All Customers page.'
                : '${_name.text.trim()} has Joined $Appname. You can view the customer profile from All Customers page.',
          );
          // unawaited(Navigator.pushReplacement(
          //     this.context,
          //     MaterialPageRoute(
          //         builder: (newContext) => CustomerHome(
          //               basicsettings: widget.basicsettings,
          //               currentUserID: finalID,
          //               prefs: widget.prefs,
          //             ))));

          if (!kIsWeb) await subscribeToNotification(finalID, true);
          Navigator.pushAndRemoveUntil<dynamic>(
            this.context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => AppWrapper(
                      loadAttempt: 0,
                    )),
            (route) => false, //if you want to disable back feature set to false
          );
        }
      });
    }
  }

  updateUser(DocumentSnapshot<Map<String, dynamic>> document) async {
    // final observer = Provider.of<Observer>(this.context, listen: false);
    var currentPlatform = "";
    if (kIsWeb) {
      currentPlatform = "web";
    } else {
      currentPlatform = Platform.isAndroid
          ? "android"
          : Platform.isIOS
              ? "ios"
              : "web";
    }
    await storage.write(
        key: Dbkeys.privateKey, value: document[Dbkeys.privateKey]);
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    CustomerModel customer = CustomerModel.fromSnapshot(document);
    final updatedCustomer = customer.copyWith(
      userLoginType: LoginType.phone.index,
      lastLogin: DateTime.now().millisecondsSinceEpoch,
      platform: currentPlatform,
      // mssgSent: 0,
      deviceDetails: mapDeviceInfo,
      currentDeviceID: deviceid,

      notificationTokens: [fcmToken!],
    );
    await FirebaseFirestore.instance
        .collection(DbPaths.collectioncustomers)
        .doc(document.data()![Dbkeys.id])
        .update(updatedCustomer.toMap());

    // Write data to local
    await widget.prefs
        .setString(Dbkeys.firebaseuid, document[Dbkeys.firebaseuid]);
    await widget.prefs.setString(Dbkeys.id, document[Dbkeys.id]);
    await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
    await widget.prefs
        .setString(Dbkeys.photoUrl, document[Dbkeys.photoUrl] ?? '');
    await widget.prefs
        .setString(Dbkeys.aboutMe, document[Dbkeys.aboutMe] ?? '');
    await widget.prefs.setString(Dbkeys.phone, document[Dbkeys.phone]);
    await widget.prefs.setInt(Dbkeys.userLoginType, Usertype.customer.index);
    if (widget.issecutitysetupdone == false) {
      // unawaited(Navigator.pushReplacement(
      //     this.context,
      //     MaterialPageRoute(
      //         builder: (newContext) => CustomerHome(
      //               basicsettings: widget.basicsettings,
      //               currentUserID: document[Dbkeys.id],
      //               prefs: widget.prefs,
      //             ))));
      // await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
      await subscribeToNotification(document[Dbkeys.id], false);
      Navigator.pushAndRemoveUntil<dynamic>(
        this.context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => AppWrapper(
                  loadAttempt: 0,
                )),
        (route) => false, //if you want to disable back feature set to false
      );
    } else {
      if (!kIsWeb) await subscribeToNotification(document[Dbkeys.id], false);
      Utils.toast(getTranslatedForCurrentUser(this.context, 'xxwelcomebackxx'));
      Navigator.pushAndRemoveUntil<dynamic>(
        this.context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => AppWrapper(
                  loadAttempt: 0,
                )),
        (route) => false, //if you want to disable back feature set to false
      );
      // unawaited(Navigator.pushReplacement(this.context,
      //     new MaterialPageRoute(builder: (this.context) => AppWrapper())));
    }
  }

  Future<Null> handleSignIn({AuthCredential? authCredential}) async {
    print("syam prints: handleSignIn - 001");
    final timerProvider =
        Provider.of<TimerProvider>(this.context, listen: false);
    final observerold = Provider.of<Observer>(this.context, listen: false);
    print("syam prints: handleSignIn - 002");
    setStateIfMounted(() {
      print("syam prints: handleSignIn - setStateIfMounted");
      isShowCompletedLoading = true;
    });

    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: _code);

      UserCredential firebaseUser =
          await firebaseAuth.signInWithCredential(credential);

      currentUser = firebaseUser.user;
      print("-----syam prints-----handleSignIn currentUser: $currentUser");

      setStateIfMounted(() {});

      await FirebaseFirestore.instance
          .collection(DbPaths.userapp)
          .doc(DbPaths.appsettings)
          .get()
          .then((appsettings) async {
        if (appsettings.exists) {
          observerold.setObserver(
              currentUserID: null,
              isAgent: false,
              userAppSettings: UserAppSettingsModel.fromSnapshot(appsettings));

          await FirebaseFirestore.instance
              .collection(DbPaths.collectioncustomers)
              .where(Dbkeys.phone,
                  isEqualTo: widget.onlyCode + widget.onlyPhone)
              .get()
              .then((customer) async {
            if (customer.docs.length >= 1) {
              if (widget.basicsettings.customerLoginEnabled == false) {
                if (currentUser != null) {
                  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                  await firebaseAuth.signOut();
                }
                Navigator.of(this.context).pop();
                widget.onError(
                  getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
                  getTranslatedForCurrentUser(
                      this.context, 'xxxlogintempdisbaledxxx'),
                  '',
                );
              } else {
                setStateIfMounted(() {
                  _name.text = customer.docs[0][Dbkeys.nickname];
                });
                updateUser(customer.docs.first);
              }
            } else {
              if (widget.basicsettings.customerRegistationEnabled == false) {
                if (currentUser != null) {
                  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                  await firebaseAuth.signOut();
                }
                Navigator.of(this.context).pop();
                widget.onError(
                  getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
                  getTranslatedForCurrentUser(
                      this.context, 'xxregistrationdisabledxx'),
                  '',
                );
              } else {
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionagents)
                    .where(Dbkeys.phone,
                        isEqualTo: widget.onlyCode + widget.onlyPhone)
                    .get()
                    .then((agent) async {
                  if (agent.docs.length >= 1) {
                    setStateIfMounted(() {
                      currentStatus = LoginStatus.failure.index;
                      isCodeSent = false;
                      timerProvider.resetTimer();
                      isShowCompletedLoading = false;
                      isVerifyingCode = false;
                      currentPinAttemps = 0;
                    });
                    if (currentUser != null) {
                      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                      await firebaseAuth.signOut();
                    }
                    Navigator.of(this.context).pop();
                    widget.onError(
                      getTranslatedForCurrentUser(
                              this.context, 'xxalreadyregisteredasxx')
                          .replaceAll(
                              '(####)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxagentxx')),
                      getTranslatedForCurrentUser(
                              this.context, 'xxalreadyregistereddescxx')
                          .replaceAll(
                              '(####)',
                              (widget.onlyCode + widget.onlyPhone)
                                  .trim()
                                  .toString())
                          .replaceAll(
                              '(###)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxagentxx'))
                          .replaceAll(
                              '(##)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxcustomerxx')),
                      '',
                    );
                  } else {
                    setStateIfMounted(() {
                      currentStatus = LoginStatus.entername.index;
                    });
                  }
                });
              }
            }
          }).catchError((onError) async {
            if (currentUser != null) {
              final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
              await firebaseAuth.signOut();
            }
            Navigator.of(this.context).pop();
            widget.onError(
              getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
              getTranslatedForCurrentUser(this.context, 'xxauthfailedxx'),
              'ERROR:2-${onError.toString()}',
            );
          });
        } else {
          if (currentUser != null) {
            final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
            await firebaseAuth.signOut();
          }
          Navigator.of(this.context).pop();
          widget.onError(
            'Login Failed',
            'User app is not installed properly.',
            '',
          );
        }
      }).catchError((onError) async {
        if (currentUser != null) {
          final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          await firebaseAuth.signOut();
        }
        Navigator.of(this.context).pop();
        widget.onError(
          'Login Failed',
          'Failed to load please try again.',
          'ERROR:9-${onError.toString()}',
        );
      });
    } catch (e) {
      setStateIfMounted(() {
        if (currentPinAttemps >= 4) {
          currentStatus = LoginStatus.failure.index;
          isCodeSent = false;
        }
        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps++;
      });

      if (e.toString().contains('invalid') ||
          e.toString().contains('code') ||
          e.toString().contains('verification')) {
        if (currentUser != null) {
          final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          await firebaseAuth.signOut();
        }
        Navigator.of(this.context).pop();
        widget.onError(
          getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
          getTranslatedForCurrentUser(this.context, 'xxmakesureotpxx'),
          'ERROR:4-${e.toString()}',
        );
      } else {
        if (currentUser != null) {
          final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          await firebaseAuth.signOut();
        }
        Navigator.of(this.context).pop();
        widget.onError(
          getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
          getTranslatedForCurrentUser(this.context, 'xxmakesureotpxx'),
          'ERROR:6-${e.toString()}',
        );
      }
      //  else {
      //   ShowCustomAlertDialog().open(
      //       context: this.context,
      //       dialogtype: 'error',
      //       title: 'Login Failed',
      //       errorlog: e.toString(),
      //       description: 'Please verify credentials and try again later.',
      //       isshowerrorlog: true);
      // }
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  int currentPinAttemps = 0;
  Future<void> verifyPhoneNumber() async {
    final timerProvider =
        Provider.of<TimerProvider>(this.context, listen: false);
    // start----
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      isShowCompletedLoading = true;
      setStateIfMounted(() {});
      handleSignIn(authCredential: phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setStateIfMounted(() {
        currentStatus = LoginStatus.failure.index;
        isCodeSent = false;
        timerProvider.resetTimer();
        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });

      print(
          'Authentication failed -ERROR: ${authException.message}. Try again later.');

      Navigator.of(this.context).pop();
      widget.onError(
        getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
        getTranslatedForCurrentUser(this.context, 'xxauthfailedxx'),
        '',
      );
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      timerProvider.startTimer();
      setStateIfMounted(() {
        currentStatus = LoginStatus.sentSMSCode.index;
        isVerifyingCode = false;
        isCodeSent = true;
      });

      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      setStateIfMounted(() {
        currentStatus = LoginStatus.failure.index;
        isCodeSent = false;
        timerProvider.resetTimer();
        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });
      Navigator.of(this.context).pop();
      widget.onError(
        getTranslatedForCurrentUser(this.context, 'xxfailedxx'),
        getTranslatedForCurrentUser(this.context, 'xxverffailedxx'),
        '',
      );
    };

    if (kIsWeb) {
      try {
        String phoneNumber_entered =
            (widget.onlyCode + widget.onlyPhone).trim();
        print("----syam prints----phoneNumber_entered: $phoneNumber_entered");
        final ConfirmationResult authResult =
            await firebaseAuth.signInWithPhoneNumber(phoneNumber_entered);
        print(
            'Successfully signed in with phone number: ${authResult.toString()}');

        timerProvider.startTimer();
        setStateIfMounted(() {
          currentStatus = LoginStatus.sentSMSCode.index;
          isVerifyingCode = false;
          isCodeSent = true;
        });
        this.verificationId = authResult.verificationId;
      } catch (e) {
        print('Failed to sign in with phone number: $e');
      }
    } else {
      // try {
      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: (widget.onlyCode + widget.onlyPhone).trim(),
          timeout: Duration(seconds: timeOutSeconds + timeOutSeconds + 20),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      // } catch (e) {
      //   Utils.toast('NEW CATCH' + e.toString());
      // }
    }
// end----
  }

  buildCurrentWidget(double w) {
    if (currentStatus == LoginStatus.entername.index) {
      return loginWidgetEnterName(w);
    } else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScode();
    } else if (currentStatus == LoginStatus.sentSMSCode.index) {
      print("syam prints: loginWidgetsentSMScode() - 001");
      return loginWidgetsentSMScode();
    } else if (currentStatus == LoginStatus.verifyingSMSCode.index) {
      print("syam prints: loginWidgetVerifyingSMScode() - 001");
      return loginWidgetVerifyingSMScode();
    } else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScode();
    } else if (currentStatus == LoginStatus.checkingname.index) {
      print("syam prints: LoginStatus.checkingname.index() - 001");
      return Padding(
        padding: EdgeInsets.fromLTRB(
            28, MediaQuery.of(this.context).size.height / 5, 28, 40),
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Mycolors.secondary)),
        ),
      );
    }
    // else {
    //   return loginWidgetsendSMScode(w);
    // }
  }

  loginWidgetEnterName(double w) {
    // var w = MediaQuery.of(this.context).size.width;
    return Container(
      height: MediaQuery.of(this.context).size.height / 3,
      margin: EdgeInsets.fromLTRB(15, 30, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 7),
              child: MtCustomfontBold(
                fontsize: 18,
                text: getTranslatedForCurrentUser(
                    this.context, 'xxenterfullnamexx'),
              )
              // Text(
              //   getTranslatedForCurrentUser(this.context, 'xxenterfullnamexx'),
              //   textAlign: TextAlign.left,
              //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
              // ),
              ),
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            // height: 63,
            height: 73,
            width: MediaQuery.of(this.context).size.width / 1.2,
            child: InpuTextBox(
              focuscolor: Mycolors.customerPrimary,
              boxbordercolor: Mycolors.textboxbordercolor,
              boxbcgcolor: Mycolors.textboxbgcolor,
              controller: _name,
              leftrightmargin: 0,
              showIconboundary: false,
              boxcornerradius: 5.5,
              hinttext:
                  getTranslatedForCurrentUser(this.context, 'xxfullnamexx'),
              boxheight: 55,
              prefixIconbutton: Icon(Icons.person, color: Mycolors.greylight),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          MySimpleButtonWithIcon(
            width: MediaQuery.of(this.context).size.width / 1.2,
            buttontext:
                getTranslatedForCurrentUser(this.context, 'xxcreateacxx'),
            buttoncolor:
                Mycolors.getColor(widget.prefs, Colortype.primary.index),
            onpressed: () async {
              print("----Syam Prints onpressed new user ");
              final timerProvider =
                  Provider.of<TimerProvider>(this.context, listen: false);
              timerProvider.resetTimer();
              print("----Syam Prints onpressed new user resetTimer ");
              setStateIfMounted(() {
                currentStatus = LoginStatus.checkingname.index;
                isCodeSent = false;
              });

              String finalID1 = randomNumeric(Numberlimits.customerIDlength);
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectioncustomers)
                  .doc(finalID1)
                  .get()
                  .then((value1) async {
                if (value1.exists) {
                  String finalID2 =
                      randomNumeric(Numberlimits.customerIDlength);
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectioncustomers)
                      .doc(finalID2)
                      .get()
                      .then((value2) async {
                    if (value2.exists) {
                      String finalID3 =
                          randomNumeric(Numberlimits.customerIDlength);
                      await FirebaseFirestore.instance
                          .collection(DbPaths.collectioncustomers)
                          .doc(finalID3)
                          .get()
                          .then((value3) async {
                        if (value3.exists) {
                          String finalID4 =
                              randomNumeric(Numberlimits.customerIDlength);
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectioncustomers)
                              .doc(finalID4)
                              .get()
                              .then((value4) async {
                            if (value4.exists) {
                              Utils.toast(getTranslatedForCurrentUser(
                                  this.context, 'xxerroroccuredxx'));
                            } else {
                              await createNewUser(finalID4);
                            }
                          });
                        } else {
                          await createNewUser(finalID3);
                        }
                      });
                    } else {
                      await createNewUser(finalID2);
                    }
                  });
                } else {
                  await createNewUser(finalID1);
                }
              });
            },
          )
        ],
      ),
    );
  }

  loginWidgetsendingSMScode() {
    var w = MediaQuery.of(this.context).size.width;
    return Container(
      height: MediaQuery.of(this.context).size.height / 3,
      margin: EdgeInsets.fromLTRB(15, 30, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: w * 0.95,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: getTranslatedForCurrentUser(
                          this.context, 'xxsending_codexx'),
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.regular,
                          color: Mycolors.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                  TextSpan(
                      text: ' ${widget.onlyCode}-${widget.onlyPhone}',
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.bold,
                          color: Mycolors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
              Mycolors.getColor(widget.prefs, Colortype.primary.index),
            )),
          ),
          SizedBox(
            height: 48,
          ),
        ],
      ),
    );
  }

  loginWidgetsentSMScode() {
    var w = MediaQuery.of(this.context).size.width;
    print(
        "syam prints: loginWidgetsentSMScode() - isShowCompletedLoading: $isShowCompletedLoading");
    return Container(
      height: MediaQuery.of(this.context).size.height / 2.5,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),

          Container(
            margin: EdgeInsets.all(25),
            // height: 70,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: PinFieldAutoFill(
                codeLength: 6,
                decoration: UnderlineDecoration(
                  bgColorBuilder: FixedColorBuilder(Color(0xfff0f4fb)),
                  textStyle: TextStyle(
                      fontSize: 22,
                      color: Mycolors.blackDynamic,
                      fontWeight: FontWeight.bold),
                  colorBuilder: FixedColorBuilder(Color(0xfff0f4fb)),
                ),
                currentCode: _code,
                onCodeSubmitted: (code) {
                  print("syam prints: onCodeSubmitted - 001");

                  setStateIfMounted(() {
                    _code = code;
                  });
                  if (code.length == 6) {
                    setStateIfMounted(() {
                      currentStatus = LoginStatus.verifyingSMSCode.index;
                    });
                    handleSignIn();
                  } else {
                    Utils.toast(getTranslatedForCurrentUser(
                        this.context, 'xxcorrectotpxx'));
                  }
                },
                onCodeChanged: (code) {
                  if (code!.length == 6) {
                    FocusScope.of(this.context).requestFocus(FocusNode());
                    setStateIfMounted(() {
                      _code = code;
                    });
                  }
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: w * 0.95,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: getTranslatedForCurrentUser(
                          this.context, 'xxenter_verfcodexx'),
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.regular,
                          color: Mycolors.grey,
                          // fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                  TextSpan(
                      text: ' ${widget.onlyCode}-${widget.onlyPhone}',
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.bold,
                          color: Mycolors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
            ),
          ),

          isShowCompletedLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Mycolors.secondary)),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MySimpleButtonWithIcon(
                      width: MediaQuery.of(this.context).size.width / 1.2,
                      buttontext: getTranslatedForCurrentUser(
                          this.context, 'xxverify_otpxx'),
                      buttoncolor: Mycolors.getColor(
                          widget.prefs, Colortype.primary.index),
                      onpressed: () {
                        if (_code.length == 6) {
                          setStateIfMounted(() {
                            isVerifyingCode = true;
                          });
                          handleSignIn();
                        } else
                          Utils.toast(getTranslatedForCurrentUser(
                              this.context, 'xxcorrectotpxx'));
                      },
                    ),
                  ],
                ),

          SizedBox(
            height: 20,
          ),
          isShowCompletedLoading == true
              ? SizedBox(
                  height: 36,
                )
              : Consumer<TimerProvider>(
                  builder: (context, timeProvider, _) => timeProvider.wait ==
                              true &&
                          isCodeSent == true
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                          child: RichText(
                              text: TextSpan(
                            children: [
                              TextSpan(
                                text: getTranslatedForCurrentUser(
                                    this.context, 'xxresendcodexx'),
                                style: TextStyle(
                                    fontFamily: MyRegisteredFonts.regular,
                                    fontSize: 14,
                                    color: Mycolors.grey),
                              ),
                              TextSpan(
                                text: "  00:${timeProvider.start}  ",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Mycolors.getColor(
                                        widget.prefs, Colortype.primary.index),
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: getTranslatedForCurrentUser(
                                    this.context, 'xxsecondsxx'),
                                style: TextStyle(
                                    fontFamily: MyRegisteredFonts.regular,
                                    fontSize: 14,
                                    color: Mycolors.grey),
                              ),
                            ],
                          )),
                        )
                      : timeProvider.isActionBarShow == false
                          ? SizedBox(
                              height: 35,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                attempt > 1
                                    ? SizedBox(
                                        height: 0,
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setStateIfMounted(() {
                                            attempt++;

                                            timeProvider.resetTimer();
                                            isCodeSent = false;
                                            currentStatus = LoginStatus
                                                .sendingSMScode.index;
                                          });
                                          verifyPhoneNumber();
                                        },
                                        child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(10, 4, 28, 4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.restart_alt_outlined,
                                                color: Mycolors.getColor(
                                                    widget.prefs,
                                                    Colortype.secondary.index),
                                              ),
                                              Text(
                                                ' ' +
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxresendxx'),
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Mycolors.getColor(
                                                        widget.prefs,
                                                        Colortype
                                                            .secondary.index),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ))
                              ],
                            ),
                ),

          //
        ],
      ),
    );
  }

  loginWidgetVerifyingSMScode() {
    print("syam prints: loginWidgetVerifyingSMScode() - 001");
    return Container(
      height: MediaQuery.of(this.context).size.height / 3,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),

          Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Mycolors.secondary)),
          ),

          InkWell(
            onTap: () {
              setStateIfMounted(() {
                currentStatus = LoginStatus.sendSMScode.index;
              });
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(13, 22, 13, 8),
                child: Center(
                  child: Text(
                    getTranslatedForCurrentUser(this.context, 'xxbackxx'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                )),
          ),
          //
          SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MyScaffold(
        iconTextColor: Mycolors.black,
        iconWidget: Consumer<TimerProvider>(
            builder: (context, timeProvider, _) => IconButton(
                onPressed: () async {
                  if ((currentStatus == LoginStatus.sentSMSCode.index &&
                          timeProvider.isActionBarShow == true) ||
                      currentStatus == LoginStatus.checkingname.index) {
                    if (currentUser != null) {
                      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                      await firebaseAuth.signOut();
                    }
                    Navigator.of(this.context).pop();
                  }
                },
                icon: Icon(
                  (currentStatus == LoginStatus.sentSMSCode.index &&
                              timeProvider.isActionBarShow == true) ||
                          currentStatus == LoginStatus.checkingname.index
                      ? Icons.close
                      : null,
                ))),
        title: getTranslatedForCurrentUser(this.context, 'xxverifynumberxx'),
        isforcehideback: true,
        body: Container(
          color: Mycolors.backgroundcolor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  color: Mycolors.whiteDynamic,
                  child: Center(
                      child: Image.asset('assets/images/verify.png',
                          height: MediaQuery.of(this.context).size.height / 3)),
                ),
              ),
              Container(
                decoration: boxDecoration(radius: 8),
                padding: const EdgeInsets.fromLTRB(18, 35, 18, 8),
                // color: Colors.white,
                child:
                    buildCurrentWidget(MediaQuery.of(this.context).size.width),
              )
            ],
          ),
        ),
      ),
    );
  }
}
