import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/listeners/message_listener.dart';
import 'package:xmpp_sdk/ui/listeners/statue_listener.dart';
import 'package:xmpp_sdk/ui/util/date_util.dart';

final dbHelper = DatabaseHelper.instance;

class ChatDetail extends StatefulWidget {
  @override
  ChatDetailState createState() => ChatDetailState();
}

class ChatDetailState extends State<ChatDetail> implements UIMessageListener, UIStatusListener {
  final _contentTextController = TextEditingController();
  final _statusTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  var previous = '';
  bool composingSent = false;

  @override
  void initState() {
    XMPPConnection.messageListener.addMessageCallback(this);
    XMPPConnection.messageListener.addStatusCallback(this);
    
    super.initState();
    Future.delayed(Duration(seconds: 1), () => scrollBottom());

    _contentTextController.addListener(() {
      print(_contentTextController.text);
      if (!composingSent && _contentTextController.text != previous) {
        // typing
        XMPPConnection.instance.sendStateToCurrentChat(Constants.COMPOSING);
        Timer(Duration(seconds: 5), () {
          composingSent = false;
          XMPPConnection.instance.sendStateToCurrentChat(Constants.PAUSED);
        });
        composingSent = true;
      } else if (_contentTextController.text == previous) {
        // paused
        XMPPConnection.instance.sendStateToCurrentChat(Constants.PAUSED);
        composingSent = false;
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: ExactAssetImage('assets/images/default.png'),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        XMPPConnection.currentChat,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<List>(
              future: dbHelper.getCurrentChatDetail(),
              initialData: List(),
              builder: (context, snapshot) {
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 120),
                  controller: _scrollController,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data[index];

                    return Container(
                      padding: EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment: (map[DatabaseHelper.sender_username] ==
                                XMPPConnection.currentChat
                            ? Alignment.topLeft
                            : Alignment.topRight),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (map[DatabaseHelper.sender_username] ==
                                      XMPPConnection.currentChat
                                  ? Colors.grey.shade200
                                  : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child:
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                                    text: (map[DatabaseHelper.content]),
                                  ),
                                  if (map[DatabaseHelper.sender_username] !=
                                      XMPPConnection.currentChat)
                                    WidgetSpan(
                                      child: Icon(Icons.check,
                                          color: Colors.green),
                                    ),
                                ],
                              ),
                            ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w400),
                                      text: (DateUtil.showChatDetailMessageTime(map[DatabaseHelper.received_time])),
                                    ),
                                      WidgetSpan(
                                        child: Icon(Icons.access_time,
                                            color: Colors.green),
                                      ),
                                  ],
                                ),
                              )

                            ]
                            ),
                        ),
                      ),
                    );
                  },
                );
              }),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _contentTextController,
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      XMPPConnection.instance.sendMessageToCurrentChat(
                          _contentTextController.text, this);
                      _contentTextController.text = '';
                      refresh();
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // scrollBottom();
    return scaffold;
  }

  @override
  void refresh() {
    setState(() {});
    scrollBottom();
  }

  void scrollBottom() {
    print('scroll to bottom');
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    XMPPConnection.messageListener.removeMessageCallback(this);
    XMPPConnection.messageListener.removeStatusCallback(this);
    super.dispose();
  }

  @override
  void updateStatus(String status) {
    _statusTextController.text =  XMPPConnection.currentChat + " is " + status;
  }
}
