import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tags/flutter_tags.dart';

import 'package:note/model/memo.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({
    Key key,
    @required this.memo,
    @required this.userEmail,
  }) : super(key: key);

  final MemoTable memo;
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
                      /* Expanded(
                        child: Tags(
                          textField: (widget.memo.userEmail == widget.userEmail)
                              ? TagsTextField(
                                  autofocus: false,
                                  onSubmitted: (String tag) {
                                    setState(() {
                                      widget.memo.tags.add("#" + tag);
                                      updateMemo(
                                          widget.memo,
                                          _titleEditingController.text,
                                          _bodyEditingController.text);
                                    });
                                  },
                                )
                              : null,
                          itemCount: widget.memo.tags.length,
                          itemBuilder: (int index) {
                            final item = widget.memo.tags[index];
                            return ItemTags(
                              key: Key(index.toString()),
                              index: index,
                              title: item,
                              combine: ItemTagsCombine.withTextBefore,
                              removeButton:
                                  (widget.memo.userEmail == widget.userEmail &&
                                          widget.memo.tags[index] != "#memo")
                                      ? ItemTagsRemoveButton(
                                          onRemoved: () {
                                            setState(() {
                                              widget.memo.tags.removeAt(index);
                                              updateMemo(
                                                  widget.memo,
                                                  _titleEditingController.text,
                                                  _bodyEditingController.text);
                                            });
                                            return true;
                                          },
                                        )
                                      : null,
                            );
                          },
                        ),
                      ) */
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
                                        onPressed: () {
                                          setState(() {
                                            _isEditingTitleText = false;
                                          });
                                          updateMemo(
                                              widget.memo,
                                              _titleEditingController.text
                                                  .toUpperCase(),
                                              _bodyEditingController.text);
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
                                    overscroll.disallowGlow();
                                    return;
                                  },
                                  child: Markdown(
                                    data: _titleEditingController.text
                                            .toUpperCase() ??
                                        '',
                                    selectable: false,
                                  ),
                                ))),
                  ),
                  Expanded(
                    child: ClipRRect(
                      child: Container(
                          child: (_isEditingBodyText &&
                                  widget.memo.userEmail == widget.userEmail)
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
                                          onPressed: () {
                                            setState(() {
                                              _isEditingBodyText = false;
                                            });
                                            updateMemo(
                                                widget.memo,
                                                _titleEditingController.text
                                                    .toUpperCase(),
                                                _bodyEditingController.text);
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
                                      overscroll.disallowGlow();
                                      return;
                                    },
                                    child: Markdown(
                                      data: _bodyEditingController.text ?? '',
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
