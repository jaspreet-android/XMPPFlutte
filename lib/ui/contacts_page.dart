import 'package:flutter/material.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/chat_detail.dart';

final dbHelper = DatabaseHelper.instance;

class ContactList extends StatelessWidget {
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
                      title: _ContactItem(
                          map[DatabaseHelper.username],
                          map [DatabaseHelper.user_image],
                          false,
                          'Welcome to scramble apps!!!')
                  );
                },
              );
            }
        )
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String imgURL, name, message;
  final bool active;

  _ContactItem(this.name, this.imgURL, this.active, this.message);

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
                    child:

                    CircleAvatar(
                      backgroundImage: imgURL == ''? ExactAssetImage('assets/images/default.png'): NetworkImage(this.imgURL),
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
          ],
        ),
      ),
    );
  }
}
