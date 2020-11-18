import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'models.dart';
import 'package:azblob/azblob.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';

class ChatAPIs {
  static const String _BASE_URL = 'https://schooldude-nodeapp.herokuapp.com';
  static const String _GET_ALL_CHAT_ROOM_URL = _BASE_URL + '/getAllChatRooms';
  static const String _GET_ALL_CHATS_URL = _BASE_URL + '/getAllchats';
  static const String _UPLOAD_FILE = _BASE_URL + '/uploadFile';
  static const String _GET_ALL_USERS = _BASE_URL + '/getAllUsers';
  static const String _CREATE_CHAT_ROOM = _BASE_URL + '/createChatRoom';

  static Future<String> uploadFile(File file) async {
    var fileName = basename(file.path);
    var storageConnectionString = "DefaultEndpointsProtocol=https;" +
        "AccountName=schoolsms;" +
        "AccountKey=fK4HqZOk01ydeeX17H+oi3Pht1UCm43TcnNHW5OCmbr4taUOCJstRE+eyoY9MZUYjwmcIjkHBWccbh3KTjcUjA==";
    var storage = AzureStorage.parse(storageConnectionString);
    await storage.putBlob('/appuploads/$fileName',
        bodyBytes: file.readAsBytesSync(),
        contentType: lookupMimeType(fileName));

    return ('https://schoolsms.blob.core.windows.net/appuploads/$fileName');

    // var request = http.MultipartRequest('POST', Uri.parse(UPLOAD_FILE));
    // request.files.add(await http.MultipartFile.fromPath('recfile', filepath));
    // var res = await request.send();
    //return "res.reasonPhrase";
  }

  static Future<List<ChatRoom>> getAllChatRooms({String userID}) async {
    List<ChatRoom> chatRooms = [];
    var body = {'userID': userID};
    var response = await http.post(_GET_ALL_CHAT_ROOM_URL, body: body);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = convert.jsonDecode(response.body);
      jsonResponse.forEach((element) {
        chatRooms.add(ChatRoom.fromJson(element));
      });
      print("REsult: ${response.body}");
      return chatRooms;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return null;
    }
  }

  static Future<bool> requestStoragePermission() async {
    bool result = false;
    if (Platform.isAndroid) {
      print("Platform.isAndroid : ${Platform.isAndroid}");
      if (!await Permission.storage.isGranted) {
        PermissionStatus status = await Permission.storage.request();
        result = status == PermissionStatus.granted ? true : false;
      } else {
        result = true;
        print(
            "Permission.storage.isGranted: ${await Permission.storage.isGranted}");
      }
    } else if (Platform.isIOS) {
      if (!await Permission.storage.isGranted) {
        PermissionStatus status = await Permission.mediaLibrary.request();
        result = status == PermissionStatus.granted ? true : false;
      } else {
        result = true;
        print(
            "Permission.storage.isGranted: ${await Permission.storage.isGranted}");
      }
    } else {
      print("Invalid Platform");
    }
    return result;
  }

  static Future<List<Message>> getAllChats({GetALLChatsBody body}) async {
    List<Message> messages = [];
    var response = await http.post(_GET_ALL_CHATS_URL, body: body.toJson());
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = convert.jsonDecode(response.body);
      jsonResponse.forEach((element) {
        messages.add(Message.fromJson(element));
      });
      print("Result: ${response.body}");
      return messages;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return null;
    }
  }

  static Future<List<UserModel>> getAllUsers(int userID) async {
    List<UserModel> users = [];
    var body = {
      "userID": "$userID",
    };
    var response = await http.post(_GET_ALL_USERS, body: body);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = convert.jsonDecode(response.body);
      jsonResponse.forEach((element) {
        users.add(UserModel.fromJson(element));
      });
      return users;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return null;
    }
  }

  static Future<String> createChatRoom(
      {String chatRoomName,
      int creatorId,
      String avatarUrl,
      bool isGroup,
      List<int> usersIds}) async {
    var body = {
      "chatRoomName": "$chatRoomName",
      "creatorId": "$creatorId",
      "avatarUrl": "$avatarUrl",
      "isGroup": "$isGroup",
      "usersIds": convert.jsonEncode(usersIds),
    };
    print(body);
    //{chatRoomName: "ChatRoomName","usersIds":[1,2,3], creatorId:1, avatarUrl:"", isGroup:1}
    var response = await http.post(_CREATE_CHAT_ROOM, body: body);
    if (response.statusCode == 200) {
      print("${convert.jsonDecode(response.body)["chatRoomID"]}");
      return("${convert.jsonDecode(response.body)["chatRoomID"]}");
    } else {
      print('Request failed with status: ${response.statusCode}.');
      print('Request failed with status: ${response.body}.');
      return null;
    }
  }
}
