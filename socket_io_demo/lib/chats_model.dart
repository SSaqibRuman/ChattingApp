class Chats {
  int participantId;
  int userId;
  int chatRoomId;
  String created;
  String avatarUrl;
  String description;
  String name;
  bool isGroup;
  String chatRoomName;
  String lastMessage;

  Chats(
      {this.participantId,
      this.userId,
      this.chatRoomId,
      this.created,
      this.avatarUrl,
      this.description,
      this.name,
      this.lastMessage,
      this.isGroup,
      this.chatRoomName});

  Chats.fromJson(Map<String, dynamic> json) {
    participantId = json['participant_id'];
    userId = json['user_id'];
    chatRoomId = json['chatRoom_id'];
    created = json['created'];
    avatarUrl = json['avatar_url'];
    lastMessage = json['last_message'];
    description = json['description'];
    name = json['name'];
    isGroup = json['isGroup'];
    chatRoomName = json['chat_room_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['participant_id'] = this.participantId;
    data['user_id'] = this.userId;
    data['chatRoom_id'] = this.chatRoomId;
    data['created'] = this.created;
    data['avatar_url'] = this.avatarUrl;
    data['description'] = this.description;
    data['last_message'] = this.lastMessage;
    data['name'] = this.name;
    data['isGroup'] = this.isGroup;
    data['chat_room_name'] = this.chatRoomName;
    return data;
  }
}