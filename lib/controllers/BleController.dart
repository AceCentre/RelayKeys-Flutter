import 'dart:async';

import 'package:relay_keys/consts/Const.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:biii_in_utils/biii_in_utils.dart';
import 'package:relay_keys/controllers/BBleDevice.dart';
import 'package:relay_keys/controllers/BBleScanFilter.dart';

final bleContoller = BleController._();
final _ble = FlutterReactiveBle();

class BleController {
  DeviceConnectionState connectionState;
  StreamSubscription<ConnectionStateUpdate> _connection;
  String _bleDeviceID;
  get radioStatus => _ble.status;
  get deviceID => _bleDeviceID;

  BleController._();

  Stream<BleStatus> get bleStatusStream => _ble.statusStream;

  Future<void> writeToChar(
      QualifiedCharacteristic cmdChar, List<int> list) async {
    Log.d(this, 'Writing $list to $cmdChar');
    return _ble.writeCharacteristicWithResponse(cmdChar, value: list);
  }

  startScan({
    BBleScanFilter filter,
    int timeout,
    void Function(BBleDevice) onDeviceFound,
  }) async {
    //
    assert(timeout != null);
    assert(onDeviceFound != null);
    assert(filter != null);
    assert(timeout > 0);
    //
    var scanStream = _ble.scanForDevices(withServices: []).listen(
      (dev) {
        if (filter.isValid(dev)) {
          onDeviceFound(BBleDevice(dev));
        }
      },
    );
    await Future.delayed(Duration(seconds: timeout), () => scanStream.cancel());
  }

  void handleConnectionUpdate(ConnectionStateUpdate event) {
    Log.i('BLEConnectionStream', '$event');
    connectionState = event.connectionState;
    switch (event.connectionState) {
      case DeviceConnectionState.connecting:
        break;
      case DeviceConnectionState.connected:
        break;
      case DeviceConnectionState.disconnecting:
        break;
      case DeviceConnectionState.disconnected:
        break;
    }
  }

  Future<bool> connect(BBleDevice device) async {
    Log.d(this, 'CONNECT: START');
    await _connection?.cancel();
    _bleDeviceID = device.id;
    _ble.clearGattCache(_bleDeviceID);
    _connection = _ble
        .connectToDevice(
          id: device.id,
          // servicesWithCharacteristicsToDiscover: bleDevProfile.profileMap,
          connectionTimeout: Duration(seconds: Const.connectTimeout),
        )
        .listen(handleConnectionUpdate);
    connectionState = null;
    //
    const int millisToWait = 10000;
    const int millisStable = 2000;
    const int millisToTick = 100;
    int millisElapsed = 0;
    while ((connectionState != DeviceConnectionState.connected) &&
        (millisElapsed < millisToWait)) {
      await Future.delayed(Duration(milliseconds: millisToTick));
      millisElapsed += millisToTick;
    }
    if (millisElapsed < millisToWait) {
      await Future.delayed(Duration(milliseconds: millisStable));
    }
    return Future.value(connectionState == DeviceConnectionState.connected);
  }

  void disconnect() {
    _connection?.cancel();
  }
}
