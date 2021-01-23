import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);

  final Function({String message, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposed = false;
  final _sendInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              //ImagePicker.pickImage(source: ImageSource.camera);
              PickedFile selectedFile =
                  await ImagePicker().getImage(source: ImageSource.gallery);
              File selected = File(selectedFile.path);
              if (selected == null)
                return;
              else
                widget.sendMessage(imgFile: selected);
            },
            color: Colors.black,
          ),
          Expanded(
              child: TextField(
            controller: _sendInputController,
            onSubmitted: (text) {
              widget.sendMessage(message: text);
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
