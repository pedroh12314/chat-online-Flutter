import 'dart:io';

import 'package:chat/screens/text-composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat-message.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSign = GoogleSignIn();
  FirebaseUser _currentUser;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((event) {
      setState(() {
        _currentUser = event;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount = await googleSign.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      FirebaseUser user = authResult.user;
      return user;
    } catch (error) {
      print("Ocorreu um erro: " + error);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("ATENÇÃO: Ocorreu um erro: " + error),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  void sendMessage({String message, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível logar! tente novamente..."),
        backgroundColor: Colors.red,
      ));
    }
    Map<String, dynamic> data = {
      "uid": user.uid,
      "nomeDestinatario": user.displayName,
      "fotoUsuario": user.photoUrl
    };

    if (imgFile != null) {
      setState(() {
        _isLoading = true;
      });
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child("images")
          .child(DateTime.now().millisecondsSinceEpoch.toString() +
              "_" +
              _currentUser.uid)
          .putFile(imgFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();

      data["imageUrl"] = url;
    }
    if (message != null) data["text"] = message;
    data["hora"] = Timestamp.now();
    Firestore.instance.collection("messages").document().setData(data);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: _currentUser != null
            ? Text(
                _currentUser.displayName,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                "Não logado",
              ),
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSign.signOut();
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Deslogado com sucesso!"),
                      backgroundColor: Colors.green,
                    ));
                  })
              : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("messages")
                  .orderBy("hora")
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (contex, index) {
                        return ChatMessage(documents[index].data,
                            documents[index].data['uid'] == _currentUser?.uid);
                      },
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(sendMessage)
        ],
      ),
    );
  }
}
