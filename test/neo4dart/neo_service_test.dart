library neo4dart.batch_token_test;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';
import 'package:mock/mock.dart';
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:neo4dart/testing/node_bean.dart';
import 'dart:mirrors';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_service_test");

  group('batch_token toJson', () {

    test('- json is well formated', () {
      try {

        ClassMirror classMirror = reflectClass(NodeBean);
        var metadata = classMirror.metadata;
        var obj = metadata.first.reflectee;

        print(metadata);
        print(metadata.length);
        _logger.info(classMirror.declarations.values);

        print(obj);

      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });

}
