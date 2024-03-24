// //*************   © Copyrighted by aagama_it. 

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:aagama_it/Configs/Dbpaths.dart';
// import 'package:aagama_it/Configs/app_constants.dart';
// import 'package:aagama_it/Configs/db_keys.dart';
// import 'package:aagama_it/Configs/my_colors.dart';
// import 'package:aagama_it/Models/DataModel.dart';
// import 'package:aagama_it/Screens/AgentScreens/broadcast/BroadcastChatPage.dart';
// import 'package:aagama_it/Screens/AgentScreens/calls/callhistory.dart';
// import 'package:aagama_it/Screens/chat_screen/chat_tiles/getLastMessageTime.dart';
// import 'package:aagama_it/Localization/language_constants.dart';
// import 'package:aagama_it/Utils/unawaited.dart';
// import 'package:aagama_it/widgets/OtherCustomWidgets/late_load.dart';


// Widget broadcastMessageTile(
//     {required BuildContext context,
//     required List<Map<String, dynamic>> streamDocSnap,
//     required int index,
//     required String currentUserNo,
//     required SharedPreferences prefs,
//     required DataModel cachedModel}) {
//   showMenuForBroadcastChat(
//     contextForDialog,
//     var broadcastDoc,
//   ) {
//     List<Widget> tiles = List.from(<Widget>[]);

//     tiles.add(ListTile(
//         dense: true,
//         leading: Icon(Icons.delete, size: 22),
//         title: Text(
//           getTranslatedForCurrentUser(contextForDialog, 'deletebroadcast'),
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         onTap: () async {
//           Navigator.of(contextForDialog).pop();
//           unawaited(showDialog(
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: new Text(getTranslatedForCurrentUser(context, 'deletebroadcast')),
//                 actions: [
//                   // ignore: deprecated_member_use
//                   FlatButton(
//                     child: Text(
//                       getTranslatedForCurrentUser(context, 'xxcancelxx'),
//                       style: TextStyle(color: Mycolors.primary, fontSize: 18),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   // ignore: deprecated_member_use
//                   FlatButton(
//                     child: Text(
//                       getTranslatedForCurrentUser(context, 'xxdeletexx'),
//                       style: TextStyle(color: Colors.red, fontSize: 18),
//                     ),
//                     onPressed: () async {
//                       String broadcastID = broadcastDoc[Dbkeys.broadcastID];
//                       Navigator.of(context).pop();

//                       Future.delayed(const Duration(milliseconds: 500),
//                           () async {
//                         await FirebaseFirestore.instance
//                             .collection(DbPaths.collectionbroadcasts)
//                             .doc(broadcastID)
//                             .get()
//                             .then((doc) async {
//                           await doc.reference.delete();
//                           //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
//                         });
//                       });
//                     },
//                   )
//                 ],
//               );
//             },
//             context: context,
//           ));
//         }));

//     showDialog(
//         context: contextForDialog,
//         builder: (contextForDialog) {
//           return SimpleDialog(children: tiles);
//         });
//   }

//   return Theme(
//       data: ThemeData(
//           fontFamily: FONTFAMILY_NAME,
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent),
//       child: streamLoadCollections(
//           stream: FirebaseFirestore.instance
//               .collection(DbPaths.collectionbroadcasts)
//               .doc(streamDocSnap[index][Dbkeys.broadcastID])
//               .collection(DbPaths.collectionbroadcastsChats)
//               .orderBy(Dbkeys.timestamp, descending: true)
//               .limit(1)
//               .snapshots(),
//           placeholder: SizedBox(),
//           noDataWidget: Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 ListTile(
//                   onLongPress: () {
//                     showMenuForBroadcastChat(context, streamDocSnap[index]);
//                   },
//                   contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                   leading: customCircleAvatarBroadcast(
//                       url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
//                       radius: 22),
//                   title: Text(
//                     streamDocSnap[index][Dbkeys.broadcastNAME],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Mycolors.black,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16.4,
//                     ),
//                   ),
//                   subtitle: Text(
//                     '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${getTranslatedForCurrentUser(context, 'recipients')}',
//                     style: TextStyle(
//                       color: Mycolors.grey,
//                       fontSize: 14,
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         new MaterialPageRoute(
//                             builder: (context) => new BroadcastChatPage(
//                                 model: cachedModel,
//                                 prefs: prefs,
//                                 currentUserno: currentUserNo,
//                                 broadcastID: streamDocSnap[index]
//                                     [Dbkeys.broadcastID])));
//                   },
//                 ),
//                 Divider(height: 0),
//               ],
//             ),
//           ),
//           onfetchdone: (events) {
//             return Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   ListTile(
//                     onLongPress: () {
//                       showMenuForBroadcastChat(context, streamDocSnap[index]);
//                     },
//                     contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                     leading: customCircleAvatarBroadcast(
//                         url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
//                         radius: 22),
//                     title: Text(
//                       streamDocSnap[index][Dbkeys.broadcastNAME],
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Mycolors.black,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16.4,
//                       ),
//                     ),
//                     subtitle: Text(
//                       '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${getTranslatedForCurrentUser(context, 'recipients')}',
//                       style: TextStyle(
//                         color: lightGrey,
//                         fontSize: 14,
//                       ),
//                     ),
//                     trailing: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 2),
//                           child: Text(
//                             getLastMessageTime(context, currentUserNo,
//                                 events.last[Dbkeys.timestamp]),
//                             style: TextStyle(
//                                 color: lightGrey,
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 12),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 23,
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           new MaterialPageRoute(
//                               builder: (context) => new BroadcastChatPage(
//                                     model: cachedModel,
//                                     prefs: prefs,
//                                     broadcastID: streamDocSnap[index]
//                                         [Dbkeys.broadcastID],
//                                     currentUserno: currentUserNo,
//                                   )));
//                     },
//                   ),
//                   Divider(height: 0),
//                 ],
//               ),
//             );
//           }));
// }
