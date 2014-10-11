library neo4dart.client.batch.batch_token_handler_test;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';
import 'package:mock/mock.dart';
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.client.batch.batch_token_handler_test");

  group('addNodeToBatch', () {

    test('ok', () {
      try {
        Node node = new Person("Claude", city: "Gagny");

        BatchTokenHandler handler = new BatchTokenHandler();
        BatchToken token = handler.addNodeToBatch(node);

        BatchToken expected = new BatchToken("POST", "/node", {"name" : "Claude", "city" : "Gagny"});

        return expect(token, equals(expected));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });

}
