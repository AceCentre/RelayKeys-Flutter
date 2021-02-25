import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frccblue/frccblue.dart';
import 'package:future_button/future_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:relay_keys/controllers/BBleDevice.dart';
import 'package:relay_keys/controllers/BleController.dart';
import 'package:relay_keys/controllers/BBleScanFilter.dart';
import 'package:relay_keys/consts/Const.dart';

bool showSplash = true;

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<BBleDevice> devices = <BBleDevice>[];
  String _platformVersion = 'Unknown';

  Future checkAndroidPermissions() async {
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      checkAndroidPermissions();
    }
    initPlatformState();
    if (!mounted) {
      return;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Frccblue.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    Frccblue.init(didReceiveRead: (MethodCall call) {
      print(call.arguments);
      return Uint8List.fromList([
        11,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
      ]);
    }, didReceiveWrite: (MethodCall call) {
      Frccblue.peripheralUpdateValue(
          call.arguments["centraluuidString"],
          call.arguments["characteristicuuidString"],
          Uint8List.fromList([11, 2, 3]));
      print(call.arguments);
    }, didSubscribeTo: (MethodCall call) {
      print(call.arguments);
      Frccblue.peripheralUpdateValue(
          call.arguments["centraluuidString"],
          call.arguments["characteristicuuidString"],
          Uint8List.fromList([11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 2, 3]));
    }, didUnsubscribeFrom: (MethodCall call) {
      print(call.arguments);
    }, peripheralManagerDidUpdateState: (MethodCall call) {
      print(call.arguments);
    });

    Frccblue.startPeripheral("00000000-0000-0000-0000-AAAAAAAAAAA1",
            "00000000-0000-0000-0000-AAAAAAAAAAA2")
        .then((_) {});

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('You are about to exit RelayKeys'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Exit'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Stay'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: showSplash
              ? null
              : AppBar(
                  title: Text('RelayKeys: Home'),
                ),
          body: Stack(
            children: [
              StreamBuilder<BleStatus>(
                stream: bleContoller.bleStatusStream,
                builder: (context, snapshot) {
                  var errorMag;
                  if (snapshot.hasError) {
                    errorMag = 'BLE State detect error';
                  }
                  if (!snapshot.hasData) {
                    errorMag = 'Waitimg for BLE State';
                  }
                  switch (snapshot.data) {
                    case BleStatus.unknown:
                      errorMag = 'Unknown Ble State';
                      break;
                    case BleStatus.unsupported:
                      errorMag = 'Ble Not supported';
                      break;
                    case BleStatus.unauthorized:
                      errorMag = 'BLE Permission not granted';
                      break;
                    case BleStatus.poweredOff:
                      errorMag = 'Turn On BLE';
                      break;
                    case BleStatus.locationServicesDisabled:
                      errorMag = 'Enable Location Service for proper operation';
                      break;
                    case BleStatus.ready:
                      return getActiveWidget(context);
                  }
                  errorMag = errorMag ?? 'BLE Unknown Error';
                  return Center(child: Text(errorMag));
                },
              ),
              if (showSplash)
                SplashScreen(
                  onDone: () => setState(() => showSplash = false),
                ),
            ],
          ),
        ),
      );

  void showConnectionDialog(BuildContext context, BBleDevice device) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        elevation: 4,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Connecting to ... '),
            SizedBox(height: 4),
            Text('${device.name} [${device.id}]'),
            SizedBox(height: 8),
            FutureBuilder(
              future: bleContoller.connect(device),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError || !(snapshot.data as bool)) {
                    Fluttertoast.showToast(msg: 'Error Connecting');
                  }
                  if (snapshot.data as bool) {
                    Future.delayed(Duration.zero,
                        () => Navigator.of(context).popAndPushNamed('/hid'));
                  } else {
                    Future.delayed(
                        Duration.zero, () => Navigator.of(context).pop());
                  }
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  getActiveWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FutureRaisedButton(
              child: Text('Scan RelayKeys'),
              color: Const.primaryColor,
              textColor: Colors.white,
              disabledColor: Colors.grey[100],
              disabledTextColor: Colors.grey[500],
              progressIndicatorLocation: ProgressIndicatorLocation.right,
              visualDensity: VisualDensity.comfortable,
              onPressed: () {
                setState(() => devices.clear());
                return bleContoller.startScan(
                  filter: BBleScanFilter(name: 'RelayKeys'),
                  timeout: 5,
                  onDeviceFound: (dev) {
                    if (!devices.contains(dev)) {
                      setState(() => devices.add(dev));
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (c, i) => Card(
                child: ListTile(
                  title: Text('${devices[i].name}'),
                  subtitle: Text('${devices[i].id}'),
                  leading: Icon(Icons.bluetooth),
                  onTap: () => showConnectionDialog(context, devices[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Function() onDone;
  SplashScreen({this.onDone});
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double logoOpacity = 0;
  bool startSequence = true;

  @override
  Widget build(BuildContext context) {
    if (startSequence) {
      Future.delayed(
        Duration(milliseconds: 500),
        () => setState(() => logoOpacity = 1.0),
      );
      Future.delayed(
        Duration(milliseconds: 3500),
        () => setState(() => logoOpacity = 0.0),
      );
      Future.delayed(
        Duration(milliseconds: 5500),
        () => widget.onDone?.call(),
      );
      startSequence = false;
    }
    return Container(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: AnimatedOpacity(
            opacity: logoOpacity,
            duration: Duration(milliseconds: 2000),
            child: Image.asset('assets/logo.jpg'),
          ),
        ),
      ),
    );
  }
}
