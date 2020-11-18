import 'package:flutter/material.dart';
import 'dart:convert' as convert;

import 'download_attachment_card.dart';

class ReceivedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  Map<String, dynamic> message;

  ReceivedMessageWidget({
    Key key,
    this.content,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    message = convert.jsonDecode(content);
    print(context);
    return Container(
        child: Padding(
      padding:
          const EdgeInsets.only(right: 75.0, left: 8.0, top: 8.0, bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(15),
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15)),
        child: Container(
          color: Colors.orange[700],
          child: Stack(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  right: 8.0, left: 8.0, top: 8.0, bottom: 15.0),
              child: message['text'] == null
                  ? DownloadAttachmentCard(message['url'])
                  : Text(message['text']),
            ),
            Positioned(
              bottom: 1,
              right: 10,
              child: Text(
                time,
                style: TextStyle(
                    fontSize: 10, color: Colors.black.withOpacity(0.6)),
              ),
            )
          ]),
        ),
      ),
    ));
  }
}
