//*************   © Copyrighted by aagama_it.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Models/basic_settings_model_userapp.dart';
import 'package:aagama_it/Models/batch_write_component.dart';
import 'package:aagama_it/Screens/AgentScreens/home/agent_home.dart';
import 'package:aagama_it/Screens/CustomerScreens/home/customer_home.dart';
import 'package:aagama_it/Screens/initialization/initialization_constant.dart';
import 'package:aagama_it/Screens/splash_screen/splash_screen.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Utils/batch_write.dart';
import 'package:aagama_it/Utils/custom_url_launcher.dart';
import 'package:aagama_it/Utils/error_codes.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as web;
import 'package:restart_app/restart_app.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Initialize extends StatefulWidget {
  const Initialize(
      {Key? key,
      required this.prefs,
      required this.app,
      required this.doc,
      required this.loadAttempt,
      required this.iscustomer})
      : super(key: key);

  final SharedPreferences prefs;
  final bool iscustomer;
  final String app;
  final String doc;
  final int loadAttempt;
  @override
  _InitializeState createState() => _InitializeState();
}

class _InitializeState extends State<Initialize> {
  bool isprocessing = true;
  bool isDocHave = false;
  bool iscircleprogressindicator = false;
  bool isSecuritySetupPending = false;
  String securityRuleName = "";
  bool isready = false;
  var mapDeviceInfo = {};
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceid;
  bool isemulator = false;
  var doc;
  Color mycolor = Mycolors.primary;
  String platform = "";

  setdeviceinfo() async {
    print("syam prints: _InitializeState() - setdeviceinfo -001");
    if (kIsWeb) {
    } else {
      if (Platform.isAndroid == true) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceid = androidInfo.id + androidInfo.androidId;
          isemulator = !androidInfo.isPhysicalDevice;
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
        setState(() {
          deviceid = iosInfo.systemName + iosInfo.model + iosInfo.systemVersion;
          isemulator = !iosInfo.isPhysicalDevice;
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

  bool isRetrying = false;
  BasicSettingModelUserApp? serverappsettings;
  initialise() async {
    await setdeviceinfo();
    setState(() {
      k1 = InitializationConstant.k1;
      k2 = InitializationConstant.k2;
      k3 = InitializationConstant.k3;
      k4 = InitializationConstant.k4;
      k5 = InitializationConstant.k5;
      k6 = InitializationConstant.k6;
      k7 = InitializationConstant.k7;
      project = InitializationConstant.k8;
    });
    platform = "";
    if (kIsWeb) {
      platform = "web";
    } else {
      platform = Platform.isIOS
          ? "ios"
          : Platform.isAndroid
              ? "android"
              : "web";
    }

    await FirebaseFirestore.instance
        .collection(widget.doc)
        .doc(widget.app)
        .get()
        .then((firestoredoc) async {
      if (firestoredoc.exists) {
        var fd = firestoredoc.data();
        if (fd!['3h64ft'] is String && fd['f9846v'] != null) {
          Codec<String, String> stringToBase64 = utf8.fuse(base64);
          String v = stringToBase64.decode(reverse(fd["3h64ft"])).toString();
          print('INSTALLED VERSION : ${int.tryParse(v)!}');
          print('CURRENT VERSION : ${int.tryParse(k4)!}');
          isDocHave = true;
          setState(() {});
          if (int.tryParse(v)! >= int.tryParse(k4)!) {
            try {
              if (kIsWeb) {
                print("syam prints: Initialize() - kIsWeb -001");
                // f9846v
                String to = stringToBase64.decode(fd['f9846v']).toString();

                var appSettings = json.decode(to) as Map<String, dynamic>;
                serverappsettings =
                    BasicSettingModelUserApp.fromJson(appSettings);

                setState(() {});

                if (serverappsettings!.isemulatorallowed == false &&
                    mapDeviceInfo[Dbkeys.deviceInfoISPHYSICAL] == false) {
                  showERRORSheet(this.context, "7010");
                } else {
                  print("syam prints: Initialize() - kIsWeb -002");
                  //final PackageInfo info = await PackageInfo.fromPlatform();
                  //widget.prefs.setString('app_version', info.version);
                  print("syam prints: Initialize() - kIsWeb -003");
                  final observer =
                      Provider.of<Observer>(this.context, listen: false);
                  observer.setbasicsettings(basicModel: serverappsettings);
                  print("syam prints: Initialize() - kIsWeb -004");
                  setState(() {
                    isready = true;
                    iscircleprogressindicator = false;
                    isprocessing = false;
                  });
                }
              } else {
                // f9846v

                String to = stringToBase64.decode(fd['f9846v']).toString();

                var appSettings = json.decode(to) as Map<String, dynamic>;
                serverappsettings =
                    BasicSettingModelUserApp.fromJson(appSettings);

                if (Platform.isAndroid
                    ? serverappsettings!.isappunderconstructionandroid == false
                    : serverappsettings!.isappunderconstructionios == false) {
                  ///--------------------------------------

                  setState(() {});

                  if (serverappsettings!.isemulatorallowed == false &&
                      mapDeviceInfo[Dbkeys.deviceInfoISPHYSICAL] == false) {
                    showERRORSheet(this.context, "7010");
                  } else {
                    final PackageInfo info = await PackageInfo.fromPlatform();
                    widget.prefs.setString('app_version', info.version);

                    int currentAppVersionInPhone = int.tryParse(info.version
                                .trim()
                                .split(".")[0]
                                .toString()
                                .padLeft(3, '0') +
                            info.version
                                .trim()
                                .split(".")[1]
                                .toString()
                                .padLeft(3, '0') +
                            info.version
                                .trim()
                                .split(".")[2]
                                .toString()
                                .padLeft(3, '0')) ??
                        0;
                    int currentNewAppVersionInServer =
                        int.tryParse(appSettings[Platform.isAndroid
                                        ? Dbkeys.latestappversionandroid
                                        : Platform.isIOS
                                            ? Dbkeys.latestappversionios
                                            : Dbkeys.latestappversionweb]
                                    .trim()
                                    .split(".")[0]
                                    .toString()
                                    .padLeft(3, '0') +
                                appSettings[Platform.isAndroid
                                        ? Dbkeys.latestappversionandroid
                                        : Platform.isIOS
                                            ? Dbkeys.latestappversionios
                                            : Dbkeys.latestappversionweb]
                                    .trim()
                                    .split(".")[1]
                                    .toString()
                                    .padLeft(3, '0') +
                                appSettings[Platform.isAndroid
                                        ? Dbkeys.latestappversionandroid
                                        : Platform.isIOS
                                            ? Dbkeys.latestappversionios
                                            : Dbkeys.latestappversionweb]
                                    .trim()
                                    .split(".")[2]
                                    .toString()
                                    .padLeft(3, '0')) ??
                            0;

                    if (currentAppVersionInPhone <
                        currentNewAppVersionInServer) {
                      showDialog<String>(
                        context: this.context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          String title = getTranslatedForCurrentUser(
                              this.context, 'xxupdateavlxx');
                          String message = getTranslatedForCurrentUser(
                              this.context, 'xxupdateavlmsgxx');

                          String btnLabel = getTranslatedForCurrentUser(
                              this.context, 'xxupdatnowxx');

                          return new WillPopScope(
                              onWillPop: () async => false,
                              child: AlertDialog(
                                title: Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Mycolors.getColor(
                                        widget.prefs,
                                        Colortype.primary.index,
                                      )),
                                ),
                                content: Text(message),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text(
                                        btnLabel,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Mycolors.getColor(
                                                widget.prefs,
                                                Colortype.secondary.index)),
                                      ),
                                      onPressed: () => custom_url_launcher(
                                          appSettings[Platform.isAndroid
                                              ? Dbkeys.newapplinkandroid
                                              : Dbkeys.newapplinkios])),
                                ],
                              ));
                        },
                      );
                    } else {
                      final observer =
                          Provider.of<Observer>(this.context, listen: false);
                      observer.setbasicsettings(basicModel: serverappsettings);
                      setState(() {
                        isready = true;
                        iscircleprogressindicator = false;
                        isprocessing = false;
                      });
                    }
                  }

                  //-----------------------------
                } else {
                  isappundermaintainance = true;
                  maintaincemssg = serverappsettings!.maintainancemessage ??
                      "Currently under maintenance. please visit later.";
                  setState(() {});
                }
              }
            } catch (e) {
              print(e.toString());
              showERRORSheet(this.context, "7021");
            }
          } else {
            setState(() {
              doc = firestoredoc.data();
              iscircleprogressindicator = false;
              isprocessing = false;
              k7 = "kj485bfud87jxh9824hdb";
            });
          }
        } else {
          showERRORSheet(this.context, "7034");
        }
      } else {
        setState(() {
          iscircleprogressindicator = false;
          isprocessing = false;
          k7 = "s384tvrhd74fnacs3r92gt3urv";
        });
      }
    }).catchError((onError) async {
      // [Firestore]: Listen for Query(target=Query(appsettings/userapp order by __name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
      if (onError.message.toString().contains("permission") ||
          onError.message.toString().contains("missing") ||
          onError.message.toString().contains("denied") ||
          onError.message.toString().contains("permissions") ||
          onError.message.toString().contains("insufficient")) {
        this.isSecuritySetupPending = true;
        securityRuleName = "SECURITY RULES TEST ENVIRONMENT";
        setState(() {});
      } else {
        if ((onError.message.toString().contains("unavailable") ||
                onError.message.toString().contains("transient") ||
                onError.message.toString().contains("retrying") ||
                onError.message.toString().contains("backoff") ||
                onError.message.toString().contains("corrected")) &&
            widget.loadAttempt < 10 &&
            isRetrying == false) {
          Future.delayed(
              Duration(
                  milliseconds: widget.loadAttempt < 6
                      ? 6000
                      : widget.loadAttempt * 1000), () {
            Utils.toast("Retrying (${widget.loadAttempt + 1})");
            setState(() {
              isRetrying = true;
            });
            // Navigator.of(this.context).pop();
            Navigator.of(this.context).pushAndRemoveUntil(
              // the new route
              MaterialPageRoute(
                builder: (BuildContext context) => AppWrapper(
                  loadAttempt: widget.loadAttempt + 1,
                ),
              ),

              (Route route) => false,
            );
          });
        } else {
          if (isRetrying == true) {
          } else {
            setState(() {
              iscircleprogressindicator = false;
              isinstalled = false;
            });
            showERRORSheet(this.context, "7121",
                message: (onError.message.toString().contains("unavailable") ||
                        onError.message.toString().contains("transient") ||
                        onError.message.toString().contains("retrying") ||
                        onError.message.toString().contains("backoff") ||
                        onError.message.toString().contains("corrected"))
                    ? onError.message.toString() +
                        ".  Kindly restart the App and try again."
                    : onError.message.toString());
          }
        }
      }
    });
  }

  bool isappundermaintainance = false;
  String maintaincemssg = "";
  @override
  void initState() {
    initialise();

    super.initState();
  }

  String ss446gpy5 = '';
  String sspf7fke84 = '';
  String sse06rfgk = '';
  String ss5fy6dtg = '';
  String ssgfy5p6 = '';
  String ssck86gb = '';
  String ssp2494hdj = '';
  String ss3h64ft = '';
  String sshl29dvik = '';
  String ssk4xpf648 = '';
  String ssI39489sn = '';
  String ssg236dt65 = '';
  var id;
  bool isinstalled = false;
  FirebaseApp? app = Firebase.app();

  gett(String c, String sk3, String sk4) async {
    String error1 = "";
    String error2 = "";
    String error3 = "";
    String error4 = "";
    // ignore: unused_local_variable
    String error5 = "";
    String error8 = "";
    setState(() {
      iscircleprogressindicator = true;
    });
    var url;

    await InitializationConstant.k12.get().then((value) async {
      if (doc == null || ssI39489sn == "c763g82gj8dmlp2") {
        url = Uri.parse(
            'https://klientx.com/f02hi3j74kploer985zmq712lpweibwq5/c07543663368885424787426799851763427?h895nxu=$c&I39489sn=$sk3&p2494hdj=$k1&oebr3sd7=${DateTime.now().millisecondsSinceEpoch.toString()}&84kftegro=$platform&hl29dvik=$k7&pf7fke84=$k2&p2bx84bs=${app!.options.projectId}&tr94nr24=$k3&g236dt65=$sk4');
      } else {
        setState(() {
          ss446gpy5 = doc["446gpy5"] ?? '';
          sspf7fke84 = doc["pf7fke84"] ?? '';
          sse06rfgk = doc["e06rfgk"] ?? '';
          ss5fy6dtg = doc["5fy6dtg"] ?? '';
          ssgfy5p6 = doc["gfy5p6"] ?? '';
          ssck86gb = doc["ck86gb"] ?? '';
          ssp2494hdj = k1;
          ss3h64ft = doc["3h64ft"] ?? '';
          sshl29dvik = doc["hl29dvik"] ?? '';
          ssk4xpf648 = doc["k4xpf648"] ?? '';
          ssI39489sn = doc["I39489sn"] ?? '';
          ssg236dt65 = doc["g236dt65"] ?? '';
        });
        url = Uri.parse(
            'https://klientx.com/f02hi3j74kploer985zmq712lpweibwq5/c07543663368885424787426799851763427?pf7fke84=$sspf7fke84&446gpy5=$ss446gpy5&e06rfgk=$sse06rfgk&5fy6dtg=$ss5fy6dtg&gfy5p6=$ssgfy5p6&ck86gb=$ssck86gb&p2494hdj=$ssp2494hdj&3h64ft=$ss3h64ft&hl29dvik=$sshl29dvik&84kftegro=$platform&k4xpf648=$ssk4xpf648&p2bx84bs=${app!.options.projectId}&I39489sn=$ssI39489sn&g236dt65=$ssg236dt65');
      }
      try {
        web.Response response =
            await web.get(url).timeout(Duration(seconds: 15));

        if (response.statusCode == 200) {
          String data = response.body;

          if (data != '') {
            if (data.toString().length == 4) {
              if (data == "7044" || data == "7001") {
                Utils.toast("Error:  $data");
                ssI39489sn = "c763g82gj8dmlp2";
                k7 = 's384tvrhd74fnacs3r92gt3urv';
                setState(() {
                  isinstalled = false;
                  iscircleprogressindicator = false;
                });
              } else {
                iscircleprogressindicator = false;

                setState(() {});

                showERRORSheet(this.context, data.toString());
              }
            } else {
              var jsonString = data;
              // ignore: unused_local_variable
              var decodeSucceeded = false;
              var jsonobject;
              try {
                jsonobject = json.decode(jsonString) as Map<String, dynamic>;
              } catch (e) {
                error1 = e.toString();
                showERRORSheet(this.context, "7110");
                isinstalled = false;
                print(e.toString());
                setState(() {});
              }
              if (error1 == "") {
                decodeSucceeded = true;
                isinstalled = true;
                id = jsonobject["446gpy5"];
                if (jsonobject.containsKey('7062')) {
                  //task manipualation will occur since sale is reversed
                  var jsonobject2;
                  Codec<String, String> stringToBase64 = utf8.fuse(base64);
                  try {
                    String loginToken = stringToBase64
                        .decode(jsonobject["i84l35jh"])
                        .toString();

                    jsonobject2 =
                        json.decode(loginToken) as Map<String, dynamic>;
                  } catch (e) {
                    error2 = e.toString();
                    showERRORSheet(this.context, "7114");
                    isinstalled = false;
                    print(e.toString());
                    setState(() {});
                  }
                  if (error2 == "") {
                    await FirebaseFirestore.instance
                        .collection(jsonobject2["k252b9j"])
                        .doc(jsonobject2["jwy72hg9"])
                        .set(jsonobject2, SetOptions(merge: true))
                        .then((c) {
                      setState(() {
                        isinstalled = false;
                      });
                      // initialise();
                      showERRORSheet(this.context, "7062");
                    }).catchError((e) {
                      error5 = e.toString();
                      showERRORSheet(this.context, "7118");
                      isinstalled = false;
                      print(e.toString());
                      setState(() {});
                    });
                  }
                } else {
                  if (jsonobject["x8465jf"] != "") {
                    var jsonobject2;
                    Codec<String, String> stringToBase64 = utf8.fuse(base64);
                    try {
                      String loginToken2 = stringToBase64
                          .decode(jsonobject["x8465jf"])
                          .toString();

                      jsonobject2 =
                          json.decode(loginToken2.replaceAll("__", ""))
                              as Map<String, dynamic>;
                    } catch (e) {
                      error3 = e.toString();
                      showERRORSheet(this.context, "7115");
                      isinstalled = false;
                      print(e.toString());
                      setState(() {});
                    }
                    if (error3 == "") {
                      List<dynamic> keylist =
                          jsonobject2["collections"].keys.toList();
                      List<dynamic> valuelist =
                          jsonobject2["collections"].values.toList();

                      if (keylist.length == valuelist.length &&
                          valuelist.length != 0) {
                        try {
                          for (String collectionID in keylist) {
                            int index = keylist.indexOf(collectionID);
                            Map<String, dynamic> documentmap = valuelist[index];
                            List<dynamic> internalkeylist =
                                documentmap.keys.toList();
                            List<dynamic> internalvaluelist =
                                documentmap.values.toList();

                            for (String internaldocumentID in internalkeylist) {
                              int internalindex =
                                  internalkeylist.indexOf(internaldocumentID);
                              Map<String, dynamic> internaldocumentmap =
                                  internalvaluelist[internalindex];

                              if (k7 == "s384tvrhd74fnacs3r92gt3urv" &&
                                  isDocHave == false) {
                                await FirebaseFirestore.instance
                                    .collection(collectionID)
                                    .doc(internaldocumentID)
                                    .set(internaldocumentmap,
                                        SetOptions(merge: false))
                                    .onError((e, s) {
                                  throw new Exception();
                                });
                              } else {
                                await FirebaseFirestore.instance
                                    .collection(collectionID)
                                    .doc(internaldocumentID)
                                    .get()
                                    .then((doc) async {
                                  if (doc.exists) {
                                    Map<String, dynamic>?
                                        internaldocumentmapFromFirestore =
                                        doc.data();
                                    internaldocumentmap
                                        .forEach((key, value) async {
                                      internaldocumentmapFromFirestore!
                                          .putIfAbsent(key, () => value);
                                    });

                                    await FirebaseFirestore.instance
                                        .collection(collectionID)
                                        .doc(internaldocumentID)
                                        .set(internaldocumentmapFromFirestore!,
                                            SetOptions(merge: true))
                                        .onError((e, s) {
                                      throw new Exception();
                                    });
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection(collectionID)
                                        .doc(internaldocumentID)
                                        .set(internaldocumentmap,
                                            SetOptions(merge: true))
                                        .onError((e, s) {
                                      throw new Exception();
                                    });
                                  }
                                }).onError((e, s) {
                                  throw new Exception();
                                });
                              }
                            }
                          }
                        } catch (e) {
                          if (e.toString().contains("permission") ||
                              e.toString().contains("missing") ||
                              e.toString().contains("denied") ||
                              e.toString().contains("permissions") ||
                              e.toString().contains("insufficient")) {
                            this.isSecuritySetupPending = true;
                            securityRuleName =
                                "SECURITY RULES TEST ENVIRONMENT";

                            error8 = e.toString();
                            iscircleprogressindicator = false;
                            isinstalled = false;
                            setState(() {});
                          } else {
                            setState(() {
                              error8 = e.toString();
                              iscircleprogressindicator = false;
                              isinstalled = false;
                            });
                            showERRORSheet(this.context, "7122");
                          }
                        }
                      }
                      if (error8 == "") {
                        if (jsonobject["i84l35jh"] == "") {
                          if (jsonobject.containsKey("x8465jf")) {
                            setState(() {
                              jsonobject["x8465jf"] = "em";
                            });
                          }

                          await batchwriteFirestoreData([
                            BatchWriteComponent(
                                    ref: FirebaseFirestore.instance
                                        .collection(jsonobject["k252b9j"])
                                        .doc(jsonobject["jwy72hg9"]),
                                    map: jsonobject)
                                .toMap(),
                            BatchWriteComponent(
                              ref: FirebaseFirestore.instance
                                  .collection(jsonobject["k252b9j"])
                                  .doc(jsonobject["jwy72hg9"]),
                              map: {
                                Dbkeys.lastupdatedepoch:
                                    DateTime.now().millisecondsSinceEpoch
                              },
                            ).toMap(),
                            // BatchWriteComponent(ref: ref, map: map).toMap(),
                          ]).then((value) {
                            if (value == true) {
                              initialise();
                            } else {
                              showERRORSheet(this.context, "7110");
                              isinstalled = false;
                              setState(() {});
                            }
                          });
                        } else {
                          if (jsonobject.containsKey("x8465jf")) {
                            setState(() {
                              jsonobject["x8465jf"] = "nem";
                            });
                          }

                          await batchwriteFirestoreData([
                            BatchWriteComponent(
                                    ref: FirebaseFirestore.instance
                                        .collection(jsonobject["k252b9j"])
                                        .doc(jsonobject["jwy72hg9"]),
                                    map: jsonobject)
                                .toMap(),
                            BatchWriteComponent(
                              ref: FirebaseFirestore.instance
                                  .collection(jsonobject["k252b9j"])
                                  .doc(jsonobject["jwy72hg9"]),
                              map: {
                                Dbkeys.lastupdatedepoch:
                                    DateTime.now().millisecondsSinceEpoch
                              },
                            ).toMap(),
                            // BatchWriteComponent(ref: ref, map: map).toMap(),
                          ]).then((value) {
                            if (value == true) {
                              initialise();
                            } else {
                              showERRORSheet(this.context, "7117");
                              isinstalled = false;
                              setState(() {});
                            }
                          });
                          var jsonobject2;
                          try {
                            String loginToken = stringToBase64
                                .decode(jsonobject["i84l35jh"])
                                .toString();

                            jsonobject2 =
                                json.decode(loginToken) as Map<String, dynamic>;
                          } catch (e) {
                            error4 = e.toString();
                            showERRORSheet(this.context, "7116");
                            isinstalled = false;
                            print(e.toString());
                            setState(() {});
                          }
                          if (error4 == "") {
                            await FirebaseFirestore.instance
                                .collection(jsonobject2["k252b9j"])
                                .doc(jsonobject2["jwy72hg9"])
                                .set(jsonobject2, SetOptions(merge: true))
                                .then((value) {
                              initialise();
                            }).catchError((e) {
                              showERRORSheet(this.context, "7119");
                              isinstalled = false;
                              print(e.toString());
                              setState(() {});
                            });
                          }
                        }
                      }
                    }
                  } else {
                    await batchwriteFirestoreData([
                      BatchWriteComponent(
                              ref: FirebaseFirestore.instance
                                  .collection(jsonobject["k252b9j"])
                                  .doc(jsonobject["jwy72hg9"]),
                              map: jsonobject)
                          .toMap(),
                      BatchWriteComponent(
                          ref: FirebaseFirestore.instance
                              .collection(jsonobject["k252b9j"])
                              .doc(jsonobject["jwy72hg9"]),
                          map: {
                            Dbkeys.lastupdatedepoch:
                                DateTime.now().millisecondsSinceEpoch,
                            'I39489sn': 'dbdjbd'
                          }).toMap(),
                    ]).then((value) {
                      if (value == true) {
                        initialise();
                      } else {
                        showERRORSheet(this.context, "7110");
                        isinstalled = false;
                        setState(() {});
                      }
                    });
                  }
                  // }
                }
              }
            }
            setState(() {
              iscircleprogressindicator = false;
            });
          } else {
            setState(() {
              iscircleprogressindicator = false;
            });
            showERRORSheet(this.context, "7108");
          }

          return data;
        } else {
          showERRORSheet(this.context, "7111");
          setState(() {
            iscircleprogressindicator = false;
          });
          return 'failed';
        }
      } catch (e) {
        if (e.toString().contains("permission") ||
            e.toString().contains("missing") ||
            e.toString().contains("permissions") ||
            e.toString().contains("insufficient")) {
          this.isSecuritySetupPending = true;
          securityRuleName = "SECURITY RULES TEST ENVIRONMENT";
          setState(() {});
        } else {
          showERRORSheet(this.context, "7039", message: e.toString());
          setState(() {
            isinstalled = false;
            iscircleprogressindicator = false;
          });
          return 'failed';
        }
      }
    }).catchError((e) {
      setState(() {
        this.isSecuritySetupPending = true;
        securityRuleName = "SECURITY RULES TEST ENVIRONMENT";
        isinstalled = false;
        iscircleprogressindicator = false;
      });
    });
  }

  final _controller = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  String project = "";
  String k1 = '';
  String k2 = '';
  String k3 = '';
  String k4 = '';
  String k5 = '';
  String k6 = '';
  String k7 = '';
  // ignore: unused_field
  String _code = '';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return isappundermaintainance == true
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    height: 6,
                  ),
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.orange[400],
                    size: 80,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Under Maintenance",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        height: 1.4, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    maintaincemssg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        height: 1.2, fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        : isSecuritySetupPending == true
            ? Scaffold(
                backgroundColor: Colors.white,
                body: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topRight,
                        height: 6,
                      ),
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.pink[400],
                        size: 80,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Firebase Security Rules Pending Setup",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.4,
                            fontSize: 17,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        "Firebase Security Rules are currently not as required for this task. Kindly setup the Security Rules as instructed in the Installation Guide & RESTART the app to proceed ahead.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.2,
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Text(
                        "Rules Required in Firestore :",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.2,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        securityRuleName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.2,
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Kindly copy the security rules code provided along with source code and paste it in your:  Firebase Dashboard -> Firestore Database -> Rules",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.2,
                            color: Mycolors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              )
            : isprocessing == true
                ? Splashscreen()
                : isready == false
                    ? iscircleprogressindicator == true
                        ? Scaffold(
                            backgroundColor: mycolor,
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Scaffold(
                            backgroundColor: mycolor,
                            body: Center(
                              child: ListView(
                                padding: const EdgeInsets.all(20),
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        20, h / 15, 20, h / 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Welcome to $project Installation Desk',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 30,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          InitializationConstant.k13,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'VERSION :  v$k4',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(15, 17, 15, 15),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: isinstalled == true
                                            ? [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.green,
                                                  size: 80,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Text(
                                                    'License validated & Installed Successfully',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 22,
                                                        color: Colors.black87),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 0,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'For the Project :',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12.5,
                                                        color: Colors
                                                            .blueGrey[600]),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 0,
                                                ),
                                                Text(
                                                  id == null
                                                      ? ''
                                                      : '${reverse(id)}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13.7,
                                                      color:
                                                          Colors.blueGrey[600]),
                                                ),
                                                SizedBox(
                                                  height: 21,
                                                ),
                                                ElevatedButton(
                                                  child: const Text(
                                                      'START USING APP'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          elevation: 0.0,
                                                          backgroundColor:
                                                              Colors.green),
                                                  onPressed: () {
                                                    Restart.restartApp();
                                                  },
                                                ),
                                              ]
                                            : k7 == "kj485bfud87jxh9824hdb"
                                                ? [
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      'Update Available',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16.7,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                    SizedBox(
                                                      height: 19,
                                                    ),
                                                    iscircleprogressindicator ==
                                                            true
                                                        ? const SizedBox()
                                                        : ElevatedButton(
                                                            child: const Text(
                                                                'INSTALL  UPDATE'),
                                                            style: ElevatedButton.styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green),
                                                            onPressed: () {
                                                              gett(
                                                                  "43hpr762g89ni89l",
                                                                  k6,
                                                                  "75gdrLprw764");
                                                            },
                                                          ),
                                                  ]
                                                : [
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      'Paste Purchase Code',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16.7,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    TextFormField(
                                                      controller: _controller,

                                                      decoration:
                                                          InputDecoration(
                                                        fillColor: Colors
                                                            .blueGrey
                                                            .withOpacity(0.06),
                                                        filled: true,
                                                        contentPadding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 5, 10, 4),
                                                        hintText:
                                                            'xxxxxx-xxx-xxxxx-xxx-xxx-xxxxxx-xx',
                                                        hintStyle: TextStyle(
                                                            color: Colors
                                                                .blueGrey
                                                                .withOpacity(
                                                                    0.2)),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: mycolor
                                                                  .withOpacity(
                                                                      0.5),
                                                              width: 1.4),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .blueGrey
                                                                  .withOpacity(
                                                                      0.2),
                                                              width: 1.4),
                                                        ),
                                                      ),
                                                      // use the validator to return an error string (or null) based on the input text
                                                      validator: (text) {
                                                        if (text == null ||
                                                            text.isEmpty) {
                                                          return 'Can\'t be empty';
                                                        }
                                                        if (text.length < 4) {
                                                          return 'Too short';
                                                        }
                                                        return null;
                                                      },

                                                      onChanged: (text) =>
                                                          setState(() => _code =
                                                              text.trimLeft()),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    iscircleprogressindicator ==
                                                            true
                                                        ? const SizedBox()
                                                        : ElevatedButton(
                                                            child: const Text(
                                                                'VALIDATE  &  INSTALL'),
                                                            style: ElevatedButton.styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green),
                                                            onPressed: () {
                                                              if (_controller
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  (_controller.text
                                                                              .trim()
                                                                              .length ==
                                                                          36 ||
                                                                      _controller
                                                                              .text
                                                                              .trim()
                                                                              .length ==
                                                                          23)) {
                                                                gett(
                                                                    _controller
                                                                        .text
                                                                        .trim(),
                                                                    k6,
                                                                    _controller.text.trim().length ==
                                                                            23
                                                                        ? "b204bn9qkw"
                                                                        : _controller.text.trim().length ==
                                                                                36
                                                                            ? "glp274vey4"
                                                                            : "743kgs63h");
                                                              } else {
                                                                if (iscircleprogressindicator ==
                                                                    false) {
                                                                } else {
                                                                  setState(() {
                                                                    iscircleprogressindicator =
                                                                        false;
                                                                  });
                                                                }
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'Kindly Paste the correct Purchase Code');
                                                              }
                                                            },
                                                          ),
                                                    SizedBox(height: 7),
                                                    iscircleprogressindicator ==
                                                            true
                                                        ? const SizedBox()
                                                        : ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                            ),
                                                            onPressed: () {
                                                              custom_url_launcher(
                                                                  "https://klientx.com/p/license-usage-rules");
                                                            },
                                                            child: Text(
                                                                "See License Usage rules",
                                                                style: TextStyle(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                            .blue[
                                                                        400]))),
                                                  ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //
                                  Text(
                                    'REGULAR License - 1 project\nEXTENDED License - 10 projects',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Colors.white70),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    'For any assistance OR Issue reporting, you can open a Support Ticket at www.klientx.com',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Colors.white30),
                                  ),
                                ],
                              ),
                            ),
                          )
                    : isemulator == true &&
                            serverappsettings!.isemulatorallowed == false
                        ? Scaffold(
                            backgroundColor: Colors.white,
                            body: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.topRight,
                                    height: 6,
                                  ),
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.pink[400],
                                    size: 80,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Emulator Not Allowed",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        height: 1.4,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    "Emulators are restricted by admin. Kindly use a real device.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        height: 1.2,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : widget.iscustomer == true
                            ? CustomerHome(
                                basicsettings: serverappsettings!,
                                prefs: widget.prefs,
                                currentUserID:
                                    widget.prefs.getString(Dbkeys.id),
                              )
                            : AgentHome(
                                basicsettings: serverappsettings!,
                                prefs: widget.prefs,
                                currentUserID:
                                    widget.prefs.getString(Dbkeys.id),
                              );
  }

  String reverse(String string) {
    if (string.length < 2) {
      return string;
    }

    final characters = Characters(string);
    return characters.toList().reversed.join();
  }
}
