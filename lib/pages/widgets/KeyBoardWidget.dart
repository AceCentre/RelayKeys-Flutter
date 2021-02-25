import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:relay_keys/pages/widgets/KeyboardHIDCodes.dart';
import 'package:relay_keys/utils/ListEx.dart';

const String txtPad = ' ';
ValueNotifier<int> keyModifer = ValueNotifier(0);

class KeyBoardWidget extends StatefulWidget {
  final bool enable;
  final void Function(int modifier, List<int> data) onKeyChange;

  KeyBoardWidget({this.enable, this.onKeyChange});
  @override
  _KeyBoardWidgetState createState() => _KeyBoardWidgetState();
}

class _KeyBoardWidgetState extends State<KeyBoardWidget> {
  List<int> codeUnits = [];
  String displayTxt = '';

  List<Widget> specialKeys = [];
  Widget keyMap;

  @override
  void initState() {
    super.initState();
    hidKeys.forEach(
      (keyRow) {
        specialKeys.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: keyRow.transform(
              (i, h) => HidKeyButton(
                hidKey: h,
                onKeyPressed: handleKeyState,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            displayTxt,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
        Expanded(
          child: FittedBox(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: specialKeys,
            ),
          ),
          // child: GridView.count(
          //   crossAxisCount: 8,
          //   childAspectRatio: 1,
          //   children: specialKeys,
          // ),
        ),
      ],
    );
  }

  void handleKeyState(HidKey key, bool locked) {
    displayTxt = '+ ${key.primary}';
    setState(() {});
    if (key.isSpecial) {
      keyModifer.value ^= key.hidCode;
      widget.onKeyChange(keyModifer.value, [key.hidCode]);
    } else {
      widget.onKeyChange(keyModifer.value, [key.hidCode]);
    }
  }
}

class HidKeyButton extends StatefulWidget {
  final HidKey hidKey;
  final void Function(HidKey key, bool locked) onKeyPressed;

  HidKeyButton({this.hidKey, this.onKeyPressed});

  @override
  _HidKeyButtonState createState() => _HidKeyButtonState();
}

class _HidKeyButtonState extends State<HidKeyButton> {
  bool state = false;
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: keyModifer,
        builder: (context, value, child) => FlatButton(
          minWidth: 8,
          visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          onPressed: () => widget.onKeyPressed(widget.hidKey, null),
          color: widget.hidKey.getBgColor(value),
          textColor: widget.hidKey.getTxtColor(value),
          child: Text(
            widget.hidKey.getTxt(value),
            softWrap: true,
          ),
        ),
      );
}
