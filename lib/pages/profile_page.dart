import 'dart:io';

import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:chat_app/pages/home_page.dart';

import '../widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  const ProfilePage({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  FilePickerResult? result;
  String imagePath = "";
  String userDp = "";

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
    getUserData();
  }

  getUserData() async {
    await HelperFunctions.getUserProfilePicFromSF().then((value) {
      setState(() {
        userDp = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
          backgroundColor: Theme.of(context).backgroundColor,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              (userDp == "")
                  ? Icon(
                      Icons.account_circle,
                      size: 150,
                      color: Colors.grey[700],
                    )
                  : CircleAvatar(
                      radius: 75,
                      backgroundImage: NetworkImage(userDp),
                    ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.username,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                height: 2,
              ),
              ListTile(
                onTap: () {
                  nextScreen(context, const HomePage());
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.group),
                title: const Text(
                  "Groups",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () {},
                selected: true,
                selectedColor: Theme.of(context).accentColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.group),
                title: Text(
                  "Profile",
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
              ),
              ListTile(
                onTap: () async {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content:
                              const Text("Are you sure you want to logout?"),
                          actions: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await authService.signOut();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => LoginPage()));
                              },
                              icon: const Icon(
                                Icons.done,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        );
                      });
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                (imagePath == "")
                    ? (userDp == "")
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
                                backgroundImage: NetworkImage(userDp)),
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
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Full Name", style: TextStyle(fontSize: 17)),
                Text(widget.username, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email", style: TextStyle(fontSize: 17)),
                Text(widget.email, style: const TextStyle(fontSize: 17)),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            (imagePath != "")
                ? ElevatedButton(
                    onPressed: () {
                      updateDp();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).accentColor),
                    child: Text("Save"))
                : Container()
          ],
        ),
      ),
    );
  }

  updateDp() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .updateUserDp(imagePath)
        .then((value) {
      print(value);
      showSnackbar(context, Colors.green, "Successfully updated!");
    }, onError: (e) => print("Error updating document $e"));

    setState(() {});
  }
}
