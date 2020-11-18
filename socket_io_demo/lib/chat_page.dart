import 'dart:async';

import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'api.dart';
import 'create_chat_room.dart';
import 'models.dart';

import 'messages_screen.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  TextEditingController _text = new TextEditingController();
  var childList = <Widget>[];
  Animation<double> _animation;
  AnimationController _animationController;

  StreamController myChatsStreamController;

  List<String> toPrint = ["trying to connect"];
  SocketIO socketIO = SocketIOManager().createSocketIO(
    "https://schooldude-nodeapp.herokuapp.com/",
    //"https://192.168.137.1:3001",
    //"https://192.168.43.157:3000",
    "/",
  );
  TextEditingController messageController = TextEditingController();
  List<ChatRoom> chats = [];
  int userID = 1;
  String userName = "Tom";
  @override
  void initState() {
    socketIO.init();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    socketIO.connect().then((value) {
      print('I am HERE >>>>>>> 41');
    });

    socketIO.subscribe("chat message", (message) {
      print("socketID: ${socketIO.getId()}");
      print("Message: " + message);
    });

    socketIO.sendMessage('getChats', '{"userId": $userID}');
    super.initState();
  }

  @override
  void dispose() {
    myChatsStreamController.close();
    socketIO.unSubscribe('chats');
    socketIO.unSubscribe('chat message');
    socketIO.destroy();
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionBubble(
        animation: _animation,
        backGroundColor: Colors.white,
        iconColor: Colors.blue,
        iconData: Icons.add,
        items: <Bubble>[
          Bubble(
              title: "Create Chat",
              iconColor: Colors.white,
              bubbleColor: Colors.blue,
              icon: Icons.add_comment,
              titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {
                _animationController.reverse();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateChatRoom(
                      userId: userID,
                      userName: userName,
                      isIndividualChat: true,
                    ),
                  ),
                );
              }),
          Bubble(
            title: "Create Group",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.group_add,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _animationController.reverse();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateChatRoom(
                      userId: userID,
                      userName: userName,
                      isIndividualChat: false,
                    ),
                  ),
                );
            },
          ),
        ],
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          child: Column(
            children: <Widget>[
              Text("Chats Room"),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(),
              FutureBuilder(
                  future: ChatAPIs.getAllChatRooms(userID: "$userID"),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ChatRoom>> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    return Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount:
                            snapshot.data == null ? 0 : snapshot.data.length,
                        itemBuilder: (context, pos) {
                          ChatRoom chatObj = snapshot.data[pos];
                          if (chatObj != null)
                            return GestureDetector(
                              //child: Text(chatObj.name ?? ""),
                              child: ChatListViewItem(
                                chat: chatObj,
                                userID: userID,
                                hasUnreadMessage: false,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Messages(
                                      chatRoomId: chatObj.chatRoomId,
                                      userId: chatObj.userId,
                                      chatRoomName: chatObj.chatRoomName,
                                    ),
                                  ),
                                );
                              },
                            );
                          else
                            return Container();
                        },
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatListViewItem extends StatelessWidget {
  final ChatRoom chat;
  final int userID;
  final bool hasUnreadMessage;

  const ChatListViewItem({
    Key key,
    this.chat,
    this.userID,
    this.hasUnreadMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: ListTile(
                  title: Text(
                    chat.isGroup
                        ? chat.chatRoomName
                        :chat.name,
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chat.avatarUrl),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        TimeAgo.getTimeAgo(DateTime.parse(chat.modified)),
                        style: TextStyle(fontSize: 12),
                      ),
                      hasUnreadMessage
                          ? Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  )),
                              child: Center(
                                  child: Text(
                                '0',
                                style: TextStyle(fontSize: 11),
                              )),
                            )
                          : SizedBox()
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Messages(
                          chatRoomId: chat.chatRoomId,
                          userId: userID,
                          chatRoomName: chat.isGroup
                              ? chat.chatRoomName
                              : chat.name,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Divider(
            endIndent: 12.0,
            indent: 12.0,
            height: 0,
          ),
        ],
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Archive',
          color: Colors.blue,
          icon: Icons.archive,
          onTap: () {},
        ),
      ],
    );
  }
}
