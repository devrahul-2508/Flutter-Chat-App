import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({super.key});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  TextEditingController messageControllerNew = TextEditingController();

  List<Color> colorList = [
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.deepPurple,
    Colors.yellow
  ];

  bool isEditButtonClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.crop)),
          IconButton(
              onPressed: () {},
              icon: Text(
                "T",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              )),
          IconButton(
              onPressed: () {
                setState(() {
                  isEditButtonClicked = !isEditButtonClicked;
                });
              },
              icon: Icon(Icons.edit)),
        ],
      ),
      body: Column(
        children: [
          (isEditButtonClicked)
              ? editLayout(context)
              : Container(
                  height: 150,
                ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 350,
            color: Colors.red,
          ),
          SizedBox(
            height: 60,
          ),
          _buildMessageComposer()
        ],
      ),
    );
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
              controller: messageControllerNew,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration.collapsed(
                hintText: "Enter a caption",
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          )),
          ButtonBar(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
                  //sendMessage();
                },
              ),
            ],
          )
        ]),
      ),
    );
  }

  Widget editLayout(BuildContext context) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          _horizontalWrappedRow(colorList),
          Slider(value: 0.5, onChanged: (value) {})
        ],
      ),
    );
  }

  Widget circleTile(Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), color: color),
      ),
    );
  }

  Widget _horizontalWrappedRow(List data) {
    var list = <Widget>[];

    //create a new row widget for each data element
    data.forEach((element) {
      list.add(circleTile(element));
    });

    // add the list of widgets to the Row as children
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: list,
      ),
    );
  }
}
