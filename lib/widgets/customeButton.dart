import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:aagama_it/Utils/colors.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {@required this.label,
      this.width,
      this.onPressed,
      this.isShadow,
      this.vertPad,
      this.height,
      this.colorButton,
      this.colorLabel,
      this.borderRadius,
      this.action});

  final String? label;
  final double? width;
  final bool? isShadow;
  final double? vertPad;
  final double? height;
  final double? borderRadius;
  final Color? colorButton;
  final Color? colorLabel;
  final Function()? onPressed;
  bool? action = true;

  @override
  Widget build(BuildContext context) {
    var h = Get.height / 812;
    var b = Get.width / 375;

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: Get.width,
        height: h * 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorButton ?? buttonColor,
          borderRadius: BorderRadius.circular(borderRadius ?? h * 5),
        ),
        child: Row(
          mainAxisAlignment: action != null && action == true
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            if (action != null && action == true) SizedBox(),
            Center(
              child: Text(
                label!,
                style: TextStyle(
                  color: colorLabel ?? Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  fontSize: h * 18,
                ),
              ),
            ),
            if (action != null && action == true)
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {
  LoadingButton({Key? key, this.width}) : super(key: key);

  final double? width;

  @override
  Widget build(BuildContext context) {
    var h = Get.height / 812;
    var b = Get.width / 375;

    return Container(
      width: Get.width,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: h * 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(b * 15),
      ),
      child: SpinKitCircle(
        color: secondaryColor,
        size: b * 20,
      ),
    );
  }
}
