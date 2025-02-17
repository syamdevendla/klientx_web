//*************   © Copyrighted by aagama_it.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Services/Providers/BroadcastProvider.dart';
import 'package:aagama_it/Services/Providers/GroupChatProvider.dart';
import 'package:aagama_it/Services/Providers/TicketChatProvider.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:flutter/material.dart';

class InfiniteCOLLECTIONListViewWidget extends StatefulWidget {
  final FirestoreDataProviderMESSAGESforGROUPCHAT?
      firestoreDataProviderMESSAGESforGROUPCHAT;
  final FirestoreDataProviderMESSAGESforTICKETCHAT?
      firestoreDataProviderMESSAGESforTICKETCHAT;
  final FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE?
      firestoreDataProviderMESSAGESforBROADCASTCHATPAGE;
  final String? datatype;
  final Widget? list;
  final Query? refdata;
  final bool? isreverse;
  final EdgeInsets? padding;
  final String? parentid;
  final ScrollController scrollController;
  const InfiniteCOLLECTIONListViewWidget({
    this.firestoreDataProviderMESSAGESforGROUPCHAT,
    this.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE,
    this.firestoreDataProviderMESSAGESforTICKETCHAT,
    this.datatype,
    this.isreverse,
    this.padding,
    this.parentid,
    this.list,
    this.refdata,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  _InfiniteCOLLECTIONListViewWidgetState createState() =>
      _InfiniteCOLLECTIONListViewWidgetState();
}

class _InfiniteCOLLECTIONListViewWidgetState
    extends State<InfiniteCOLLECTIONListViewWidget> {
  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(scrollListener);
    if (widget.datatype == Dbkeys.datatypeGROUPCHATMSGS) {
      widget.firestoreDataProviderMESSAGESforGROUPCHAT!
          .fetchNextData(widget.datatype, widget.refdata, true);
    } else if (widget.datatype == Dbkeys.datatypeBROADCASTCMSGS) {
      widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
          .fetchNextData(widget.datatype, widget.refdata, true);
    } else if (widget.datatype == Dbkeys.datatypeTICKETMSSGS) {
      widget.firestoreDataProviderMESSAGESforTICKETCHAT!
          .fetchNextData(widget.datatype, widget.refdata, true);
    }
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (widget.scrollController.offset >=
            widget.scrollController.position.maxScrollExtent / 2 &&
        !widget.scrollController.position.outOfRange) {
      if (widget.datatype == Dbkeys.datatypeGROUPCHATMSGS) {
        if (widget.firestoreDataProviderMESSAGESforGROUPCHAT!.hasNext) {
          widget.firestoreDataProviderMESSAGESforGROUPCHAT!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      } else if (widget.datatype == Dbkeys.datatypeBROADCASTCMSGS) {
        if (widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!.hasNext) {
          widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      } else if (widget.datatype == Dbkeys.datatypeTICKETMSSGS) {
        if (widget.firestoreDataProviderMESSAGESforTICKETCHAT!.hasNext) {
          widget.firestoreDataProviderMESSAGESforTICKETCHAT!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      reverse:
          widget.isreverse == null || widget.isreverse == false ? false : true,
      controller: widget.scrollController,
      padding: widget.padding == null ? EdgeInsets.all(0) : widget.padding,
      children: widget.datatype == Dbkeys.datatypeTICKETMSSGS
          ? [
              Container(child: widget.list),
              (widget.firestoreDataProviderMESSAGESforTICKETCHAT!.hasNext ==
                      true)
                  ? Center(
                      child: GestureDetector(
                        onTap: () {
                          widget.firestoreDataProviderMESSAGESforTICKETCHAT!
                              .fetchNextData(
                                  widget.datatype, widget.refdata, false);
                        },
                        child: Padding(
                          padding:
                              widget.firestoreDataProviderMESSAGESforTICKETCHAT!
                                          .recievedDocs.length ==
                                      0
                                  ? EdgeInsets.fromLTRB(
                                      38,
                                      MediaQuery.of(context).size.height / 3,
                                      38,
                                      38)
                                  : EdgeInsets.fromLTRB(18, 38, 18, 48),
                          child: Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Mycolors.secondary),
                            ),
                          ),
                        ),
                      ),
                    )
                  : widget.firestoreDataProviderMESSAGESforTICKETCHAT!
                              .recievedDocs.length <
                          1
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.fromLTRB(26, 28, 26, 97),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.message_rounded,
                                size: 60,
                                color: Mycolors.secondary,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                getTranslatedForCurrentUser(
                                    context, 'xxnorecentchatsxx'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Mycolors.grey, fontSize: 16),
                              )
                            ],
                          ),
                        ))
                      : SizedBox(),
            ]
          : widget.datatype == Dbkeys.datatypeBROADCASTCMSGS
              ? [
                  Container(child: widget.list),
                  (widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                              .hasNext ==
                          true)
                      ? Center(
                          child: GestureDetector(
                            onTap: () {
                              widget
                                  .firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                                  .fetchNextData(
                                      widget.datatype, widget.refdata, false);
                            },
                            child: Padding(
                              padding:
                                  widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                                              .recievedDocs.length ==
                                          0
                                      ? EdgeInsets.fromLTRB(
                                          38,
                                          MediaQuery.of(context).size.height /
                                              3,
                                          38,
                                          38)
                                      : EdgeInsets.fromLTRB(18, 38, 18, 48),
                              child: Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Mycolors.secondary),
                                ),
                              ),
                            ),
                          ),
                        )
                      : widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                                  .recievedDocs.length <
                              1
                          ? Center(
                              child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(26, 28, 26, 97),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message_rounded,
                                    size: 60,
                                    color: Mycolors.secondary,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getTranslatedForCurrentUser(
                                        context, 'xxnorecentchatsxx'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Mycolors.grey, fontSize: 16),
                                  )
                                ],
                              ),
                            ))
                          : SizedBox(),
                ]
              : [
                  Container(child: widget.list),
                  (widget.firestoreDataProviderMESSAGESforGROUPCHAT!.hasNext ==
                          true)
                      ? Center(
                          child: GestureDetector(
                            onTap: () {
                              widget.firestoreDataProviderMESSAGESforGROUPCHAT!
                                  .fetchNextData(
                                      widget.datatype, widget.refdata, false);
                            },
                            child: Padding(
                              padding:
                                  widget.firestoreDataProviderMESSAGESforGROUPCHAT!
                                              .recievedDocs.length ==
                                          0
                                      ? EdgeInsets.fromLTRB(
                                          38,
                                          MediaQuery.of(context).size.height /
                                              3,
                                          38,
                                          38)
                                      : EdgeInsets.fromLTRB(18, 38, 18, 18),
                              child: Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Mycolors.secondary),
                                ),
                              ),
                            ),
                          ),
                        )
                      : widget.firestoreDataProviderMESSAGESforGROUPCHAT!
                                  .recievedDocs.length <
                              1
                          ? Center(
                              child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(26, 28, 26, 97),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message_rounded,
                                    size: 60,
                                    color: Mycolors.secondary,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    getTranslatedForCurrentUser(
                                        context, 'xxnorecentchatsxx'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Mycolors.grey, fontSize: 16),
                                  )
                                ],
                              ),
                            ))
                          : SizedBox(),
                ]);
}
