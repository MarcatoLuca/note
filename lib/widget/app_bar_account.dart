import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AppBarAccount extends StatelessWidget {
  const AppBarAccount(
      {Key key,
      @required this.value,
      @required this.onPressed,
      @required this.handleSignOut,
      @required this.user})
      : super(key: key);

  final bool value;
  final Function onPressed;
  final Function handleSignOut;
  final GoogleSignInAccount user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
                margin: const EdgeInsets.only(left: 42.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                duration: Duration(milliseconds: 650),
                width: value ? MediaQuery.of(context).size.width : 0,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 40,
                    ),
                    Flexible(
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.displayName ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user.email ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: () => handleSignOut()),
                    VerticalDivider(
                      indent: 8,
                      endIndent: 8,
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => onPressed()),
                    )
                  ],
                ))),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50.0,
              maxWidth: 76.0,
            ),
            child: RawMaterialButton(
              highlightElevation: 0,
              onPressed: () => onPressed(),
              elevation: 0,
              fillColor: Colors.white,
              child: GoogleUserCircleAvatar(
                backgroundColor: const Color(0xFF3366FF),
                identity: user,
              ),
              shape: CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
