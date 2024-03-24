import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Screens/chat_screen/chat.dart';
import 'package:aagama_it/Utils/error_codes.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/custominput.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/myscaffold.dart';

class Resetpassword extends StatefulWidget {
  final SharedPreferences prefs;
  const Resetpassword({Key? key, required this.prefs}) : super(key: key);

  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  final _email = TextEditingController();
  GlobalKey<State> _keyLoader45555 =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsseaadsqeqe45555');
  @override
  void dispose() {
    super.dispose();
    _email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: getTranslatedForCurrentUser(this.context, 'xxresetpwdxx'),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          InpuTextBox(
            isboldinput: true,
            controller: _email,
            title: getTranslatedForCurrentUser(this.context, 'xxemailxx'),
            hinttext:
                getTranslatedForCurrentUser(this.context, 'xxenteremailxx'),
          ),
          MtCustomfontBoldSemi(
            fontsize: 14,
            lineheight: 1.25,
            text: getTranslatedForCurrentUser(this.context, 'xxsendpwdemailxx'),
          ),
          SizedBox(
            height: 20,
          ),
          MySimpleButton(
            onpressed: () async {
              if (_email.text.trim().length < 3 ||
                  !_email.text.trim().contains('@') ||
                  !_email.text.trim().contains('.')) {
                Utils.toast(getTranslatedForCurrentUser(
                    this.context, 'xxvalidemailxx'));
              } else {
                hidekeyboard(this.context);
                if (widget.prefs.getInt("lasttymreset") != null) {
                  int timeDiff = DateTime.now()
                      .difference(DateTime.fromMillisecondsSinceEpoch(
                          widget.prefs.getInt("lasttymreset")!))
                      .inMinutes;
                  int tryied = widget.prefs.getInt("lasttymresettry")!;
                  if (timeDiff >= tryied * 2 ||
                      DateTime.fromMillisecondsSinceEpoch(
                                  widget.prefs.getInt("lasttymreset")!)
                              .day !=
                          DateTime.now().day) {
                    if (DateTime.fromMillisecondsSinceEpoch(
                                widget.prefs.getInt("lasttymreset")!)
                            .day !=
                        DateTime.now().day) {
                      tryied = 0;
                    }
                    ShowLoading()
                        .open(context: this.context, key: _keyLoader45555);
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(
                              email: _email.text.trim().toLowerCase())
                          .then((value) async {
                        await widget.prefs.setInt("lasttymreset",
                            DateTime.now().millisecondsSinceEpoch);
                        await widget.prefs
                            .setInt("lasttymresettry", tryied + 2);
                        ShowLoading()
                            .close(context: this.context, key: _keyLoader45555);

                        ShowCustomAlertDialog().open(
                            context: this.context,
                            dialogtype: "success",
                            title: getTranslatedForCurrentUser(
                                this.context, 'xxemailsentxx'),
                            description: getTranslatedForCurrentUser(
                                this.context, 'xxpwdresetsentxx'),
                            isshowerrorlog: false,
                            rightbuttononpress: () {
                              hidekeyboard(this.context);
                              Navigator.of(this.context).pop();
                              Navigator.of(this.context).pop();
                            });
                      });
                    } catch (e) {
                      ShowLoading()
                          .close(context: this.context, key: _keyLoader45555);
                      showERRORSheet(this.context, "RS_1002",
                          message:
                              "${getTranslatedForCurrentUser(this.context, 'xxfailedsentemailxx')} \n\nERROR: $e");
                    }
                  } else {
                    Utils.toast(
                      getTranslatedForCurrentUser(
                              this.context, 'xxpwdsentrecentxx')
                          .replaceAll('(####)', '${timeDiff - tryied * 2}'),
                    );
                  }
                } else {
                  ShowLoading()
                      .open(context: this.context, key: _keyLoader45555);
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(
                            email: _email.text.trim().toLowerCase())
                        .then((value) async {
                      await widget.prefs.setInt("lasttymreset",
                          DateTime.now().millisecondsSinceEpoch);
                      await widget.prefs.setInt("lasttymresettry", 1);
                      ShowLoading()
                          .close(context: this.context, key: _keyLoader45555);
                      // Navigator.of(this.context).pop();
                      ShowCustomAlertDialog().open(
                          context: this.context,
                          dialogtype: "success",
                          title: getTranslatedForCurrentUser(
                              this.context, 'xxemailsentxx'),
                          description: getTranslatedForCurrentUser(
                              this.context, 'xxpwdresetsentxx'),
                          isshowerrorlog: false,
                          rightbuttononpress: () {
                            hidekeyboard(this.context);
                            Navigator.of(this.context).pop();
                            Navigator.of(this.context).pop();
                          });
                    });
                  } catch (e) {
                    ShowLoading()
                        .close(context: this.context, key: _keyLoader45555);
                    showERRORSheet(this.context, "RS_1001",
                        message:
                            "${getTranslatedForCurrentUser(this.context, 'xxfailedsentemailxx')} \n\nERROR: $e");
                  }
                }
              }
            },
            buttoncolor:
                Mycolors.getColor(widget.prefs, Colortype.primary.index),
            buttontext:
                getTranslatedForCurrentUser(this.context, 'xxsendresetemailxx'),
          ),
          SizedBox(
            height: 20,
          ),
          MtCustomfontLight(
            fontsize: 12,
            lineheight: 1.25,
            text: getTranslatedForCurrentUser(this.context, 'xxdontrecievexx'),
          ),
        ],
      ),
    );
  }
}
