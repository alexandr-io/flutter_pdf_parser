import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_pdf_parser/parse_object.dart';
import 'package:flutter_pdf_parser/parsing_content.dart';
import 'package:flutter_pdf_parser/pdf_object.dart';

IdObject objectFromId(int id, List<IdObject> list) {
  var i = 0;
  while (i < list.length && list[i].id != id) {
    ++i;
  }
  if (i >= list.length) return throw ("not a valid link");
  return (list[i]);
}

class Font {
  String name;
  Font(this.name, Dictionnary src) {}
}

class Gstate {
  String name;
  Gstate(this.name, Dictionnary src) {}
}

class Ressource {
  List<Font> font = [];
  List<Gstate> gstate = [];
  List<PatternPdf> pattern = [];
  List<Shading> shading = [];
  List<XObject> xobj = [];
  ProcSet? proc;
  int i = 0;
  Ressource.empty() {}
  Ressource(Dictionnary src, ParseObject parse) {
    src.content.forEach((key, value) {
      switch (key) {
        case 'Font':
          (value as Dictionnary).content.forEach((key, value) {
            font.add(new Font(key, objectFromId((value as Linkpdf).nbr, parse.objContent).objContent[0] as Dictionnary));
          });
          break;
        case 'ExtGState':
          (value as Dictionnary).content.forEach((key, value) {
            gstate.add(new Gstate(key, objectFromId((value as Linkpdf).nbr, parse.objContent).objContent[0] as Dictionnary));
          });
          break;
        case 'Pattern':
          (value as Dictionnary).content.forEach((key, value) {
            pattern.add(new PatternPdf(key, objectFromId((value as Linkpdf).nbr, parse.objContent).objContent[0]));
          });
          break;
        case 'Shading':
          (value as Dictionnary).content.forEach((key, value) {
            shading.add(new Shading(key, objectFromId((value as Linkpdf).nbr, parse.objContent).objContent[0]));
          });
          break;
        case 'XObject':
          (value as Dictionnary).content.forEach((key, value) {
            xobj.add(new XObject(key, objectFromId((value as Linkpdf).nbr, parse.objContent)));
          });
          break;
        case 'ProcSet':
          proc = new ProcSet(value as Arraypdf);
          break;
        default:
          break;
      }
    });
  }
}

class ProcSet {
  Arraypdf value;
  ProcSet(this.value);
}

class XObject {
  String id;
  Dictionnary? spec;
  Image? tmp;
  List<int> content = [];
  ParsingContent? rec;
  double width = 0;
  double height = 0;
  XObject(this.id, IdObject objContent) {
    spec = objContent.objContent[0] as Dictionnary?;
    for (var rune in (objContent.objContent[1] as Stream).content.runes) {
      content.add(rune);
    }
    spec!.content.forEach((key, value) {
      switch (key) {
        case 'Width':
          width = (value as Numeric).nbr;
          break;
        case 'Height':
          height = (value as Numeric).nbr;
          break;
        default:
      }
    });
    if ((spec!.content['Filter'] as Namepdf).value == 'DCTDecode') {
      tmp = Image.memory(Uint8List.fromList(content), width: width, height: height);
    } else if ((spec!.content['Filter'] as Namepdf).value == 'FlateDecode') {
      var stream = String.fromCharCodes(zlib.decode(content));
      rec = ParsingContent(splitIt(stream), Ressource.empty());
    }
  }
}

class Shading {
  Shading(String key, Objectpdf value);
}

class PatternPdf {
  String id;
  Objectpdf value;
  PatternPdf(this.id, this.value);
}

class Content {
  String filter = "";
  String stream = "";
  String convertedStream = "";
  double length = 0;
  ParsingContent? content;

  Content(IdObject src, Ressource ressource, ParseObject parse) {
    Dictionnary dic = src.objContent[0] as Dictionnary;
    stream = (src.objContent[1] as Stream).content;
    dic.content.forEach((key, value) {
      switch (key) {
        case 'Filter':
          filter = (value as Namepdf).value;
          break;
        case 'Length':
          length = (value as Numeric).nbr;
      }
    });
    chooseFilter(ressource);
  }
  chooseFilter(Ressource ressource) {
    switch (filter) {
      case 'FlateDecode':
        List<int> tmp = [];
        stream.runes.forEach((int rune) {
          tmp.add(rune);
        });
        var value = zlib.decode(tmp);
        convertedStream = String.fromCharCodes(value);
        break;
      default:
    }
    content = ParsingContent(splitIt(convertedStream), ressource);
  }
}

List<String> splitIt(String src) {
  var i = 0;
  String tmp = "";
  List<String> dest = [];
  while (i < src.length) {
    if (isWhiteSpace(src[i]))
      ++i;
    else if (src[i] == '<') {
      int count = 1;
      tmp = '<';
      ++i;
      while (count != 0) {
        tmp += src[i];
        if (src[i] == '<') ++count;
        if (src[i] == '>') --count;
        ++i;
      }
      dest.add(tmp);
      tmp = "";
    } else if (src[i] == '(') {
      int count = 1;
      tmp = '(';
      ++i;
      while (count != 0) {
        if (src[i] == '\\') {
          tmp += src[i + 1];
          i += 2;
        } else {
          tmp += src[i];
          if (src[i] == '(') ++count;
          if (src[i] == ')') --count;
          ++i;
        }
      }
      dest.add(tmp);
      tmp = "";
    } else if (src[i] == '[') {
      int count = 1;
      tmp = '[';
      ++i;
      while (count != 0) {
        if (src[i] == '\\') {
          tmp += src[i + 1];
          i += 2;
        } else {
          tmp += src[i];
          if (src[i] == '[') ++count;
          if (src[i] == ']') --count;
          ++i;
        }
      }
      dest.add(tmp);
      tmp = "";
    } else {
      while (!isWhiteSpace(src[i]) && src[i] != '[' && src[i] != '<' && src[i] != '(') {
        if (src[i] == '\\') {
          tmp += src[i + 1];
          i += 2;
        } else {
          tmp += src[i++];
        }
      }
      dest.add(tmp);
      tmp = "";
    }
  }
  return (dest);
}

class PageNode {
  Ressource? ressource;
  Content? content;
  PageNode(IdObject obj, ParseObject parse) {
    Dictionnary dic = obj.objContent[0] as Dictionnary;
    var tmp;
    dic.content.forEach((key, value) {
      switch (key) {
        case 'Type':
          break;
        case 'Resources':
          ressource = Ressource(value as Dictionnary, parse);
          break;
        case 'Contents':
          tmp = objectFromId((value as Linkpdf).nbr, parse.objContent);
          break;
      }
    });
    content = Content(tmp, ressource!, parse);
  }
}

class PageTree {
  int nbr = 0;
  List<PageTree> child = [];
  List<PageNode> leaf = [];
  List<bool> ispage = [];
  List<int> childId = [];
  PageTree(IdObject obj, ParseObject parse) {
    Dictionnary dic = obj.objContent[0] as Dictionnary;
    dic.content.forEach((key, value) {
      switch (key) {
        case 'Type':
          break;
        case 'Count':
          nbr = (value as Numeric).type;
          break;
        case 'Kids':
          for (var item in (value as Arraypdf).array) {
            childId.add((item as Linkpdf).nbr);
          }
          break;
        default:
      }
    });
  }
  void addNode(IdObject obj, ParseObject parse) {
    Dictionnary value = obj.objContent[0] as Dictionnary;
    Namepdf type = value.content['Type'] as Namepdf;
    if (type.value == 'Pages') {
      child.add(PageTree(obj, parse));
      ispage.add(false);
    } else if (type.value == 'Page') {
      leaf.add(PageNode(obj, parse));
      ispage.add(true);
    } else
      throw ('incorect page tree');
  }

  void fillTree(ParseObject parse) {
    var itree = 0;
    for (var i = 0; i < childId.length; ++i) {
      addNode(objectFromId(childId[i], parse.objContent), parse);
      if (ispage[ispage.length - 1] == false) {
        child[itree].fillTree(parse);
        ++itree;
      }
    }
  }

  int getPageNumber() {
    int i = 0;
    int childi = 0;
    for (var j in ispage) {
      if (j == true) {
        ++i;
      } else {
        i += child[childi].getPageNumber();
        childi++;
      }
    }
    return (i);
  }

  PageNode getPage(int i) {
    int leafi = 0;
    int childi = 0;
    for (var j in ispage) {
      if (i == 0 && j == true) {
        return leaf[leafi];
      } else if (j == true) {
        i--;
        leafi++;
      } else {
        var tmp = child[childi].getPageNumber();
        if (tmp > i) {
          return getPage(i);
        } else {
          childi++;
          i -= tmp;
        }
      }
    }
    return (leaf[leafi]);
  }
}
