import 'dart:async';

import 'package:flutter/material.dart';
import 'package:relay_keys/consts/Const.dart';

class TrackPadWidget extends StatefulWidget {
  final TrackPad trackPad;
  final bool enable;

  TrackPadWidget({this.enable, onDown, onUp, onMove})
      : trackPad = TrackPad(onDown: onDown, onUp: onUp, onMove: onMove);
  @override
  _TrackPadWidgetState createState() => _TrackPadWidgetState();
}

class _TrackPadWidgetState extends State<TrackPadWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Listener(
                onPointerDown: widget.enable
                    ? (down) =>
                        widget.trackPad.addPointer(down.pointer, down.position)
                    : null,
                onPointerUp: (up) => widget.enable
                    ? widget.trackPad.removePointer(up.pointer, up.position)
                    : null,
                onPointerMove: (move) => widget.enable
                    ? widget.trackPad.movePointer(move.pointer, move.position)
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(),
                    color: widget.enable ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Listener(
                  onPointerDown: (e) => widget.trackPad.onDown(1),
                  onPointerUp: (e) => widget.trackPad.onUp(1),
                  child: RaisedButton(
                    color: Const.primaryColor,
                    textColor: Colors.white,
                    child: Text('LEFT'),
                    onPressed: widget.enable ? () => {} : null,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Listener(
                onPointerDown: (e) => widget.trackPad.onDown(3),
                onPointerUp: (e) => widget.trackPad.onUp(3),
                child: RaisedButton(
                  color: Const.primaryColor,
                  textColor: Colors.white,
                  child: Text('WHEEL'),
                  onPressed: widget.enable ? () => {} : null,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Listener(
                  onPointerDown: (e) => widget.trackPad.onDown(2),
                  onPointerUp: (e) => widget.trackPad.onUp(2),
                  child: RaisedButton(
                    color: Const.primaryColor,
                    textColor: Colors.white,
                    child: Text('RIGHT'),
                    onPressed: widget.enable ? () => {} : null,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TrackPad {
  final Function(int) onDown;
  final Function(int) onUp;
  final Function(int, int, int) onMove;

  TrackPad({this.onDown, this.onUp, this.onMove});

  Map<int, Offset> fingers = {};
  int fingerCountLock;
  int primaryFinger = 0;
  bool isMoving = false;
  Timer dragTimer;

  void addPointer(int id, Offset position) {
    if (fingers.length == 0) {
      dragTimer = Timer(
        Duration(milliseconds: 100),
        () {
          dragTimer.cancel();
          dragTimer = null;
          if (fingers.length > 0) {
            fingerCountLock = fingers.length;
            isMoving = true;
          }
        },
      );
      primaryFinger = id;
      isMoving = false;
    }
    fingers[id] = position;
  }

  void removePointer(int id, Offset position) {
    if (dragTimer != null) {
      dragTimer.cancel();
      dragTimer = null;
      int count = fingers.length;
      onDown(count);
      Future.delayed(Duration(milliseconds: 40), () => onUp(count));
    }
    if (fingerCountLock == fingers.length) {
      fingerCountLock = null;
    }
    fingers.remove(id);
  }

  void movePointer(int id, Offset position) {
    if ((id == primaryFinger)) {
      Offset dis = fingers[id] - position;
      if (dis.distance > 2.0) {
        if ((isMoving) && (fingerCountLock == fingers.length)) {
          if (dis.distance.abs() < 32) {
            onMove(fingerCountLock, dis.dx.toInt(), dis.dy.toInt());
          }
          fingers[id] = position;
        }
      }
    }
  }
}
