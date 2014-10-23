library neo4dart.client.batch.neo_client_batch_test;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';
import 'package:mock/mock.dart';
import 'dart:async';
import 'package:path/path.dart' as path;

import '../../util/util.dart' as util;

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:neo4dart/testing/person.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.client.batch.neo_client_batch_test");

  group('executeBatch', () {

    test('ok', () {
      try {

        Person justin = new Person("Justin", city: 'Moscow');
        BatchToken batchToken = new BatchToken("POST", "/node", justin.toJson(), id: 0, neoEntity: justin);

        var client200 = new MockClient((request) {
          var responseBody = util.readFile('neo4dart/client/batch/json/executeBatch.json');
          return new http.Response(responseBody, 200);
        });
        NeoClientBatch neoClient = new NeoClientBatch.withClient(client200);

        Set batchTokens = new Set();
        batchTokens.add(batchToken);

        return neoClient.executeBatch(batchTokens).then((ok) {
          expect(justin.id, equals(87));
          expect(ok, equals(true));
        });
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

    test('if code 500 then false', () {
      try {
        BatchToken batchToken = new BatchToken("POST", "/node", {"name" : "bob"});

        var client500 = new MockClient((request) {
          return new http.Response("", 500);
        });
        NeoClientBatch neoClient = new NeoClientBatch.withClient(client500);
        Set batchTokens = new Set();
        batchTokens.add(batchToken);

        expect(neoClient.executeBatch(batchTokens), throwsA(new isInstanceOf<String>()));

      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });

}
