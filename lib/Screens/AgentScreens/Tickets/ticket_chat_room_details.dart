//*************   © Copyrighted by aagama_it.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/number_limits.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/ticket_message.dart';
import 'package:aagama_it/Models/ticket_model.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/widgets/ticketStatus.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:aagama_it/Screens/activity/filtered_activity_history.dart';
import 'package:aagama_it/Services/FirebaseServices/firebase_api.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Utils/color_light_dark.dart';
import 'package:aagama_it/Utils/getRolePermission.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_time_formatter.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/dynamic_modal_bottomsheet.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Services/Providers/liveListener.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/Avatar.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/userrole_based_sticker.dart';

class TicketDetails extends StatefulWidget {
  final String ticketID;
  final SharedPreferences prefs;
  final String currentuserid;
  final bool isCustomerViewing;
  final Function onrefreshPreviousPage;
  final String ticketCosmeticID;
  const TicketDetails(
      {Key? key,
      required this.ticketID,
      required this.prefs,
      required this.isCustomerViewing,
      required this.currentuserid,
      required this.ticketCosmeticID,
      required this.onrefreshPreviousPage})
      : super(key: key);

  @override
  _TicketDetailsState createState() => _TicketDetailsState();
}

class _TicketDetailsState extends State<TicketDetails> {
  File? imageFile;
  String error = "";
  bool isloading = true;
  final GlobalKey<State> _keyLoader223 =
      new GlobalKey<State>(debugLabel: '272husd1');

  TicketModel? ticket;

  final TextEditingController _textEditingController =
      new TextEditingController();
  late DocumentReference docRef;
  bool issecondaryloaderon = false;
  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  fetchdata() async {
    docRef = FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(widget.ticketID);
    await docRef.get().then((dc) async {
      if (dc.exists) {
        ticket = TicketModel.fromSnapshot(dc);

        setState(() {
          isloading = false;
          issecondaryloaderon = false;
        });
      } else {
        setState(() {
          error = "This ticket does not exists.";
        });
      }
    }).catchError((onError) {
      setState(() {
        error = "Error loading ticket. ERROR: $onError";

        isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // var w = MediaQuery.of(this.context).size.width;
    var observer = Provider.of<Observer>(this.context, listen: true);

    var registry = Provider.of<UserRegistry>(this.context, listen: true);
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: true);
    bool isready = livedata == null
        ? false
        : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
                livedata.docmap[Dbkeys.secondadminID] == '' ||
                livedata.docmap[Dbkeys.secondadminID] == null
            ? false
            : true;
    String secondadminID =
        isready == true ? livedata!.docmap[Dbkeys.secondadminID] : "";
    assignAgentForCall(BuildContext context, String agentid) async {
      ShowConfirmDialog().open(
          context: this.context,
          title:
              getTranslatedForCurrentUser(this.context, 'xxassignxxforcallxx')
                  .replaceAll('(####)',
                      getTranslatedForCurrentUser(this.context, 'xxagentxx')),
          subtitle: getTranslatedForCurrentUser(
                  this.context, 'xxassignxxforcalldescxx')
              .replaceAll(
                  '(####)',
                  getTranslatedForCurrentUser(this.context, 'xxagentidxx') +
                      " $agentid")
              .replaceAll('(###)',
                  getTranslatedForCurrentUser(this.context, 'xxcustomerxx'))
              .replaceAll('(##)',
                  getTranslatedForCurrentUser(this.context, 'xxsupporttktxx'))
              .replaceAll('(#)',
                  getTranslatedForCurrentUser(this.context, 'xxagentxx')),
          rightbtntext: getTranslatedForCurrentUser(this.context, 'xxconfirmxx')
              .toUpperCase(),
          rightbtnonpress: observer
                      .checkIfCurrentUserIsDemo(widget.currentuserid) ==
                  true
              ? () {
                  Utils.toast(getTranslatedForCurrentUser(
                      this.context, 'xxxnotalwddemoxxaccountxx'));
                }
              : () async {
                  Navigator.of(this.context).pop();
                  int timeNowold = DateTime.now().millisecondsSinceEpoch;
                  ShowLoading().open(
                    context: this.context,
                    key: _keyLoader223,
                  );
                  await docRef.update({
                    Dbkeys.ticketCallInfoMap: {
                      Dbkeys.ticketCallAssignedBy: widget.currentuserid,
                      Dbkeys.ticketCallAssignedTime:
                          DateTime.now().millisecondsSinceEpoch,
                      Dbkeys.ticketCallId: agentid
                    }
                  });

                  int timeNow = DateTime.now().millisecondsSinceEpoch;
                  await docRef
                      .collection(DbPaths.collectionticketChats)
                      .doc(timeNow.toString() + '--' + widget.currentuserid)
                      .set(
                          TicketMessage(
                            tktMsgCUSTOMERID: ticket!.ticketcustomerID,
                            tktMssgCONTENT: agentid,
                            tktMssgISDELETED: false,
                            tktMssgTIME: timeNow,
                            tktMssgSENDBY: widget.currentuserid,
                            tktMssgTYPE: MessageType
                                .rROBOTassignAgentForACustomerCall.index,
                            tktMssgSENDERNAME: "",
                            tktMssgISREPLY: false,
                            tktMssgISFORWARD: false,
                            tktMssgREPLYTOMSSGDOC: {},
                            tktMssgTicketName: ticket!.ticketTitle,
                            tktMssgTicketIDflitered: ticket!.ticketidFiltered,
                            tktMssgSENDFOR: [
                              MssgSendFor.agent.index,
                              MssgSendFor.customer.index,
                            ],
                            tktMsgSenderIndex: Usertype.agent.index,
                            tktMsgInt2: 0,
                            isShowSenderNameInNotification: false,
                            tktMsgBool2: true,
                            notificationActiveList:
                                ticket!.tktNOTIFICATIONactiveList,
                            tktMssgLISToptional: [],
                            tktMsgList2: [],
                            tktMsgList3: [],
                            tktMsgMap1: {},
                            tktMsgMap2: {},
                            tktMsgDELETEREASON: '',
                            tktMsgDELETEDby: '',
                            tktMsgString4: '',
                            tktMsgString5: '',
                            ttktMsgString3: '',
                          ).toMap(),
                          SetOptions(merge: true));
                  if (widget.currentuserid != agentid) {
                    await Utils.sendDirectNotification(
                        title: getTranslatedForEventsAndAlerts(
                            this.context, 'xxassignedforcallxx'),
                        parentID: "TICKET--${ticket!.ticketID}",
                        plaindesc: getTranslatedForEventsAndAlerts(this.context, 'xxassingedcalllongxx')
                            .replaceAll(
                                '(######)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxcustomerxx'))
                            .replaceAll(
                                '(#####)',
                                getTranslatedForEventsAndAlerts(this.context, 'xxticketidxx') +
                                    " ${ticket!.ticketID}")
                            .replaceAll(
                                '(####)',
                                getTranslatedForEventsAndAlerts(this.context, 'xxcustomeridxx') +
                                    " ${ticket!.ticketcustomerID}")
                            .replaceAll(
                                '(###)',
                                getTranslatedForEventsAndAlerts(this.context, 'xxagentidxx') +
                                    " ${widget.currentuserid}")
                            .replaceAll(
                                '(##)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxcustomerxx'))
                            .replaceAll(
                                '(#)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxsupporttktxx')),
                        docRef: FirebaseFirestore.instance
                            .collection(DbPaths.collectionagents)
                            .doc(agentid)
                            .collection(DbPaths.agentnotifications)
                            .doc(DbPaths.agentnotifications),
                        postedbyID: widget.currentuserid);
                  }
                  if (observer.userAppSettingsDoc!
                          .customerCanDialCallsInTicketChatroom ==
                      true) {
                    await Utils.sendDirectNotification(
                        title:
                            getTranslatedForEventsAndAlerts(this.context, 'xxassignedforcall')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForEventsAndAlerts(
                                        this.context, 'xxagentxx'))
                                .replaceAll(
                                    '(###)',
                                    getTranslatedForEventsAndAlerts(
                                        this.context, 'xxyouxx')),
                        parentID: "TICKET--${ticket!.ticketID}",
                        plaindesc: getTranslatedForEventsAndAlerts(
                                this.context, 'xxagentassignedforuxx')
                            .replaceAll(
                                '(###)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxagentxx'))
                            .replaceAll(
                                '(##)',
                                getTranslatedForEventsAndAlerts(this.context, 'xxticketidxx') +
                                    " ${ticket!.ticketID}")
                            .replaceAll(
                                '(#)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxsupporttktxx')),
                        docRef: FirebaseFirestore.instance
                            .collection(DbPaths.collectioncustomers)
                            .doc(ticket!.ticketcustomerID)
                            .collection(DbPaths.customernotifications)
                            .doc(DbPaths.customernotifications),
                        postedbyID: widget.currentuserid);
                  } else {
                    await Utils.sendDirectNotification(
                        title: getTranslatedForEventsAndAlerts(
                                this.context, 'xxassignedforcall')
                            .replaceAll(
                                '(####)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxagentxx'))
                            .replaceAll(
                                '(###)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxyouxx')),
                        parentID: "TICKET--${ticket!.ticketID}",
                        plaindesc: getTranslatedForEventsAndAlerts(
                                this.context, 'xxagentassignedforushortxx')
                            .replaceAll(
                                '(###)',
                                getTranslatedForEventsAndAlerts(
                                    this.context, 'xxagentxx'))
                            .replaceAll(
                                '(##)',
                                getTranslatedForEventsAndAlerts(
                                        this.context, 'xxticketidxx') +
                                    " ${ticket!.ticketID}"),
                        docRef: FirebaseFirestore.instance
                            .collection(DbPaths.collectioncustomers)
                            .doc(ticket!.ticketcustomerID)
                            .collection(DbPaths.customernotifications)
                            .doc(DbPaths.customernotifications),
                        postedbyID: widget.currentuserid);
                  }

                  if (ticket!.ticketCallInfoMap!.isNotEmpty) {
                    await docRef
                        .collection(DbPaths.collectionticketChats)
                        .doc(
                            timeNowold.toString() + '--' + widget.currentuserid)
                        .set(
                            TicketMessage(
                              tktMsgCUSTOMERID: ticket!.ticketcustomerID,
                              tktMssgCONTENT: ticket!
                                  .ticketCallInfoMap![Dbkeys.ticketCallId],
                              tktMssgISDELETED: false,
                              tktMssgTIME: timeNowold,
                              tktMssgSENDBY: widget.currentuserid,
                              tktMssgTYPE: MessageType
                                  .rROBOTremoveAssignAgentForACustomerCall
                                  .index,
                              tktMssgSENDERNAME: "",
                              tktMssgISREPLY: false,
                              tktMssgISFORWARD: false,
                              tktMssgREPLYTOMSSGDOC: {},
                              tktMssgTicketName: ticket!.ticketTitle,
                              tktMssgTicketIDflitered: ticket!.ticketidFiltered,
                              tktMssgSENDFOR: [
                                MssgSendFor.agent.index,
                                MssgSendFor.customer.index,
                              ],
                              tktMsgSenderIndex: Usertype.agent.index,
                              tktMsgInt2: 0,
                              isShowSenderNameInNotification: false,
                              tktMsgBool2: true,
                              notificationActiveList:
                                  ticket!.tktNOTIFICATIONactiveList,
                              tktMssgLISToptional: [],
                              tktMsgList2: [],
                              tktMsgList3: [],
                              tktMsgMap1: {},
                              tktMsgMap2: {},
                              tktMsgDELETEREASON: '',
                              tktMsgDELETEDby: '',
                              tktMsgString4: '',
                              tktMsgString5: '',
                              ttktMsgString3: '',
                            ).toMap(),
                            SetOptions(merge: true));
                    await Utils.sendDirectNotification(
                        title: getTranslatedForEventsAndAlerts(
                            this.context, 'xxyouareremoedfromcallxx'),
                        parentID: "TICKET--${ticket!.ticketID}",
                        plaindesc:
                            "You are removed from assigned Call with Customer in Ticket ID: ${ticket!.ticketcosmeticID} for Customer ID: ${ticket!.ticketcustomerID}. This was changed by Agent ID: ${widget.currentuserid}. Another agent is assigned for this task.",
                        docRef: FirebaseFirestore.instance
                            .collection(DbPaths.collectionagents)
                            .doc(agentid)
                            .collection(DbPaths.agentnotifications)
                            .doc(DbPaths.agentnotifications),
                        postedbyID: widget.currentuserid);
                    await FirebaseApi.runTransactionRecordActivity(
                      parentid: "TICKET--${ticket!.ticketID}",
                      title: getTranslatedForCurrentUser(
                              this.context, 'xxaremovedorcall')
                          .replaceAll(
                              '(####)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxagentxx'))
                          .replaceAll(
                              '(###)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxcustomerxx')),
                      postedbyID: widget.currentuserid,
                      onErrorFn: (e) {},
                      onSuccessFn: () {},
                      // styledDesc:
                      //     "Agent ID: $agentid is <bold>removed from assigned Call</bold> With Customer ID: ${ticket!.ticketcustomerID} in Ticket ID: ${ticket!.ticketID} Chatroom.",
                      plainDesc: getTranslatedForCurrentUser(
                              this.context, 'xxaremovedorcalllong')
                          .replaceAll(
                              '(####)',
                              getTranslatedForCurrentUser(
                                      this.context, 'xxagentidxx') +
                                  " $agentid")
                          .replaceAll(
                              '(###)',
                              getTranslatedForCurrentUser(
                                      this.context, 'xxcustomeridxx') +
                                  " ${ticket!.ticketcustomerID}")
                          .replaceAll(
                              '(##)',
                              getTranslatedForCurrentUser(
                                      this.context, 'xxticketidxx') +
                                  " ${ticket!.ticketID}"),
                    );
                  }
                  await FirebaseApi.runTransactionRecordActivity(
                    parentid: "TICKET--${ticket!.ticketID}",
                    title: getTranslatedForCurrentUser(
                            this.context, 'xxassignedforcall')
                        .replaceAll(
                            '(####)',
                            getTranslatedForCurrentUser(
                                this.context, 'xxagentxx'))
                        .replaceAll(
                            '(###)',
                            getTranslatedForCurrentUser(
                                this.context, 'xxcustomerxx')),
                    postedbyID: widget.currentuserid,
                    onErrorFn: (e) {
                      ShowLoading().close(key: _keyLoader223, context: context);
                      Utils.toast(
                          "Unable to assign agent for Call.\n\n Error: $e");
                      fetchdata();
                    },
                    onSuccessFn: () {
                      ShowLoading().close(key: _keyLoader223, context: context);
                      Navigator.of(this.context).pop();
                      fetchdata();
                    },
                    // styledDesc:
                    //     "An Agent ID: $agentid is <bold>assigned for a Call</bold> With Customer ID: ${ticket!.ticketcustomerID} in Ticket ID: ${ticket!.ticketID} Chatroom. Agent & Customer can communicate using Calls in this Ticket.",
                    plainDesc:
                        "An Agent ID: $agentid is assigned for a Call With Customer ID: ${ticket!.ticketcustomerID} in Ticket ID: ${ticket!.ticketID} Chatroom. Agent & Customer can communicate using Calls in this Ticket.",
                  );
                });
    }

    removeAgentForCall(BuildContext context, String currentagentid) async {
      ShowConfirmDialog().open(
          context: this.context,
          title: getTranslatedForCurrentUser(
                  this.context, 'xxremoveagentforcallxx')
              .replaceAll('(####)',
                  getTranslatedForCurrentUser(this.context, 'xxagentxx')),
          subtitle: getTranslatedForCurrentUser(
                  this.context, 'xxremoveagentdescxx')
              .replaceAll(
                  '(####)',
                  getTranslatedForCurrentUser(this.context, 'xxagentidxx') +
                      " $currentagentid")
              .replaceAll('(###)',
                  getTranslatedForCurrentUser(this.context, 'xxcustomerxx')),
          rightbtntext:
              getTranslatedForCurrentUser(this.context, 'xxconfirmxx'),
          rightbtnonpress: observer
                      .checkIfCurrentUserIsDemo(widget.currentuserid) ==
                  true
              ? () {
                  Utils.toast(getTranslatedForCurrentUser(
                      this.context, 'xxxnotalwddemoxxaccountxx'));
                }
              : () async {
                  Navigator.of(this.context).pop();
                  ShowLoading().open(
                    context: this.context,
                    key: _keyLoader223,
                  );
                  await docRef.update({Dbkeys.ticketCallInfoMap: {}});
                  int timeNow = DateTime.now().millisecondsSinceEpoch;
                  await docRef
                      .collection(DbPaths.collectionticketChats)
                      .doc(timeNow.toString() + '--' + widget.currentuserid)
                      .set(
                          TicketMessage(
                            tktMsgCUSTOMERID: ticket!.ticketcustomerID,
                            tktMssgCONTENT: currentagentid,
                            tktMssgISDELETED: false,
                            tktMssgTIME: timeNow,
                            tktMssgSENDBY: widget.currentuserid,
                            tktMssgTYPE: MessageType
                                .rROBOTremoveAssignAgentForACustomerCall.index,
                            tktMssgSENDERNAME: "",
                            tktMssgISREPLY: false,
                            tktMssgISFORWARD: false,
                            tktMssgREPLYTOMSSGDOC: {},
                            tktMssgTicketName: ticket!.ticketTitle,
                            tktMssgTicketIDflitered: ticket!.ticketidFiltered,
                            tktMssgSENDFOR: [
                              MssgSendFor.agent.index,
                              MssgSendFor.customer.index,
                            ],
                            tktMsgSenderIndex: Usertype.agent.index,
                            tktMsgInt2: 0,
                            isShowSenderNameInNotification: false,
                            tktMsgBool2: true,
                            notificationActiveList:
                                ticket!.tktNOTIFICATIONactiveList,
                            tktMssgLISToptional: [],
                            tktMsgList2: [],
                            tktMsgList3: [],
                            tktMsgMap1: {},
                            tktMsgMap2: {},
                            tktMsgDELETEREASON: '',
                            tktMsgDELETEDby: '',
                            tktMsgString4: '',
                            tktMsgString5: '',
                            ttktMsgString3: '',
                          ).toMap(),
                          SetOptions(merge: true));
                  // if (widget.currentuserid != currentagentid) {
                  await Utils.sendDirectNotification(
                      title: "You are removed from Assigned Call",
                      parentID: "TICKET--${ticket!.ticketID}",
                      plaindesc:
                          "You are removed from assigned Call with Customer in Ticket ID: ${ticket!.ticketcosmeticID} for Customer ID: ${ticket!.ticketcustomerID}. This was changed by Agent ID: ${widget.currentuserid}.",
                      docRef: FirebaseFirestore.instance
                          .collection(DbPaths.collectionagents)
                          .doc(currentagentid)
                          .collection(DbPaths.agentnotifications)
                          .doc(DbPaths.agentnotifications),
                      postedbyID: widget.currentuserid);

                  await FirebaseApi.runTransactionRecordActivity(
                    parentid: "TICKET--${ticket!.ticketID}",
                    title: "Agent Removed from Assigned Call",
                    postedbyID: widget.currentuserid,
                    onErrorFn: (e) {
                      ShowLoading().close(key: _keyLoader223, context: context);
                      Utils.toast("Unable to remove agent.\n\n Error: $e");
                      fetchdata();
                    },
                    onSuccessFn: () {
                      ShowLoading().close(key: _keyLoader223, context: context);

                      fetchdata();
                    },
                    styledDesc:
                        "Agent ID: $currentagentid is <bold>removed from assigned Call</bold> With Customer ID: ${ticket!.ticketcustomerID} in Ticket ID: ${ticket!.ticketID} Chatroom.",
                    plainDesc:
                        "Agent ID: $currentagentid is removed from assigned Call With Customer ID: ${ticket!.ticketcustomerID} in Ticket ID: ${ticket!.ticketID} Chatroom. ",
                  );
                });
    }

    selectAgentSheet(BuildContext context) async {
      showDynamicModalBottomSheet(
        title: "",
        context: this.context,
        widgetList: [
          SizedBox(
            height: 28,
          ),
          MtCustomfontBold(
            text: getTranslatedForCurrentUser(this.context, 'xxselectxxtoaddxx')
                .replaceAll('(####)',
                    getTranslatedForCurrentUser(this.context, 'xxagentxx')),
            color: Mycolors.primary,
            fontsize: 16,
            textalign: TextAlign.center,
          ),
          SizedBox(
            height: 9,
          ),
          ListView.builder(
              padding: EdgeInsets.all(15),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: ticket!.tktMEMBERSactiveList.length,
              itemBuilder: (BuildContext context, int i) {
                var agentid = ticket!.tktMEMBERSactiveList[i];
                return agentid == ticket!.ticketcustomerID
                    ? SizedBox()
                    : Column(
                        children: [
                          ListTile(
                            onTap: () async {
                              await assignAgentForCall(this.context, agentid);
                            },
                            trailing: Icon(
                              ticket!.ticketCallInfoMap!.isEmpty
                                  ? Icons.check_box_outline_blank_rounded
                                  : agentid ==
                                          ticket!.ticketCallInfoMap![
                                              Dbkeys.ticketCallId]
                                      ? Icons.check_box_sharp
                                      : Icons.check_box_outline_blank_rounded,
                              size: 18,
                              color: ticket!.ticketCallInfoMap!.isEmpty
                                  ? Mycolors.grey
                                  : agentid ==
                                          ticket!.ticketCallInfoMap![
                                              Dbkeys.ticketCallId]
                                      ? Mycolors.green
                                      : Mycolors.grey,
                            ),
                            contentPadding: EdgeInsets.all(0),
                            leading: avatar(
                                imageUrl: registry
                                    .getUserData(this.context, agentid)
                                    .photourl),
                            title: MtCustomfontRegular(
                                fontsize: 16,
                                color: Mycolors.black,
                                text: registry
                                    .getUserData(this.context, agentid)
                                    .fullname),
                            subtitle: Row(children: [
                              MtCustomfontRegular(
                                fontsize: 13,
                                text:
                                    "${getTranslatedForCurrentUser(this.context, 'xxidxx')} " +
                                        registry
                                            .getUserData(this.context, agentid)
                                            .id,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              secondadminID == agentid
                                  ? roleBasedSticker(
                                      this.context, Usertype.secondadmin.index)
                                  : SizedBox()
                            ]),
                          ),
                        ],
                      );
              }),
          SizedBox(
            height: 28,
          ),
        ],
      );
    }

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
                  : Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        width: 70,
                        child: Center(
                          child: Text(
                            widget.isCustomerViewing
                                ? ticketStatusTextShortForCustomers(
                                    this.context, ticket!.ticketStatus)
                                : ticketStatusTextShortForAgents(
                                    this.context, ticket!.ticketStatus),
                            style: TextStyle(
                                color: widget.isCustomerViewing
                                    ? ticketStatusColorForCustomers(
                                        ticket!.ticketStatus)
                                    : ticketStatusColorForAgents(
                                        ticket!.ticketStatus),
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: widget.isCustomerViewing
                              ? ticketStatusColorForCustomers(
                                      ticket!.ticketStatus)
                                  .withOpacity(0.2)
                              : ticketStatusColorForAgents(ticket!.ticketStatus)
                                  .withOpacity(0.2),
                        ),
                        height: 20,
                      ),
                    ),
            ],
            backgroundColor: Mycolors.white,
            title: InkWell(
              onTap: () {
                // Navigator.push(
                //     context,
                //     PageRouteBuilder(
                //         opaque: false,
                //         pageBuilder: (this.context, a1, a2) => ProfileView(peer)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MtCustomfontBoldSemi(
                    text: getTranslatedForCurrentUser(this.context, 'xxtktsxx'),
                    fontsize: 17,
                    color: Mycolors.black,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${widget.ticketCosmeticID}",
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
                            children: [
                              ticket!.ticketStatus == TicketStatus.active.index
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Container(
                                        padding: EdgeInsets.all(7),
                                        child: Center(
                                          child: Text(
                                            widget.isCustomerViewing
                                                ? ticketStatusTextLongForCustomer(
                                                    this.context,
                                                    ticket!.ticketStatus)
                                                : ticketStatusTextLongForAgent(
                                                    this.context,
                                                    ticket!.ticketStatus),
                                            style: TextStyle(
                                                color: widget.isCustomerViewing
                                                    ? ticketStatusColorForCustomers(
                                                        ticket!.ticketStatus)
                                                    : ticketStatusColorForAgents(
                                                        ticket!.ticketStatus),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white),
                                      ),
                                    ),
                              SizedBox(
                                height: 10,
                              ),
                              widget.isCustomerViewing &&
                                      observer.userAppSettingsDoc!
                                              .customerCanSeeAgentNameInTicketCallScreen ==
                                          false
                                  ? SizedBox()
                                  : myinkwell(
                                      onTap: () {
                                        pageNavigator(
                                            this.context,
                                            FilteredActivityHistory(
                                              subtitle:
                                                  "${getTranslatedForCurrentUser(this.context, 'xxticketidxx')} " +
                                                      widget.ticketID,
                                              isShowDesc: widget
                                                          .currentuserid ==
                                                      ticket!.ticketcustomerID
                                                  ? false
                                                  : true,
                                              extrafieldid:
                                                  "TICKET--" + widget.ticketID,
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
                                                            'xxtktsxx')),
                                                color: Colors.white,
                                              )
                                            ],
                                          )),
                                    ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(16),
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
                                          "${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxtitlexx')}",
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
                                    MtCustomfontBold(
                                      text: ticket!.ticketTitle == ""
                                          ? "No Title"
                                          : ticket!.ticketTitle,
                                      fontsize: 16,
                                      isitalic: ticket!.ticketTitle == "",
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
                              widget.isCustomerViewing == true
                                  ? SizedBox()
                                  : Container(
                                      color: lighten(Colors.yellow, 0.3),
                                      padding: EdgeInsets.all(16),
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
                                                    this.context,
                                                    'xxcustomerxx'),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Mycolors.secondary,
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          Divider(),
                                          ListTile(
                                            contentPadding:
                                                EdgeInsets.fromLTRB(6, 6, 6, 0),
                                            leading: avatar(
                                                imageUrl: registry
                                                    .getUserData(
                                                        this.context,
                                                        ticket!
                                                            .ticketcustomerID)
                                                    .photourl),
                                            title: MtCustomfontBoldSemi(
                                              color: Mycolors.black,
                                              text: registry
                                                  .getUserData(this.context,
                                                      ticket!.ticketcustomerID)
                                                  .fullname,
                                              fontsize: 15,
                                            ),
                                            subtitle: Row(
                                              children: [
                                                MtCustomfontRegular(
                                                  fontsize: 13,
                                                  text: "${getTranslatedForCurrentUser(this.context, 'xxidxx')} " +
                                                      registry
                                                          .getUserData(
                                                              this.context,
                                                              ticket!
                                                                  .ticketcustomerID)
                                                          .id,
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              SizedBox(
                                height: 38,
                              ),
                              widget.isCustomerViewing == false &&
                                      observer.userAppSettingsDoc!
                                              .departmentBasedContent ==
                                          true &&
                                      observer.userAppSettingsDoc!
                                              .agentCanViewAgentsListJoinedTicket ==
                                          true
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 3, 10, 3),
                                          child: Text(
                                            observer.userAppSettingsDoc!
                                                        .departmentList!
                                                        .firstWhere(
                                                          (department) =>
                                                              department[Dbkeys
                                                                      .departmentTitle]
                                                                  .toString()
                                                                  .trim() ==
                                                              ticket!
                                                                  .ticketDepartmentID
                                                                  .trim(),
                                                        )[Dbkeys
                                                            .departmentAgentsUIDList]
                                                        .length <
                                                    1
                                                ? "${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')} - ${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxagentxx')}"
                                                : "${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')} - ${observer.userAppSettingsDoc!.departmentList!.firstWhere(
                                                      (department) =>
                                                          department[Dbkeys
                                                                  .departmentTitle]
                                                              .toString()
                                                              .trim() ==
                                                          ticket!
                                                              .ticketDepartmentID
                                                              .trim(),
                                                    )[Dbkeys.departmentAgentsUIDList].length.toString()} ${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxagentxx')}",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Mycolors.secondary,
                                                fontSize: 15),
                                          ),
                                        ),
                                        ListView.builder(
                                            padding: EdgeInsets.all(26),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: observer
                                                .userAppSettingsDoc!
                                                .departmentList!
                                                .firstWhere(
                                                  (department) =>
                                                      department[Dbkeys
                                                              .departmentTitle]
                                                          .toString()
                                                          .trim() ==
                                                      ticket!.ticketDepartmentID
                                                          .trim(),
                                                )[Dbkeys
                                                    .departmentAgentsUIDList]
                                                .length,
                                            itemBuilder:
                                                (BuildContext context, int i) {
                                              var agentid = observer
                                                      .userAppSettingsDoc!
                                                      .departmentList!
                                                      .firstWhere(
                                                (department) =>
                                                    department[Dbkeys
                                                            .departmentTitle]
                                                        .toString()
                                                        .trim() ==
                                                    ticket!.ticketDepartmentID
                                                        .trim(),
                                              )[Dbkeys.departmentAgentsUIDList]
                                                  [i];
                                              return agentid ==
                                                      ticket!.ticketcustomerID
                                                  ? SizedBox()
                                                  : Column(
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
                                                              color: Mycolors
                                                                  .black,
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
                                                                  width: 10,
                                                                ),
                                                                secondadminID ==
                                                                        agentid
                                                                    ? roleBasedSticker(
                                                                        this
                                                                            .context,
                                                                        Usertype
                                                                            .secondadmin
                                                                            .index)
                                                                    : SizedBox(),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                observer.userAppSettingsDoc!
                                                                            .departmentList!
                                                                            .firstWhere(
                                                                          (department) =>
                                                                              department[Dbkeys.departmentTitle].toString().trim() ==
                                                                              ticket!.ticketDepartmentID.trim(),
                                                                        )[Dbkeys
                                                                            .departmentManagerID] ==
                                                                        agentid
                                                                    ? roleBasedSticker(
                                                                        this
                                                                            .context,
                                                                        Usertype
                                                                            .departmentmanager
                                                                            .index)
                                                                    : SizedBox(),
                                                              ]),
                                                        ),
                                                        i ==
                                                                observer.userAppSettingsDoc!
                                                                        .departmentList!
                                                                        .firstWhere(
                                                                          (department) =>
                                                                              department[Dbkeys.departmentTitle].toString().trim() ==
                                                                              ticket!.ticketDepartmentID.trim(),
                                                                        )[Dbkeys
                                                                            .departmentAgentsUIDList]
                                                                        .length -
                                                                    1
                                                            ? SizedBox()
                                                            : Divider(
                                                                height: 1,
                                                              ),
                                                      ],
                                                    );
                                            }),
                                      ],
                                    )
                                  : widget.isCustomerViewing == true &&
                                              observer.userAppSettingsDoc!
                                                      .customerCanSeeAgentNameInTicketCallScreen ==
                                                  false ||
                                          widget.currentuserid == secondadminID
                                      ? observer.userAppSettingsDoc!
                                                  .departmentBasedContent ==
                                              true
                                          ? observer.userAppSettingsDoc!
                                                      .departmentList!
                                                      .firstWhere(
                                                        (department) =>
                                                            department[Dbkeys
                                                                    .departmentTitle]
                                                                .toString()
                                                                .trim() ==
                                                            ticket!
                                                                .ticketDepartmentID
                                                                .trim(),
                                                      )[Dbkeys
                                                          .departmentAgentsUIDList]
                                                      .length ==
                                                  0
                                              ? SizedBox(
                                                  height: 00,
                                                )
                                              :

                                              //---department agents below
                                              Container(
                                                  color: Colors.white,
                                                  padding: EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            observer.userAppSettingsDoc!
                                                                        .departmentList!
                                                                        .firstWhere(
                                                                          (department) =>
                                                                              department[Dbkeys.departmentTitle].toString().trim() ==
                                                                              ticket!.ticketDepartmentID.trim(),
                                                                        )[Dbkeys
                                                                            .departmentAgentsUIDList]
                                                                        .length <
                                                                    1
                                                                ? "${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')} - ${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxagentxx')}"
                                                                : "${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')} - ${observer.userAppSettingsDoc!.departmentList!.firstWhere(
                                                                      (department) =>
                                                                          department[Dbkeys.departmentTitle]
                                                                              .toString()
                                                                              .trim() ==
                                                                          ticket!
                                                                              .ticketDepartmentID
                                                                              .trim(),
                                                                    )[Dbkeys.departmentAgentsUIDList].length.toString()} ${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxagentxx')}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Mycolors
                                                                    .secondary,
                                                                fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(height: 15),
                                                      observer.userAppSettingsDoc!
                                                                  .departmentList!
                                                                  .firstWhere(
                                                                    (department) =>
                                                                        department[Dbkeys.departmentTitle]
                                                                            .toString()
                                                                            .trim() ==
                                                                        ticket!
                                                                            .ticketDepartmentID
                                                                            .trim(),
                                                                  )[Dbkeys
                                                                      .departmentAgentsUIDList]
                                                                  .length ==
                                                              0
                                                          ? MtCustomfontRegular(
                                                              fontsize: 14,
                                                              isitalic: true,
                                                              text: getTranslatedForCurrentUser(
                                                                      this
                                                                          .context,
                                                                      'xxnoxxisassignedinxx')
                                                                  .replaceAll(
                                                                      '(####)',
                                                                      getTranslatedForCurrentUser(
                                                                          this
                                                                              .context,
                                                                          'xxagentxx'))
                                                                  .replaceAll(
                                                                      '(###)',
                                                                      getTranslatedForCurrentUser(
                                                                          this
                                                                              .context,
                                                                          'xxdepartmentxx')))
                                                          : ListView.builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6),
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              itemCount: observer
                                                                  .userAppSettingsDoc!
                                                                  .departmentList!
                                                                  .firstWhere(
                                                                    (department) =>
                                                                        department[Dbkeys.departmentTitle]
                                                                            .toString()
                                                                            .trim() ==
                                                                        ticket!
                                                                            .ticketDepartmentID
                                                                            .trim(),
                                                                  )[Dbkeys.departmentAgentsUIDList]
                                                                  .length,
                                                              itemBuilder: (BuildContext context, int i) {
                                                                var agentid = observer
                                                                    .userAppSettingsDoc!
                                                                    .departmentList!
                                                                    .firstWhere(
                                                                  (department) =>
                                                                      department[Dbkeys
                                                                              .departmentTitle]
                                                                          .toString()
                                                                          .trim() ==
                                                                      ticket!
                                                                          .ticketDepartmentID
                                                                          .trim(),
                                                                )[Dbkeys
                                                                    .departmentAgentsUIDList][i];
                                                                return agentid ==
                                                                        ticket!
                                                                            .ticketcustomerID
                                                                    ? SizedBox()
                                                                    : Column(
                                                                        children: [
                                                                          ListTile(
                                                                            contentPadding:
                                                                                EdgeInsets.all(0),
                                                                            leading:
                                                                                avatar(imageUrl: registry.getUserData(this.context, agentid).photourl),
                                                                            title: MtCustomfontRegular(
                                                                                fontsize: 16,
                                                                                color: Mycolors.black,
                                                                                text: registry.getUserData(this.context, agentid).fullname),
                                                                            subtitle:
                                                                                Row(children: [
                                                                              MtCustomfontRegular(
                                                                                fontsize: 13,
                                                                                text: "${getTranslatedForCurrentUser(this.context, 'xxidxx')} " + registry.getUserData(this.context, agentid).id,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              secondadminID == agentid ? roleBasedSticker(this.context, Usertype.secondadmin.index) : SizedBox(),
                                                                              SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              observer.userAppSettingsDoc!.departmentList!.firstWhere(
                                                                                        (department) => department[Dbkeys.departmentTitle].toString().trim() == ticket!.ticketDepartmentID.trim(),
                                                                                      )[Dbkeys.departmentManagerID] ==
                                                                                      agentid
                                                                                  ? roleBasedSticker(this.context, Usertype.departmentmanager.index)
                                                                                  : SizedBox(),
                                                                            ]),
                                                                          ),
                                                                          i ==
                                                                                  observer.userAppSettingsDoc!.departmentList!
                                                                                          .firstWhere(
                                                                                            (department) => department[Dbkeys.departmentTitle].toString().trim() == ticket!.ticketDepartmentID.trim(),
                                                                                          )[Dbkeys.departmentAgentsUIDList]
                                                                                          .length -
                                                                                      1
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
                                                )
                                          //----individual below
                                          : Container(
                                              color: Colors.white,
                                              padding: EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        ticket!.tktMEMBERSactiveList
                                                                    .length <
                                                                1
                                                            ? "${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}"
                                                            : ticket!
                                                                    .tktMEMBERSactiveList
                                                                    .length
                                                                    .toString() +
                                                                " ${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Mycolors
                                                                .secondary,
                                                            fontSize: 15),
                                                      ),
                                                      // IconButton(
                                                      //     onPressed: () {
                                                      //       addNewAgentsToDepartment(
                                                      //           this.context,
                                                      //           department!
                                                      //               .departmentAgentsUIDList,
                                                      //           registry);
                                                      //     },
                                                      //     icon: Icon(
                                                      //       Icons.add,
                                                      //       size: 25,
                                                      //       color: Mycolors
                                                      //           .primary,
                                                      //     ))
                                                    ],
                                                  ),
                                                  Divider(),
                                                  ticket!.tktMEMBERSactiveList
                                                              .length ==
                                                          0
                                                      ? MtCustomfontRegular(
                                                          fontsize: 14,
                                                          isitalic: true,
                                                          text: getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'xxnoxxisassignedinxx')
                                                              .replaceAll(
                                                                  '(####)',
                                                                  getTranslatedForCurrentUser(
                                                                      this
                                                                          .context,
                                                                      'xxagentxx'))
                                                              .replaceAll(
                                                                  '(###)',
                                                                  getTranslatedForCurrentUser(
                                                                      this
                                                                          .context,
                                                                      'xxsupporttktxx')))
                                                      : ListView.builder(
                                                          padding:
                                                              EdgeInsets.all(6),
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemCount: ticket!
                                                              .tktMEMBERSactiveList
                                                              .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int i) {
                                                            var agentid = ticket!
                                                                .tktMEMBERSactiveList[i];
                                                            return agentid ==
                                                                    ticket!
                                                                        .ticketcustomerID
                                                                ? SizedBox()
                                                                : Column(
                                                                    children: [
                                                                      ListTile(
                                                                        contentPadding:
                                                                            EdgeInsets.all(0),
                                                                        leading:
                                                                            avatar(imageUrl: registry.getUserData(this.context, agentid).photourl),
                                                                        title: MtCustomfontRegular(
                                                                            fontsize:
                                                                                16,
                                                                            color:
                                                                                Mycolors.black,
                                                                            text: registry.getUserData(this.context, agentid).fullname),
                                                                        subtitle:
                                                                            Row(
                                                                                children: [
                                                                              MtCustomfontRegular(
                                                                                fontsize: 13,
                                                                                text: "${getTranslatedForCurrentUser(this.context, 'xxidxx')} " + registry.getUserData(this.context, agentid).id,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              secondadminID == agentid ? roleBasedSticker(this.context, Usertype.secondadmin.index) : SizedBox()
                                                                            ]),
                                                                      ),
                                                                      i ==
                                                                              observer.userAppSettingsDoc!.departmentList!
                                                                                      .firstWhere(
                                                                                        (department) => department[Dbkeys.departmentTitle].toString().trim() == ticket!.ticketDepartmentID.trim(),
                                                                                      )[Dbkeys.departmentAgentsUIDList]
                                                                                      .length -
                                                                                  1
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
                                            )
                                      : SizedBox(),
                              SizedBox(
                                height: 18,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              widget.isCustomerViewing == true ||
                                      observer.userAppSettingsDoc!
                                              .isCallAssigningAllowed ==
                                          false
                                  ? SizedBox(
                                      height: 20,
                                    )
                                  : ticket!.ticketStatus ==
                                              TicketStatus.active.index ||
                                          ticket!.ticketStatus ==
                                              TicketStatus
                                                  .needsAttention.index ||
                                          ticket!.ticketStatus ==
                                              TicketStatus
                                                  .reOpenedByAgent.index ||
                                          ticket!.ticketStatus ==
                                              TicketStatus
                                                  .reOpenedByCustomer.index
                                      ? Container(
                                          margin: EdgeInsets.all(9),
                                          // height: 100,
                                          // width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            border: Border.all(
                                              color: Colors.green,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ListTile(
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: MtCustomfontBoldSemi(
                                                    color: Colors.green,
                                                    text: getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxcallxxxx')
                                                        .replaceAll(
                                                            '(####)',
                                                            getTranslatedForCurrentUser(
                                                                this.context,
                                                                'xxagentxx')),
                                                    fontsize: 16.6,
                                                  ),
                                                ),
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: MtCustomfontRegular(
                                                    lineheight: 1.3,
                                                    text: getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxwhowillrecievecallsxx')
                                                        .replaceAll(
                                                            '(####)',
                                                            getTranslatedForCurrentUser(
                                                                this.context,
                                                                'xxagentxx'))
                                                        .replaceAll(
                                                            '(###)',
                                                            getTranslatedForCurrentUser(
                                                                this.context,
                                                                'xxcustomerxx'))
                                                        .replaceAll(
                                                            '(##)',
                                                            getTranslatedForCurrentUser(
                                                                this.context,
                                                                'xxtktsxx')),
                                                    color: Colors.green[700],
                                                    fontsize: 11,
                                                  ),
                                                ),
                                                leading: Icon(
                                                  Icons.phone,
                                                  color: Colors.green,
                                                ),
                                                isThreeLine: false,
                                                onTap: () {},
                                              ),
                                              SizedBox(
                                                height: 9,
                                              ),
                                              ticket!.ticketCallInfoMap!.isEmpty
                                                  ? observer.userAppSettingsDoc!
                                                                  .agentCanScheduleCalls ==
                                                              true ||
                                                          (iAmSecondAdmin(
                                                                      currentuserid:
                                                                          widget
                                                                              .currentuserid,
                                                                      context:
                                                                          context) &&
                                                                  observer
                                                                      .userAppSettingsDoc!
                                                                      .secondadminCanScheduleCalls!) ==
                                                              true ||
                                                          (iAmDepartmentManager(
                                                                      currentuserid:
                                                                          widget
                                                                              .currentuserid,
                                                                      context:
                                                                          context) &&
                                                                  observer
                                                                      .userAppSettingsDoc!
                                                                      .departmentManagerCanScheduleCalls!) ==
                                                              true
                                                      ? ElevatedButton(
                                                          onPressed: () {
                                                            selectAgentSheet(
                                                                context);
                                                          },
                                                          // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                                                          style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Mycolors
                                                                      .primary,
                                                              elevation: 2.0,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons.add_call,
                                                                size: 17,
                                                              ),
                                                              SizedBox(
                                                                width: 12,
                                                              ),
                                                              MtCustomfontBold(
                                                                text: getTranslatedForCurrentUser(
                                                                        this
                                                                            .context,
                                                                        'xxaddxx')
                                                                    .replaceAll(
                                                                        '(####)',
                                                                        getTranslatedForCurrentUser(
                                                                            this.context,
                                                                            'xxagentxx')),
                                                                color: Colors
                                                                    .white,
                                                                fontsize: 13,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : MtCustomfontBoldSemi(
                                                          text: getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'xxnoxxisassignedinxx')
                                                              .replaceAll(
                                                                  '(####)',
                                                                  getTranslatedForCurrentUser(
                                                                      this.context,
                                                                      'xxagentxx'))
                                                              .replaceAll(
                                                                '(###)',
                                                                getTranslatedForCurrentUser(
                                                                        this
                                                                            .context,
                                                                        'xxcallxxxx')
                                                                    .replaceAll(
                                                                        '(####)',
                                                                        ''),
                                                              ),
                                                          fontsize: 13,
                                                        )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          18, 3, 18, 3),
                                                      child: ListTile(
                                                        trailing: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  await selectAgentSheet(
                                                                      this.context);
                                                                },
                                                                icon: Icon(
                                                                  Icons.edit,
                                                                  size: 19,
                                                                  color: Mycolors
                                                                      .primary,
                                                                )),
                                                            IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  removeAgentForCall(
                                                                      this
                                                                          .context,
                                                                      ticket!.ticketCallInfoMap![
                                                                          Dbkeys
                                                                              .ticketCallId]);
                                                                },
                                                                icon: Icon(
                                                                  Icons.close,
                                                                  size: 22,
                                                                  color:
                                                                      Mycolors
                                                                          .red,
                                                                )),
                                                          ],
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.all(0),
                                                        leading: avatar(
                                                            imageUrl: registry
                                                                .getUserData(
                                                                    this
                                                                        .context,
                                                                    ticket!.ticketCallInfoMap![
                                                                        Dbkeys
                                                                            .ticketCallId])
                                                                .photourl),
                                                        title: MtCustomfontRegular(
                                                            fontsize: 16,
                                                            color:
                                                                Mycolors.black,
                                                            text: registry
                                                                .getUserData(
                                                                    this
                                                                        .context,
                                                                    ticket!.ticketCallInfoMap![
                                                                        Dbkeys
                                                                            .ticketCallId])
                                                                .fullname),
                                                        subtitle:
                                                            MtCustomfontRegular(
                                                          fontsize: 13,
                                                          text: "${getTranslatedForCurrentUser(this.context, 'xxagentidxx')} " +
                                                              registry
                                                                  .getUserData(
                                                                      this
                                                                          .context,
                                                                      ticket!.ticketCallInfoMap![
                                                                          Dbkeys
                                                                              .ticketCallId])
                                                                  .id,
                                                        ),
                                                      ),
                                                    ),
                                              SizedBox(
                                                height: 17,
                                              )
                                            ],
                                          ))
                                      : SizedBox(),
                              SizedBox(
                                height: 8,
                              ),
                              observer.userAppSettingsDoc!
                                          .departmentBasedContent ==
                                      true
                                  ? Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: MtCustomfontBoldSemi(
                                            color: Mycolors.black,
                                            text:
                                                '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}',
                                            fontsize: 15.6,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: MtCustomfontRegular(
                                            color: Mycolors.grey,
                                            text: ticket!.ticketDepartmentID,
                                            fontsize: 12.8,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.location_city,
                                          color: Mycolors.secondary,
                                        ),
                                        isThreeLine: false,
                                        onTap: () {},
                                      ))
                                  : SizedBox(),
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
                                                this.context, 'xxcreatedbyxx')
                                            .replaceAll(
                                                '(####)',
                                                getTranslatedForCurrentUser(
                                                    this.context, 'xxtktsxx'))
                                            .replaceAll('(###)', ""),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: ticket!.ticketcreatedBy == "sys"
                                          ? MtCustomfontRegular(
                                              text: getTranslatedForCurrentUser(
                                                  this.context, 'xxsystemxx'),
                                              fontsize: 12.8,
                                            )
                                          : ticket!.ticketcreatedBy == "Admin"
                                              ? MtCustomfontRegular(
                                                  text:
                                                      getTranslatedForCurrentUser(
                                                          this.context,
                                                          "xxadminxx"),
                                                  fontsize: 12.8,
                                                )
                                              : MtCustomfontRegular(
                                                  lineheight: 1.4,
                                                  color: Mycolors.grey,
                                                  text: widget.currentuserid ==
                                                          ticket!
                                                              .ticketcreatedBy
                                                      ? getTranslatedForCurrentUser(
                                                          this.context,
                                                          'xxmexx')
                                                      : widget.isCustomerViewing ==
                                                              true
                                                          ? observer
                                                                  .userAppSettingsDoc!
                                                                  .customercanseeagentnameandphoto!
                                                              ? "${registry.getUserData(this.context, ticket!.ticketcreatedBy).fullname} (${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${registry.getUserData(this.context, ticket!.ticketcreatedBy).id})" +
                                                                  "\n${registry.getUserData(this.context, ticket!.ticketcreatedBy).usertype == Usertype.agent.index ? getTranslatedForCurrentUser(this.context, 'xxagentxx') : getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}"
                                                              : "(${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${registry.getUserData(this.context, ticket!.ticketcreatedBy).id})" +
                                                                  "\n${registry.getUserData(this.context, ticket!.ticketcreatedBy).usertype == Usertype.agent.index ? getTranslatedForCurrentUser(this.context, 'xxagentxx') : getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}"
                                                          : observer
                                                                  .userAppSettingsDoc!
                                                                  .agentcanseeagentnameandphoto!
                                                              ? "${registry.getUserData(this.context, ticket!.ticketcreatedBy).fullname} (${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${registry.getUserData(this.context, ticket!.ticketcreatedBy).id})" +
                                                                  "\n${registry.getUserData(this.context, ticket!.ticketcreatedBy).usertype == Usertype.agent.index ? getTranslatedForCurrentUser(this.context, 'xxagentxx') : getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}"
                                                              : "(${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${registry.getUserData(this.context, ticket!.ticketcreatedBy).id})" +
                                                                  "\n${registry.getUserData(this.context, ticket!.ticketcreatedBy).usertype == Usertype.agent.index ? getTranslatedForCurrentUser(this.context, 'xxagentxx') : getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}",
                                                  fontsize: 12.8,
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
                                                    this.context, 'xxtktsxx')),
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
                                              ticket!.ticketcreatedOn,
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
                                height: 8,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        )));
  }

  editDescription(BuildContext context, String existingdesc) {
    _textEditingController.text = existingdesc;
    final observer = Provider.of<Observer>(this.context, listen: false);
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
                          maxcharacters: Numberlimits.maxTicketDesc,
                          boxcornerradius: 5.5,
                          // boxheight: 70,
                          hinttext:
                              "${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxdescxx')}",
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
                                    Numberlimits.maxTicketDesc) {
                                  Utils.toast(
                                    getTranslatedForCurrentUser(
                                            this.context, 'xxmaxxxcharxx')
                                        .replaceAll(
                                            '(####)',
                                            Numberlimits.maxTicketDesc
                                                .toString()),
                                  );
                                } else {
                                  Navigator.of(this.context).pop();
                                  ShowLoading().open(
                                      context: this.context,
                                      key: _keyLoader223);

                                  await docRef.update({
                                    Dbkeys.ticketDescription:
                                        _textEditingController.text.trim(),
                                  }).then((value) async {
                                    await FirebaseApi
                                        .runTransactionRecordActivity(
                                            parentid:
                                                "TICKET--${widget.ticketID}",
                                            title: _textEditingController.text
                                                        .trim()
                                                        .length <
                                                    1
                                                ? "Ticket Description Removed"
                                                : "Ticket Description Updated",
                                            plainDesc: _textEditingController
                                                    .text.isEmpty
                                                ? "Ticket Description Removed"
                                                : "Ticket ${ticket!.ticketTitle} description updated by ${widget.currentuserid}",
                                            postedbyID: widget.currentuserid,
                                            styledDesc: _textEditingController
                                                    .text.isEmpty
                                                ? "Ticket <bold>${ticket!.ticketTitle}</bold> (ID: ${widget.ticketCosmeticID}) Description Removed by ${widget.currentuserid}.   \n\n(Old Description was - ${ticket!.ticketDescription})"
                                                : "Ticket <bold>${ticket!.ticketTitle}</bold> (ID: ${widget.ticketCosmeticID}) description updated by ${widget.currentuserid}.  \n\n(New Description is - ${_textEditingController.text.trim()})",
                                            context: this.context,
                                            onSuccessFn: () async {
                                              _textEditingController.clear();
                                              ShowLoading().close(
                                                  context: this.context,
                                                  key: _keyLoader223);
                                              await fetchdata();
                                              widget.onrefreshPreviousPage();
                                            },
                                            onErrorFn: (e) {
                                              _textEditingController.clear();
                                              print(e.toString());
                                              ShowLoading().close(
                                                  context: this.context,
                                                  key: _keyLoader223);
                                              Utils.errortoast(
                                                  "E_5001: Error occured while runTransactionRecordActivity(). Please contact developer. ERROR: " +
                                                      e.toString());
                                            });
                                  }).catchError((e) {
                                    ShowLoading().close(
                                        context: this.context,
                                        key: _keyLoader223);
                                    Utils.toast(
                                        "E_5002: Error occured while updating description. Please contact developer. ERROR: " +
                                            e.toString());
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
