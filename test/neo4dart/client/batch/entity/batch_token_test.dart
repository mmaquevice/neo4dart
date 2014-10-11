library neo4dart.client.batch.entity.batch_token_test;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';
import 'package:mock/mock.dart';
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.batch_token_test");

  group('batch_token toJson', () {

    test('- json is well formated', () {
      try {
        BatchToken batchToken = new BatchToken("POST", "/node", {"name" : "bob"});
        var json = new JsonEncoder().convert(batchToken);
        expect(json, '{"id":0,"method":"POST","to":"/node","body":{"name":"bob"}}');
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });

}
