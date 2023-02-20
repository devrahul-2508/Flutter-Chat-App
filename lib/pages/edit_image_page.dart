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
import 'package:path_provider/path_provider.dart';

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
  bool isEditButtonClicked = false;

  List<DrawingArea?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;
  File? loadedImage;
  CroppedFile? croppedImage;

  static GlobalKey ssKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getImage();
  }

  getImage() {
    loadedImage = File(widget.imagePath);
    setState(() {
      isImageloaded = true;
    });
  }

  // convertImage() async {
  //   File file = File(widget.imagePath);
  //   Uint8List bytes = await file.readAsBytes();
  //   backgroundImage = await loadImage(bytes);
  // }

  // Future<ui.Image> loadImage(Uint8List bytes) async {
  //   final Completer<ui.Image> completer = Completer();
  //   ui.decodeImageFromList(bytes, (ui.Image img) {
  //     setState(() {
  //       isImageloaded = true;
  //     });
  //     return completer.complete(img);
  //   });
  //   return completer.future;
  // }

  Future takeScreenShort() async {
    RenderRepaintBoundary boundary =
        ssKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List memoryImageData = bytes!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    loadedImage = await File('${tempDir.path}/image.png').create();
    loadedImage!.writeAsBytesSync(memoryImageData);
  }

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
      
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 60,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: (isImageloaded)
                        ? RepaintBoundary(
                            key: ssKey,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: (croppedImage != null)
                                      ? Image.file(
                                          File(croppedImage!.path),
                                          fit: BoxFit.fill,
                                          width:
                                              MediaQuery.of(context).size.width,
                                        )
                                      : Image.file(
                                          File(loadedImage!.path),
                                          fit: BoxFit.fill,
                                          width:
                                              MediaQuery.of(context).size.width,
                                        ),
                                ),
                                Positioned(
                                  left: 0.0,
                                  right: 0.0,
                                  bottom: 0.0,
                                  top: 0.0,
                                  child: GestureDetector(
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
                                    child: ClipRRect(
                                      child: CustomPaint(
                                        painter: MyCustomPainter(points),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(
                            color: Theme.of(context).accentColor,
                          )),
                  ),
                ),
                Positioned(bottom: 10.0, child: _buildMessageComposer()),
              ],
            ),
          ),

          //SizedBox(height: 0)
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
    await takeScreenShort();
    croppedImage = await ImageCropper().cropImage(
      sourcePath: loadedImage!.path,
      //  (croppedImage == null) ? widget.imagePath : croppedImage!.path,
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

    setState(() {});
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea?> points;

  MyCustomPainter(
    this.points,
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
