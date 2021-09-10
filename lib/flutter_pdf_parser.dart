library flutter_pdf_parser;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_parser/complete_object.dart';
import 'package:flutter_pdf_parser/pagetree.dart';
import 'parse_object.dart';

/// A Calculator.
class Flutter_pdf {
  CompleteObject? completeObject;
  int totalpages = 3;
  Flutter_pdf(Uint8List bytes) {
    // ParseObject parseobj = ParseObject(bytes);
    // completeObject = CompleteObject(parseobj);
    // totalpages = completeObject!.rootTree!.getPageNumber();
  }
  int getPageContent(int i) {
    // PageTree tree = completeObject!.rootTree!;
    // PageNode leaf = tree.getPage(i);
    // Content content = leaf.content!;
    return i;
  }
}

class PDFPage extends StatelessWidget {
  PDFPage(int index) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 0.2, color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(),
      ),
    );
  }
}

class PDFBook extends StatelessWidget {
  Flutter_pdf? flutterpdf;

  PDFBook(Uint8List bytes) {
    flutterpdf = Flutter_pdf(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [for (var i = 0; i < flutterpdf!.totalpages; ++i) PDFPage(flutterpdf!.getPageContent(i))],
    ));
  }
}
