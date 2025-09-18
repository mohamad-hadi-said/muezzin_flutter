import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Toast {
  void dismissAll() {
    toastification.dismissAll();
  }

  Toast.warning(BuildContext context, String message) {
    dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.bottomRight,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  Toast.error(BuildContext? context, String message) {
    dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  Toast.success(BuildContext? context, String message) {
    dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
  
  Toast.info(BuildContext context, String message) {
    dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  Toast.loading(BuildContext context, String message) {
    dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      showProgressBar: true,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}

class Itoast {
  Itoast.online(BuildContext context, String msg) {
    toastification.dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.minimal,
      primaryColor: Colors.green,
      title: Text(msg),
      alignment: Alignment.bottomLeft,
      showProgressBar: false,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
  Itoast.offline(BuildContext context, String msg) {
    toastification.dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.error,
      icon: const Icon(Icons.cloud_off),
      style: ToastificationStyle.minimal,
      title: Text(msg),
      alignment: Alignment.bottomLeft,
      showProgressBar: false,
    );
  }
}
