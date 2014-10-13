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
        Node node = new Person("Claude", city: "Gagny");

        BatchTokenHandler handler = new BatchTokenHandler();
        BatchToken token = handler.addNodeToBatch(node);

        BatchToken expected = new BatchToken("POST", "/node", {"name" : "Claude", "city" : "Gagny"});

        expect(token, equals(expected));
    });
  });

  group('addNodeAndRelationsToBatch', () {

    test('ok', () {
        Person node = new Person("Tintin", city: "Tibet");
        node.coworkers = [new Person("Haddock", city: "Boat"), new Person("Tournesol", city: "Laboratory")];

        BatchTokenHandler handler = new BatchTokenHandler();
        Set<BatchToken> tokens = handler.addNodeAndRelationsToBatch(node);

        List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Tintin", "city": "Tibet"}, id: 0),
                                     new BatchToken("POST", "/node", {"name" : "Haddock", "city": "Boat"}, id: 2),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': null, 'type': 'works with'}),
                                     new BatchToken("POST", "/node", {"name" : "Tournesol", "city": "Laboratory"}, id: 4),
                                     new BatchToken("POST", "{0}/relationships", {'to': '{4}', 'data': null, 'type': 'works with'})];

        expect(tokens, unorderedEquals(expected));
    });
  });

  group('addNodeAndRelationsViaToBatch', () {

    test('ok', () {
      Person romeo = new Person("Romeo", city: "Roma");
      Person julieta = new Person("Julieta", city: "Venizia");
      Person liliana = new Person("Liliana", city: "Friul");
      Set lovers = new Set();

      romeo.eternalLovers.add(new Love(romeo,julieta, "so so", "1345"));
      romeo.eternalLovers.add(new Love(romeo,liliana, "so so so", "1346"));

      BatchTokenHandler handler = new BatchTokenHandler();
      Set<BatchToken> tokens = handler.addNodeAndRelationsViaToBatch(romeo);

      List<BatchToken> expected = [new BatchToken("POST", "/node", {"name" : "Romeo", "city": "Roma"}, id: 0),
                                   new BatchToken("POST", "/node", {"name" : "Julieta", "city": "Venizia"}, id: 2),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{2}', 'data': {'howMuch': 'so so', 'since': 1345}, 'type': 'secretly loves'}),
                                   new BatchToken("POST", "/node", {"name" : "Liliana", "city": "Friul"}, id: 4),
                                   new BatchToken("POST", "{0}/relationships", {'to': '{4}', 'data': {'howMuch': 'so so so', 'since': 1346}, 'type': 'secretly loves'}),];

      expect(tokens, unorderedEquals(expected));
    });
  });

}