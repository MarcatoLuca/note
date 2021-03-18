import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_tags/flutter_tags.dart';

import 'package:note/model/memo.dart';
import 'package:note/model/tag.dart';

class BodySwitchMemo extends StatelessWidget {
  const BodySwitchMemo({
    Key key,
    @required this.memo,
    @required this.user,
    @required this.tagDao,
    @required this.bodySwitcher,
    @required this.onTap,
    @required this.onTapDown,
    @required this.onLongPress,
    @required this.closeCard,
    @required this.cardKeys,
  }) : super(key: key);

  final List<MemoTable> memo;
  final String user;
  final TagTableDao tagDao;
  final bool bodySwitcher;
  final Function onTap;
  final Function onTapDown;
  final Function onLongPress;
  final Function closeCard;
  final Map<int, GlobalKey<FlipCardState>> cardKeys;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        physics: BouncingScrollPhysics(),
        childAspectRatio: (bodySwitcher) ? 0.7 : 1.7,
        crossAxisCount: (bodySwitcher) ? 2 : 1,
        children: List.generate(
          memo.length,
          (int index) {
            cardKeys.putIfAbsent(index, () => GlobalKey<FlipCardState>());
            GlobalKey<FlipCardState> thisCard = cardKeys[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: ScaleAnimation(
                child: FlipCard(
                  flipOnTouch: false,
                  key: thisCard,
                  front: GestureDetector(
                    onTap: () {
                      onTap(memo[index], user);
                    },
                    onTapDown: (details) => onTapDown(details),
                    onLongPress: () => onLongPress(
                        memo[index].id, memo[index].userEmail, thisCard),
                    child: Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                memo[index].userDisplayName ?? '',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              subtitle: Text(memo[index].userEmail ?? '',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(30))),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 30,
                                      child: Markdown(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          data: memo[index].title ?? ''),
                                    ),
                                    Flexible(
                                      child: Markdown(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          data: memo[index].text ?? ''),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  back: Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  height: 34,
                                  width: 34,
                                  child: RawMaterialButton(
                                    highlightElevation: 0,
                                    onPressed: () => closeCard(thisCard),
                                    elevation: 0,
                                    fillColor: Colors.black.withOpacity(0.1),
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    child: Icon(Icons.clear, size: 20),
                                    shape: CircleBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder<List<TagTable>>(
                                future:
                                    tagDao.findAllTagByMemoId(memo[index].id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Tags(
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (int tagIndex) {
                                        final item = snapshot.data[tagIndex];
                                        return ItemTags(
                                          key: Key(tagIndex.toString()),
                                          index: tagIndex,
                                          title: item.tagText,
                                          combine:
                                              ItemTagsCombine.withTextBefore,
                                        );
                                      },
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                          ),
                        ],
                      )),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
