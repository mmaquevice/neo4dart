library neo4dart.neo_client_test;

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

  final _logger = new Logger("neo4dart.neo_client_test");

  group('neo client executes batch', () {

    test('- if code 200 then true', () {
      try {
        BatchToken batchToken = new BatchToken("POST", "/node", {"name" : "bob"});

        var client200 = new MockClient((request) {
          return new http.Response("", 200);
        });
        NeoClient neoClient = new NeoClient.withClient(client200);
        Set batchTokens = new Set();
        batchTokens.add(batchToken);

        return neoClient.executeBatch(batchTokens).then((ok) => expect(ok, equals(true)));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

    test('- if code 500 then false', () {
      try {
        BatchToken batchToken = new BatchToken("POST", "/node", {"name" : "bob"});

        var client500 = new MockClient((request) {
          return new http.Response("", 500);
        });
        NeoClient neoClient = new NeoClient.withClient(client500);
        Set batchTokens = new Set();
        batchTokens.add(batchToken);

        return neoClient.executeBatch(batchTokens).then((ok) => expect(ok, equals(false)));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });

}
