library flutter_pdf_parser;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_parser/complete_object.dart';
import 'package:flutter_pdf_parser/pagetree.dart';
import 'parse_object.dart';

/// A Calculator.
class flutter_pdf {
  String path;
  CompleteObject? completeObject;
  int totalpages = 0;
  flutter_pdf(this.path) {
    File tmp = new File(path);
    ParseObject parseobj = new ParseObject(tmp.readAsBytesSync());
    completeObject = new CompleteObject(parseobj);
    totalpages = completeObject!.rootTree!.getPageNumber();
  }
  getPageContent(int i) {
    PageTree tree = completeObject!.rootTree!;
    PageNode leaf = tree.getPage(i);
    Content content = leaf.content!;
  }
}
