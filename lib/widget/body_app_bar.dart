import 'package:flutter/material.dart';

class BodyAppBar extends StatelessWidget {
  const BodyAppBar({
    Key key,
    @required this.onAddPress,
    @required this.onSearchPress,
    @required this.tag,
  }) : super(key: key);

  final Function onAddPress;
  final Function onSearchPress;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
