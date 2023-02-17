// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({super.key});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class DrawingArea {
  Offset point;
  Paint areaPaint;
  DrawingArea({
    required this.point,
    required this.areaPaint,
  });
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

  List<DrawingArea?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool isEditButtonClicked = false;

  void selectColour() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (isEditButtonClicked)
              ? editLayout(context)
              : Container(
                  height: 150,
                ),
          GestureDetector(
            onPanDown: (details) {
              setState(() {
                points.add(
                  DrawingArea(
                    point: details.localPosition,
                    areaPaint: Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanUpdate: (details) {
              setState(() {
                points.add(
                  DrawingArea(
                    point: details.localPosition,
                    areaPaint: Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanEnd: (details) {
              setState(() {
                points.add(null);
              });
            },
            child: CustomPaint(
              painter: MyCustomPainter(points),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 350,
              ),
            ),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 110),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Colors.white),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: () {
                selectColour();
              },
              color: selectedColor,
            ),
            Expanded(
                child: Slider(
              min: 1.0,
              max: 7.0,
              activeColor: selectedColor,
              value: strokeWidth,
              onChanged: (value) {
                setState(() {
                  strokeWidth = value;
                });
              },
            )),
            IconButton(
              icon: Icon(
                Icons.layers_clear,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  points.clear();
                });
              },
            ),
          ],
        ),
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

class MyCustomPainter extends CustomPainter {
  List<DrawingArea?> points;

  MyCustomPainter(
    this.points,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i]!.areaPaint;
        canvas.drawLine(points[i]!.point, points[i + 1]!.point, paint);
      } else if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i]!.areaPaint;

        canvas.drawPoints(PointMode.points, [points[i]!.point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
