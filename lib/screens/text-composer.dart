import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage, {this.document});

  final Function({String message, File imgFile}) sendMessage;
  final DocumentSnapshot document;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposed = false;
  TextEditingController _sendInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.document != null)
      _sendInputController.text = widget.document.data["text"];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              PickedFile selectedFile =
                  await ImagePicker().getImage(source: ImageSource.gallery);
              File selected = File(selectedFile.path);
              if (selected == null)
                return;
              else {
                widget.sendMessage(imgFile: selected);
                Navigator.pop(context);
              }
            },
            color: Colors.black,
          ),
          Expanded(
              child: TextField(
            controller: _sendInputController,
            onSubmitted: (text) {
              (widget.document == null)
                  ? widget.sendMessage(message: text)
                  : widget.sendMessage(message: text);
              _sendInputController.clear();
              setState(() {
                _isComposed = false;
              });
            },
            decoration:
                InputDecoration.collapsed(hintText: "Digite uma mensagem..."),
            onChanged: (text) {
              setState(() {
                _isComposed = text.isNotEmpty;
              });
            },
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposed
                  ? () {
                      widget.sendMessage(message: _sendInputController.text);
                      _sendInputController.clear();
                      setState(() {
                        _isComposed = false;
                      });
                    }
                  : null)
        ],
      ),
    );
  }
}
