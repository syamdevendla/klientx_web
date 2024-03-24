//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/user_registry_model.dart';
import 'package:aagama_it/Screens/AgentScreens/users/widgets/usercard.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleSelectUser extends StatefulWidget {
  const SingleSelectUser({
    required this.prefs,
    required this.title,
    required this.usertype,
    required this.isShowPhonenumber,
    this.manageruid,
    this.initfetchlimit,
    required this.onselected,
    this.bannedusers,
  });
  final String title;
  final String? manageruid;
  final int usertype;
  final Function(String uid, UserRegistryModel userMap) onselected;
  final int? initfetchlimit;
  final SharedPreferences prefs;
  final List<dynamic>? bannedusers;
  final bool isShowPhonenumber;
  @override
  _SingleSelectUserState createState() => new _SingleSelectUserState();
}

class _SingleSelectUserState extends State<SingleSelectUser> {
  List<dynamic> selectedList = [];
  @override
  Widget build(BuildContext context) {
    final registry = Provider.of<UserRegistry>(this.context, listen: false);
    //print(registry.agents.map((e) => print(e.id)));
    return Scaffold(
      backgroundColor: Mycolors.backgroundcolor,
      appBar: AppBar(
          elevation: 0.4,
          backgroundColor:
              Mycolors.getColor(widget.prefs, Colortype.primary.index),
          title: MtCustomfontBold(
            text: widget.title,
            fontsize: 18,
            color: Mycolors.whiteDynamic,
          )),
      body: widget.usertype == Usertype.agent.index
          ? registry.agents.length == 0
              ? noDataWidget(
                  context: this.context,
                  title: getTranslatedForCurrentUser(
                          this.context, 'xxnoxxavailabletoaddxx')
                      .replaceAll(
                          '(####)',
                          getTranslatedForCurrentUser(
                              this.context, 'xxagentsxx')),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 150),
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: registry.agents.length,
                  itemBuilder: (BuildContext context, int i) {
                    UserRegistryModel dc = registry.agents[i];
                    // return Text(dc.id.toString());
                    return selectableusercard(
                        isShowPhonenumber: widget.isShowPhonenumber,
                        onselected: widget.onselected,
                        doc: dc,
                        context: this.context,
                        bannedusers: widget.bannedusers ?? [],
                        isCustomer: false,
                        isManager: widget.manageruid == dc.id);
                  })
          : widget.usertype == Usertype.customer.index
              ? registry.customer.length == 0
                  ? noDataWidget(
                      context: this.context,
                      title: getTranslatedForCurrentUser(
                              this.context, 'xxnoxxavailabletoaddxx')
                          .replaceAll(
                              '(####)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxcustomerxx')),
                      subtitle: getTranslatedForCurrentUser(
                              this.context, 'xxnoxxavailabletoaddforxxxx')
                          .replaceAll(
                              '(####)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxcustomerxx'))
                          .replaceAll(
                              '(###)',
                              getTranslatedForCurrentUser(
                                  this.context, 'xxsupporttktxx')))
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 150),
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: registry.customer.length,
                      itemBuilder: (BuildContext context, int i) {
                        var dc = registry.customer[i];
                        return selectableusercard(
                          isShowPhonenumber: widget.isShowPhonenumber,
                          onselected: widget.onselected,
                          doc: dc,
                          context: this.context,
                          isCustomer: true,
                          bannedusers: widget.bannedusers ?? [],
                        );
                      })
              : noDataWidget(
                  context: this.context,
                  title: getTranslatedForCurrentUser(
                          this.context, 'xxnoxxavailabletoaddxx')
                      .replaceAll('(####)',
                          getTranslatedForCurrentUser(this.context, 'xxusersxx'))),
    );
  }
}
