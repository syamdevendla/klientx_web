//*************   © Copyrighted by aagama_it.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/my_colors.dart';
//import 'package:aagama_it/Services/Admob/admob.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/optional_constants.dart';

class EditGroupDetails extends StatefulWidget {
  final String? groupName;
  final String? groupDesc;
  final String? groupType;
  final String? groupID;
  final String currentUserID;
  final bool isadmin;
  final SharedPreferences prefs;
  EditGroupDetails(
      {this.groupName,
      this.groupDesc,
      required this.isadmin,
      required this.prefs,
      this.groupID,
      this.groupType,
      required this.currentUserID});
  @override
  State createState() => new EditGroupDetailsState();
}

class EditGroupDetailsState extends State<EditGroupDetails> {
  TextEditingController? controllerName = new TextEditingController();
  TextEditingController? controllerDesc = new TextEditingController();

  bool isLoading = false;

  final FocusNode focusNodeName = new FocusNode();
  final FocusNode focusNodeDesc = new FocusNode();

  String? groupTitle;
  String? groupDesc;
  String? groupType;
  // final BannerAd myBanner = BannerAd(
  //   adUnitId: getBannerAdUnitId()!,
  //   size: AdSize.mediumRectangle,
  //   request: AdRequest(),
  //   listener: BannerAdListener(),
  // );
  // AdWidget? adWidget;
  var adWidget = null;
  @override
  void initState() {
    super.initState();
    Utils.internetLookUp();
    groupDesc = widget.groupDesc;
    groupTitle = widget.groupName;
    groupType = widget.groupType;
    controllerName!.text = groupTitle!;
    controllerDesc!.text = groupDesc!;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        // myBanner.load();
        // adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  void handleUpdateData() {
    focusNodeName.unfocus();
    focusNodeDesc.unfocus();

    setState(() {
      isLoading = true;
    });
    groupTitle =
        controllerName!.text.isEmpty ? groupTitle : controllerName!.text;
    groupDesc = controllerDesc!.text.isEmpty ? groupDesc : controllerDesc!.text;
    setState(() {});
    FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentGroups)
        .doc(widget.groupID)
        .update({
      Dbkeys.groupNAME: groupTitle ?? '',
      Dbkeys.groupDESCRIPTION: groupDesc ?? '',
      Dbkeys.groupTYPE: groupType,
    }).then((value) async {
      DateTime time = DateTime.now();
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentGroups)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc(time.millisecondsSinceEpoch.toString() +
              '--' +
              widget.currentUserID)
          .set({
        Dbkeys.groupmsgCONTENT: widget.isadmin
            ? getTranslatedForCurrentUser(
                this.context, 'xxgrpdetailsupdatebyadminxx')
            : '${widget.currentUserID} ${getTranslatedForCurrentUser(this.context, 'xxhasupdatedgrpdetailsxx')}',
        Dbkeys.deletedReason: '',
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
        Dbkeys.groupmsgSENDBY: widget.currentUserID,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails,
      });
      Navigator.of(this.context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Utils.toast(err.toString());
    });
  }

  void _handleTypeChange(String value) {
    setState(() {
      groupType = value;
    });
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
    final observer = Provider.of<Observer>(this.context, listen: false);
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
                  Icons.arrow_back,
                  size: 24,
                  color: Mycolors.black,
                ),
              ),
              titleSpacing: 0,
              backgroundColor: Colors.white,
              title: new Text(
                getTranslatedForCurrentUser(this.context, 'xxeditgroupxx'),
                style: TextStyle(
                  fontSize: 20.0,
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
                      color: Mycolors.primary,
                    ),
                  ),
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 25,
                      ),
                      InpuTextBox(
                          focuscolor: Mycolors.getColor(
                              widget.prefs, Colortype.primary.index),
                          title: getTranslatedForCurrentUser(
                              this.context, 'xxgroupnamexx'),
                          controller: controllerName,
                          validator: (v) {
                            return v!.isEmpty
                                ? getTranslatedForCurrentUser(
                                    this.context, 'xxvaliddetailsxx')
                                : null;
                          },
                          hinttext: getTranslatedForCurrentUser(
                              this.context, 'xxvaliddetailsxx')),
                      SizedBox(
                        height: 30,
                      ),
                      InpuTextBox(
                        focuscolor: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        controller: controllerDesc,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxgroupdescxx'),
                        maxLines: 10,
                        minLines: 1,
                        hinttext: getTranslatedForCurrentUser(
                            this.context, 'xxgroupdescxx'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(5, 20, 12, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 20, 12, 10),
                                child: Text(
                                  getTranslatedForCurrentUser(
                                      this.context, 'xxgrouptypexx'),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Both User & Admin Messages Allowed',
                                    groupValue: groupType,
                                    onChanged: (v) {
                                      _handleTypeChange(v!);
                                    },
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(this.context).size.width /
                                            1.5,
                                    child: Text(
                                      getTranslatedForCurrentUser(this.context,
                                              'xxbothxxmssgalowedxx')
                                          .replaceAll(
                                              '(####)',
                                              getTranslatedForCurrentUser(
                                                  this.context, 'xxagentxx')),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Only Admin Messages Allowed',
                                    groupValue: groupType,
                                    onChanged: (v) {
                                      _handleTypeChange(v!);
                                    },
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(this.context).size.width /
                                            1.5,
                                    child: Text(
                                      getTranslatedForCurrentUser(
                                          this.context, 'xxonlyadminxx'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      IsBannerAdShow == true &&
                              observer.isadmobshow == true &&
                              adWidget != null
                          ? Container(
                              height:
                                  MediaQuery.of(this.context).size.width - 30,
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
