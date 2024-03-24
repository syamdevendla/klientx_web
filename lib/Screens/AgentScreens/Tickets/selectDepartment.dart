//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/department_model.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/dynamic_modal_bottomsheet.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Widget categoryCard(SharedPreferences prefs, DepartmentModel cat,
    Function(DepartmentModel c) onSelect) {
  return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 2),
          onTap: () {
            onSelect(cat);
          },
          title: MtCustomfontBoldSemi(
            text: cat.departmentTitle,
          ),
          subtitle: cat.departmentDesc == ''
              ? null
              : MtCustomfontRegular(
                  text: cat.departmentDesc,
                  maxlines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontsize: 14,
                ),
          leading: cat.departmentLogoURL == ""
              ? Utils.squareAvatarIcon(
                  backgroundColor: Utils.randomColorgenratorBasedOnFirstLetter(
                      cat.departmentTitle),
                  iconData: Icons.location_city,
                  size: 45)
              : Utils.squareAvatarImage(url: cat.departmentLogoURL, size: 45)));
}

selectADepartment({
  required BuildContext context,
  required String title,
  required List<DepartmentModel> datalist,
  DepartmentModel? alreadyselected,
  required SharedPreferences prefs,
  required Function(DepartmentModel cat) onselected,
}) {
  showDynamicModalBottomSheet(
    context: context,
    widgetList: datalist
        .map((e) => categoryCard(prefs, e, (selectedCat) {
              Navigator.of(context).pop();
              onselected(selectedCat);
            }))
        .toList(),
    title: getTranslatedForCurrentUser(context, 'xxselectaxxxx').replaceAll(
        '(####)', getTranslatedForCurrentUser(context, 'xxdepartmentxx')),
  );
}

selectAOrg({
  required BuildContext context,
  required String title,
  required List<dynamic> datalist,
  alreadyselected,
  required SharedPreferences prefs,
  required Function(String cat) onselected,
}) {
  showDynamicModalBottomSheet(
    context: context,
    widgetList: datalist
        .map((e) => orgCard(prefs, e, (selectedCat) {
              Navigator.of(context).pop();
              onselected(selectedCat);
            }))
        .toList(),
    title: getTranslatedForCurrentUser(context, 'xxselectaxxxx')
        .replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxorgxx')),
  );
}

Widget orgCard(SharedPreferences prefs, cat, Function(String org) onSelect) {
  return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 2),
          onTap: () {
            onSelect(cat.id);
          },
          title: MtCustomfontBoldSemi(
            text: cat.data()['orgName'],
          ),
          subtitle: cat.data()['orgName'] == ''
              ? null
              : MtCustomfontRegular(
                  text: cat.data()['orgName'],
                  maxlines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontsize: 14,
                ),
          leading: cat.data()['orgphotourl'] == ""
              ? Utils.squareAvatarIcon(
                  backgroundColor: Utils.randomColorgenratorBasedOnFirstLetter(
                      cat.data()['orgphotourl']),
                  iconData: Icons.location_city,
                  size: 45)
              : Utils.squareAvatarImage(
                  url: cat.data()['orgphotourl'], size: 45)));
}
