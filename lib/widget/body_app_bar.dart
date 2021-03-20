import 'package:flutter/material.dart';

class BodyAppBar extends StatelessWidget {
  const BodyAppBar(
      {Key key,
      @required this.onSwitcherPress,
      @required this.onAddPress,
      @required this.onSearchPress,
      @required this.tag,
      @required this.bodySwitcherController})
      : super(key: key);

  final Function onSwitcherPress;
  final Function onAddPress;
  final Function onSearchPress;
  final String tag;
  final AnimationController bodySwitcherController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RawMaterialButton(
          onPressed: () => onSwitcherPress(),
          elevation: 0,
          highlightElevation: 0,
          fillColor: Colors.black.withOpacity(0.1),
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: AnimatedIcon(
            size: 20,
            icon: AnimatedIcons.view_list,
            progress: bodySwitcherController,
          ),
          shape: CircleBorder(),
        ),
        Expanded(
          child: Center(
            child: Container(
              child: Text(
                tag,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: SizedBox(
            height: 34,
            width: 34,
            child: RawMaterialButton(
              highlightElevation: 0,
              onPressed: () => onSearchPress(),
              elevation: 0,
              fillColor: Colors.black.withOpacity(0.1),
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Icon(Icons.search, size: 20),
              shape: CircleBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: SizedBox(
            height: 34,
            width: 34,
            child: RawMaterialButton(
              highlightElevation: 0,
              onPressed: () => onAddPress(),
              elevation: 0,
              fillColor: Colors.black.withOpacity(0.1),
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: Icon(
                Icons.add,
                size: 20,
              ),
              shape: CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
