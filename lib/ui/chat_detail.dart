import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:xmpp_sdk/core/constants.dart';
import 'package:xmpp_sdk/core/xmpp_connection.dart';
import 'package:xmpp_sdk/db/database_helper.dart';
import 'package:xmpp_sdk/ui/listeners/message_listener.dart';

final dbHelper = DatabaseHelper.instance;

class ChatDetail extends StatefulWidget {
  @override
  ChatDetailState createState() => ChatDetailState();
}

class ChatDetailState extends State<ChatDetail> implements UIMessageListener {

  final _contentTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  var previous = '';
  bool composingSent =false;

  @override
  void initState() {
    XMPPConnection.messageListener.addCallback(this);
    super.initState();
    Future.delayed(Duration(seconds: 1), () => scrollBottom());

    _contentTextController.addListener(() {
      print(_contentTextController.text);
     if (!composingSent && _contentTextController.text != previous ){
       // typing
       XMPPConnection.instance.sendStateToCurrentChat(Constants.COMPOSING);
       composingSent = true;
     }else if(_contentTextController.text == previous){
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
                  backgroundImage: NetworkImage(Constants.DEFAULT_IMAGE),
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
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body:
      Stack(
        children: <Widget>[
          FutureBuilder<List>(
              future: dbHelper.getCurrentChatDetail(),
              initialData: List(),
              builder: (context, snapshot) {
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 100),
                  controller: _scrollController,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data[index];
                    return ListTile(
                      title: Text(
                        map[DatabaseHelper.content],
                        style: TextStyle(fontSize: 18),
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
                      child: Icon(Icons.add, color: Colors.white, size: 20,),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      controller: _contentTextController,
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: () {
                      XMPPConnection.instance.sendMessageToCurrentChat(_contentTextController.text,this);
                      _contentTextController.text = '';
                      refresh();
                    },
                    child: Icon(Icons.send, color: Colors.white, size: 18,),
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

  void scrollBottom(){
    print('scroll to bottom');
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut
    );
  }

  @override
  void dispose() {
    XMPPConnection.messageListener.removeCallback(this);
    super.dispose();
  }
}
