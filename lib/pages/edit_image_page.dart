import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({super.key, required this.imagePath});

  final String imagePath;

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

  ui.Image? backgroundImage;
  bool isImageloaded = false;

  List<DrawingArea?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;

  static GlobalKey ssKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    convertImage();
  }

  convertImage() async {
    File file = File(widget.imagePath);
    Uint8List bytes = await file.readAsBytes();
    backgroundImage = await loadImage(bytes);
  }

  Future<ui.Image> loadImage(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  void takeScreenShort() async {
    RenderRepaintBoundary boundary =
        ssKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List memoryImageData = bytes!.buffer.asUint8List();
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
          IconButton(
              onPressed: () {
                _cropImage();
              },
              icon: Icon(Icons.crop)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (isEditButtonClicked)
              ? editLayout(context)
              : Container(
                  height: 150,
                ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 220,
                child: ClipRRect(child: Image.file(File(widget.imagePath))),
              ),
              GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      if (isEditButtonClicked) {
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
                      }
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (isEditButtonClicked) {
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
                      }
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      if (isEditButtonClicked) {
                        points.add(null);
                      }
                    });
                  },
                  child: (isImageloaded)
                      ? Container(
                          height: 220,
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            child: CustomPaint(
                              painter:
                                  MyCustomPainter(points, backgroundImage!),
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                          color: Theme.of(context).accentColor,
                        ))),
            ],
          ),
          SizedBox(
            height: 60,
          ),
          _buildMessageComposer(),
          SizedBox(height: 40)
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

  _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea?> points;
  final ui.Image myBackground;

  MyCustomPainter(
    this.points,
    this.myBackground,
  );

  @override
  void paint(Canvas canvas, Size size) {
    //canvas.drawImage(myBackground, Offset.zero, Paint());

    Paint background = Paint()..color = Colors.transparent;
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
