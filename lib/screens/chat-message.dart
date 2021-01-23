import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_formatter/time_formatter.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: [
          !mine
              ? Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['fotoUsuario']),
                  ),
                )
              : Container(),
          Expanded(
              child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Divider(
                  height: 5.0,
                  color: Colors.grey,
                ),
              ),
              Text(
                data['nomeDestinatario'],
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _getData().toString(),
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              data['imageUrl'] != null
                  ? Image.network(
                      data['imageUrl'],
                      width: 250.0,
                    )
                  : Text(
                      data['text'],
                      style: TextStyle(fontSize: 16.0),
                      textAlign: mine ? TextAlign.end : TextAlign.start,
                    ),
            ],
          )),
          mine
              ? Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data['fotoUsuario']),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  DateTime _getData() {
    return data['hora'].toDate();
  }
}
