import 'dart:io';
import 'dart:typed_data';

import 'package:card_master/data/photo_face.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// A fake "card photo": sharp black/white stripes, so blurring is easy to
/// detect (blurred pixels turn grey).
Uint8List _stripes(int w, int h) {
  final im = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final on = (x ~/ 4).isEven;
      im.setPixelRgb(x, y, on ? 255 : 0, on ? 255 : 0, on ? 255 : 0);
    }
  }
  return Uint8List.fromList(img.encodePng(im));
}

/// Average distance from mid-grey: high for sharp stripes, low when blurred.
double _contrast(img.Image im, int x0, int y0, int w, int h) {
  var sum = 0.0;
  for (var y = y0; y < y0 + h; y++) {
    for (var x = x0; x < x0 + w; x++) {
      sum += (im.getPixel(x, y).r - 128).abs();
    }
  }
  return sum / (w * h);
}

void main() {
  test('crops to card size and burns the blur into the number area', () {
    final out = img.decodeJpg(
        prepareCardPhoto(_stripes(2000, 1500), [BlurBox.numberDefault]))!;
    expect(out.width, faceWidth);
    expect(out.height, faceHeight);

    final inside = _contrast(out, 200, 360, 500, 60); // within the box
    final outside = _contrast(out, 200, 60, 500, 60); // top of the card
    expect(outside, greaterThan(90)); // stripes still sharp
    expect(inside, lessThan(30)); // number area unreadable
  });

  test('stored photos are encrypted and round-trip', () async {
    final dir = await Directory.systemTemp.createTemp('cm_faces');
    final key = PhotoStore.newKey();
    final store = PhotoStore(dir: dir, key: () async => key);
    final jpeg = prepareCardPhoto(_stripes(800, 600), const []);

    await store.save('c1', jpeg);
    final onDisk = await File('${dir.path}/face_c1.bin').readAsBytes();
    expect(onDisk.sublist(12, 15), isNot([0xFF, 0xD8, 0xFF])); // not a JPEG
    expect(await store.load('c1'), jpeg);

    final wrongKey = PhotoStore(dir: dir, key: () async => PhotoStore.newKey());
    expect(wrongKey.load('c1'), throwsA(anything));

    await store.delete('c1');
    expect(await store.load('c1'), isNull);
    await dir.delete(recursive: true);
  });
}
