import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter_tags/flutter_tags.dart';

import 'package:http/http.dart' as http;

import 'package:note/model/memo.dart';
import 'package:note/model/memo_tag.dart';
import 'package:note/model/tag.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({
    Key key,
    @required this.memo,
    @required this.memoDao,
    @required this.tagDao,
    @required this.memoTagDao,
    @required this.userEmail,
  }) : super(key: key);

  final MemoTable memo;
  final MemoTableDao memoDao;
  final TagTableDao tagDao;
  final MemoTagDao memoTagDao;
  final String userEmail;

  @override
  _Memo createState() => _Memo();
}

class _Memo extends State<MemoPage> {
  //Memo Text Controller and Value
  bool _isEditingTitleText = false;
  TextEditingController _titleEditingController;

  //Memo Text Controller and Value
  bool _isEditingBodyText = false;
  TextEditingController _bodyEditingController;

  @override
  void initState() {
    super.initState();

    _bodyEditingController = TextEditingController();
    _bodyEditingController.text = widget.memo.text;

    _titleEditingController = TextEditingController();
    _titleEditingController.text = widget.memo.title;
  }

  Future<void> _saveDataOnDB() async {
    //Query - Load on db Fetched Data from Server
    await widget.memoDao.insertMemos(await fetchMemo(http.Client()));
    await widget.tagDao.insertTags(await fetchTag(http.Client()));
    await widget.memoTagDao.insertMemoTags(await fetchMemoTag(http.Client()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                      child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 8.0, right: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                  child: Text(
                                widget.memo.userDisplayName + " - Note",
                                style: TextStyle(fontSize: 16),
                              )),
                            ),
                            IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => Navigator.pop(
                                    context)) //Close Navigation Push Call
                          ],
                        ),
                      ),
                      FutureBuilder<List<TagTable>>(
                          future:
                              widget.tagDao.findAllTagByMemoId(widget.memo.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Expanded(
                                //Tags Package
                                child: Tags(
                                  textField: (widget.memo.userEmail ==
                                          widget
                                              .userEmail) //Google User Permission - Creator of the Memo
                                      ? TagsTextField(
                                          autofocus: false,
                                          onSubmitted: (String text) async {
                                            String tag = "#" + text;

                                            //Query - Init the Tag Object by its tagText
                                            TagTable tagTable = await widget
                                                .tagDao
                                                .findTagByTagText(tag);

                                            if (tagTable == null) {
                                              //If Tag Obj doesn't exist

                                              //Http call "POST" new Tag
                                              var tagResponse =
                                                  await createTag(tag);
                                              tagTable = TagTable.fromJson(
                                                  jsonDecode(tagResponse.body));
                                            }
                                            //Http call "POST" new MemoTag
                                            createMemoTag(
                                                widget.memo.id, tagTable.id);
                                            //Method - Save on db the Data just created
                                            await _saveDataOnDB()
                                                .whenComplete(() {
                                              setState(() {});
                                            });
                                          },
                                        )
                                      : null,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (int index) {
                                    final item = snapshot.data[index];
                                    return ItemTags(
                                      key: Key(index.toString()),
                                      index: index,
                                      title: item.tagText,
                                      combine: ItemTagsCombine.withTextBefore,
                                      removeButton: (widget.memo.userEmail ==
                                                  widget.userEmail &&
                                              snapshot.data[index].tagText !=
                                                  "#memo") //Google User Permission - Creator of the Memo
                                          ? ItemTagsRemoveButton(
                                              onRemoved: () {
                                                setState(() async {
                                                  //Query - Fing the Memo_Tag by the memo and tag ID
                                                  MemoTagTable memoTagTable =
                                                      await widget.memoTagDao
                                                          .findMemoTagByMemoIdAndTagid(
                                                              widget.memo.id,
                                                              item.id);
                                                  //Http call "DELETE" the Memo_Tag relathion
                                                  deleteMemoTag(
                                                      memoTagTable.id);
                                                  //Query - Delete the Memo_Tag relathion
                                                  await widget.memoTagDao
                                                      .deleteMemoTag(
                                                          memoTagTable)
                                                      .whenComplete(() {
                                                    //Refresher
                                                    setState(() {});
                                                  });
                                                });
                                                return true;
                                              },
                                            )
                                          : null,
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Container();
                            }
                          })
                    ],
                  ))),
            ),
            Divider(
              indent: 8,
              endIndent: 8,
              thickness: 3,
            ),
            Flexible(
              flex: 7,
              child: Column(
                children: [
                  ClipRRect(
                    child: Container(
                        height: 90,
                        child: (_isEditingTitleText &&
                                widget.memo.userEmail == widget.userEmail)
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: TextField(
                                  maxLength: 30,
                                  maxLengthEnforced: true,
                                  textInputAction: TextInputAction.newline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      labelText: 'Title:',
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _isEditingTitleText = false;
                                          });
                                          //Set new Memo Title Value
                                          widget.memo.title =
                                              _titleEditingController.text
                                                  .toUpperCase();

                                          //Query - Update Memo
                                          await widget.memoDao
                                              .updateMemo(widget.memo)
                                              .whenComplete(() {
                                            setState(() {});
                                          });
                                          //Http call "UPDATE"
                                          updateMemo(widget.memo);
                                        },
                                        icon: Icon(Icons.done),
                                      )),
                                  autofocus: true,
                                  controller: _titleEditingController,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    _isEditingTitleText = true;
                                  });
                                },
                                child: NotificationListener<
                                    OverscrollIndicatorNotification>(
                                  onNotification:
                                      (OverscrollIndicatorNotification
                                          overscroll) {
                                    overscroll
                                        .disallowGlow(); //disable ListView Scroll Glow
                                    return;
                                  },
                                  child: Markdown(
                                    data: (widget.memo.title != null)
                                        ? widget.memo.title.toUpperCase()
                                        : '',
                                    selectable: false,
                                  ),
                                ))),
                  ),
                  Expanded(
                    child: ClipRRect(
                      child: Container(
                          child: (_isEditingBodyText &&
                                  widget.memo.userEmail ==
                                      widget
                                          .userEmail) //Google User Permission - Creator of the Memo
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10.0, left: 8.0, right: 8.0),
                                  child: TextField(
                                    textInputAction: TextInputAction.newline,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        labelText: 'Write here your note:',
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              _isEditingBodyText = false;
                                            });

                                            //Set new Memo Text Value
                                            widget.memo.text =
                                                _bodyEditingController.text;

                                            //Query - Update Memo
                                            await widget.memoDao
                                                .updateMemo(widget.memo)
                                                .whenComplete(() {
                                              setState(() {});
                                            });
                                            //Http call "UPDATE"
                                            updateMemo(widget.memo);
                                          },
                                          icon: Icon(Icons.done),
                                        )),
                                    autofocus: true,
                                    controller: _bodyEditingController,
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isEditingBodyText = true;
                                    });
                                  },
                                  child: NotificationListener<
                                      OverscrollIndicatorNotification>(
                                    onNotification:
                                        (OverscrollIndicatorNotification
                                            overscroll) {
                                      overscroll
                                          .disallowGlow(); //Disable ListView Scroll Glow
                                      return;
                                    },
                                    child: Markdown(
                                      data: (widget.memo.text != null)
                                          ? widget.memo.text
                                          : '',
                                      selectable: false,
                                    ),
                                  ))),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
