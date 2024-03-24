//*************   © Copyrighted by aagama_it. 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Models/user_registry_model.dart';
import 'package:aagama_it/Utils/error_codes.dart';
import 'package:flutter/material.dart';

class UserRegistry with ChangeNotifier {
  List<UserRegistryModel> users = [];
  List<UserRegistryModel> agents = [];
  List<UserRegistryModel> customer = [];
  UserRegistryModel getUserData(BuildContext context, String userid) {
    int i = users.lastIndexWhere((element) => element.id == userid);
    if (i >= 0) {
      return users[i];
    } else {
      // fetchUserRegistry(context);
      return UserRegistryModel(
          fullname: userid,
          shortname: userid,
          photourl: "",
          phone: "",
          usertype: 1,
          id: userid,
          email: "",
          extra1: "",
          extra2: "",
          us1: userid,
          extraMap: {});
    }
  }

  updateParticularUser(
      BuildContext context, String userid, int usertype) async {
    await FirebaseFirestore.instance
        .collection(usertype == Usertype.agent.index ||
                usertype == Usertype.secondadmin.index
            ? DbPaths.collectionagents
            : DbPaths.collectioncustomers)
        .doc(userid)
        .get()
        .then((value) {
      if (value.exists) {
        int i = users.lastIndexWhere((element) => element.id == userid);
        // users = value.data()!['list'];
        // agents = users
        //     .where((user) => user.usertype == Usertype.agent.index)
        //     .toList();
        // customer = users
        //     .where((user) => user.usertype == Usertype.customer.index)
        //     .toList();
        if (i >= 0) {
          //run transaction
        } else {}

        notifyListeners();
      } else {
        showERRORSheet(context, "",
            message: "User does not exists. kindly contact the developer.");
      }
    }).catchError((e) {
      showERRORSheet(context, "",
          message:
              "App Installation not Completed properly. kindly contact the developer. ERROR: $e");
    });
  }

  fetchUserRegistry(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection(DbPaths.userapp)
        .doc(DbPaths.registry)
        .get()
        .then((value) {
      if (value.exists) {
        users = [];
        agents = [];
        customer = [];
        // List<dynamic> list = [];
        // list = value.data()!['list'];
        // list.forEach((element) {
        //   users.add(UserRegistryModel.fromJson(element));
        // });
        for (final p in value.data()!['list']) {
          users.add(UserRegistryModel.fromJson(p));
        }

        // users =
        //     value.data()!['list'].map((val) => UserRegistryModel.fromJson(val));
        agents = users
            .where((user) => user.usertype == Usertype.agent.index)
            .toList();
        customer = users
            .where((user) => user.usertype == Usertype.customer.index)
            .toList();
        notifyListeners();
      } else {
        showERRORSheet(context, "",
            message: "Error ocuured while fetching registry");
      }
    }).catchError((e) {
      showERRORSheet(context, "",
          message: "Error ocuured while fetching registry ERROR: $e");
    });
  }
}
