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
import 'package:native_pdf_view/native_pdf_view.dart';

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
      dest.add(Text(
        tmp,
      ));
    }
    if (mark.isImage) {
      dest.add(mark.image);
    }
    return (dest);
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
        widg.add(Text(tmp.stringLine.join()));
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
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),

          child: ListView(
            children: content,
          ),
          // child: Stack(),
        ));
  }
}

class PDFBook extends StatefulWidget {
  final String book;
  final String token;
  final Uint8List bytes;
  final String title;
  final String library;
  final String? progress;

  PDFBook({Key? key, required this.book, required this.token, required this.bytes, required this.title, required this.library, required this.progress}) : super(key: key);
  @override
  _PDFBookState createState() => _PDFBookState();
}

class _PDFBookState extends State<PDFBook> {
  late AlexandrioAPIController _alexandrioController;
  late PdfController _flutterpdf;
  late TextEditingController _textEditingController;

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  List<AlexandrioBookmark> bookmarkList = [];
  bool isLongPressed = false;
  double button1pos = 1.5;
  double button2pos = 1.5;

  Future<bool> _initBookmarkList() async {
    var tmp = await _alexandrioController.getAllUserData(widget.token, widget.library, widget.book);
    setState(() {
      for (var data in tmp) {
        bookmarkList.add(AlexandrioBookmark(
            pos: data[0],
            id: bookmarkList.length + 1,
            status: () {},
            redirect: () {
              _pdfRedirect(data[0]);
            },
            isNote: data[data.length - 1] == 'note' ? true : false,
            note: data[2],
            dataId: data[1]));
      }
    });
    return true;
  }

  void _showBookmarkOptions() {
    setState(() {
      button1pos = 0.95;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        button2pos = 0.8;
      } else {
        button2pos = 0.6;
      }
      isLongPressed = true;
    });
  }

  void _pdfRedirect(String cfi) {
    _flutterpdf.jumpToPage(int.tryParse(cfi) ?? 0);
    Navigator.pop(context);
  }

  void _fillIconList(String cfi, bool _isNote, String _note, int _id) {
    setState(() {
      var tmp = AlexandrioBookmark(
          pos: cfi,
          id: _id,
          status: () {},
          redirect: () {
            _pdfRedirect(cfi);
          },
          isNote: _isNote,
          note: _note,
          dataId: '');
      bookmarkList.add(tmp);
    });
  }

  void _removeIconFromList(int _id, String _dataId) {
    setState(() {
      bookmarkList.removeWhere((element) => element.id == _id);
    });
    _alexandrioController.deleteUserData(widget.token, widget.library, widget.book, _dataId);
  }

  @override
  void initState() {
    _alexandrioController = AlexandrioAPIController();
    int page = int.tryParse(widget.progress ?? '0') ?? 0;
    _flutterpdf = PdfController(document: PdfDocument.openData(widget.bytes), initialPage: page);
    _textEditingController = TextEditingController();
    _initBookmarkList().then((tmp) {
      // if (bookmarkList.isNotEmpty) {
      //   _alexandrioController.deleteAllUserData(
      //       widget.token, widget.library, widget.book);
      // }
    });
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
            onPressed: () {
              _globalKey.currentState!.openEndDrawer();
            },
            icon: const Icon(Icons.bookmark),
            tooltip: "Bookmarks",
          ),
          IconButton(
            onPressed: () {
              var progression = _flutterpdf.page;
              _alexandrioController.postProgression(widget.token, widget.book, widget.library, progression.toString());
              bookmarkList.forEach((element) {
                _alexandrioController.postUserData(widget.token, widget.library, widget.book, element.isNote ? 'note' : 'bookmark', element.note, element.isNote ? 'note' : 'bookmark', element.pos!);
              });
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: "Return",
          )
        ],
      ),
      endDrawer: Drawer(
          child: ListView(children: [
        for (var bookmark in bookmarkList)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Material(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(32.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          !bookmark.isNote ? Icons.bookmark : Icons.book,
                          color: Colors.white.withAlpha(196),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (bookmark.isNote)
                        Text(
                          bookmark.isNote ? 'Note' : 'Bookmark',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          bookmark.isNote ? '${bookmark.note}' : '',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      {
                        _flutterpdf.jumpToPage(int.tryParse(bookmark.pos!) ?? 0);
                      }
                    },
                    icon: const Icon(Icons.fmd_good_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      //setState(() {
                      // bookmarkList.removeWhere((element) => element.id == bookmark.id);
                      //});
                      _removeIconFromList(bookmark.id, bookmark.dataId);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          ),
      ])),
      endDrawerEnableOpenDragGesture: true,
      // body: PdfView(
      //   controller: _flutterpdf,
      //   scrollDirection: Axis.vertical,
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPressStart: (LongPressStartDetails details) {
                //_showBookmarkOptions(),
                print('helli');
                setState(() {
                  isLongPressed = true;
                });
              },
              onTap: () {
                print('22222222222222222');
                setState(() {
                  isLongPressed = false;
                });
              },
              // onTap: () => {
              //   setState(() => {isLongPressed = false})
              // },
              child: PdfView(
                scrollDirection: Axis.vertical,
                controller: _flutterpdf,
              ),
            ),
          ),
          if (isLongPressed == true)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      tooltip: "Add a bookmark",
                      child: const Icon(Icons.bookmark),
                      onPressed: () => {_fillIconList(_flutterpdf.page.toString(), false, '', bookmarkList.length + 1), button1pos = 1.5, button2pos = 1.5},
                    ),
                    SizedBox(width: 16.0),
                    FloatingActionButton(
                      tooltip: "Add a note",
                      child: const Icon(Icons.notes),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Write your note'),
                          content: TextField(
                            controller: _textEditingController,
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => {_fillIconList(_flutterpdf.page.toString(), true, _textEditingController.text, bookmarkList.length + 1), Navigator.pop(context, "Add")},
                              child: const Text("Add"),
                            ),
                            TextButton(onPressed: () => {Navigator.pop(context, "Cancel")}, child: const Text("Cancel"))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
