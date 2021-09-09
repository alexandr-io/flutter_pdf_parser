import 'dart:typed_data';

import 'package:flutter_pdf_parser/pdf_object.dart';

class IdObject {
  int id = 0;
  int generation = 0;
  List<Objectpdf> objContent = [];
  IdObject(String content) {
    var i = content.indexOf('\n');
    if (i == -1) {
      throw ('no newline error');
    }
    var j = getdelimiter(content);
    id = int.parse(content.substring(0, j));
    var line = content.substring(j + 1);
    j = getdelimiter(line);
    generation = int.parse(line.substring(0, j));
    i += 1;
    content = content.substring(i);
    i = 0;
    while (i < content.length) {
      var tmp;
      if (isWhiteSpace(content[i]))
        ++i;
      else {
        tmp = identifyObject(content.substring(i));
        objContent.add(createObject(tmp.item1, tmp.item3));
        i += tmp.item2 as int;
      }
    }
  }
}

class Table {
  int begin = 0;
  int end = 0;
  List<Ref> value = [];
  Table(List<String> str) {
    var tmp = str[0];
    var i = getdelimiter(tmp);
    begin = int.parse(tmp.substring(0, i));
    tmp = tmp.substring(i + 1);
    i = getdelimiter(tmp);
    end = int.parse(tmp.substring(0, i));
    str = str.sublist(1);
    for (var item in str) {
      value.add(new Ref(item));
    }
  }
}

class Ref {
  int position = 0;
  int generation = 0;
  bool isfree = false;
  Ref(String str) {
    position = int.parse(str.substring(0, 9));
    generation = int.parse(str.substring(11, 15));
    if (str[17] == 'f') isfree = true;
  }
}

class XrefObj {
  List<Table> table = [];
  Dictionnary? trailer;
  String start = '';

  bool beginSection(String str) {
    if (str[str.length - 2] != 'n' && str[str.length - 2] != 'f') return (false);
    return (true);
  }

  XrefObj(String str) {
    List<String> tab = str.split('\n');
    var end = 0;
    while (tab[end].indexOf('trailer') == -1) ++end;
    var i = 2;
    List<String> tmp = [tab[1]];
    while (i < end) {
      while (!beginSection(tab[i])) {
        tmp.add(tab[i]);
        ++i;
      }
      table.add(Table(tmp));
      tmp = [tab[i]];
      ++i;
    }
    ++i;
    String fnl = "";
    // while (i < tab.length) fnl += tab[i++];
    // trailer = createObject(fnl, 6);
    start = tab[i + 2];
  }
}

class ParseObject {
  List<IdObject> objContent = [];
  List<String> specification = [];
  List<XrefObj> xref = [];
  ParseObject(Uint8List pdfFile) {
    var content = String.fromCharCodes(pdfFile);
    var i = 0;
    while (i < content.length) {
      if (isWhiteSpace(content[i])) {
        ++i;
      } else if (content[i] == '%') {
        var end = content.indexOf('\n', i);
        if (end == -1) {
          throw ("no newline, invalid file");
        }
        specification.add(content.substring(i, end));
        i = end;
      } else if (content[i] == '\n') {
        ++i;
      } else if (content.substring(i, i + 4) == "xref") {
        while (isWhiteSpace(content[i])) ++i;
        //xref.add(new XrefObj(content.substring(i, content.indexOf('%%EOF', i))));
        i = content.indexOf('%%EOF', i) + 6;
      } else {
        var end = content.indexOf("endobj", i);
        if (end == -1) {
          throw ("no endobj");
        }
        var str = content.substring(i, end);
        objContent.add(new IdObject(str));
        i = end + 6;
      }
    }
  }
}
