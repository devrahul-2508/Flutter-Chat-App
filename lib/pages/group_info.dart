import 'dart:io';

import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName,
      required this.groupIcon});
  final String groupId;
  final String groupName;
  final String adminName;
  final String groupIcon;

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  FilePickerResult? result;

  String imagePath = "";
  String groupDp = "";
  String username = "";

  selectImages() async {
    result = await FilePicker.platform.pickFiles();

    if (result != null) {
      imagePath = result!.files.single.path!;

      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembers();
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getMembers() async {
    await HelperFunctions.getUserNameFromSF().then(
      (value) {
        username = value!;
      },
    );

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text("Group Info"),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.exit_to_app))
          ],
        ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Stack(
                  children: [
                    (imagePath == "")
                        ? (widget.groupIcon == "")
                            ? GestureDetector(
                                onTap: selectImages,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 200,
                                  color: Colors.grey[700],
                                ),
                              )
                            : GestureDetector(
                                onTap: selectImages,
                                child: CircleAvatar(
                                    radius: 100,
                                    backgroundImage:
                                        NetworkImage(widget.groupIcon)),
                              )
                        : GestureDetector(
                            onTap: selectImages,
                            child: CircleAvatar(
                                radius: 100,
                                backgroundImage: FileImage(File(imagePath))),
                          ),
                    Positioned(
                        bottom: 10,
                        right: 20,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).accentColor,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ))
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                (imagePath == "")
                    ? Container()
                    : ElevatedButton(
                        onPressed: () {
                          uploadGroupDp();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).accentColor),
                        child: Text("Save")),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Theme.of(context).accentColor.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).accentColor,
                        child: Text(
                          widget.groupName.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Group:  ${widget.groupName}"),
                          SizedBox(
                            height: 3,
                          ),
                          Text("Admin:  ${getName(widget.adminName)}")
                        ],
                      )
                    ],
                  ),
                ),
                memberList()
              ],
            )));
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).accentColor,
                        child: Text(
                          getName(snapshot.data['members'][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).accentColor,
          ));
        }
      },
    );
  }

  uploadGroupDp() async {
    if (username == widget.adminName) {
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateGroupDp(imagePath, widget.groupId)
          .then((value) {
        showSnackbar(context, Colors.green, "Successfully updated");
      },
              onError: (e) =>
                  showSnackbar(context, Colors.red, "Error while updating"));
    } else {
      showSnackbar(context, Colors.red, "You are not allowed to do that");
    }

    setState(() {});
  }
}
