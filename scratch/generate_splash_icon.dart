import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/logo.png');
  if (!file.existsSync()) {
    print('assets/logo.png not found!');
    return;
  }

  final bytes = file.readAsBytesSync();
  final srcImage = img.decodePng(bytes);
  if (srcImage == null) {
    print('Failed to decode logo.png');
    return;
  }

  print('Source logo.png: ${srcImage.width}x${srcImage.height}');

  // 1. Create Light Logo Variant
  final lightLogo = img.Image(width: srcImage.width, height: srcImage.height, numChannels: 4);

  for (int y = 0; y < srcImage.height; y++) {
    for (int x = 0; x < srcImage.width; x++) {
      final pixel = srcImage.getPixel(x, y);
      final a = pixel.a;
      if (a < 10) {
        lightLogo.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();
      final alpha = pixel.a.toInt();

      final maxChannel = [r, g, b].reduce((v, e) => v > e ? v : e);
      final isDark = maxChannel < 90 && (r - g).abs() < 30 && (g - b).abs() < 30;

      if (isDark) {
        lightLogo.setPixelRgba(x, y, 255, 255, 255, alpha);
      } else {
        final newR = (r * 1.20).clamp(0, 255).toInt();
        final newG = (g * 1.20).clamp(0, 255).toInt();
        final newB = (b * 1.20).clamp(0, 255).toInt();
        final newAlpha = alpha < 128 ? alpha * 2 : 255;
        lightLogo.setPixelRgba(x, y, newR, newG, newB, newAlpha.clamp(0, 255));
      }
    }
  }

  // Save light logo for Flutter assets
  File('assets/logo_light.png').writeAsBytesSync(img.encodePng(lightLogo));
  print('Saved assets/logo_light.png');

  // 2. Create 512x512 Square Canvas for Android 12+ Splash Screen API (288dp canvas)
  // Inner artwork must fit inside 192dp circle (central 66% = ~338px diameter)
  const canvasSize = 512;
  const targetWidth = 340;
  final targetHeight = (targetWidth * (srcImage.height / srcImage.width)).round();

  final resizedLogo = img.copyResize(
    lightLogo,
    width: targetWidth,
    height: targetHeight,
    interpolation: img.Interpolation.linear,
  );

  final splashIconCanvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  // Fill background transparently
  for (int y = 0; y < canvasSize; y++) {
    for (int x = 0; x < canvasSize; x++) {
      splashIconCanvas.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  // Composite logo into center of 512x512 canvas
  final offsetX = (canvasSize - targetWidth) ~/ 2;
  final offsetY = (canvasSize - targetHeight) ~/ 2;

  img.compositeImage(
    splashIconCanvas,
    resizedLogo,
    dstX: offsetX,
    dstY: offsetY,
  );

  final splashIconPng = img.encodePng(splashIconCanvas);

  // Write splash icon to drawables
  File('android/app/src/main/res/drawable/splash_icon_288dp.png').writeAsBytesSync(splashIconPng);
  File('android/app/src/main/res/drawable-v21/splash_icon_288dp.png').writeAsBytesSync(splashIconPng);

  print('Successfully generated splash_icon_288dp.png (512x512 square transparent canvas)!');
}
