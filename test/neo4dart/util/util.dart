library neo4dart.util;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

final _logger = new Logger("neo4dart.util");

// TODO mma - workaround til dart offers a proper way to retrieve the root project directory
String readFile(String relativePathFromRootProjectDirectory) {

  Directory rootDirectory = _findRootDirectory();

  String absolutePath = path.join(rootDirectory.path, relativePathFromRootProjectDirectory);
  return new File(absolutePath).readAsStringSync();
}

Directory _findRootDirectory() {

  int i = 0;
  Directory current = Directory.current;

  while (!_isRootDirectory(current)) {
    if (i == 10) {
      throw 'Cannot read file.';
    }

    current = current.parent;
    i++;
  }

  return current;
}

bool _isRootDirectory(Directory directory) {

  bool isRoot = false;
  directory.listSync().forEach((FileSystemEntity file) {
    if(file.path.endsWith("pubspec.yaml")) {
      isRoot=true;
    }
  });

  return isRoot;
}



