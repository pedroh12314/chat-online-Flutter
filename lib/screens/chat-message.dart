import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edit-message.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.document, this.mine);

  final DocumentSnapshot document;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showOptons(context);
      },
      onTap: () {
        _showOptons(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          children: [
            !mine
                ? Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: CircleAvatar(
                      backgroundImage: document.data['fotoUsuario'] != null
                          ? NetworkImage(document.data['fotoUsuario'])
                          : AssetImage("images/person.png"),
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
                  document.data['nomeDestinatario'],
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _getData().toString() +
                        (document.data["isEdited"] == true ? " • Editada" : ""),
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                document.data['imageUrl'] != null
                    ? Image.network(
                        document.data['imageUrl'],
                        width: 250.0,
                      )
                    : Text(
                        document.data['text'],
                        style: TextStyle(fontSize: 16.0),
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                      ),
              ],
            )),
            mine
                ? Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: CircleAvatar(
                      backgroundImage: document.data['fotoUsuario'] != null
                          ? NetworkImage(document.data['fotoUsuario'])
                          : AssetImage("images/person.png"),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  DateTime _getData() {
    return document.data['hora'].toDate();
  }

  _showOptons(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showChangeMessage(context);
                          },
                          child: Text(
                            "Editar",
                            style:
                                TextStyle(color: Colors.black, fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showConfirmDelete(context);
                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          )),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  void _showChangeMessage(BuildContext context) async {
    // final backMessage = await Navigator.push(context,
    // MaterialPageRoute(builder: (context) => EditMessage(document)));
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditMessage(document)));
    //if (backMessage != null) {
    // if (contato != null) {
    //   await contactHelper.updateContact(contactBack);
    // } else {
    //   await contactHelper.saveContact(contactBack);
    // }
    //_getAllContacts();
    //}
  }

  Future<bool> _showConfirmDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Excluir Mensagem?"),
            content: Text("Esta ação exclui permanentemente sua mensagem."),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Firestore.instance
                      .collection("messages")
                      .document(document.documentID)
                      .delete();
                },
                child: Text(
                  "Excluir",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
    return Future.value(false);
  }
}
