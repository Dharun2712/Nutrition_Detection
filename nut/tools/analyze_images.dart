import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

double computeBrightness(Uint8List rgba, int width, int height, int stepX, int stepY) {
  double total = 0.0;
  int count = 0;
  for (int y = 0; y < height; y += stepY) {
    for (int x = 0; x < width; x += stepX) {
      final int idx = (y * width + x) * 4;
      if (idx + 2 >= rgba.length) continue;
      final int r = rgba[idx];
      final int g = rgba[idx + 1];
      final int b = rgba[idx + 2];
      total += (r + g + b) / 3.0;
      count++;
    }
  }
  return count == 0 ? 128.0 : total / count;
}

double computeSaturation(Uint8List rgba, int width, int height, int stepX, int stepY) {
  double total = 0.0;
  int count = 0;
  for (int y = 0; y < height; y += stepY) {
    for (int x = 0; x < width; x += stepX) {
      final int idx = (y * width + x) * 4;
      if (idx + 2 >= rgba.length) continue;
      final int r = rgba[idx];
      final int g = rgba[idx + 1];
      final int b = rgba[idx + 2];
      int maxRGB = r > g ? (r > b ? r : b) : (g > b ? g : b);
      int minRGB = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final double sat = maxRGB == 0 ? 0.0 : (maxRGB - minRGB) / maxRGB;
      total += sat;
      count++;
    }
  }
  return count == 0 ? 0.5 : total / count;
}

void analyzeFile(File f) {
  print('--- ${f.path} ---');
  try {
    final bytes = f.readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) {
      print('Failed to decode');
      return;
    }
    final rgba = image.getBytes(format: img.Format.rgba);
    final width = image.width;
    final height = image.height;
    final stepX = (width / 40).ceil().clamp(1, width);
    final stepY = (height / 40).ceil().clamp(1, height);
    final brightness = computeBrightness(rgba, width, height, stepX, stepY);
    final saturation = computeSaturation(rgba, width, height, stepX, stepY);
    print('w:${width} h:${height} samples:${(width/stepX).ceil()*(height/stepY).ceil()}');
    print('Brightness: ${brightness.toStringAsFixed(1)}, Saturation: ${saturation.toStringAsFixed(3)}');
  } catch (e) {
    print('Error: $e');
  }
}

void main() {
  final base = Directory.current.path;
  final healthy = Directory('healthy');
  final deficient = Directory('nutrition deficient');
  if (healthy.existsSync()) {
    for (final f in healthy.listSync()) {
      if (f is File) analyzeFile(f);
    }
  }
  if (deficient.existsSync()) {
    for (final f in deficient.listSync()) {
      if (f is File) analyzeFile(f);
    }
  }
}
