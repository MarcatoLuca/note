import 'package:flutter/material.dart';

import 'package:flutter_progress_button/flutter_progress_button.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:note/first_page.dart';
import 'package:note/model/app_database.dart';

//Google API Authorize Requests Scopes
//https://developers.google.com/identity/protocols/oauth2/scopes#people
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.email',
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Floor Database Instance
  final appDatabase =
      await $FloorAppDatabase.databaseBuilder('database.db').build();

  runApp(MyApp(appDatabase: appDatabase));
}

class MyApp extends StatelessWidget {
  final AppDatabase appDatabase;

  const MyApp({Key key, this.appDatabase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Note',
      theme: ThemeData(
        fontFamily: 'Helvetica',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Note Home Page', database: appDatabase),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.database}) : super(key: key);

  final String title;
  final AppDatabase database;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Logged Google User Account
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently(); //Auto SignIn if user already logged once
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Widget _buildBody() {
    GoogleSignInAccount user = _currentUser;
    if (user != null) {
      return FirstPage(
          googleSignIn: _googleSignIn, user: user, database: widget.database);
    } else {
      return Column(
        children: [
          Flexible(
            flex: 2,
            child: Center(
                child: ConstrainedBox(
              constraints: BoxConstraints.loose(new Size(350, double.infinity)),
              child: Text(
                "Benvenuto su Note \naccedi con il tuo account \nGoogle",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            )),
          ),
          Flexible(
            flex: 1,
            child: ProgressButton(
              defaultWidget: Text("ACCEDI",
                  style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 18,
                      fontFamily: 'Helvetica-Bold')),
              borderRadius: 150.0,
              progressWidget: const CircularProgressIndicator(),
              width: 196,
              height: 40,
              onPressed: () async {
                //Graphic delay
                await Future.delayed(
                    const Duration(milliseconds: 500), () => _handleSignIn());
              },
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: new BoxDecoration(
        //Background Theme
        gradient: new LinearGradient(
            colors: [
              const Color(0xFF3366FF),
              const Color(0xFF00CCFF),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    ));
  }
}

// $ npm install -g json-server
// $ json-server --watch db.json
// $ json-server --host 192.168.1.55 db.json
