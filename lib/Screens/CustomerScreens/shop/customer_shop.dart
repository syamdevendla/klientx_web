//*************   © Copyrighted by aagama_it.

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Models/ticket_model.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/create_support_ticket.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/ticket_chat_room.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:aagama_it/Utils/Setupdata.dart';
//import 'package:aagama_it/Services/Admob/admob.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Localization/language.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/callhistory.dart';
import 'package:aagama_it/Models/DataModel.dart';
import 'package:aagama_it/Utils/getRolePermission.dart';
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

class CustomerShop extends StatefulWidget {
  CustomerShop(
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
  State createState() => new CustomerShopState();
}

class CustomerShopState extends State<CustomerShop>
    with TickerProviderStateMixin {
  bool isAuthenticating = false;

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
  List<dynamic> ticketDocOrgList = [];
  loadAndListenTickets() async {
    print("syam prints  customer_shop - loadAndListenTickets");
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .where(Dbkeys.ticketcustomerID, isEqualTo: widget.currentUserID)
        .orderBy(Dbkeys.ticketlatestTimestampForCustomer, descending: true)
        .get()
        .then((tickets) {
      if (tickets.docs.isNotEmpty) {
        print('FOUND DOCS ${tickets.docs.length}');
        tickets.docs.forEach((ticket) async {
          // var orgId = ticket.data()['toi'];

          // await FirebaseFirestore.instance
          //     .collection('organization')
          //     .doc(orgId)
          //     .get()
          //     .then((orgData) {
          //   ticketDocOrgList.add(orgData);
          // });
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
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.4,
              backgroundColor: Mycolors.whiteDynamic,
              title: MtCustomfontBold(
                text: getTranslatedForCurrentUser(this.context, 'xxshopxx'),
                color: Mycolors.blackDynamic,
                textalign: TextAlign.center,
                fontsize: 18,
              ),
              centerTitle: true,
              titleSpacing: -1,
              actions: isloading == false ? [] : [],
            ),
            bottomSheet: IsBannerAdShow == true &&
                    observer.isadmobshow == true &&
                    adWidget != null
                ? Container(
                    height: 60,
                    margin: EdgeInsets.only(
                        bottom: Platform.isIOS == true ? 25.0 : 5, top: 0),
                    child: Center(child: adWidget),
                  )
                : SizedBox(
                    height: 0,
                  ),
            backgroundColor: Mycolors.backgroundcolor,
            body: ticketDocList.length == 0
                ? lateLoad(
                    timeinseconds: 1,
                    placeholder: circularProgress(),
                    actualwidget: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: observer.userAppSettingsDoc!
                                      .customerCanCreateTicket ==
                                  true
                              ? 60
                              : h / 6,
                        ),
                        noDataWidget(
                          context: this.context,
                          iconData: LineAwesomeIcons.alternate_ticket,
                          subtitle: observer.userAppSettingsDoc!.customerCanCreateTicket == true
                              ? getTranslatedForCurrentUser(
                                      this.context, 'xxnoticketcustomerxx')
                                  .replaceAll(
                                      '(#####)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxsupporttktxx'))
                                  .replaceAll(
                                      '(####)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxsupporttktxx'))
                                  .replaceAll(
                                      '(###)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxagentsxx'))
                                  .replaceAll(
                                      '(##)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxagentxx'))
                                  .replaceAll(
                                      '(#)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxsupporttktxx'))
                              : getTranslatedForCurrentUser(this.context, 'xxnoticketcustomerforyouxx')
                                  .replaceAll(
                                      '(#####)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxsupporttktxx'))
                                  .replaceAll(
                                      '(####)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxagentsxx'))
                                  .replaceAll(
                                      '(###)',
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxsupporttktxx')),
                          title: getTranslatedForCurrentUser(
                              this.context, 'xxnosupporttktxx'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        observer.userAppSettingsDoc!.customerCanCreateTicket ==
                                    true &&
                                observer.departmentlistlive.length > 0
                            ? Padding(
                                padding:
                                    EdgeInsets.fromLTRB(w / 8, 2, w / 8, 2),
                                child: MySimpleButtonWithIcon(
                                  onpressed: () {
                                    showTicketOptions(context: this.context);
                                  },
                                  iconData: Icons.add,
                                  buttoncolor: Mycolors.getColor(
                                      widget.prefs, Colortype.secondary.index),
                                  buttontext: getTranslatedForCurrentUser(
                                          this.context, 'xxcreatexx')
                                      .replaceAll(
                                          '(####)',
                                          getTranslatedForCurrentUser(
                                              this.context, 'xxsupporttktxx')),
                                ),
                              )
                            : SizedBox()
                      ],
                    ))
                : ListView.builder(
                    // shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: ticketDocList.reversed.toList().length,
                    itemBuilder: (BuildContext context, int i) {
                      print(ticketDocList.length);

                      return ticketWidgetForCustomers(
                          customerCanAgentOnline:
                              observer.userAppSettingsDoc!.showIsAgentOnline!,
                          currentUserID: widget.currentUserID!,
                          ticketdoc: ticketDocList[i],
                          //orgdoc: ticketDocOrgList[i],
                          context: this.context,
                          ontap: (ticketid, customerUID) {
                            pageNavigator(
                                this.context,
                                TicketChatRoom(
                                  agentsListinParticularDepartment: observer
                                              .userAppSettingsDoc!
                                              .departmentBasedContent ==
                                          true
                                      ? observer.userAppSettingsDoc!.departmentList!
                                                  .where((element) =>
                                                      element[Dbkeys.departmentTitle] ==
                                                      ticketDocList[i][Dbkeys
                                                          .ticketDepartmentID])
                                                  .toList()
                                                  .length >
                                              0
                                          ? observer.userAppSettingsDoc!
                                              .departmentList!
                                              .where((element) =>
                                                  element[Dbkeys.departmentTitle] ==
                                                  ticketDocList[i]
                                                      [Dbkeys.ticketDepartmentID])
                                              .toList()[0][Dbkeys.departmentAgentsUIDList]
                                          : []
                                      : [],
                                  ticketTitle: ticketDocList[i]
                                      [Dbkeys.ticketTitle],
                                  cuurentUserCanSeeAgentNamePhoto: iAmSecondAdmin(
                                          currentuserid: widget.currentUserID!,
                                          context: context)
                                      ? observer.userAppSettingsDoc!
                                          .secondadmincanseeagentnameandphoto!
                                      : iAmDepartmentManager(
                                              currentuserid:
                                                  widget.currentUserID!,
                                              context: context)
                                          ? observer.userAppSettingsDoc!
                                              .departmentmanagercanseeagentnameandphoto!
                                          : customerUID == widget.currentUserID
                                              ? observer.userAppSettingsDoc!
                                                  .customercanseeagentnameandphoto!
                                              : observer.userAppSettingsDoc!
                                                  .agentcanseeagentnameandphoto!,
                                  cuurentUserCanSeeCustomerNamePhoto: iAmSecondAdmin(
                                          currentuserid: widget.currentUserID!,
                                          context: context)
                                      ? observer.userAppSettingsDoc!
                                          .secondadmincanseecustomernameandphoto!
                                      : iAmDepartmentManager(
                                              currentuserid:
                                                  widget.currentUserID!,
                                              context: context)
                                          ? observer.userAppSettingsDoc!
                                              .departmentmanagercanseecustomernameandphoto!
                                          : observer.userAppSettingsDoc!
                                              .agentcanseecustomernameandphoto!,
                                  currentuserfullname: registry
                                      .getUserData(
                                          this.context, widget.currentUserID!)
                                      .fullname,
                                  customerUID: customerUID,
                                  currentUserID: widget.currentUserID!,
                                  isSharingIntentForwarded: false,
                                  ticketID: ticketid,
                                  prefs: widget.prefs,
                                  model: _cachedModel!,
                                ));
                          },
                          prefs: widget.prefs,
                          ticket: TicketModel.fromSnapshot(ticketDocList[i]));
                    }),
          ),
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
