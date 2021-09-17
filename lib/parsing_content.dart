import 'package:flutter/cupertino.dart';
import 'package:flutter_pdf_parser/pagetree.dart';
import 'package:flutter_pdf_parser/parse_object.dart';
import 'package:flutter_pdf_parser/pdf_object.dart';

const List<String> textStateList = ['Tc', 'Tw', 'Tz', 'TL', 'Tf', 'Tr', 'Ts'];

const Map<String, int> cmdList = {
  'BX': 0,
  'EX': 0,
  'MP': 1,
  'DP': 1,
  'BMC': 1,
  'BDC': 1,
  'EMC': 1,
  'Do': 2,
  'BI': 3,
  'ID': 3,
  'EI': 3,
  'sh': 4,
  'CS': 5,
  'cs': 5,
  'SCN': 5,
  'scn': 5,
  'SC': 5,
  'sc': 5,
  'G': 5,
  'g': 5,
  'RG': 5,
  'rg': 5,
  'K': 5,
  'k': 5,
  'd0': 6,
  'd1': 6,
  'Tj': 7,
  'TJ': 7,
  '\'': 7,
  '"': 7,
  'Td': 8,
  'TD': 8,
  'Tm': 8,
  'T*': 8,
  'Tc': 9,
  'Tw': 9,
  'Tz': 9,
  'TL': 9,
  'Tf': 9,
  'Tr': 9,
  'Ts': 9,
  'BT': 10,
  'ET': 10,
  'W*': 11,
  'W': 11,
  'S': 12,
  's': 12,
  'f*': 12,
  'f': 12,
  'F': 12,
  'B*': 12,
  'B': 12,
  'b*': 12,
  'b': 12,
  'n': 12,
  'm': 13,
  'l': 13,
  'c': 13,
  'v': 13,
  'y': 13,
  'h': 13,
  're': 13,
  'q': 14,
  'Q': 14,
  'cm': 14,
  'w': 15,
  'J': 15,
  'j': 15,
  'M': 15,
  'd': 15,
  'ri': 15,
  'i': 15,
  'gs': 15,
};

class FontContent {
  String fontid = "";
  int size = 0;
  FontContent(List<String> line) {}
}

class TextContent {
  Ressource dictionnary;
  List<int> textMatrix = [0, 0, 0, 0, 0, 0, 0, 0, 1];
  List<int> textLineMatrix = [0, 0, 0, 0, 0, 0, 0, 0, 1];
  List<int> textRenderMatrix = [0, 0, 0, 0, 0, 0, 0, 0, 1];
  List<String> stringLine = [];
  List<MarkContent> markNode = [];
  String font = "";
  int sizeFont = 0;

  TextContent(List<String> line, this.dictionnary) {

    var i = 0;
    List<String> cmd = [];
    while (i < line.length) {
      if (cmdList.containsKey(line[i])) {
        switch (line[i]) {
          case 'Tf':
            font = cmd[0];
            sizeFont = int.parse(cmd[1]);
            break;
          /*case 'Tm':
            textMatrix[0] = int.parse(cmd[0]);
            textMatrix[1] = int.parse(cmd[1]);
            textMatrix[3] = int.parse(cmd[2]);
            textMatrix[4] = int.parse(cmd[3]);
            textMatrix[6] = int.parse(cmd[4]);
            textMatrix[7] = int.parse(cmd[5]);
            textLineMatrix[0] = int.parse(cmd[0]);
            textLineMatrix[1] = int.parse(cmd[1]);
            textLineMatrix[3] = int.parse(cmd[2]);
            textLineMatrix[4] = int.parse(cmd[3]);
            textLineMatrix[6] = int.parse(cmd[4]);
            textLineMatrix[7] = int.parse(cmd[5]);
            break;
          case 'Td':
            List<int> tmp = [1, 0, 0, 0, 1, 0, int.parse(cmd[0]), int.parse(cmd[1]), 1];
            textMatrix[0] = tmp[0] * textLineMatrix[0] + tmp[1] * textLineMatrix[3] + tmp[2] * textLineMatrix[6];
            textMatrix[1] = tmp[0] * textLineMatrix[1] + tmp[1] * textLineMatrix[4] + tmp[2] * textLineMatrix[7];
            textMatrix[2] = tmp[0] * textLineMatrix[2] + tmp[1] * textLineMatrix[5] + tmp[2] * textLineMatrix[8];
            textMatrix[3] = tmp[3] * textLineMatrix[0] + tmp[4] * textLineMatrix[3] + tmp[5] * textLineMatrix[6];
            textMatrix[4] = tmp[3] * textLineMatrix[1] + tmp[4] * textLineMatrix[4] + tmp[5] * textLineMatrix[7];
            textMatrix[5] = tmp[3] * textLineMatrix[2] + tmp[4] * textLineMatrix[5] + tmp[5] * textLineMatrix[8];
            textMatrix[6] = tmp[6] * textLineMatrix[0] + tmp[7] * textLineMatrix[3] + tmp[8] * textLineMatrix[6];
            textMatrix[7] = tmp[6] * textLineMatrix[1] + tmp[7] * textLineMatrix[4] + tmp[8] * textLineMatrix[7];
            textMatrix[8] = tmp[6] * textLineMatrix[2] + tmp[7] * textLineMatrix[5] + tmp[8] * textLineMatrix[8];
            textLineMatrix[0] = textMatrix[0];
            textLineMatrix[1] = textMatrix[1];
            textLineMatrix[2] = textMatrix[2];
            textLineMatrix[3] = textMatrix[3];
            textLineMatrix[4] = textMatrix[4];
            textLineMatrix[5] = textMatrix[5];
            textLineMatrix[6] = textMatrix[6];
            textLineMatrix[7] = textMatrix[7];
            textLineMatrix[8] = textMatrix[8];
            break;*/
          case 'TD':
            break;
          case 'TJ':
            stringLine.add(parseString(splitIt(cmd[0].substring(1, cmd[0].length - 1))));
            break;
          case 'Tj':
            stringLine.add(parseString(splitIt(cmd[0].substring(1, cmd[0].length - 1))));
            break;
          case 'RG':
            break;
          case 'rg':
            break;
          case 'BMC':
            var copy = cmd;
            cmd = [];
            while (line[i] != 'EMC') {
              cmd.add(line[i++]);
            }
            markNode.add(MarkContent.BMC(copy, cmd, this.dictionnary));
            break;
          case 'BDC':
            var copy = cmd;
            cmd = [];
            while (line[i] != 'EMC') {
              cmd.add(line[i++]);
            }
            markNode.add(MarkContent.BDC(copy, cmd, this.dictionnary));
            break;
          default:
        }
        cmd = [];
      } else {
        cmd.add(line[i]);
      }
      ++i;
    }
  }
}

String parseString(List<String> cmd) {
  String dest = "";
  for (var i in cmd) {
    if (i[0] == '(') {
      dest += i.substring(1, i.length - 1);
    }
    if (i[0] == '<') {
      for (var value = 1; value < i.length - 1; value += 2) {
        //dest += String.fromCharCode(int.parse((i[value] + i[value + 1]), radix: 16));
      }
    }
  }
  return (dest);
}

class Position {
  Position(List<String> line) {}
}

class ParsingContent {
  Ressource dictionnary;
  List<bool> isMark = [];
  List<MarkContent> markNode = [];
  List<TextContent> textNode = [];
  List<Shape> shapeNode = [];
  List<PathObject> pathNode = [];
  GraphicState gstate = GraphicState();
  TextState tstate = TextState();
  ParsingContent(List<String> src, this.dictionnary) {
    var i = 0;
    List<String> cmd = [];
    while (i < src.length) {
      if (cmdList.containsKey(src[i])) {
        switch (src[i]) {
          case 'cm':
            gstate.setmatrix(cmd);
            break;
          case 'q':
            gstate.savestate();
            break;
          case 'Q':
            gstate.popstate();
            break;
          case 're':
            while (cmdList.containsKey(src[i]) && cmdList[src[i]] != 12) {
              cmd.add(src[i++]);
            }
            cmd.add(src[i]);
            pathNode.add(PathObject(cmd));
            break;
          case 'RG':
            break;
          case 'rg':
            break;
          case 'gs':
            //           gstate.setgraphicstate(getgstate(cmd[0]));
            break;
          case 'BMC':
            var copy = cmd;
            cmd = [];
            while (src[i] != 'EMC') {
              cmd.add(src[i++]);
            }
            markNode.add(MarkContent.BMC(copy, cmd, dictionnary));
            isMark.add(true);
            break;
          case 'BDC':
            var copy = cmd;
            cmd = [];
            while (src[i] != 'EMC') {
              cmd.add(src[i++]);
            }
            markNode.add(MarkContent.BDC(copy, cmd, dictionnary));
            isMark.add(true);
            break;
          default:
        }
        if (cmdList[src[i]] == 9) {
          //tstate.setvalue(int.parse(cmd[0]), textStateList.indexOf(src[i]));
        }
        if (src[i] == 'BT') {
          i += 1;
          while (src[i] != 'ET') {
            cmd.add(src[i++]);
          }
          textNode.add(TextContent(cmd, dictionnary));
          isMark.add(false);
        }
        cmd = [];
      } else {
        cmd.add(src[i]);
      }
      ++i;
    }
  }
}

class MarkContent {
  Ressource dictionnary;
  Namepdf? name;
  Dictionnary? properties;
  List<TextContent> textNode = [];
  bool isImage = false;
  Widget image = Text('tmp');

  MarkContent.BMC(List<String> tag, List<String> cmd, this.dictionnary) {
    name = Namepdf(tag[0]);
    createcontent(cmd);
  }

  MarkContent.BDC(List<String> copy, List<String> cmd, this.dictionnary) {
    name = Namepdf(copy[0]);
    properties = Dictionnary(copy[1]);
    createcontent(cmd);
  }

  void createcontent(List<String> src) {
    var i = 0;
    List<String> cmd = [];

    while (i < src.length) {
      if (cmdList.containsKey(src[i])) {
        if (src[i] == 'BT') {
          i += 1;
          while (src[i] != 'ET') {
            cmd.add(src[i++]);
          }
          textNode.add(TextContent(cmd, dictionnary));
        } else if (src[i] == 'Do') {
          var tmp = dictionnary.xobj;
          for (var j in tmp) {
            if (j.id == cmd[0].substring(1)) {
              if (j.tmp != null) {
                image = j.tmp!;
                isImage = true;
              }
            }
          }
        }
        cmd = [];
      } else {
        cmd.add(src[i]);
      }
      ++i;
    }
  }
}

// Text State Valueprint("hum");
//
// leading is the diff between the base of two lines
//   int charspace = 0;
//   int wordspace = 0;
//   int scale = 100;
//   int leading = 0;
//   int fontsize;
//   int render = 0;
//   int rise = 0;

class TextState {
  List<int> statut = [0, 0, 100, 0, 0, 0, 0];
  void setvalue(int parse, int pos) {
    statut[pos] = parse;
  }
}

// GraphicState getgstate(String cmd) {
//   return null;
// }

class PathObject {
  PathObject(List<String> cmd) {}
}

// Matrix value
//
// The location of the origin
// The orientation of x and y axes
// The length of the unit uses for each axes

class GraphicState {
  List<GraphicState> stack = [];
  List<double> matrix = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  GraphicState();
  GraphicState.copy(GraphicState graphicState) {
    matrix = graphicState.matrix;
  }

  void setmatrix(List<String> cmd) {
    for (var i = 0; i < 6; ++i) {
      matrix[i] = double.parse(cmd[i]);
    }
  }

  void savestate() {
    stack.add(new GraphicState.copy(this));
  }

  void popstate() {
    stack.removeLast();
  }

  void setgraphicstate(GraphicState getgstate) {}
}

class Shape {
  Shape(String line) {}
}
