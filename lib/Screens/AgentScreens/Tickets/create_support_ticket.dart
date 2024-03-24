//*************   © Copyrighted by aagama_it.

// ignore_for_file: unnecessary_statements

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Configs/number_limits.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/department_model.dart';
import 'package:aagama_it/Models/ticket_message.dart';
import 'package:aagama_it/Models/ticket_model.dart';
import 'package:aagama_it/Models/userapp_settings_model.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/selectDepartment.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/callhistory.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:aagama_it/Screens/chat_screen/chat.dart';
import 'package:aagama_it/Services/FirebaseServices/firebase_api.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Utils/getRolePermission.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'autoComplete.dart';
import 'country_page.dart';

class CreateSupportTicket extends StatefulWidget {
  final String currentUserID;
  final String customerUID;

  final SharedPreferences prefs;
  CreateSupportTicket(
      {required this.currentUserID,
      required this.customerUID,
      required this.prefs});

  @override
  _CreateSupportTicketState createState() => _CreateSupportTicketState();
}

class _CreateSupportTicketState extends State<CreateSupportTicket> {
  TextEditingController _titletextcontroller = new TextEditingController();
  TextEditingController _desctextcontroller = new TextEditingController();
  TextEditingController _categorytextcontroller = new TextEditingController();
  TextEditingController _orgtextcontroller = new TextEditingController();
  bool isloading = true;
  final tempDoc = [];
  List<dynamic>? listOrg = [];
  static List<String> _fruitOptions = [];

  BuildContext? ctx;
  @override
  void initState() {
    super.initState();
    ctx = ctx ?? this.context;

    print("syam prints -- CreateSupportTicket initState - 001");

    // QuerySnapshot querySnapshot =
    //     FirebaseFirestore.instance.collection("organization").getDocuments();
    // var list = querySnapshot.documents;

    // CollectionReference _cat =
    //     FirebaseFirestore.instance.collection("organization");
    // QuerySnapshot querySnapshot = _cat.get();
    // final _docData = querySnapshot.docs.map((doc) => doc.data()).toList();
    // print(_docData);
    _fruitOptions = [];
    FirebaseFirestore.instance.collection("organization").get().then(
      (value) {
        listOrg = value.docs;
        value.docs.forEach(
          (element) {
            // print(element.data());
            _fruitOptions.add(element.data()['orgName']);
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer =
          Provider.of<Observer>(ctx ?? this.ctx ?? this.context, listen: false);
      listMap = iAmSecondAdmin(
                  currentuserid: widget.currentUserID,
                  context: ctx ?? this.context) ==
              true
          ? observer.departmentlistlive
          : iAmDepartmentManager(
                      userappsettings: observer.userAppSettingsDoc!,
                      currentuserid: widget.currentUserID,
                      context: ctx ?? this.context) ==
                  true
              ? observer.userAppSettingsDoc!
                          .departmentmanagerCanViewGlobalDepartments ==
                      true
                  ? observer.departmentlistlive
                  : observer.departmentlistlive
                      .where((element) =>
                          element.departmentManagerID == widget.currentUserID)
                      .toList()
              : observer.userAppSettingsDoc!.departmentBasedContent == true
                  ? widget.customerUID == widget.currentUserID
                      ? observer.departmentlistlive
                      : observer.departmentlistlive
                          .where((element) => element.departmentAgentsUIDList
                              .contains(widget.currentUserID))
                          .toList()
                  : observer.userAppSettingsDoc!.departmentList!
                      .map((e) => DepartmentModel.fromJson(e))
                      .toList();
      selectedcategory = listMap!.first;
      _categorytextcontroller.text = selectedcategory!.departmentTitle;
      listcategory = listMap;
      listdepartments = listMap;

      setState(() {});
    });
    Future.delayed(const Duration(milliseconds: 200), () {
// Here you can write your code
      setMembersData();
    });
  }

  setMembersData() {
    if (selectedcategory == null) {
      Utils.toast(getTranslatedForCurrentUser(
              ctx ?? this.ctx ?? this.context, 'xxnodeptagentsxx')
          .replaceAll(
              '(####)',
              getTranslatedForCurrentUser(
                  ctx ?? this.context, 'xxdepartmentxx'))
          .replaceAll('(###)',
              getTranslatedForCurrentUser(ctx ?? this.context, 'xxagentsxx'))
          .replaceAll(
              '(##)',
              getTranslatedForCurrentUser(
                  ctx ?? this.context, 'xxsupporttktxx')));
      Navigator.of(ctx ?? this.context).pop();
    } else {
      agentlist.clear();
      setState(() {});
      agentlist = selectedcategory!.departmentAgentsUIDList;
      if (!agentlist.contains(widget.currentUserID) &&
          widget.currentUserID != widget.customerUID) {
        agentlist.add(widget.currentUserID);
      }

      setState(() {
        isloading = false;
      });
    }
  }

  setOrgData(id) {
    //print(id);
    if (id != '') {
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
          _orgtextcontroller.text = doc['orgName'];
          setState(() {
            selectedOrg = id;
            selectedOrgPhoto = doc['orgphotourl'];
            selectedOrgName = doc['orgName'];
          });
        }
      });
      listcategoryDisplay = listdepartments!
          .where((element) => element.departmentCreatedby == id)
          .toList();
      _categorytextcontroller.text = "";

      setState(() {
        selectedOrg = id;
        //selectedcategory = null;
      });
    } else {
      listcategoryDisplay = [];
    }
  }

  setOrgDataAuto(orgName) {
    listOrg!.forEach(
      (element) {
        if (element.data()['orgName'] == orgName) {
          setOrgData(element.id);
        }
      },
    );
  }

  setOrgDataAutoWIthID(orgId) {
    setOrgData(orgId);
  }

  @override
  void dispose() {
    super.dispose();
    _titletextcontroller.dispose();
    _desctextcontroller.dispose();
    _categorytextcontroller.dispose();
    _orgtextcontroller.dispose();
  }

  DepartmentModel? selectedcategory;
  List<DepartmentModel>? listMap;
  List<DepartmentModel>? listcategory = [];
  List<DepartmentModel>? listcategoryDisplay = [];
  List<DepartmentModel>? listdepartments = [];
  List<dynamic> agentlist = [];
  String selectedOrg = '';
  String selectedOrgPhoto = '';
  String selectedOrgName = '';

  // static const List<String> _fruitOptions = <String>[
  //   'apple',
  //   'banana',
  //   'orange',
  //   'mango',
  //   'grapes',
  //   'watermelon',
  //   'kiwi',
  //   'strawberry',
  //   'sugarcane',
  // ];

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(ctx ?? this.context, listen: true);
    final registry =
        Provider.of<UserRegistry>(ctx ?? this.context, listen: true);
    //print(listOrg);
    // SpecialLiveConfigData? livedata =
    //     Provider.of<SpecialLiveConfigData?>(ctx?? this.context, listen: true);
    var cusd = registry.getUserData(this.context, widget.currentUserID);
    if (cusd.usertype == 1) {
      _fruitOptions = [];
      setOrgDataAutoWIthID(cusd.us1);
      FirebaseFirestore.instance.collection("organization").get().then(
        (value) {
          listOrg = value.docs;
          value.docs.forEach(
            (element) {
              if (element.id == cusd.us1) {
                _fruitOptions.add(element.data()['orgName']);
              }
            },
          );
        },
      );
    }
    return PickupLayout(
        curentUserID: widget.currentUserID,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(MyScaffold(
          backgroundColor: Colors.white,
          title: getTranslatedForCurrentUser(ctx ?? this.context, 'xxcreatexx')
              .replaceAll(
                  '(####)',
                  getTranslatedForCurrentUser(
                      ctx ?? this.context, 'xxsupporttktxx')),
          iconTextColor: Mycolors.whiteDynamic,
          appbarColor: Mycolors.getColor(widget.prefs, Colortype.primary.index),
          body: isloading == true
              ? circularProgress()
              : ListView(
                  padding: EdgeInsets.all(15),
                  children: [
                    widget.currentUserID == widget.customerUID
                        ? SizedBox()
                        : SizedBox(
                            height: 20,
                          ),
                    widget.currentUserID == widget.customerUID
                        ? SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MtCustomfontBoldSemi(
                                text: getTranslatedForCurrentUser(
                                        ctx ?? this.context, 'xxxxdetailsxx')
                                    .replaceAll(
                                        '(####)',
                                        getTranslatedForCurrentUser(
                                            ctx ?? this.context,
                                            getTranslatedForCurrentUser(
                                                ctx ?? this.context,
                                                'xxcustomerxx'))),
                                fontsize: 13,
                                color: Mycolors.grey,
                              ),
                              SizedBox(height: 5),
                              ListTile(
                                leading: customCircleAvatar(
                                    url: registry
                                        .getUserData(ctx ?? this.context,
                                            widget.customerUID)
                                        .photourl,
                                    radius: 20),
                                title: MtCustomfontBoldSemi(
                                  text: registry
                                      .getUserData(ctx ?? this.context,
                                          widget.customerUID)
                                      .fullname,
                                  fontsize: 16,
                                ),
                                subtitle: MtCustomfontRegular(
                                  text:
                                      '${getTranslatedForCurrentUser(ctx ?? this.context, 'xxcustomeridxx')} ' +
                                          "${widget.customerUID}",
                                  fontsize: 13,
                                ),
                              ),
                              MtCustomfontBoldSemi(
                                text: '',
                                fontsize: 16,
                              )
                            ],
                          ),
                    widget.currentUserID == widget.customerUID
                        ? SizedBox()
                        : SizedBox(
                            height: 10,
                          ),
                    //AutoComplete(),
                    Text("Organization",
                        style: TextStyle(
                          color: Mycolors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        )),
                    InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 0.5),
                        hintText: "Search..",
                      ),
                      child: Autocomplete(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return _fruitOptions.where((String option) {
                            return (option.toLowerCase())
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },

                        onSelected: (selection) {
                          setOrgDataAuto(selection);
                        },
                        //),
                      ),
                    ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Autocomplete<String>(
                    //       optionsBuilder:
                    //           (TextEditingValue fruitTextEditingValue) {
                    //         // if user is input nothing
                    //         if (fruitTextEditingValue.text == '') {
                    //           return const Iterable<String>.empty();
                    //         }

                    //         // if user is input something the build
                    //         // suggestion based on the user input
                    //         return _fruitOptions.where((String option) {
                    //           return option.contains(
                    //               fruitTextEditingValue.text.toLowerCase());
                    //         });
                    //       },

                    //       // when user click on the suggested
                    //       // item this function calls
                    //       onSelected: (String value) {
                    //         debugPrint('You just selected $value');
                    //       },
                    //     ),
                    //   ],
                    // ),

                    // InpuTextBox(
                    //   focuscolor: Mycolors.getColor(
                    //       widget.prefs, Colortype.primary.index),
                    //   controller: _orgtextcontroller, disabled: true,
                    //   // maxcharacters: Numberlimits.maxTicketTitle,
                    //   title: 'Organization',
                    //   hinttext: 'Select Organization',
                    //   sufficIconbutton: observer.departmentlistlive.length < 2
                    //       ? null
                    //       : IconButton(
                    //           icon: Icon(Icons.keyboard_arrow_down),
                    //           onPressed: () {
                    //             // listcategory!.removeAt(0);
                    //             selectAOrg(
                    //                 context: ctx ?? this.context,
                    //                 title: 'Select  Organization',
                    //                 datalist: listOrg!,
                    //                 alreadyselected: selectedOrg,
                    //                 onselected: (id) {
                    //                   // _orgtextcontroller.text =
                    //                   //     s.departmentTitle;
                    //                   // setState(() {
                    //                   //   selectedcategory = s;
                    //                   // });

                    //                   setOrgData(id);
                    //                   hidekeyboard(ctx ?? this.context);
                    //                 },
                    //                 prefs: widget.prefs);
                    //           },
                    //         ),
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    observer.userAppSettingsDoc!.departmentBasedContent ==
                                false ||
                            observer.departmentlistlive.length < 1
                        ? SizedBox()
                        : InpuTextBox(
                            focuscolor: Mycolors.getColor(
                                widget.prefs, Colortype.primary.index),
                            controller: _categorytextcontroller, disabled: true,
                            // maxcharacters: Numberlimits.maxTicketTitle,
                            title: getTranslatedForCurrentUser(
                                    ctx ?? this.context, 'xxtktsxx') +
                                " " +
                                getTranslatedForCurrentUser(
                                    ctx ?? this.context, 'xxdepartmentxx'),
                            hinttext: getTranslatedForCurrentUser(
                                    ctx ?? this.context, 'xxselectaxxxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        ctx ?? this.context, 'xxdepartmentxx')),
                            sufficIconbutton: observer
                                        .departmentlistlive.length <
                                    2
                                ? null
                                : IconButton(
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    onPressed: () {
                                      // listcategory!.removeAt(0);
                                      selectADepartment(
                                          context: ctx ?? this.context,
                                          title: getTranslatedForCurrentUser(
                                                  ctx ?? this.context,
                                                  'xxselectaxxxx')
                                              .replaceAll(
                                                  '(####)',
                                                  getTranslatedForCurrentUser(
                                                          ctx ?? this.context,
                                                          'xxtktsxx') +
                                                      " " +
                                                      getTranslatedForCurrentUser(
                                                          ctx ?? this.context,
                                                          'xxdepartmentxx')),
                                          datalist: listcategoryDisplay!,
                                          alreadyselected: selectedcategory,
                                          onselected: (s) {
                                            _categorytextcontroller.text =
                                                s.departmentTitle;
                                            setState(() {
                                              selectedcategory = s;
                                            });
                                            setMembersData();
                                            hidekeyboard(ctx ?? this.context);
                                          },
                                          prefs: widget.prefs);
                                    },
                                  ),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    InpuTextBox(
                      focuscolor: Mycolors.getColor(
                          widget.prefs, Colortype.primary.index),
                      controller: _titletextcontroller,
                      maxcharacters: Numberlimits.maxTicketTitle,
                      title: getTranslatedForCurrentUser(
                              ctx ?? this.context, 'xxtktsxx') +
                          " " +
                          getTranslatedForCurrentUser(
                              ctx ?? this.context, 'xxtitlexx'),
                      hinttext: getTranslatedForCurrentUser(
                              ctx ?? this.context, 'xxtktsxx') +
                          " " +
                          getTranslatedForCurrentUser(
                              ctx ?? this.context, 'xxtitlexx'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InpuTextBox(
                      maxLines: 10,
                      minLines: 7,
                      focuscolor: Mycolors.getColor(
                          widget.prefs, Colortype.primary.index),
                      controller: _desctextcontroller,
                      maxcharacters: Numberlimits.maxTicketDesc,
                      title: getTranslatedForCurrentUser(
                              ctx ?? this.context, 'xxtktsxx') +
                          " " +
                          getTranslatedForCurrentUser(
                              ctx ?? this.context, 'xxdescxx'),
                      hinttext:
                          '(${getTranslatedForCurrentUser(ctx ?? this.context, 'xxoptionalxx')})',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MySimpleButtonWithIcon(
                      iconData: Icons.add,
                      buttoncolor: Mycolors.getColor(
                          widget.prefs, Colortype.secondary.index),
                      buttontext: getTranslatedForCurrentUser(
                              ctx ?? this.context, 'xxcreatexx')
                          .replaceAll(
                              '(####)',
                              getTranslatedForCurrentUser(
                                  ctx ?? this.context, 'xxtktsxx')),
                      onpressed: observer.checkIfCurrentUserIsDemo(
                                  widget.currentUserID) ==
                              true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  ctx ?? this.context,
                                  'xxxnotalwddemoxxaccountxx'));
                            }
                          : () async {
                              if (_titletextcontroller.text.trim().isEmpty) {
                                Utils.toast(getTranslatedForCurrentUser(
                                    ctx ?? this.context,
                                    'xxpleasefillrequiredinfoxx'));
                              } else if (observer.departmentlistlive.length <
                                      1 &&
                                  observer.userAppSettingsDoc!
                                          .departmentBasedContent ==
                                      true) {
                                Utils.toast(getTranslatedForCurrentUser(
                                        ctx ?? this.context, 'xxnodeptagentsxx')
                                    .replaceAll(
                                        '(####)',
                                        getTranslatedForCurrentUser(
                                            ctx ?? this.context,
                                            'xxdepartmentxx'))
                                    .replaceAll(
                                        '(###)',
                                        getTranslatedForCurrentUser(
                                            ctx ?? this.context, 'xxagentsxx'))
                                    .replaceAll(
                                        '(##)',
                                        getTranslatedForCurrentUser(
                                            ctx ?? this.context,
                                            'xxsupporttktxx')));
                              } else {
                                setState(() {
                                  isloading = true;
                                });
                                String cosmeticID =
                                    randomNumeric(Numberlimits.ticketIDlength);
                                String ticketID = '$cosmeticID';

                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectiontickets)
                                    .doc(ticketID)
                                    .get()
                                    .then((value) async {
                                  if (value.exists) {
                                    String cosmeticID1 = randomNumeric(
                                        Numberlimits.ticketIDlength);
                                    String ticketID1 = '$cosmeticID1';

                                    await FirebaseFirestore.instance
                                        .collection(DbPaths.collectiontickets)
                                        .doc(ticketID1)
                                        .get()
                                        .then((value1) async {
                                      if (value1.exists) {
                                        String cosmeticID2 = randomNumeric(
                                            Numberlimits.ticketIDlength);
                                        String ticketID2 = '$cosmeticID2';

                                        await FirebaseFirestore.instance
                                            .collection(
                                                DbPaths.collectiontickets)
                                            .doc(ticketID2)
                                            .get()
                                            .then((value2) async {
                                          if (value2.exists) {
                                            setState(() {
                                              isloading = false;
                                            });
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    ctx ?? this.context,
                                                    'xxfailedxx'));
                                          } else {
                                            await createTicket(
                                                ctx ?? this.context,
                                                widget.currentUserID,
                                                observer.userAppSettingsDoc!,
                                                ticketID2,
                                                ticketID2);
                                          }
                                        });
                                      } else {
                                        await createTicket(
                                            ctx ?? this.context,
                                            widget.currentUserID,
                                            observer.userAppSettingsDoc!,
                                            ticketID1,
                                            ticketID1);
                                      }
                                    });
                                  } else {
                                    await createTicket(
                                        ctx ?? this.context,
                                        widget.currentUserID,
                                        observer.userAppSettingsDoc!,
                                        ticketID,
                                        ticketID);
                                  }
                                });
                              }
                            },
                    )
                  ],
                ),
        )));
  }

  createTicket(
    BuildContext context,
    String manageruid,
    UserAppSettingsModel userAppSettings,
    String ticketID,
    String cosmeticID,
  ) async {
    final registry =
        Provider.of<UserRegistry>(ctx ?? this.context, listen: false);

    int timestamp = DateTime.now().millisecondsSinceEpoch;

    await FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(ticketID.toString())
        .set(TicketModel(
          ticketMap9: {},
          ticketStatusShort: agentlist.length > 0
              ? TicketStatusShort.active.index
              : TicketStatusShort.notstarted.index,
          tktdepartmentNameList: [
            selectedcategory!.departmentTitle,
          ],
          ticketcosmeticID: cosmeticID,
          ticketID: ticketID,
          ticketcustomerID: widget.customerUID,
          ticketissuedby: manageruid == widget.currentUserID
              ? Usertype.secondadmin.index.toString()
              : widget.prefs.getInt(Dbkeys.userLoginType).toString(),
          ticketStatus: agentlist.length > 0
              ? TicketStatus.active.index
              : TicketStatus.waitingForAgentsToJoinTicket.index,
          ticketTitle: _titletextcontroller.text.trim(),
          ticketPhotoURL: '',
          ticketOrgId: selectedOrg,
          ticketOrgPhoto: selectedOrgPhoto,
          ticketOrgName: selectedOrgName,
          ticketDepartmentID: selectedcategory!.departmentTitle,
          departmentNamestoredinList: selectedcategory!.departmentTitle,
          ticketDescription: _desctextcontroller.text.trim(),
          ticketcreatedBy: widget.currentUserID,
          ticketidFiltered: ticketID,
          ticketisTyingID: '',
          ticketclosedby: '',
          ticketchatdeletedby: '',
          ticketCallInfoMap: {},
          ticketcreatedOn: timestamp,
          ticketlatestTimestampForCustomer: timestamp,
          ticketmediaDeletedTimestamp: 0,
          tktMEMBERSactiveList: agentlist,
          tktNOTIFICATIONactiveList: agentlist,
          ticketadminlist: [manageruid],
          transcriptsGeneratedBy: [],
          rating: 0,
          isreviewRequired: true,
          ticketSecondaryStatus: '',
          ticketlatestTimestampForAgents: timestamp,
          tktLastMssgBy: widget.currentUserID,
        ).toMap())
        .then((value) {
      FirebaseFirestore.instance
          .collection(DbPaths.collectiontickets)
          .doc(ticketID)
          .collection(DbPaths.collectionticketChats)
          .doc(timestamp.toString() + '--' + widget.currentUserID)
          .set(
              TicketMessage(
                      tktMssgCONTENT: '${_desctextcontroller.text.trim()}',
                      tktMssgISDELETED: false,
                      tktMssgTIME: timestamp,
                      tktMssgSENDBY: widget.currentUserID,
                      tktMssgTYPE: MessageType.rROBOTticketcreated.index,
                      tktMssgSENDERNAME: registry
                          .getUserData(
                              ctx ?? this.context, widget.currentUserID)
                          .fullname,
                      tktMssgTicketName: _titletextcontroller.text.trim(),
                      tktMssgTicketIDflitered: ticketID,
                      tktMssgSENDFOR: [
                        MssgSendFor.agent.index,
                        MssgSendFor.customer.index,
                      ],
                      tktMsgCUSTOMERID: widget.customerUID,
                      tktMsgSenderIndex: widget.prefs
                                      .getInt(Dbkeys.userLoginType) ==
                                  Usertype.customer.index ||
                              widget.prefs.getInt(Dbkeys.userLoginType) == null
                          ? Usertype.customer.index
                          : Usertype.agent.index,
                      notificationActiveList: agentlist,
                      //-----
                      tktMssgISREPLY: false,
                      tktMssgISFORWARD: false,
                      tktMssgREPLYTOMSSGDOC: {},
                      tktMsgInt2: 0,
                      isShowSenderNameInNotification: true,
                      tktMsgBool2: true,
                      tktMsgList2: [],
                      tktMsgList3: [],
                      tktMssgLISToptional: [],
                      tktMsgMap1: {},
                      tktMsgMap2: {},
                      tktMsgDELETEREASON: '',
                      tktMsgDELETEDby: '',
                      tktMsgString4: '',
                      tktMsgString5: '',
                      ttktMsgString3: '')
                  .toMap(),
              SetOptions(merge: true));
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection(DbPaths.userapp)
          .doc(DbPaths.docdashboarddata)
          .update({Dbkeys.totalopentickets: FieldValue.increment(1)});

      agentlist.forEach((agent) async {
        await Utils.sendDirectNotification(
            title: getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxnewxxassignedxx')
                .replaceAll(
                    '(####)',
                    getTranslatedForEventsAndAlerts(
                        ctx ?? this.context, 'xxtktsxx')),
            parentID: "TICKET--$ticketID",
            plaindesc: widget.currentUserID == widget.customerUID
                ? getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxyouareassignedxx')
                    .replaceAll(
                        '(####)',
                        getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxticketidxx') +
                            " $cosmeticID")
                : getTranslatedForEventsAndAlerts(
                        ctx ?? this.context, 'xxyouareassignedbyxx')
                    .replaceAll(
                        '(####)',
                        getTranslatedForEventsAndAlerts(
                            ctx ?? this.context, 'xxticketidxx'))
                    .replaceAll(
                        '(###)',
                        getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxagentidxx') +
                            " ${widget.currentUserID}")
                    .replaceAll('(##)', getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxcustomeridxx') + " ${widget.customerUID}"),
            // styleddesc: widget.currentUserID == widget.customerUID
            //     ? "You are assigned to a New Ticket ID: <bold>$cosmeticID</bold> automatically."
            //     : "You are <bold>assigned</bold> to a New Ticket ID: <bold>$cosmeticID</bold> by Agent ID: <bold>${widget.currentUserID}</bold> for Customer ID: <bold>${widget.customerUID}</bold>\n\nTicket Title: <bold>${_titletextcontroller.text.trim()}</bold> automatically.",
            docRef: FirebaseFirestore.instance.collection(DbPaths.collectionagents).doc(agent).collection(DbPaths.agentnotifications).doc(DbPaths.agentnotifications),
            postedbyID: widget.currentUserID);
      });
      await Utils.sendDirectNotification(
          title: getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxnewxxcreatedxx').replaceAll(
              '(####)',
              getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxtktsxx')),
          parentID: "TICKET--$ticketID",
          plaindesc: widget.currentUserID == widget.customerUID
              ? getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxhavecreatedxx')
                      .replaceAll(
                          '(####)',
                          getTranslatedForEventsAndAlerts(
                              ctx ?? this.context, 'xxyouxx'))
                      .replaceAll(
                          '(###)',
                          getTranslatedForEventsAndAlerts(
                              ctx ?? this.context, 'xxsupporttktxx')) +
                  ". ${getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxticketidxx')} $cosmeticID"
              : getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxcreatedforyouxx')
                      .replaceAll(
                          '(####)', getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxsupporttktxx'))
                      .replaceAll('(###)', getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxyouxx')) +
                  ". ${getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxticketidxx')} $cosmeticID",
          docRef: FirebaseFirestore.instance.collection(DbPaths.collectioncustomers).doc(widget.customerUID).collection(DbPaths.customernotifications).doc(DbPaths.customernotifications),
          postedbyID: widget.currentUserID);

      await FirebaseApi.runTransactionRecordActivity(
        parentid: "TICKET--$ticketID",
        title: getTranslatedForEventsAndAlerts(
                ctx ?? this.context, 'xxnewxxcreatedxx')
            .replaceAll(
                '(####)',
                getTranslatedForEventsAndAlerts(
                    ctx ?? this.context, 'xxtktsxx')),
        postedbyID: widget.currentUserID,
        onErrorFn: (e) {
          Navigator.of(ctx ?? this.context).pop();
          print('ERROR OCCURED $e');
        },
        onSuccessFn: () {
          Navigator.of(ctx ?? this.context).pop();
          Utils.toast(getTranslatedForCurrentUser(
                      ctx ?? this.context, 'xxcreatedwithidxx')
                  .replaceAll(
                      '(####)',
                      getTranslatedForCurrentUser(
                          ctx ?? this.context, 'xxsupporttktxx'))
                  .replaceAll(
                      '(###)',
                      getTranslatedForCurrentUser(
                          ctx ?? this.context, 'xxticketidxx')) +
              ' $cosmeticID');
        },
        plainDesc: widget.currentUserID == widget.customerUID
            ? getTranslatedForEventsAndAlerts(
                        ctx ?? this.context, 'xxhavecreatedxx')
                    .replaceAll(
                        '(####)',
                        getTranslatedForEventsAndAlerts(
                            ctx ?? this.context,
                            getTranslatedForCurrentUser(
                                ctx ?? this.context, 'xxcustomerxx')))
                    .replaceAll(
                        '(###)',
                        getTranslatedForEventsAndAlerts(
                            ctx ?? this.context, 'xxsupporttktxx')) +
                ". ${getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxticketidxx')} $cosmeticID"
            : getTranslatedForEventsAndAlerts(
                        ctx ?? this.context, 'xxcreatedforyouxx')
                    .replaceAll(
                        '(####)',
                        getTranslatedForEventsAndAlerts(
                            ctx ?? this.context, 'xxsupporttktxx'))
                    .replaceAll('(###)',
                        '${getTranslatedForCurrentUser(ctx ?? this.context, 'xxcustomeridxx')} ${widget.customerUID}') +
                ". ${getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxticketidxx')} $cosmeticID" +
                ". ${getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxxcreatedbyxx')} ${getTranslatedForEventsAndAlerts(ctx ?? this.context, 'xxagentidxx')} ${widget.currentUserID}",
      );
    }).catchError((e) {
      Navigator.of(ctx ?? this.context).pop();
      print('ERROR OCCURED $e');
      Utils.toast(
        'An error occurred while creating the Ticket. Please try again or contact admin. ERROR- $e',
      );
    });
  }
}

String getFilteredticketID(String ticketID) {
  return ticketID;
}
