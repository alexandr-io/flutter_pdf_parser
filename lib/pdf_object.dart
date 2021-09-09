import 'package:tuple/tuple.dart';

bool isWhiteSpace(String c) {
  String whitespace = String.fromCharCodes([0, 9, 10, 12, 13, 32]);
  if (whitespace.contains(c)) return (true);
  return (false);
}

bool isdelimitor(String c) {
  String delimiter = "()<>[]{}/%";
  if (delimiter.contains(c)) return (true);
  return (false);
}

bool isdelimiterorwhitespace(String c) {
  if (isWhiteSpace(c) || isdelimitor(c)) return (true);
  return (false);
}

int getdelimiter(String str) {
  int i = 0;

  while (i < str.length && !isdelimiterorwhitespace(str[i])) ++i;
  return (i);
}

bool isnumber(String str) {
  int i = 0;
  bool isfloat = false;

  while (i < str.length && !isdelimiterorwhitespace(str[i])) {
    if (str[i] == '.' && isfloat == false) {
      isfloat = true;
    } else if (str[i] == '.') {
      return (false);
    }
    if (str.codeUnitAt(i) < '0'.codeUnitAt(0) || str[i].codeUnitAt(0) > '9'.codeUnitAt(0)) return (false);
    ++i;
  }
  if (i == 0) return (false);
  return (true);
}

Objectpdf createObject(String str, int type) {
  switch (type) {
    case 1:
      return (new Boolean(str));
      break;
    case 2:
      return (new Numeric(str));
      break;
    case 3:
      return (new Stringpdf(str));
      break;
    case 4:
      return (new Namepdf(str));
      break;
    case 5:
      return (new Arraypdf(str));
      break;
    case 6:
      return (new Dictionnary(str));
      break;
    case 7:
      return (new Stream(str));
      break;
    case 8:
      return (new Nullpdf(str));
    default:
      return (new Linkpdf(str));
  }
}

int getclose(String str, String open, String end) {
  int close = 1;
  int i = 1;

  while (close > 0) {
    if (str[i] == open) close++;
    if (str[i] == end) close--;
    ++i;
  }
  ++i;
  return (i);
}

bool isLink(String content) {
  var str = content;
  var i = getdelimiter(str) + 1;
  str = str.substring(i);
  if (!isnumber(str)) return (false);
  i = getdelimiter(str) + 1;
  if (i >= str.length || str[i] != 'R') return (false);
  return (true);
}

Tuple3<String, int, int> identifyObject(String content) {
  int i = 0;
  if (content[0] == '<' && content[1] == '<') {
    int close = 1;
    i = 2;
    while (close > 0) {
      if (content[i] == '<' && content[i + 1] == '<') close++;
      if (content[i] == '>' && content[i + 1] == '>') close--;
      ++i;
    }
    i = i + 1;
    return Tuple3(content.substring(0, i), i, 6);
  }
  if (content[0] == '<') {
    int end = getclose(content, '<', '>');
    return Tuple3(content.substring(0, end - 1), end - 1, 3);
  }
  if (content[0] == '(') {
    int end = getclose(content, '(', ')');
    return Tuple3(content.substring(0, end), end, 3);
  }
  if (content[0] == '[') {
    int end = getclose(content, '[', ']');
    return Tuple3(content.substring(0, end), end, 5);
  }
  if (content.length >= 4 && content.substring(0, 4) == "null" && isdelimiterorwhitespace(content[4])) {
    return Tuple3(content.substring(0, 3), 4, 8);
  }
  if (content.length >= 4 && content.substring(0, 4) == "true" && isdelimiterorwhitespace(content[4])) {
    return Tuple3(content.substring(0, 4), 4, 1);
  }
  if (content.length >= 5 && content.substring(0, 5) == "false" && isdelimiterorwhitespace(content[5])) {
    return Tuple3(content.substring(0, 5), 5, 1);
  }
  if (content[0] == '/') {
    int end = getdelimiter(content.substring(1));
    return Tuple3(content.substring(0, end + 1), end + 1, 4);
  }
  if (content.length >= 6 && content.substring(0, 6) == "stream" && isdelimiterorwhitespace(content[6])) {
    int end = content.indexOf("endstream");
    var tmp = content.substring(7, end - 1);
    while (isdelimiterorwhitespace(tmp[0])) tmp = tmp.substring(1);
    return Tuple3(tmp, end + 9, 7);
  }
  if (isnumber(content)) {
    if (isLink(content)) {
      int end = 0;
      while (content[end] != 'R') ++end;
      return Tuple3(content.substring(0, end + 1), end + 1, 9);
    }
    int end = getdelimiter(content);
    return Tuple3(content.substring(0, end), end, 2);
  } else {
    int end = getdelimiter(content);
    return Tuple3(content.substring(0, end), end, 3);
  }
}

abstract class Objectpdf {
  int type = 0;
}

class Boolean implements Objectpdf {
  @override
  int type = 1;
  Boolean(String line) {
    if (line == "true") value = true;
    value = false;
  }
  bool value = true;
}

class Numeric implements Objectpdf {
  @override
  int type = 2;
  double nbr = 0.0;
  Numeric(String line) {
    nbr = double.parse(line);
  }
}

class Stringpdf implements Objectpdf {
  @override
  int type = 3;

  String convertoct(String c) {
    return c;
  }

  String converthex(String c) {
    return c;
  }

  Stringpdf(String line) {
    originalstring = line;
  }
  String originalstring = "";
  String finalstring = "";
}

class Namepdf implements Objectpdf {
  @override
  int type = 4;

  String converthex(String c) {
    return c;
  }

  Namepdf(String line) {
    value = line.substring(1);
  }
  String value = "";
}

class Arraypdf implements Objectpdf {
  @override
  int type = 5;
  Arraypdf(String line) {
    int i = 1;
    while (i < line.length && line[i] != ']') {
      var tmp;
      if (isWhiteSpace(line[i]))
        ++i;
      else {
        tmp = identifyObject(line.substring(i));
        array.add(createObject(tmp.item1, tmp.item3));
        i += tmp.item2 as int;
      }
    }
  }
  List<Objectpdf> array = [];
}

class Dictionnary implements Objectpdf {
  @override
  int type = 6;
  Dictionnary(String line) {
    int i = 0;
    Namepdf? name;
    line = line.substring(2);
    while (i < line.length && line[i] != '>' && line[i + 1] != '>') {
      var tmp;

      if (isWhiteSpace(line[i]))
        ++i;
      else {
        tmp = identifyObject(line.substring(i));
        if (name == null) {
          name = createObject(tmp.item1, tmp.item3) as Namepdf?;
        } else {
          content.addEntries([MapEntry(name.value, createObject(tmp.item1, tmp.item3))]);
          name = null;
        }
        i += tmp.item2 as int;
      }
    }
  }
  Map<String, Objectpdf> content = {};
}

class Stream implements Objectpdf {
  @override
  int type = 7;
  String content = "";
  Stream(String line) {
    content = line;
  }
}

class Nullpdf implements Objectpdf {
  @override
  int type = 8;
  Nullpdf(String line);
}

class Linkpdf implements Objectpdf {
  @override
  int type = 9;
  int nbr = 0;
  int sec = 0;
  Linkpdf(String line) {
    var i = getdelimiter(line);
    nbr = int.parse(line.substring(0, i));
    line = line.substring(i + 1);
    i = getdelimiter(line);
    sec = int.parse(line.substring(0, i));
  }
}
