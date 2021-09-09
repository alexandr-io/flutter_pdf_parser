import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pdf_parser/flutter_pdf_parser.dart';

void main() {
  test('adds one to input values', () {
    final flutterpdf = flutter_pdf('test.pdf');
    for (var i = 0; i < flutterpdf.totalpages; ++i) flutterpdf.getPageContent(i);
  });
}
