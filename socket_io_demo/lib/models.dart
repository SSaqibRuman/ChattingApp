class ChatRoom {
  int participantId;
  String lastMessage;
  String avatarUrl;
  int userId;
  int chatRoomId;
  String created;
  String modified;
  String description;
  String name;
  bool isGroup;
  String chatRoomName;

  ChatRoom(
      {this.participantId,
      this.lastMessage,
      this.avatarUrl,
      this.userId,
      this.chatRoomId,
      this.modified,
      this.created,
      this.description,
      this.name,
      this.isGroup,
      this.chatRoomName});

  ChatRoom.fromJson(Map<String, dynamic> json) {
    participantId = json['participant_id'];
    lastMessage = json['last_message'];
    avatarUrl = json['avatar_url'];
    userId = json['user_id'];
    chatRoomId = json['chatRoom_id'];
    created = json['created'];
    modified = json['modified'];
    description = json['description'];
    name = json['name'];
    isGroup = json['isGroup'];
    chatRoomName = json['chat_room_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['participant_id'] = this.participantId;
    data['last_message'] = this.lastMessage;
    data['avatar_url'] = this.avatarUrl;
    data['user_id'] = this.userId;
    data['chatRoom_id'] = this.chatRoomId;
    data['modified'] = this.modified;
    data['created'] = this.created;
    data['description'] = this.description;
    data['name'] = this.name;
    data['isGroup'] = this.isGroup;
    data['chat_room_name'] = this.chatRoomName;
    return data;
  }
}


class GetALLChatsBody{
  String chatRoomId;
  String limit;
  String skipCounter;

  GetALLChatsBody({this.chatRoomId, this.limit, this.skipCounter});

  GetALLChatsBody.fromJson(Map<String, dynamic> json){
    chatRoomId = json['chatRoomId'];
    limit = json['limit'];
    skipCounter = json['skipCounter'];
  }

   Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatRoomId'] = this.chatRoomId;
    data['limit'] = this.limit;
    data['skipCounter'] = this.skipCounter;
    return data;
  }

}

class Message {
  int chatId;
  int senderId;
  String senderName;
  String avatarUrl;
  String isRead;
  String rowNumber;
  String created;
  String message;

  Message(
      {this.chatId,
      this.senderId,
      this.senderName,
      this.avatarUrl,
      this.isRead,
      this.rowNumber,
      this.message,
      this.created});

  Message.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    senderId = json['sender_id'];
    senderName = json['senderName'];
    message = json['message'];
    avatarUrl = json['avatar_url'];
    isRead = json['isRead'].toString();
    rowNumber = json['RowNumber'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chat_id'] = this.chatId;
    data['sender_id'] = this.senderId;
    data['senderName'] = this.senderName;
    data['message'] = this.message;
    data['avatar_url'] = this.avatarUrl;
    data['isRead'] = this.isRead;
    data['RowNumber'] = this.rowNumber;
    data['created'] = this.created;
    return data;
  }
}

class ReceivedMessage {
  int senderId;
  int chatRoomId;
  String messageType;
  String message;

  ReceivedMessage(
      {this.senderId, this.chatRoomId, this.messageType, this.message});

  ReceivedMessage.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    chatRoomId = json['chatRoomId'];
    messageType = json['messageType'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['senderId'] = this.senderId;
    data['chatRoomId'] = this.chatRoomId;
    data['messageType'] = this.messageType;
    data['message'] = this.message;
    return data;
  }
}

class UserModel {
  int userId;
  String name;
  String avatarUrl;
  String created;
  bool isActive;
  bool isSelected = false;

  UserModel(
      {this.userId, this.name, this.avatarUrl, this.created, this.isActive});

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    avatarUrl = json['avatar_url'];
    created = json['created'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['avatar_url'] = this.avatarUrl;
    data['created'] = this.created;
    data['isActive'] = this.isActive;
    return data;
  }
}

class CreateChatRoomModel {
  String chatRoomName;
  int creatorId;
  String avatarUrl;
  bool isGroup;
  bool isActive;
  List<int> usersIds;

  CreateChatRoomModel(
      {this.chatRoomName,
      this.creatorId,
      this.avatarUrl,
      this.isGroup,
      this.isActive,
      this.usersIds});

  CreateChatRoomModel.fromJson(Map<String, dynamic> json) {
    chatRoomName = json['chatRoomName'];
    creatorId = json['creatorId'];
    avatarUrl = json['avatarUrl'];
    isGroup = json['isGroup'];
    isActive = json['isActive'];
    usersIds = json['usersIds'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatRoomName'] = this.chatRoomName;
    data['creatorId'] = this.creatorId;
    data['avatarUrl'] = this.avatarUrl;
    data['isGroup'] = this.isGroup;
    data['isActive'] = this.isActive;
    data['usersIds'] = this.usersIds;
    return data;
  }
}

