import 'package:flutter/material.dart';
import 'dart:convert' as convert;

import 'package:flutter_link_preview/flutter_link_preview.dart';

import 'download_attachment_card.dart';

class SendedMessageWidget extends StatelessWidget {
  final String content;
  final String time;
  Map<String, dynamic> message;

  SendedMessageWidget({
    Key key,
    this.content,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    message = convert.jsonDecode(content);
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
            right: 8.0, left: 50.0, top: 4.0, bottom: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15)),
          child: Container(
            color: Colors.blue[200],

            // margin: const EdgeInsets.only(left: 10.0),

            child: Stack(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    right: 12.0, left: 23.0, top: 8.0, bottom: 15.0),
                child: message['text'] == null
                  ? DownloadAttachmentCard(message['url'])
                  : Text(message['text']),
              ),
              Positioned(
                bottom: 1,
                left: 10,
                child: Text(
                  time,
                  style: TextStyle(
                      fontSize: 10, color: Colors.black.withOpacity(0.6)),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
