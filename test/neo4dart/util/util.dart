library neo4dart.util;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

final _logger = new Logger("neo4dart.util");

String readFile(String relativePathFromTestDirectory) {

  int i = 0;
  Directory current = Directory.current;
  while (!current.path.endsWith("test")) {
    if (i == 10) {
      throw 'Cannot read file.';
    }
    current = current.parent;
    i++;
  }

  String absolutePath = path.join(current.path, relativePathFromTestDirectory);
  return new File(absolutePath).readAsStringSync();
}


