import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<Uint8List> read() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsBytes();

      return (contents);
    } catch (e) {
      // If encountering an error, return 0
      return throw ("not a valid file");
    }
  }
}
