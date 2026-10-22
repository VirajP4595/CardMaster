import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:card_master/domain/statement_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx_engine/pdfrx_engine.dart';

/// Builds a tiny one-page PDF with the given text lines (Helvetica).
Uint8List _pdf(List<String> lines) {
  final content = StringBuffer('BT /F1 10 Tf 14 TL 40 780 Td\n');
  for (final l in lines) {
    final esc = l.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
    content.write('($esc) Tj T*\n');
  }
  content.write('ET');
  final objs = [
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>',
    '<< /Length ${content.length} >>\nstream\n$content\nendstream',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
  ];
  final out = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[];
  for (var i = 0; i < objs.length; i++) {
    offsets.add(latin1.encode(out.toString()).length);
    out.write('${i + 1} 0 obj\n${objs[i]}\nendobj\n');
  }
  final xref = latin1.encode(out.toString()).length;
  out.write('xref\n0 ${objs.length + 1}\n0000000000 65535 f \n');
  for (final o in offsets) {
    out.write('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  out.write('trailer\n<< /Size ${objs.length + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF');
  return Uint8List.fromList(latin1.encode(out.toString()));
}

void main() {
  // PDFium isn't part of the Flutter test host. CI downloads it and sets
  // PDFIUM_PATH (see .github/workflows/android.yml); without it this test is
  // reported as skipped, not passed.
  final pdfium = Platform.environment['PDFIUM_PATH'];
  test('text extracted from a statement PDF parses into spends', () async {
    Pdfrx.pdfiumModulePath = pdfium;
    await pdfrxInitialize();
    final bytes = _pdf([
      'Card Number: XXXX XXXX XXXX 7302',
      '21/10/2026 BESCOM BANGALORE 2,400.00',
      '25/10/2026 PAYMENT RECEIVED - THANK YOU 18,240.00 Cr',
      '28/10/2026 ZOMATO 512.00',
    ]);
    final doc = await PdfDocument.openData(bytes);
    final text = StringBuffer();
    for (final p in doc.pages) {
      text.writeln((await p.loadText())?.fullText ?? '');
    }
    await doc.dispose();

    final r = parseStatementText(text.toString());
    expect(r.last4, '7302');
    expect(r.spends.map((s) => s.amountPaise), [240000, 51200]);
    expect(r.creditsSkipped, 1);
  },
      timeout: const Timeout(Duration(minutes: 3)),
      skip: pdfium == null ? 'Set PDFIUM_PATH to libpdfium to run' : null);
}
