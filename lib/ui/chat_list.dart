import 'package:flutter/material.dart';
import 'package:xmpp_sdk/core/cashe/cache_utils.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/chat_detail.dart';
import 'package:xmpp_sdk/ui/listeners/message_listener.dart';
import 'package:xmpp_sdk/ui/util/date_util.dart';

final dbHelper = DatabaseHelper.instance;

class ChatList extends StatefulWidget {
  @override
  ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> implements UIMessageListener{

  @override
  void initState() {
    XMPPConnection.messageListener.addMessageCallback(this);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List>(
            future: dbHelper.getLastCachedChats(),
            initialData: List(),
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> map = snapshot.data[index];
                  ListTile listTile = ListTile(
                      title: _ChatItem(
                          map[DatabaseHelper.chat_username],
                          map[DatabaseHelper.user_image],
                          map['unread_count'],
                          map[DatabaseHelper.chat_state],
                          map[DatabaseHelper.content],
                          map[DatabaseHelper.received_time]));
                  if(CacheUtil.needToCacheFromUI) {
                    CacheUtil.createLastChatsCache(
                        map[DatabaseHelper.chat_username],
                        map[DatabaseHelper.user_image],
                        map[DatabaseHelper.chat_state],
                        map[DatabaseHelper.content],
                        map['unread_count'],
                        map[DatabaseHelper.received_time]);
                    print('cached from ui');
                  }
                  return listTile;
                },
              );
            }));
  }

  refresh(){
    setState(() {});
  }
  @override
  void dispose() {
    XMPPConnection.messageListener.removeMessageCallback(this);
    super.dispose();
  }
}

class _ChatItem extends StatelessWidget {
  final String imgURL, name, message;
  final int unread;
  final String state;
  final int time;
  _ChatItem(this.name, this.imgURL, this.unread, this.state, this.message, this.time);

  Widget _activeIcon(String isActive) {
    print('state = ' + isActive);
    if (isActive == Constants.ACTIVE || isActive == Constants.COMPOSING || isActive == Constants.PAUSED) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3),
          width: 16,
          height: 16,
          color: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: Color(0xff43ce7d), // flat green
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('You want to chat with this user.');
        XMPPConnection.currentChat = name;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_context) => ChatDetail()),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 12.0),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      print('You want to see the display pictute.');
                    },
                    child: CircleAvatar(
                      backgroundImage: imgURL == ''? ExactAssetImage('assets/images/default.png'): NetworkImage(this.imgURL),
                      radius: 30.0,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _activeIcon(state),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 6.0, right: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.name,
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0),
                        child:
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                style: TextStyle(color: Colors.grey[850]) ,
                                text: (this.state == Constants.COMPOSING) ? "composing ..." : this.message,
                              ),
                              WidgetSpan(
                                child: Icon(this.state == Constants.COMPOSING? Icons.edit_outlined:
                                Icons.text_snippet_outlined,color:  Colors.green),
                              ),
                            ],
                          ),
                        )
                      )
                    ],
                  )),
            ),
            Column(
              children: <Widget>[
                Text(DateUtil.showRecentMessageTime(time), style: TextStyle(color: Colors.grey[350])),
                _UnreadIndicator(this.unread),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  final int unread;

  _UnreadIndicator(this.unread);

  @override
  Widget build(BuildContext context) {
    if (unread == 0) {
      return Container(); // return empty container
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 30,
                color: Color(0xff3e5aeb),
                width: 30,
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                child: Text(
                  unread.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )));
    }
  }
}
