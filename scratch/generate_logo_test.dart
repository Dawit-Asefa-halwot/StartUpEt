import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Generate logo_light.png', (WidgetTester tester) async {
    final file = File('assets/logo.png');
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final width = image.width.toDouble();
    final height = image.height.toDouble();

    // Draw background logo
    canvas.drawImage(image, Offset.zero, Paint());

    // ColorFilter: invert dark text to white while preserving colors
    final paintInvertDark = Paint()
      ..colorFilter = const ColorFilter.matrix(<double>[
        -1.0,  0.0,  0.0, 0.0, 255.0,
         0.0, -1.0,  0.0, 0.0, 255.0,
         0.0,  0.0, -1.0, 0.0, 255.0,
         0.0,  0.0,  0.0, 1.0,   0.0,
      ]);

    // Save as picture
    final picture = recorder.endRecording();
    final lightImage = await picture.toImage(image.width, image.height);
    final pngBytes = await lightImage.toByteData(format: ui.ImageByteFormat.png);

    final outputFile = File('assets/logo_light.png');
    await outputFile.writeAsBytes(pngBytes!.buffer.asUint8List());
    print('Successfully generated logo_light.png');
  });
}
