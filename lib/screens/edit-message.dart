import 'dart:io';

import 'package:chat/screens/text-composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'chat-message.dart';

class EditMessage extends StatefulWidget {
  final DocumentSnapshot document;

  EditMessage(this.document);

  @override
  _EditMessageState createState() => _EditMessageState();
}

class _EditMessageState extends State<EditMessage> {
  //bool _isLoading = false;
// Lembrar de salvar ao voltar tela

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text("Editar Mensagem"),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ChatMessage(widget.document, true),
            TextComposer(
              sendMessage,
              document: widget.document,
            ),
          ],
        ),
      ),
      onWillPop: _goBackPopup,
    );
  }

  void sendMessage({String message, File imgFile}) async {
    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child("images")
          .child(DateTime.now().millisecondsSinceEpoch.toString() +
              "_" +
              widget.document.data["uid"])
          .putFile(imgFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();

      Firestore.instance
          .collection("messages")
          .document(widget.document.documentID)
          .updateData(
              {"editDate": Timestamp.now(), "imageUrl": url, "isEdited": true});
    }
    widget.document.data["hora"] = Timestamp.now();

    if (message != null) {
      Firestore.instance
          .collection("messages")
          .document(widget.document.documentID)
          .updateData(
              {"editDate": Timestamp.now(), "text": message, "isEdited": true});
    }
    Navigator.pop(context);
  }

  Future<bool> _goBackPopup() {
    showDialog(
        context: context,
        builder: (contex) {
          return AlertDialog(
            title: Text("Sair do modo de edição?"),
            content: Text("Caso você saia, não perderá sua mensagem"),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Sim")),
            ],
          );
        });
    return Future.value(true);
  }
}
