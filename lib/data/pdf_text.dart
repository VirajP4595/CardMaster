import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

class PdfPasswordNeeded implements Exception {
  const PdfPasswordNeeded();
}

/// Extracts the text of every page, on this phone (PDFium via pdfrx).
/// Only `openData` is used: pdfrx's URL loading is never called, so no
/// network access happens here. Returns pages joined by newlines.
Future<String> extractPdfText(
  Uint8List bytes, {
  Future<String?> Function()? askPassword,
}) async {
  await pdfrxFlutterInitialize();
  var asked = false;
  final PdfDocument doc;
  try {
    doc = await PdfDocument.openData(
      bytes,
      passwordProvider: askPassword == null
          ? null
          : () async {
              if (asked) return null; // one try, then give up
              asked = true;
              return askPassword();
            },
    );
  } on PdfPasswordException {
    throw const PdfPasswordNeeded();
  }
  try {
    final out = StringBuffer();
    for (final page in doc.pages) {
      final text = await page.loadText();
      if (text != null) out.writeln(text.fullText);
    }
    return out.toString();
  } finally {
    await doc.dispose();
  }
}
