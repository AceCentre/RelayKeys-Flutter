import 'package:biii_in_utils/biii_in_utils.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BBleScanFilter {
  final String name;
  BBleScanFilter({this.name});

  bool isValid(DiscoveredDevice dev) {
    if (name != null && name != dev.name) {
      Log.d(this, 'Filtered ${dev.name} against $name');
      return false;
    }
    return true;
  }
}
