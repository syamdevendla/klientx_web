//*************   © Copyrighted by aagama_it.

import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class Permissions {
  static Future<bool> cameraAndMicrophonePermissionsGranted() async {
    PermissionStatus cameraPermissionStatus = await _getCameraPermission();
    PermissionStatus microphonePermissionStatus =
        await getMicrophonePermission();

    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleInvalidPermissions(
          cameraPermissionStatus, microphonePermissionStatus);
      return false;
    }
  }

  static Future<PermissionStatus> _getCameraPermission() async {
    PermissionStatus permission = PermissionStatus.denied;
    if (kIsWeb) {
      try {
        // Request access to audio and video devices
        await html.window.navigator.getUserMedia(audio: true, video: true);
        permission = PermissionStatus.granted;
      } catch (e) {
        permission = PermissionStatus.denied;
      }
    } else {
      permission = await Permission.camera.request();
    }
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      return Permission.camera as FutureOr<PermissionStatus>? ??
          PermissionStatus.permanentlyDenied;
    } else {
      return permission;
    }
  }

  static Future<PermissionStatus> getMicrophonePermission() async {
    if (kIsWeb) {
      try {
        // Request access to audio and video devices
        await html.window.navigator.getUserMedia(audio: true, video: true);
        return PermissionStatus.granted;
      } catch (e) {
        return PermissionStatus.denied;
      }
    } else {
      if (await Permission.microphone.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        return PermissionStatus.granted;
      } else {
        return PermissionStatus.denied;
      }
    }
  }

  // static Future<PermissionStatus> getMicrophonePermission() async {
  //   PermissionStatus permission = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.microphone);
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.disabled) {
  //     Map<PermissionGroup, PermissionStatus> permissionStatus =
  //         await PermissionHandler()
  //             .requestPermissions([PermissionGroup.microphone]);
  //     return permissionStatus[PermissionGroup.microphone] ??
  //         PermissionStatus.unknown;
  //   } else {
  //     return permission;
  //   }
  // }

  static void _handleInvalidPermissions(
    PermissionStatus cameraPermissionStatus,
    PermissionStatus microphonePermissionStatus,
  ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }
}
