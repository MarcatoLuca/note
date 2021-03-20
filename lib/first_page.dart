import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:vibration/vibration.dart';

import 'package:http/http.dart' as http;

import 'package:flip_card/flip_card.dart';

import 'package:note/memo_page.dart';
import 'package:note/widget/app_bar_account.dart';
import 'package:note/widget/body_app_bar.dart';
import 'package:note/widget/body_switch_memo.dart';
import 'package:note/model/memo.dart';
import 'package:note/model/app_database.dart';
import 'package:note/model/memo_tag.dart';
import 'package:note/model/tag.dart';

class FirstPage extends StatefulWidget {
  FirstPage(
      {Key key,
      @required this.googleSignIn,
      @required this.user,
      @required this.database})
      : super(key: key);

  final GoogleSignIn googleSignIn;
  final GoogleSignInAccount user;
  final AppDatabase database;

  @override
  _FirstPage createState() => _FirstPage();
}

class _FirstPage extends State<FirstPage> with SingleTickerProviderStateMixin {
  //Floor Database Instances
  MemoTableDao _memoDao;
  TagTableDao _tagDao;
  MemoTagDao _memoTagDao;

  //Body App Bar Animation Controller and Value
  bool _bodySwitcher = true;
  AnimationController _bodySwitcherController;

  //PopupMenu Memo Values
  Offset _tapPosition;
  Map<int, GlobalKey<FlipCardState>> _cardKeys =
      Map<int, GlobalKey<FlipCardState>>();

  //Default tag used for Memo creation
  String _searchTag = "#memo";
  double _searchContainerHeight = 0;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    //Init the Instance of the Database (DAO)
    _memoDao = widget.database.memoDao;
    _tagDao = widget.database.tagDao;
    _memoTagDao = widget.database.memoTagDao;

    //Load the downloaded data from the JSON Server into the Floor db
    _saveDataOnDB();

    //Timer called every N seconds to download other users changes
    //instead of Server FCM - https://firebase.google.com/docs/cloud-messaging/
    /*WidgetsBinding.instance.addPostFrameCallback(
        (_) => Timer.periodic(Duration(seconds: 5), (Timer t) {
              setState(() {});
            }));
    */

    _bodySwitcherController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 500),
    );
  }

  Future<void> _saveDataOnDB() async {
    await _memoDao.insertMemos(await fetchMemo(http.Client()));
    await _tagDao.insertTags(await fetchTag(http.Client()));
    await _memoTagDao.insertMemoTags(await fetchMemoTag(http.Client()));
  }

  Future<void> _associateMemoTag(String tag, MemoTable memoTable) async {
    List<String> tags = ["#memo"];
    if (tag != "#memo") tags.add(tag);

    for (String tag in tags) {
      //Query - Init the Tag Object by its tagText
      TagTable tagTable = await _tagDao.findTagByTagText(tag);
      if (tagTable == null) {
        //If Tag Obj doesn't exist

        //Http call "POST" new Tag
        var tagResponse = await createTag(tag);
        tagTable = TagTable.fromJson(jsonDecode(tagResponse.body));
      }
      //Http call "POST" new MemoTag
      createMemoTag(memoTable.id, tagTable.id);
    }
    await _saveDataOnDB();
  }

  Future<void> _handleSignOut() => widget.googleSignIn.disconnect();

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _toogleCard(GlobalKey<FlipCardState> cardKey) {
    cardKey.currentState.toggleCard();
  }

  Future<void> _searchContainerController(String text, bool search) async {
    setState(() {
      if (_searchContainerHeight == 0) {
        _searchContainerHeight = 60;
        _isVisible = true;
      } else {
        _searchContainerHeight = 0;
        _isVisible = false;
        if (search) {
          if (text == "") {
            _searchTag = "#memo";
          } else {
            _searchTag = "#" + text;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _showPopupMenu(
        int memoId, String userEmail, GlobalKey<FlipCardState> cardKey) async {
      final RenderBox overlay = Overlay.of(context).context.findRenderObject();
      Vibration.vibrate(duration: 40, amplitude: 10); //Vibration Service
      await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition & Size(20, 20), Offset.zero & overlay.size),
        items: [
          PopupMenuItem(
            child: InkWell(
                onTap: () {
                  //Flip Card function Call
                  _toogleCard(cardKey);
                  Navigator.pop(context); //Close Popup Call
                },
                child: Text("Show details")),
          ),
          PopupMenuItem(
            child: InkWell(
                onTap: () async {
                  //Google User Permission
                  if (widget.user.email == userEmail) {
                    //Query - Delete MemoTag related to the Deleted Memo
                    List<MemoTagTable> memoTags =
                        await _memoTagDao.findAllMemoTagByMemoId(memoId);
                    for (MemoTagTable item in memoTags) {
                      await _memoTagDao.deleteMemoTag(item);
                      //Http call "DELETE" by memoId
                      await deleteMemoTag(item.id);
                    }
                    //Query - Delete Memo by its Id
                    await _memoDao.deleteMemoById(memoId).whenComplete(() {
                      //Refresh Page on Future Complete
                      setState(() {});
                    });

                    //Http call "DELETE" using Memo - id
                    deleteMemo(memoId);
                    Navigator.pop(context); //Close Popup Call
                  }
                },
                child: Text("Delete")),
          ),
        ],
        elevation: 8.0,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Flexible(
              flex: 2,
              child: AppBarAccount(
                //Google User Credential
                user: widget.user,
                //Google User Logout Function
                handleSignOut: _handleSignOut,
                onPressed: () {},
              )),
          Flexible(
              flex: 10,
              child: FutureBuilder<List<MemoTable>>(
                  //Http call "GET" List of Memo
                  future: _memoDao.findAllMemoByTag(_searchTag),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      //Create on successful(200) Http response
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyAppBar(
                              //Body Animation Controller
                              bodySwitcherController: _bodySwitcherController,
                              onSwitcherPress: () {
                                //Body Animation function
                                setState(() {
                                  _bodySwitcher
                                      ? _bodySwitcherController.forward()
                                      : _bodySwitcherController.reverse();
                                  _bodySwitcher = !_bodySwitcher;
                                });
                              },
                              onSearchPress: () =>
                                  _searchContainerController("", false),
                              onAddPress: () async {
                                //New Memo function

                                //Http call "POST". Create a new Memo with Google User Credential
                                var memoResponse = await createMemo(
                                    new MemoTable(
                                        userEmail: widget.user.email,
                                        userDisplayName:
                                            widget.user.displayName));

                                //Create a new Instance of MemoTag (many-to-many) Table
                                _associateMemoTag(
                                        _searchTag,
                                        MemoTable.fromJson(
                                            jsonDecode(memoResponse.body)))
                                    .whenComplete(() {
                                  setState(() {});
                                });
                              },
                              tag: _searchTag,
                            ),
                            Divider(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                height: _searchContainerHeight,
                                child: Visibility(
                                  visible: _isVisible,
                                  child: TextField(
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Search a tag..',
                                      hintStyle: TextStyle(color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    onSubmitted: (tag) =>
                                        _searchContainerController(tag, true),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: BodySwitchMemo(
                                //Memo data - id, user, tags, text
                                memo: snapshot.data,
                                //User Email to authenticate memo creator
                                user: widget.user.email,
                                tagDao: _tagDao,
                                bodySwitcher: _bodySwitcher,
                                onTap: (memo, user) {
                                  //Page Navigator -> Memo_Page
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MemoPage(
                                                memo: memo,
                                                memoDao: _memoDao,
                                                tagDao: _tagDao,
                                                memoTagDao: _memoTagDao,
                                                userEmail: user,
                                              )));
                                },
                                //Offset - Positioning of PopupMenu on the Memo
                                onTapDown: _storePosition,
                                onLongPress: (id, user, cardKey) {
                                  //Show PopupMenu call
                                  setState(() {
                                    _showPopupMenu(id, user, cardKey);
                                  });
                                },
                                closeCard: (cardKey) => _toogleCard(cardKey),
                                //Flip Card Identifier - Memo
                                cardKeys: _cardKeys,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ));
                    }
                  }))
        ],
      ),
    );
  }
}
