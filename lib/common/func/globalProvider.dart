import 'package:flutter/material.dart';

enum CustomDeviceType { phone, tablet }

CustomDeviceType? globalDeviceType;

void initGlobalDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 600) {
    globalDeviceType = CustomDeviceType.tablet;
  } else {
    globalDeviceType = CustomDeviceType.phone;
  }
}
