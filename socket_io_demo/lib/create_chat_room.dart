import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'api.dart';
import 'models.dart';

class CreateChatRoom extends StatefulWidget {
  final bool isIndividualChat;
  final int userId;
  final String userName;

  const CreateChatRoom(
      {Key key,
      @required this.isIndividualChat,
      @required this.userId,
      @required this.userName})
      : super(key: key);

  @override
  _CreateChatRoomState createState() => _CreateChatRoomState();
}

class _CreateChatRoomState extends State<CreateChatRoom> {
  final _searchQuery = new TextEditingController();
  final _groupName = new TextEditingController();
  List<UserModel> users = List();
  List<UserModel> filteredUsers = List();

  _onSearchChanged() {
    filteredUsers.clear();
    if (_searchQuery.text.isEmpty) {
      for (var user in users) {
        filteredUsers.add(UserModel.fromJson(user.toJson()));
      }
    } else {
      for (var user in users) {
        if (user.name.toLowerCase().contains(_searchQuery.text.toLowerCase())) {
          filteredUsers.add(UserModel.fromJson(user.toJson()));
        }
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    _searchQuery.addListener(_onSearchChanged);
    ChatAPIs.getAllUsers(widget.userId).then((usersFromServer) => setState(() {
          users = usersFromServer;
          for (var user in users) {
            filteredUsers.add(UserModel.fromJson(user.toJson()));
          }
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message'),
      ),
      body: Container(
        child: Column(
          children: [
            !widget.isIndividualChat
                ? Container(
                    color: Theme.of(context).primaryColor,
                    child: new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: new Card(
                          child: new ListTile(
                            title: new TextField(
                              controller: _groupName,
                              decoration: new InputDecoration(
                                  hintText: 'Group Name',
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            Container(
              color: Theme.of(context).primaryColor,
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: new Card(
                    child: new ListTile(
                      leading: new Icon(Icons.search),
                      title: new TextField(
                        controller: _searchQuery,
                        decoration: new InputDecoration(
                            hintText: 'Search', border: InputBorder.none),
                      ),
                      trailing: new IconButton(
                        icon: new Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _searchQuery.clear();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, i) {
                  return Container(
                    padding: EdgeInsets.all(5),
                    child: new Card(
                      child: widget.isIndividualChat
                          ? new ListTile(
                              leading: new CircleAvatar(
                                backgroundImage: new NetworkImage(
                                  filteredUsers[i].avatarUrl.trim(),
                                ),
                              ),
                              title: new Text(filteredUsers[i].name.trim()),
                              trailing: IconButton(
                                icon: Icon(Icons.message),
                                onPressed: () {
                                  List<int> users = [
                                    widget.userId,
                                    filteredUsers[i].userId
                                  ];
                                  addChatRoom(
                                      chatRoomName: widget.userName +
                                          "_" +
                                          filteredUsers[i].name.trim(),
                                      usersId: users);
                                },
                              ),
                            )
                          : CheckboxListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  new CircleAvatar(
                                    backgroundImage: new NetworkImage(
                                      filteredUsers[i].avatarUrl.trim(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  new Text(filteredUsers[i].name.trim()),
                                ],
                              ),
                              onChanged: (bool value) {
                                users[getIndexOf(users, filteredUsers[i])]
                                        .isSelected =
                                    users[getIndexOf(users, filteredUsers[i])]
                                                .isSelected ==
                                            true
                                        ? false
                                        : true;
                                print(users[getIndexOf(users, filteredUsers[i])]
                                    .isSelected);
                                setState(() {});
                              },
                              value: users[getIndexOf(users, filteredUsers[i])]
                                  .isSelected,
                            ),
                      margin: const EdgeInsets.all(0.0),
                    ),
                  );
                },
              ),
            ),
            widget.isIndividualChat
                ? Container()
                : RaisedButton(
                    onPressed: () {
                      List<int> users = [
                        widget.userId,
                      ];
                      for (var i = 0; i < this.users.length; i++) {
                        if (this.users[i].isSelected)
                          users.add(this.users[i].userId);
                      }
                      if (_groupName.text.isNotEmpty && users.length > 1) {
                        addChatRoom(
                            chatRoomName: _groupName.text, usersId: users);
                      } else {
                        Fluttertoast.showToast(
                            msg: _groupName.text.isEmpty
                                ? "Please enter the group name"
                                : "Please Select any users",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                    child: Text("Create Chat Room"),
                  )
          ],
        ),
      ),
    );
  }

  int getIndexOf(List<UserModel> users, UserModel user) {
    for (var i = 0; i < users.length; i++) {
      if (user.userId == users[i].userId) return i;
    }
    return -1;
  }

  void addChatRoom({String chatRoomName, List<int> usersId}) async {
    await ChatAPIs.createChatRoom(
        avatarUrl: "",
        chatRoomName: chatRoomName,
        creatorId: widget.userId,
        isGroup: !widget.isIndividualChat,
        usersIds: usersId);
  }
}
