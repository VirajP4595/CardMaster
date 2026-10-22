import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:image/image.dart' as img;

/// A region to hide, as fractions of the card image (0..1).
class BlurBox {
  const BlurBox(this.left, this.top, this.width, this.height);
  final double left;
  final double top;
  final double width;
  final double height;

  /// Where the number usually sits on a landscape card.
  static const numberDefault = BlurBox(0.06, 0.52, 0.88, 0.16);
}

const faceWidth = 1012;
const faceHeight = 638; // ISO ID-1 ratio 1.586

/// Crops a photo to card proportions, downsizes it and permanently hides
/// [boxes] (pixelate + blur burned into the pixels). The full-quality
/// original never leaves memory (docs/02-DESIGN.md §7).
Uint8List prepareCardPhoto(Uint8List photo, List<BlurBox> boxes) {
  final decoded = img.decodeImage(photo);
  if (decoded == null) throw const FormatException('Not an image');
  var image = img.bakeOrientation(decoded);

  // Centre-crop to the card ratio, then resize.
  const ratio = faceWidth / faceHeight;
  var w = image.width;
  var h = (w / ratio).round();
  if (h > image.height) {
    h = image.height;
    w = (h * ratio).round();
  }
  image = img.copyCrop(image,
      x: (image.width - w) ~/ 2, y: (image.height - h) ~/ 2, width: w, height: h);
  image = img.copyResize(image,
      width: faceWidth, height: faceHeight, interpolation: img.Interpolation.average);

  for (final b in boxes) {
    final x = (b.left * faceWidth).round().clamp(0, faceWidth - 1);
    final y = (b.top * faceHeight).round().clamp(0, faceHeight - 1);
    final bw = (b.width * faceWidth).round().clamp(1, faceWidth - x);
    final bh = (b.height * faceHeight).round().clamp(1, faceHeight - y);
    var region = img.copyCrop(image, x: x, y: y, width: bw, height: bh);
    region = img.pixelate(region, size: 28, mode: img.PixelateMode.average);
    region = img.gaussianBlur(region, radius: 14);
    img.compositeImage(image, region, dstX: x, dstY: y);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}

/// Card photos are stored encrypted (AES-GCM) in the app's private folder.
class PhotoStore {
  PhotoStore({required this.dir, required this.key});

  final Directory dir;
  final Future<List<int>> Function() key;

  File _file(String cardId) => File('${dir.path}/face_$cardId.bin');

  Future<void> save(String cardId, List<int> jpeg) async {
    final box = await AesGcm.with256bits()
        .encrypt(jpeg, secretKey: SecretKey(await key()));
    await dir.create(recursive: true);
    await _file(cardId)
        .writeAsBytes(box.concatenation(), flush: true);
  }

  Future<Uint8List?> load(String cardId) async {
    final f = _file(cardId);
    if (!await f.exists()) return null;
    final box = SecretBox.fromConcatenation(await f.readAsBytes(),
        nonceLength: 12, macLength: 16);
    final plain =
        await AesGcm.with256bits().decrypt(box, secretKey: SecretKey(await key()));
    return Uint8List.fromList(plain);
  }

  Future<void> delete(String cardId) async {
    final f = _file(cardId);
    if (await f.exists()) await f.delete();
  }

  static List<int> newKey() {
    final r = Random.secure();
    return List.generate(32, (_) => r.nextInt(256));
  }
}
