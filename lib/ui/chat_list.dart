import 'package:flutter/material.dart';
import 'package:xmpp_sdk/db/database_helper.dart';

final dbHelper = DatabaseHelper.instance;

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List>(
            future: dbHelper.queryAllRows(DatabaseHelper.contact_table),
            initialData: List(),
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> map = snapshot.data[index];
                  return ListTile(
                      title: _ChatItem(
                          map['username'],
                          'https://cdn-images-1.medium.com/max/1200/1*3X2tLj85Jfq3dlGxWqQ4TA.png',
                          1,
                          true,
                          'Its a test')
                  );
                },
              );
            }
        )
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String imgURL, name, message;
  final int unread;
  final bool active;

  _ChatItem(this.name, this.imgURL, this.unread, this.active, this.message);

  Widget _activeIcon(isActive) {
    if (isActive) {
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
      onTap: () {print('You want to chat with this user.');},
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
                      backgroundImage: NetworkImage(this.imgURL),
                      radius: 30.0,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _activeIcon(active),
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
                        child: Text(this.message,
                            style: TextStyle(
                                color: Colors.grey, fontSize: 15, height: 1.1),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      )
                    ],
                  )),
            ),
            Column(
              children: <Widget>[
                Text('15 min', style: TextStyle(color: Colors.grey[350])),
                _UnreadIndicator(this.unread),
              ],
            )
          ],
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
