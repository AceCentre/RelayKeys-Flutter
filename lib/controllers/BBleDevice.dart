import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BBleDevice {
  final DiscoveredDevice _dev;

  BBleDevice(this._dev);

  get name => _dev.name;

  get id => _dev.id;

  bool operator ==(other) => other is BBleDevice && _dev.id == other.id;

  int get hashCode => _dev.hashCode;
}
