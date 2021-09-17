import 'package:flutter_pdf_parser/pagetree.dart';
import 'package:flutter_pdf_parser/parse_object.dart';
import 'package:flutter_pdf_parser/pdf_object.dart';

class Catalog {
  String language = "";
  int pageRoot = 0;
  int metadata = 0;
  Catalog(IdObject obj) {
    Dictionnary value = obj.objContent[0] as Dictionnary;
    value.content.forEach((key, value) {
      switch (key) {
        case 'Type':
          break;
        case 'Pages':
          Linkpdf link = value as Linkpdf;
          pageRoot = link.nbr;
          break;
        case 'Lang':
          Stringpdf str = value as Stringpdf;
          language = str.originalstring;
          break;
        default:
      }
    });
  }
}

class MetaDataPdf {
  MetaDataPdf(IdObject obj) {}
}

class CompleteObject {
  Catalog? catalog;
  MetaDataPdf? metadata;
  PageTree? rootTree;
  CompleteObject(ParseObject src) {
    var i = 0;
    while (!isCatalog(src.objContent[i])) ++i;
    catalog = new Catalog(src.objContent[i]);
    rootTree = new PageTree(objectFromId(catalog!.pageRoot, src.objContent), src);
    //metadata = new MetaDataPdf(objectFromId(catalog!.metadata, src.objContent));
    rootTree!.fillTree(src);
  }

  bool isCatalog(IdObject objContent) {
    if (objContent.objContent.isEmpty) return (false);
    if (objContent.objContent[0].type != 6) {
      return false;
    }
    Dictionnary value = objContent.objContent[0] as Dictionnary;
    Namepdf obj = value.content['Type'] as Namepdf;
    if (obj != null && obj.value == 'Catalog') {
      return true;
    }
    return false;
  }
}
