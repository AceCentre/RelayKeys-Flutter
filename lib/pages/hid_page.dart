import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:relay_keys/consts/Const.dart';
import 'package:relay_keys/controllers/BleController.dart';
import 'package:biii_in_utils/biii_in_utils.dart';
import 'package:relay_keys/pages/widgets/KeyBoardWidget.dart';
import 'package:relay_keys/pages/widgets/TrackPadWidget.dart';

const uuid = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
const txuuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
const rxuuid = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

class HIDPage extends StatefulWidget {
  @override
  _HIDPageState createState() => _HIDPageState();
}

class _HIDPageState extends State<HIDPage> {
  bool mouseEnable = true;
  bool keyBoardEnable = true;
  bool showTrackPad = false;
  QualifiedCharacteristic txChar;

  @override
  void initState() {
    super.initState();
    txChar = QualifiedCharacteristic(
      serviceId: Uuid.parse(uuid),
      characteristicId: Uuid.parse(txuuid),
      deviceId: bleContoller.deviceID,
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Disconnect device ?'),
            content: Text('Going back will disconnect current device'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  bleContoller.disconnect();
                  Navigator.of(context).pop(true);
                },
                child: Text('Go Back'),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Skip'),
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
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('RelayKeys: HID'),
            actions: [
              IconButton(
                icon: Icon(Icons.link_off),
                onPressed: () => _onWillPop().then((value) {
                  if (value) {
                    Navigator.of(context).pop();
                  }
                }),
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Row(
                children: [
                  FlatButton.icon(
                    icon: Icon(Icons.mouse),
                    label: Text('TrackPad'),
                    color: showTrackPad ? Theme.of(context).primaryColor : null,
                    textColor: showTrackPad ? Colors.white : Const.primaryColor,
                    onPressed: () => setState(() => showTrackPad = true),
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.keyboard),
                    label: Text('KeyBoard'),
                    color:
                        !showTrackPad ? Theme.of(context).primaryColor : null,
                    textColor:
                        !showTrackPad ? Colors.white : Const.primaryColor,
                    onPressed: () => setState(() => showTrackPad = false),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: !showTrackPad
                      ? KeyBoardWidget(
                          enable: keyBoardEnable,
                          onKeyChange: relayKeyRecord,
                        )
                      : TrackPadWidget(
                          enable: mouseEnable,
                          onDown: relayButtonDown,
                          onUp: relayButtonUp,
                          onMove: relayMouseMove,
                        ),
                ),
              ),
            ],
          ),
        ),
      );

  void relayButtonDown(int id) async {
    Log.d(this, 'Down $id');
    await bleContoller.writeToChar(txChar, <int>[
      'b'.codeUnits[0],
      '0lrm'.codeUnits[id],
      't'.codeUnits[0],
    ]);
  }

  void relayButtonUp(int id) async {
    Log.d(this, 'Up $id');
    await bleContoller.writeToChar(txChar, <int>[
      'b'.codeUnits[0],
      '0lrm'.codeUnits[id],
      'f'.codeUnits[0],
    ]);
  }

  void relayMouseMove(int id, int x, int y) async {
    Log.d(this, 'Move $id, $x, $y');
    await bleContoller.writeToChar(txChar, <int>[
      '0mw'.codeUnits[id],
      id == 1 ? x * -2 : x ~/ -2,
      id == 1 ? y * -2 : y ~/ -2,
    ]);
  }

  void relayKeyRecord(int modifier, List<int> data) async {
    Log.d(this, 'Keys $modifier, $data');
    List<int> record = <int>['k'.codeUnits[0], modifier]..addAll(data);
    await bleContoller.writeToChar(txChar, record);
    await bleContoller
        .writeToChar(txChar, <int>['k'.codeUnits[0], modifier, 0]);
  }
}
