library neo4dart.client.batch.entity.batch_token_test;

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';

import 'package:logging/logging.dart';
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
        BatchToken batchToken = new BatchToken("POST", "/node", {"name" : "bob"}, id: 0);
        var json = new JsonEncoder().convert(batchToken);
        expect(json, '{"id":0,"method":"POST","to":"/node","body":{"name":"bob"}}');
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });

}
