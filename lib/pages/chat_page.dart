import 'package:chat_app/pages/edit_image_page.dart';
import 'package:chat_app/pages/group_info.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String groupIcon;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName,
      required this.groupIcon});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = "";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  bool _isFirstScrolled = false;

  FilePickerResult? result;

  String imagePath = "";
  String groupDp = "";
  String username = "";

  selectImages() async {
    result = await FilePicker.platform.pickFiles();

    if (result != null) {
      imagePath = result!.files.single.path!;

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EditImagePage(
                    imagePath: imagePath,
                  )));

      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getChatAndAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xffb272336),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                      groupIcon: widget.groupIcon,
                    ));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Column(
        children: [
          chatMessages(),
          SizedBox(
            height: 10,
          ),
          _buildMessageComposer(),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  getChatAndAdmin() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getChats(widget.groupId)
        .then((val) {
      setState(() {
        chats = val;
      });
    });

    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmins(widget.groupId)
        .then((value) {
      setState(() {
        admin = value;
      });
    });

    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .toggleRecentMessageSeen(widget.groupId);

    // chats!.listen((event) {
    //   DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
    //       .toggleRecentMessageSeen(widget.groupId);
    // });
  }

  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .toggleRecentMessageSeen(widget.groupId);

          return snapshot.hasData
              ? Expanded(
                  child: ListView.builder(
                      controller: listScrollController,
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return MessageTile(
                          message: snapshot.data.docs[index]["message"],
                          sender: snapshot.data.docs[index]['sender'],
                          isMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          messageTimeStamp: snapshot.data.docs[index]['time'],
                        );
                      }),
                )
              : Expanded(child: Container());
        });
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Color(0xffb312b46), borderRadius: BorderRadius.circular(40)),
        child: Row(children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              controller: messageController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration.collapsed(
                hintText: "Enter your message...",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          )),
          ButtonBar(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.attach_file,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await selectImages();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
                  sendMessage();
                },
              ),
            ],
          )
        ]),
      ),
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().microsecondsSinceEpoch
      };

      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(widget.groupId, chatMessageMap);

      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .toggleRecentMessageSeen(widget.groupId);

      setState(() {
        messageController.clear();
      });
    }
  }

  scrollToBottom() {
    if (listScrollController.hasClients) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        listScrollController.animateTo(
          listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }
}
