import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'package:permission_handler/permission_handler.dart';

void main() => runApp(DrawScreen());

class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final _points = List<Offset>();
  GlobalKey _containerKey = GlobalKey();
  int strokeNum = 3;

  @override
  void initState() {
    super.initState();

    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ocr Hiragana'),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        //drawing pad title
                        Text(
                          'Write the hiragana',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        //drawing pad sub-title
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam placerat eu leo ut varius. Aenean vitae vestibulum magna. Morbi tempus vel eros a aliquet. ',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 350.0,
              height: 350.0,
              margin: EdgeInsets.all(15),
              child: RepaintBoundary(
                key: _containerKey,
                child: Container(
                  width: 350 * 0.9,
                  height: 350.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: GestureDetector(
                    onPanStart: (DragStartDetails details) {
                      Offset _localPosition = details.localPosition;
                      if (_localPosition.dx >= 6 &&
                          _localPosition.dx <= 315 &&
                          _localPosition.dy >= 6 &&
                          _localPosition.dy <= 335) {
                        addPoint(_localPosition);
                      }
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      Offset _localPosition = details.localPosition;
                      if (_localPosition.dx >= 6 &&
                          _localPosition.dx <= 315 &&
                          _localPosition.dy >= 6 &&
                          _localPosition.dy <= 335) {
                        addPoint(_localPosition);
                      }
                    },
                    onPanEnd: (DragEndDetails details) {
                      addPoint(null);
                    },
                    child: CustomPaint(
                      painter: DrawingPainter(_points),
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: Colors.grey.shade700,
                    width: 5.0,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: _clear,
                  child: Text('clear'),
                ),
                Container(
                  width: 50,
                ),
                RaisedButton(
                  onPressed: _addImg,
                  child: Text('Add Image'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  Future<void> _addImg() async {
    RenderRepaintBoundary boundary =
        _containerKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 1);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    var imageBytes = byteData.buffer;

    img.Image oriImage = img.decodePng(imageBytes.asUint8List());
    img.Image resizedImage = img.copyResize(oriImage, height: 224, width: 224);
    Uint8List resizedImageBytes = img.encodePng(resizedImage) as Uint8List;

    // resizedImage.getBytes();
    final result = await ImageGallerySaver.saveImage(resizedImageBytes);
    print(result);
  }

  void addPoint(Offset p) {
    setState(() {
      _points.add(p);
    });
  }

  void _clear() {
    setState(() {
      _points.clear();
    });
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  final Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.black
    ..strokeWidth = 10;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], _paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
