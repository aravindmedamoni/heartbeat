
import 'dart:ffi';

import 'package:flutter/cupertino.dart';

class SensorValue{
  final DateTime time;
  final num value;

  SensorValue({@required this.value, @required this.time});
}