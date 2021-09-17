library flutter_pdf_parser;

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_parser/complete_object.dart';
import 'package:flutter_pdf_parser/pagetree.dart';
import 'package:flutter_pdf_parser/parsing_content.dart';
import 'package:flutter_pdf_parser/flutter_pdf.dart';
import 'package:flutter_pdf_parser/flutter_bookmark.dart';
import 'parse_object.dart';

class Flutter_pdf {
  CompleteObject? completeObject;
  int totalpages = 0;


  Flutter_pdf(Uint8List bytes) {
    ParseObject parseobj = ParseObject(bytes);
    completeObject = CompleteObject(parseobj);
    totalpages = completeObject!.rootTree!.getPageNumber();
  }

  List<Widget> getMarkContent(MarkContent mark) {
    List<Widget> dest = [];
    if (mark.textNode != []) {
      var tmp = "";
      for (var i in mark.textNode) {
        tmp += i.stringLine.join();
      }
        dest.add(Text(tmp,
        ));
    }
    if (mark.isImage) {
      dest.add(mark.image);
    }
    return(dest);
  }
  List<Widget> getPageContent(int i) {
    PageTree tree = completeObject!.rootTree!;
    PageNode leaf = tree.getPage(i);
    Content content = leaf.content!;
    ParsingContent all = content.content!;
    List<Widget> widg = [];

    for (var i in all.isMark) {
      if (i == true) {
        widg += getMarkContent(all.markNode.removeAt(0));
      } else {
        TextContent tmp = all.textNode.removeAt(0);
        widg.add(Text(tmp.stringLine.join()
        ));
      }
    }
    return widg;
  }
}

class PDFPage extends StatelessWidget {
  final List<Widget> content;
  const PDFPage({
     required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ScrollConfiguration(behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false), child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),

      ),
     
     child: ListView (
       children: content,
     )
      ,
     // child: Stack(),
    )
    );
  }
}

class PDFBook extends StatefulWidget {
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
  }) : super(key: key);
    @override
    _PDFBookState createState() => _PDFBookState();
}

class _PDFBookState extends State<PDFBook>{
  late AlexandrioAPIController _alexandrioController;
  late Flutter_pdf _flutterpdf;
  late ScrollController _scrollController;
  late TextEditingController _textEditingController;
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  List<AlexandrioBookmark> bookmarkList = [];
  bool isLongPressed = false;
  double button1pos = 1.5;
  double button2pos = 1.5;

  void _showBookmarkOptions() {
    setState(() {
      button1pos = 0.95;
      button2pos = 0.8;
      isLongPressed = true;
    });
  }
  void _fillIconList(String cfi, bool _isNote, String _note, int _id) {
    setState(() {
      //var tmp = AlexandrioBookmark(pos: cfi, id: _id, status: () { _removeIconFromList(_id); }, redirect: () { _epubRedirect(cfi); }, isNote: _isNote, note: _note, dataId: '');
      //bookmarkList.add(tmp);
    });
  }

  void _removeIconFromList(int _id) {
    setState(() {
      bookmarkList.removeWhere((element) => element.id == _id);
    });
  }
  void initState() {
    _alexandrioController = AlexandrioAPIController();
    _flutterpdf = Flutter_pdf(widget.bytes);
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () { _globalKey.currentState!.openEndDrawer(); },
            icon: const Icon(Icons.bookmark),
            tooltip: "Bookmarks",
          ),
          IconButton(
            onPressed: () {
//              _alexandrioController.postProgression(widget.token, widget.book, widget.library, widget.progress);
//              bookmarkList.forEach((element) {
//                _alexandrioController.postUserData(widget.token, widget.library, widget.book, element.isNote ? 'note' : 'bookmark', element.note, element.isNote ? 'note' : 'bookmark', element.pos!);
//              });
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: "Return",
          )
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 128.0 * 4.0),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0) + MediaQuery.of(context).viewPadding,
            children: [
              const SizedBox(height: 16.0),
              for (var i = 0; i < _flutterpdf.totalpages; ++i) ...[
                AspectRatio(
                  // aspectRatio: (Platform.isWindows || Platform.isLinux || Platform.isMacOS) ? 4 / 3 : 1 / 2,
                  aspectRatio: 1 / 1.4142,
                  child: PDFPage(
                    content: _flutterpdf.getPageContent(i),
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

