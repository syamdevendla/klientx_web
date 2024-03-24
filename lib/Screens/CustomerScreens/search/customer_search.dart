//*************   © Copyrighted by aagama_it.

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/create_support_ticket.dart';
import 'package:aagama_it/Utils/Setupdata.dart';
//import 'package:aagama_it/Services/Admob/admob.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Localization/language.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/DataModel.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/main.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/late_load.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:aagama_it/Configs/optional_constants.dart';

class CustomerSearch extends StatefulWidget {
  CustomerSearch(
      {required this.currentUserID,
      required this.isSecuritySetupDone,
      required this.prefs,
      required this.fullname,
      required this.photourl,
      required this.phonevariants,
      key})
      : super(key: key);
  final String? currentUserID;
  final String fullname;
  final String photourl;
  final List phonevariants;
  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  @override
  State createState() => new CustomerSearchState();
}

class CustomerSearchState extends State<CustomerSearch>
    with TickerProviderStateMixin {
  bool isAuthenticating = false;
  bool isVisible = true;
  late List<dynamic> _orgList;
  late List<dynamic> filteredOrgList;
  static List<String> _fruitOptions = [];
  var _selectedOrg;
  TextEditingController selectedorgcontroller = new TextEditingController();
  List<StreamSubscription> unreadSubscriptions = [];
  List<StreamController> controllers = [];
  // final BannerAd myBanner = BannerAd(
  //   adUnitId: getBannerAdUnitId()!,
  //   size: AdSize.banner,
  //   request: AdRequest(),
  //   listener: BannerAdListener(),
  // );
  //AdWidget? adWidget;
  var adWidget = null;

  @override
  void initState() {
    super.initState();

    getModel();
    Utils.internetLookUp();
    loadAndListenTickets();
    loadAndListenOrgs();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        // myBanner.load();
        // adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  // ignore: cancel_subscriptions
  StreamSubscription? _ticketsSubscription;
  bool isloading = true;
  List<dynamic> ticketDocList = [];
  loadAndListenTickets() async {
    print("syam prints  customer_search - loadAndListenTickets");
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .where(Dbkeys.ticketcustomerID, isEqualTo: widget.currentUserID)
        .orderBy(Dbkeys.ticketlatestTimestampForCustomer, descending: true)
        .get()
        .then((tickets) {
      if (tickets.docs.isNotEmpty) {
        print('FOUND DOCS ${tickets.docs.length}');
        tickets.docs.forEach((ticket) {
          // var t = TicketModel.fromSnapshot(ticket);
          ticketDocList.add(ticket);
        });

        setStateIfMounted(() {
          isloading = false;
          // print('All message loaded..........');
        });
      } else {
        setStateIfMounted(() {
          isloading = false;
          // print('All message loaded..........');
        });
      }
      if (mounted) {
        setStateIfMounted(() {
          ticketDocList = List.from(ticketDocList);
        });
      }
      _ticketsSubscription = FirebaseFirestore.instance
          .collection(DbPaths.collectiontickets)
          .where(Dbkeys.ticketcustomerID, isEqualTo: widget.currentUserID)
          .orderBy(Dbkeys.ticketlatestTimestampForCustomer, descending: true)
          .snapshots()
          .listen((query) {
        if (query.docs.length > 1
            ? query.docs.length != query.docChanges.length
            : 1 == 1) {
          //----below action triggers when peer new message arrives
          query.docChanges.where((doc) {
            return doc.oldIndex <= doc.newIndex &&
                doc.type == DocumentChangeType.added;
          }).forEach((change) {
            var addedticket = change.doc;
            int i = ticketDocList.indexWhere((element) =>
                element[Dbkeys.ticketID] == addedticket[Dbkeys.ticketID]);
            if (i >= 0) {
              ticketDocList.removeAt(i);
              ticketDocList.insert(i, addedticket);
            } else {
              ticketDocList.insert(0, addedticket);
            }

            setStateIfMounted(() {});
          });
          //----below action triggers when peer message get deleted
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.removed;
          }).forEach((change) {
            var removedticket = change.doc;
            int i = ticketDocList.indexWhere((element) =>
                element[Dbkeys.ticketID] == removedticket[Dbkeys.ticketID]);
            if (i >= 0) {
              ticketDocList.removeAt(i);
              setStateIfMounted(() {});
            }
          }); //----below action triggers when peer message gets modified
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.modified;
          }).forEach((change) {
            var updatedticket = change.doc;
            int i = ticketDocList.indexWhere((element) =>
                element[Dbkeys.ticketID] == updatedticket[Dbkeys.ticketID]);
            if (i >= 0) {
              ticketDocList.removeAt(i);
              ticketDocList.insert(i, updatedticket);
            } else {
              ticketDocList.insert(0, updatedticket);
            }

            setStateIfMounted(() {});
          });
          if (mounted) {
            setStateIfMounted(() {
              ticketDocList = List.from(ticketDocList);
            });
          }
        }
      });
    });
  }

  loadAndListenOrgs() async {
    _fruitOptions = [];
    await FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((orgs) async {
      if (orgs.docs.length != 0) {
        this._orgList = orgs.docs.toList();
        this.filteredOrgList = orgs.docs.toList();
        orgs.docs.forEach(
          (element) {
            // print(element.data());
            _fruitOptions.add(element.data()['orgName']);
          },
        );
      }
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  bool isLoading = false;

  DataModel? getModel() {
    _cachedModel ??=
        DataModel(widget.currentUserID, DbPaths.collectioncustomers);
    return _cachedModel;
  }

  @override
  void dispose() {
    super.dispose();
    _ticketsSubscription!.cancel();

    if (IsBannerAdShow == true) {
      //myBanner.dispose();
    }
  }

  String selectedOrg = '';
  bool showOrgDetails = false;
  var orgDetails;
  // ignore: unused_element
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocaleForUsers(language.languageCode);
    AppWrapper.setLocale(this.context, _locale);
    if (widget.currentUserID != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        FirebaseFirestore.instance
            .collection(DbPaths.collectioncustomers)
            .doc(widget.currentUserID)
            .update({
          Dbkeys.notificationStringsMap:
              getTranslateNotificationStringsMap(this.context),
        });
      });
    }
    setState(() {
      // seletedlanguage = language;
    });

    await widget.prefs.setBool('islanguageselected', true);
  }

  setOrgData(id) {
    //print(id);
    FirebaseFirestore.instance
        .collection('organization')
        .doc(id)
        .get()
        .then((doc) async {
      // ShowLoading().close(
      //   context: this.context,
      //   key: _keyLoader,
      // );
      if (doc.exists) {
        setState(() {
          orgDetails = doc.data();
          selectedOrg = id;
          showOrgDetails = true;
        });
      }
    });
  }

  setOrgDataAuto(orgName) {
    _orgList!.forEach(
      (element) {
        if (element.data()['orgName'] == orgName) {
          setOrgData(element.id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: true);
    final registry = Provider.of<UserRegistry>(this.context, listen: true);
    var w = MediaQuery.of(this.context).size.width;
    var h = MediaQuery.of(this.context).size.height;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.whiteDynamic, //or set color with: Color(0xFF0000FF)
    ));
    return Utils.getNTPWrappedWidget(ScopedModel<DataModel>(
      model: getModel()!,
      child:
          ScopedModelDescendant<DataModel>(builder: (context, child, _model) {
        _cachedModel = _model;
        return DefaultTabController(
          length: 2,
          child: isloading == true || observer.userAppSettingsDoc == null
              ? Scaffold(
                  backgroundColor: Mycolors.whiteDynamic,
                  body: Center(
                    child: circularProgress(),
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    elevation: 0.4,
                    backgroundColor: Mycolors.whiteDynamic,
                    title: MtCustomfontBold(
                      text: getTranslatedForCurrentUser(
                          this.context, 'xxxsearchxxx'),
                      color: Mycolors.blackDynamic,
                      textalign: TextAlign.center,
                      fontsize: 18,
                    ),
                    centerTitle: true,
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        15,
                        10,
                        10,
                        10,
                      ),
                    ),
                    titleSpacing: -1,
                    actions: isloading == false ? [] : [],
                  ),
                  bottomSheet: IsBannerAdShow == true &&
                          observer.isadmobshow == true &&
                          adWidget != null
                      ? Container(
                          height: 60,
                          margin: EdgeInsets.only(
                              bottom: Platform.isIOS == true ? 25.0 : 5,
                              top: 0),
                          child: Center(child: adWidget),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  backgroundColor: Mycolors.backgroundcolor,
                  body:
                      // ticketDocList.length == 0
                      //     ? lateLoad(
                      //         timeinseconds: 1,
                      //         placeholder: circularProgress(),
                      //         actualwidget: Column(
                      //           mainAxisAlignment: MainAxisAlignment.end,
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             SizedBox(
                      //               height: observer.userAppSettingsDoc!
                      //                           .customerCanCreateTicket ==
                      //                       true
                      //                   ? 60
                      //                   : h / 6,
                      //             ),
                      //             noDataWidget(
                      //               context: this.context,
                      //               iconData: LineAwesomeIcons.alternate_ticket,
                      //               subtitle: observer.userAppSettingsDoc!
                      //                           .customerCanCreateTicket ==
                      //                       true
                      //                   ? getTranslatedForCurrentUser(this.context,
                      //                           'xxnoticketcustomerxx')
                      //                       .replaceAll(
                      //                           '(#####)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxsupporttktxx'))
                      //                       .replaceAll(
                      //                           '(####)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxsupporttktxx'))
                      //                       .replaceAll(
                      //                           '(###)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxagentsxx'))
                      //                       .replaceAll(
                      //                           '(##)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxagentxx'))
                      //                       .replaceAll(
                      //                           '(#)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxsupporttktxx'))
                      //                   : getTranslatedForCurrentUser(this.context,
                      //                           'xxnoticketcustomerforyouxx')
                      //                       .replaceAll(
                      //                           '(#####)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxsupporttktxx'))
                      //                       .replaceAll(
                      //                           '(####)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxagentsxx'))
                      //                       .replaceAll(
                      //                           '(###)',
                      //                           getTranslatedForCurrentUser(
                      //                               this.context, 'xxsupporttktxx')),
                      //               title: getTranslatedForCurrentUser(
                      //                   this.context, 'xxnosupporttktxx'),
                      //             ),
                      //             SizedBox(
                      //               height: 10,
                      //             ),
                      //             observer.userAppSettingsDoc!
                      //                             .customerCanCreateTicket ==
                      //                         true &&
                      //                     observer.departmentlistlive.length > 0
                      //                 ? Padding(
                      //                     padding: EdgeInsets.fromLTRB(
                      //                         w / 8, 2, w / 8, 2),
                      //                     child: MySimpleButtonWithIcon(
                      //                       onpressed: () {
                      //                         showTicketOptions(
                      //                             context: this.context);
                      //                       },
                      //                       iconData: Icons.add,
                      //                       buttoncolor: Mycolors.getColor(
                      //                           widget.prefs,
                      //                           Colortype.secondary.index),
                      //                       buttontext: getTranslatedForCurrentUser(
                      //                               this.context, 'xxcreatexx')
                      //                           .replaceAll(
                      //                               '(####)',
                      //                               getTranslatedForCurrentUser(
                      //                                   this.context,
                      //                                   'xxsupporttktxx')),
                      //                     ),
                      //                   )
                      //                 : SizedBox()
                      //           ],
                      //         ))
                      //     :

                      // Column(children: [

                      //     InputDecorator(

                      //       decoration: InputDecoration(
                      //           border: OutlineInputBorder(),
                      //           contentPadding: EdgeInsets.symmetric(
                      //               vertical:
                      //                   10), //Change this value to custom as you like
                      //           isDense: true, // and add this line
                      //           hintText: "Organization Search..",
                      //           hintStyle: TextStyle(
                      //             color: Color(0xFFF00),
                      //           )),
                      //       child: Autocomplete(
                      //         optionsBuilder:
                      //             (TextEditingValue textEditingValue) {
                      //           if (textEditingValue.text == '') {
                      //             return const Iterable<String>.empty();
                      //           }
                      //           return _fruitOptions.where((String option) {
                      //             return (option.toLowerCase()).contains(
                      //                 textEditingValue.text.toLowerCase());
                      //           });
                      //         },
                      //         onSelected: (selection) {
                      //           setOrgDataAuto(selection);
                      //         },
                      //         //),
                      //       ),
                      //     ),
                      //   ]),
                      Column(
                    children: [
                      Container(
                        //height: MediaQuery.of(context).size.height * .35,
                        padding: const EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        child: Column(children: [
                          InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical:
                                        10), //Change this value to custom as you like
                                isDense: true, // and add this line
                                hintText: "Organization Search..",
                                hintStyle: TextStyle(
                                  color: Color(0xFFF00),
                                )),
                            child: Autocomplete(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<String>.empty();
                                }
                                return _fruitOptions.where((String option) {
                                  return (option.toLowerCase()).contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (selection) {
                                setOrgDataAuto(selection);
                              },
                              //),
                            ),
                          ),
                        ]),
                      ),
                      if (showOrgDetails == true)
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 40, right: 14, left: 14),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(orgDetails['orgName']),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(orgDetails['orgEmail']),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Text(orgDetails['orgaddress1']),
                                      const SizedBox(height: 15),
                                      Text(orgDetails['orgaddress2']),
                                      const SizedBox(height: 15),
                                      Text(orgDetails['orgcontactpersonemail']),
                                      const SizedBox(height: 15),
                                      Text(
                                          orgDetails['orgcontactpersonmobile']),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 110,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 1,
                                          itemBuilder: (context, index) =>
                                              Container(
                                            margin:
                                                const EdgeInsets.only(right: 6),
                                            width: 110,
                                            height: 110,
                                            decoration: BoxDecoration(
                                              color: Mycolors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Image.network(
                                                  orgDetails['orgphotourl'],
                                                  fit: BoxFit.fill,
                                                  width: Get.width),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                    // Container(
                    //     padding: EdgeInsets.all(10),
                    //     child: Column(
                    //       children: <Widget>[
                    //         TextField(
                    //           decoration: InputDecoration(
                    //             suffixIcon: Icon(Icons.search),
                    //             labelText: 'Search Org',
                    //           ),
                    //           controller: selectedorgcontroller,
                    //           onChanged: (value) {
                    //             setState(() {
                    //               isVisible = true;
                    //               filteredOrgList = _orgList
                    //                   .where((org) => org['orgName']!
                    //                       .toLowerCase()
                    //                       .contains(value.toLowerCase()))
                    //                   .toList();
                    //             });
                    //           },
                    //         ),
                    //         SizedBox(height: 20),
                    //         (isVisible)
                    //             ? Expanded(
                    //                 child: ListView.builder(
                    //                   shrinkWrap: true,
                    //                   itemCount: filteredOrgList.length,
                    //                   itemBuilder: (ctx, index) => Column(
                    //                     children: <Widget>[
                    //                       ListTile(
                    //                         title: Text(
                    //                           filteredOrgList[index]
                    //                               ['orgName']!,
                    //                           style: TextStyle(
                    //                               fontWeight:
                    //                                   FontWeight.w700),
                    //                         ),
                    //                         onTap: () {
                    //                           _selectedOrg =
                    //                               filteredOrgList[index];
                    //                           selectedorgcontroller.text =
                    //                               filteredOrgList[index]
                    //                                   ['orgName']!;
                    //                           isVisible = false;
                    //                         },
                    //                       ),
                    //                       Divider(thickness: 1),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               )
                    //             : SizedBox(height: 20),
                    //       ],
                    //     ),
                    //   )
                    // : ListView.builder(
                    //     // shrinkWrap: true,
                    //     physics: BouncingScrollPhysics(),
                    //     itemCount: ticketDocList.reversed.toList().length,
                    //     itemBuilder: (BuildContext context, int i) {
                    //       print(ticketDocList.length);

                    //       return ticketWidgetForCustomers(
                    //           customerCanAgentOnline: observer
                    //               .userAppSettingsDoc!.showIsAgentOnline!,
                    //           currentUserID: widget.currentUserID!,
                    //           ticketdoc: ticketDocList[i],
                    //           context: this.context,
                    //           ontap: (ticketid, customerUID) {
                    //             pageNavigator(
                    //                 this.context,
                    //                 TicketChatRoom(
                    //                   agentsListinParticularDepartment: observer
                    //                               .userAppSettingsDoc!
                    //                               .departmentBasedContent ==
                    //                           true
                    //                       ? observer.userAppSettingsDoc!.departmentList!
                    //                                   .where((element) =>
                    //                                       element[Dbkeys.departmentTitle] ==
                    //                                       ticketDocList[i][Dbkeys
                    //                                           .ticketDepartmentID])
                    //                                   .toList()
                    //                                   .length >
                    //                               0
                    //                           ? observer.userAppSettingsDoc!
                    //                               .departmentList!
                    //                               .where((element) =>
                    //                                   element[Dbkeys.departmentTitle] ==
                    //                                   ticketDocList[i][Dbkeys.ticketDepartmentID])
                    //                               .toList()[0][Dbkeys.departmentAgentsUIDList]
                    //                           : []
                    //                       : [],
                    //                   ticketTitle: ticketDocList[i]
                    //                       [Dbkeys.ticketTitle],
                    //                   cuurentUserCanSeeAgentNamePhoto: iAmSecondAdmin(
                    //                           currentuserid:
                    //                               widget.currentUserID!,
                    //                           context: context)
                    //                       ? observer.userAppSettingsDoc!
                    //                           .secondadmincanseeagentnameandphoto!
                    //                       : iAmDepartmentManager(
                    //                               currentuserid:
                    //                                   widget.currentUserID!,
                    //                               context: context)
                    //                           ? observer.userAppSettingsDoc!
                    //                               .departmentmanagercanseeagentnameandphoto!
                    //                           : customerUID ==
                    //                                   widget.currentUserID
                    //                               ? observer
                    //                                   .userAppSettingsDoc!
                    //                                   .customercanseeagentnameandphoto!
                    //                               : observer
                    //                                   .userAppSettingsDoc!
                    //                                   .agentcanseeagentnameandphoto!,
                    //                   cuurentUserCanSeeCustomerNamePhoto: iAmSecondAdmin(
                    //                           currentuserid:
                    //                               widget.currentUserID!,
                    //                           context: context)
                    //                       ? observer.userAppSettingsDoc!
                    //                           .secondadmincanseecustomernameandphoto!
                    //                       : iAmDepartmentManager(
                    //                               currentuserid:
                    //                                   widget.currentUserID!,
                    //                               context: context)
                    //                           ? observer.userAppSettingsDoc!
                    //                               .departmentmanagercanseecustomernameandphoto!
                    //                           : observer.userAppSettingsDoc!
                    //                               .agentcanseecustomernameandphoto!,
                    //                   currentuserfullname: registry
                    //                       .getUserData(this.context,
                    //                           widget.currentUserID!)
                    //                       .fullname,
                    //                   customerUID: customerUID,
                    //                   currentUserID: widget.currentUserID!,
                    //                   isSharingIntentForwarded: false,
                    //                   ticketID: ticketid,
                    //                   prefs: widget.prefs,
                    //                   model: _cachedModel!,
                    //                 ));
                    //           },
                    //           prefs: widget.prefs,
                    //           ticket:
                    //               TicketModel.fromSnapshot(ticketDocList[i]));
                    //     }),
                  )),
        );
      }),
    ));
  }

  showTicketOptions({
    required BuildContext context,
  }) {
    showModalBottomSheet(
        context: this.context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          final observer = Provider.of<Observer>(this.context, listen: false);
          // return your layout
          return Container(
              padding: EdgeInsets.all(12),
              height: 100,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ListTile(
                      onTap: observer.checkIfCurrentUserIsDemo(
                                  widget.currentUserID!) ==
                              true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  this.context, 'xxxnotalwddemoxxaccountxx'));
                            }
                          : () {
                              Navigator.of(this.context).pop();

                              pageNavigator(
                                  this.context,
                                  CreateSupportTicket(
                                    prefs: widget.prefs,
                                    currentUserID: widget.currentUserID!,
                                    customerUID: widget.currentUserID!,
                                  ));
                            },
                      title: MtCustomfontBoldSemi(
                        text: getTranslatedForCurrentUser(
                                this.context, 'xxxxnewxx')
                            .replaceAll(
                                '(####)',
                                getTranslatedForCurrentUser(
                                    this.context, 'xxsupporttktxx')),
                        fontsize: 16,
                      ),
                      leading: Icon(
                        EvaIcons.plusCircleOutline,
                        size: 30,
                        color: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                      ),
                    ),
                  ]));
        });
  }
}
