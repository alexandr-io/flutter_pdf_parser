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
  const PDFPage(
    int index, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Stack(),
    );
  }
}

class PDFBook extends StatelessWidget {
  Flutter_pdf? flutterpdf;
  final String id;
  final String token;
  final Uint8List bytes;
  final String title;

  PDFBook({
    Key? key,
    required this.id,
    required this.token,
    required this.bytes,
    required this.title,
  }) : super(key: key) {
    flutterpdf = Flutter_pdf(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 128.0 * 4.0),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0) + MediaQuery.of(context).viewPadding,
            children: [
              const SizedBox(height: 16.0),
              for (var i = 0; i < flutterpdf!.totalpages; ++i) ...[
                AspectRatio(
                  // aspectRatio: (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ? 4 / 3 : 1 / 2,
                  aspectRatio: 1 / 1.4142,
                  child: PDFPage(
                    flutterpdf!.getPageContent(i),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
