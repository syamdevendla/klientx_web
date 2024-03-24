//*************   © Copyrighted by aagama_it. 

import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Models/agent_model.dart';
import 'package:aagama_it/Models/customer_model.dart';
import 'package:aagama_it/Models/user_registry_model.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/callhistory.dart';
import 'package:aagama_it/Utils/Setupdata.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Localization/language.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/main.dart';
import 'package:aagama_it/widgets/CustomCards/customcards.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/late_load.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllUsers extends StatefulWidget {
  AllUsers(
      {required this.currentUserID,
      required this.isSecuritySetupDone,
      required this.prefs,
      required this.fullname,
      required this.isShowAgentstab,
      required this.isShowCustomerstab,
      required this.photourl,
      key})
      : super(key: key);
  final String? currentUserID;
  final String fullname;
  final bool isShowAgentstab;
  final bool isShowCustomerstab;
  final String photourl;

  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  @override
  State createState() => new AllUsersState();
}

class AllUsersState extends State<AllUsers> with TickerProviderStateMixin {
  bool isAuthenticating = false;

  List<StreamSubscription> unreadSubscriptions = [];
  List<StreamController> controllers = [];

  late TabController tabController;
  @override
  void initState() {
    super.initState();

    tabController = TabController(
      initialIndex: 0,
      length:
          widget.isShowAgentstab == true && widget.isShowCustomerstab == true
              ? 2
              : 1,
      vsync: this,
    );

    Utils.internetLookUp();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  bool isloading = true;
  List<dynamic> ticketDocList = [];

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  bool showHidden = false, biometricEnabled = false;

  bool isLoading = false;

  // ignore: unused_element
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocaleForUsers(language.languageCode);
    AppWrapper.setLocale(this.context, _locale);
    if (widget.currentUserID != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
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

  Widget buildAgentList(BuildContext context) {
    final registry = Provider.of<UserRegistry>(this.context, listen: true);
    return registry.agents.length == 0
        ? noDataWidget(
            context: this.context,
            title: getTranslatedForCurrentUser(
                    this.context, 'xxnoxxavailabletoaddxx')
                .replaceAll('(####)',
                    getTranslatedForCurrentUser(this.context, 'xxagentsxx')),
            subtitle: getTranslatedForCurrentUser(
                    this.context, 'xxnoxxjoinedyetxx')
                .replaceAll('(####)',
                    getTranslatedForCurrentUser(this.context, 'xxagentsxx')),
          )
        : ListView.builder(
            itemCount: registry.agents.length,
            itemBuilder: (BuildContext context, int i) {
              UserRegistryModel agent = registry.agents.reversed.toList()[i];
              return futureLoad(
                  future: FirebaseFirestore.instance
                      .collection(DbPaths.collectionagents)
                      .doc(agent.id)
                      .get(),
                  placeholder: RegistryUserCard(
                      usermodel: agent, currentuserid: widget.currentUserID!),
                  onfetchdone: (agentDoc) {
                    return AgentCard(
                        isswitchshow: false,
                        usermodel: AgentModel.fromJson(agentDoc),
                        currentuserid: widget.currentUserID!,
                        isProfileFetchedFromProvider: false);
                  });
            });
  }

  Widget buildCustomerList(BuildContext context) {
    final registry = Provider.of<UserRegistry>(this.context, listen: true);
    return registry.customer.length == 0
        ? noDataWidget(
            context: this.context,
            title: getTranslatedForCurrentUser(
                    this.context, 'xxnoxxavailabletoaddxx')
                .replaceAll('(####)',
                    getTranslatedForCurrentUser(this.context, 'xxcustomersxx')),
            subtitle: getTranslatedForCurrentUser(
                    this.context, 'xxnoxxjoinedyetxx')
                .replaceAll('(####)',
                    getTranslatedForCurrentUser(this.context, 'xxcustomersxx')))
        : ListView.builder(
            itemCount: registry.customer.length,
            itemBuilder: (BuildContext context, int i) {
              UserRegistryModel customer =
                  registry.customer.reversed.toList()[i];
              return futureLoad(
                  future: FirebaseFirestore.instance
                      .collection(DbPaths.collectioncustomers)
                      .doc(customer.id)
                      .get(),
                  placeholder: RegistryUserCard(
                      usermodel: customer,
                      currentuserid: widget.currentUserID!),
                  onfetchdone: (customerDoc) {
                    return CustomerCard(
                        isswitchshow: false,
                        usermodel: CustomerModel.fromJson(customerDoc),
                        currentuserid: widget.currentUserID!,
                        isProfileFetchedFromProvider: false);
                  });
            });
  }

  @override
  Widget build(BuildContext context) {
    final registry = Provider.of<UserRegistry>(this.context, listen: true);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.whiteDynamic, //or set color with: Color(0xFF0000FF)
    ));
    return Utils.getNTPWrappedWidget(DefaultTabController(
      length: 2,
      child: widget.isShowAgentstab == false &&
              widget.isShowCustomerstab == false
          ? MyScaffold(
              title: "Users",
              isforcehideback: true,
              body: noDataWidget(
                context: this.context,
                subtitle: getTranslatedForCurrentUser(
                        this.context, 'xxnoxxavailabletoaddxx')
                    .replaceAll(
                        '(####)',
                        getTranslatedForCurrentUser(
                                this.context, 'xxagentsxx') +
                            " / " +
                            getTranslatedForCurrentUser(
                                this.context, 'xxcustomersxx')),
                title: getTranslatedForCurrentUser(this.context, 'xxusersxx'),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                bottom: PreferredSize(
                    preferredSize: new Size(30.0, 50.0),
                    child: new Container(
                      width: MediaQuery.of(this.context).size.width / 1.0,
                      child: new TabBar(
                        controller: tabController,
                        indicatorWeight: 1.2,
                        unselectedLabelColor: Mycolors.grey,
                        labelColor: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        indicatorColor: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        tabs: widget.isShowAgentstab == true &&
                                widget.isShowCustomerstab == true
                            ? [
                                new Tab(
                                    icon: MtCustomfontBold(
                                  isNullColor: true,
                                  text: registry.agents.length == 0
                                      ? getTranslatedForCurrentUser(
                                          this.context, 'xxagentsxx')
                                      : '${registry.agents.length} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}',
                                  fontsize: 13,
                                  // color: Mycolors.getColor(
                                  //     widget.prefs, Colortype.primary.index),
                                )),
                                new Tab(
                                    icon: MtCustomfontBold(
                                  isNullColor: true,
                                  text: registry.customer.length == 0
                                      ? getTranslatedForCurrentUser(
                                          this.context, 'xxcustomersxx')
                                      : '${registry.customer.length} ${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}',
                                  fontsize: 13,
                                  // color: Mycolors.getColor(
                                  //     widget.prefs, Colortype.primary.index),
                                )),
                              ]
                            : [
                                widget.isShowAgentstab
                                    ? new Tab(
                                        icon: MtCustomfontBold(
                                        isNullColor: true,
                                        text: registry.agents.length == 0
                                            ? getTranslatedForCurrentUser(
                                                this.context, 'xxagentsxx')
                                            : '${registry.agents.length} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}',
                                        fontsize: 13,
                                        // color: Mycolors.getColor(
                                        //     widget.prefs, Colortype.primary.index),
                                      ))
                                    : new Tab(
                                        icon: MtCustomfontBold(
                                        isNullColor: true,
                                        text: registry.customer.length == 0
                                            ? getTranslatedForCurrentUser(
                                                this.context, 'xxcustomersxx')
                                            : '${registry.customer.length} ${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}',
                                        fontsize: 13,
                                        // color: Mycolors.getColor(
                                        //     widget.prefs, Colortype.primary.index),
                                      ))
                              ],
                      ),
                    )),
                elevation: 0.4,
                backgroundColor: Mycolors.whiteDynamic,
                title: MtCustomfontBold(
                  text: getTranslatedForCurrentUser(this.context, 'xxusersxx'),
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
                  child: customCircleAvatar(
                      url: widget.prefs.getString(Dbkeys.photoUrl) ??
                          'photo not found',
                      radius: 20),
                ),
                titleSpacing: -1,
                actions: <Widget>[],
              ),
              backgroundColor: Mycolors.backgroundcolor,
              body: TabBarView(
                  controller: tabController,
                  children: widget.isShowAgentstab == true &&
                          widget.isShowCustomerstab == true
                      ? [
                          buildAgentList(this.context),
                          buildCustomerList(this.context)
                        ]
                      : [
                          widget.isShowAgentstab == true
                              ? buildAgentList(this.context)
                              : buildCustomerList(this.context)
                        ]),
            ),
    ));
  }
}
