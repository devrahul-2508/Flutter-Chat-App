import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  // reference for collection

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // updating user data

  Future savingUserData(String username, String email) async {
    return await userCollection.doc(uid).set({
      "userName": username,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get user groups

  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //creating a group

  Future createGroup(String username, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$username",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageTime": "",
      "recentMessageSeenBy": []
    });

    //update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$username"]),
      "groupId": groupDocumentReference.id
    });

    //update group in user

    DocumentReference userDocumentReference = userCollection.doc(uid);

    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]),
    });
  }

  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmins(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot document = await d.get();
    return document["admin"];
  }

  Future getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future searchByName(String groupName) async {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  Future<bool> isUserJoined(
      String groupName, String groupId, String username) async {
    DocumentReference userReference = userCollection.doc(uid);
    DocumentSnapshot document = await userReference.get();

    List groups = document["groups"];

    if (groups.contains("${groupId}_${groupName}")) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleJoin(String groupId, String groupName, String username) async {
    DocumentReference groupReference = groupCollection.doc(groupId);
    DocumentReference userReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshots = await userReference.get();
    List groups = documentSnapshots["groups"];

    if (groups.contains("${groupId}_${groupName}")) {
      await groupReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$username"]),
      });

      await userReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });
    } else {
      await groupReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$username"]),
      });

      await userReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });
    }
  }

  Future sendMessage(
      String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);

    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData["message"],
      "recentMessageSender": chatMessageData["sender"],
      "recentMessageTime": chatMessageData["time"].toString(),
      "recentMessageSeenBy": []
    });
  }

  Future getGroupRecentMessageData(String groupId) async {
    return await groupCollection.doc(groupId).snapshots();
  }

  Future getUserGroupsv1() async {
    return await groupCollection
        .where("members", arrayContains: uid)
        .snapshots();
  }

  Future toggleRecentMessageSeen(String groupId) async {
    DocumentReference groupReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await groupReference.get();

    List messageSeenBy = documentSnapshot["recentMessageSeenBy"];

    if (!messageSeenBy.contains(uid)) {
      await groupReference.update({
        "recentMessageSeenBy": FieldValue.arrayUnion([uid]),
      });
    }
  }
}
