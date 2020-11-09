import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'sended_message.dart';
import 'received_message.dart';
import 'dart:convert' as convert;

import 'api.dart';
import 'models.dart';

class Messages extends StatefulWidget {
  final int userId;
  final int chatRoomId;
  final String chatRoomName;
  Messages(
      {Key key,
      @required this.userId,
      @required this.chatRoomId,
      @required this.chatRoomName})
      : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  TextEditingController _text = new TextEditingController();
  ScrollController _scrollController = ScrollController();
  StreamController<Message> controller = StreamController<Message>.broadcast();
  Stream stream;
  var childList = <Widget>[];
  List<Message> messages = [];
  SocketIO socketIO = SocketIOManager().createSocketIO(
    "https://schooldude-nodeapp.herokuapp.com",
    //"https://192.168.137.1:3001",
    //"https://192.168.43.157:3000",
    "/",
  );

  @override
  void dispose() {
    super.dispose();
    socketIO.destroy();
  }

  @override
  void initState() {
    super.initState();
    stream = controller.stream;
    socketIO.init();

    socketIO.subscribe('msg', (msg) {
      ReceivedMessage _msg = ReceivedMessage.fromJson(convert.jsonDecode(msg));
      if (_msg.chatRoomId == widget.chatRoomId) {
        if (_msg.senderId == widget.userId) {
          childList.add(Align(
            alignment: Alignment(1, 0),
            child: SendedMessageWidget(
              content: '{"${_msg.messageType}":"${_msg.message}"}',
              time: TimeAgo.getTimeAgo(DateTime.now()),
            ),
          ));
        } else {
          childList.add(Align(
            alignment: Alignment(-1, 0),
            child: ReceivedMessageWidget(
              content: '{"${_msg.messageType}":"${_msg.message}"}',
              time: TimeAgo.getTimeAgo(DateTime.now()),
            ),
          ));
        }
      }

      // _scrollController.animateTo(
      //   0.0,
      //   curve: Curves.easeOut,
      //   duration: const Duration(milliseconds: 300),
      // );

      setState(() {});
    });
    socketIO.connect();

    ChatAPIs.getAllChats(
      body: GetALLChatsBody(
          chatRoomId: "${widget.chatRoomId}", skipCounter: "0", limit: "10"),
    ).then((value) {
      messages = value;
      messages.forEach((element) {
        if (element.senderId == widget.userId) {
          childList.add(Align(
            alignment: Alignment(1, 0),
            child: SendedMessageWidget(
              content: element.message,
              time: TimeAgo.getTimeAgo(DateTime.parse(element.created)),
            ),
          ));
        } else {
          childList.add(Align(
            alignment: Alignment(-1, 0),
            child: ReceivedMessageWidget(
              content: element.message,
              time: TimeAgo.getTimeAgo(DateTime.parse(element.created)),
            ),
          ));
        }
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Title(
            color: Colors.black,
            child: Text(widget.chatRoomName),
          ),
        ),
        body: SafeArea(
          child: Container(
            child: Stack(
              fit: StackFit.loose,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Divider(
                      height: 0,
                      color: Colors.black54,
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                  'https://i2.wp.com/www.techgrapple.com/wp-content/uploads/2016/07/WhatsApp-Chat-theme-iPhone-stock-744.jpg'),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.linearToSrgbGamma()),
                        ),
                        child: SingleChildScrollView(
                            controller: _scrollController,
                            reverse: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: childList,
                            )),
                      ),
                    ),
                    Divider(height: 0, color: Colors.black26),
                    Container(
                      color: Colors.white,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextField(
                          maxLines: 20,
                          controller: _text,
                          decoration: InputDecoration(
                            suffixIcon: Container(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.attach_file),
                                    onPressed: () async {
                                      if (await ChatAPIs
                                          .requestStoragePermission()) {
                                        FilePickerResult result =
                                            await FilePicker.platform
                                                .pickFiles();
                                        if (result != null) {
                                          File file =
                                              File(result.files.single.path);

                                          var url =
                                              await ChatAPIs.uploadFile(file);
                                          var __message =
                                              '{"senderId":${widget.userId}, "chatRoomId": ${widget.chatRoomId}, "messageType" : "url", "message":"$url"}';
                                          socketIO.sendMessage(
                                              'sendMessage', __message);
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.send),
                                    onPressed: () {
                                      // var __message = {
                                      //   'senderId' : '${widget.userId}',
                                      //   'chatRoomId' : '${widget.chatRoomId}',
                                      //   'messageType' : 'text',
                                      //   'message' : 'HI I AM SENDING A MESSAGE.',
                                      // };
                                      var __message =
                                          '{"senderId":${widget.userId}, "chatRoomId": ${widget.chatRoomId}, "messageType" : "text", "message":"${_text.text}"}';
                                      socketIO.sendMessage(
                                          'sendMessage', __message);
                                      _text.clear();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            border: InputBorder.none,
                            hintText: "Enter your message",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
