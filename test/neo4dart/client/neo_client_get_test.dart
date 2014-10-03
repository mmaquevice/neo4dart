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

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_client_get_test");

  group('executeGetByType', () {

    test('ok', () {
      try {
        var client200 = new MockClient((request) {

          var responseBody = '''
          [ {
  "outgoing_relationships" : "http://localhost:7474/db/data/node/95/relationships/out",
  "labels" : "http://localhost:7474/db/data/node/95/labels",
  "data" : {
    "name" : "Asterix",
    "language" : "Tutu"
  },
  "all_typed_relationships" : "http://localhost:7474/db/data/node/95/relationships/all/{-list|&|types}",
  "traverse" : "http://localhost:7474/db/data/node/95/traverse/{returnType}",
  "property" : "http://localhost:7474/db/data/node/95/properties/{key}",
  "self" : "http://localhost:7474/db/data/node/95",
  "properties" : "http://localhost:7474/db/data/node/95/properties",
  "outgoing_typed_relationships" : "http://localhost:7474/db/data/node/95/relationships/out/{-list|&|types}",
  "incoming_relationships" : "http://localhost:7474/db/data/node/95/relationships/in",
  "extensions" : {
  },
  "create_relationship" : "http://localhost:7474/db/data/node/95/relationships",
  "paged_traverse" : "http://localhost:7474/db/data/node/95/paged/traverse/{returnType}{?pageSize,leaseTime}",
  "all_relationships" : "http://localhost:7474/db/data/node/95/relationships/all",
  "incoming_typed_relationships" : "http://localhost:7474/db/data/node/95/relationships/in/{-list|&|types}"
}, {
  "outgoing_relationships" : "http://localhost:7474/db/data/node/96/relationships/out",
  "labels" : "http://localhost:7474/db/data/node/96/labels",
  "data" : {
    "name" : "Obelix",
    "language" : "A la folie"
  },
  "all_typed_relationships" : "http://localhost:7474/db/data/node/96/relationships/all/{-list|&|types}",
  "traverse" : "http://localhost:7474/db/data/node/96/traverse/{returnType}",
  "property" : "http://localhost:7474/db/data/node/96/properties/{key}",
  "self" : "http://localhost:7474/db/data/node/96",
  "properties" : "http://localhost:7474/db/data/node/96/properties",
  "outgoing_typed_relationships" : "http://localhost:7474/db/data/node/96/relationships/out/{-list|&|types}",
  "incoming_relationships" : "http://localhost:7474/db/data/node/96/relationships/in",
  "extensions" : {
  },
  "create_relationship" : "http://localhost:7474/db/data/node/96/relationships",
  "paged_traverse" : "http://localhost:7474/db/data/node/96/paged/traverse/{returnType}{?pageSize,leaseTime}",
  "all_relationships" : "http://localhost:7474/db/data/node/96/relationships/all",
  "incoming_typed_relationships" : "http://localhost:7474/db/data/node/96/relationships/in/{-list|&|types}"
}, {
  "outgoing_relationships" : "http://localhost:7474/db/data/node/97/relationships/out",
  "labels" : "http://localhost:7474/db/data/node/97/labels",
  "data" : {
    "name" : "Idefix",
    "language" : "Nonos"
  },
  "all_typed_relationships" : "http://localhost:7474/db/data/node/97/relationships/all/{-list|&|types}",
  "traverse" : "http://localhost:7474/db/data/node/97/traverse/{returnType}",
  "property" : "http://localhost:7474/db/data/node/97/properties/{key}",
  "self" : "http://localhost:7474/db/data/node/97",
  "properties" : "http://localhost:7474/db/data/node/97/properties",
  "outgoing_typed_relationships" : "http://localhost:7474/db/data/node/97/relationships/out/{-list|&|types}",
  "incoming_relationships" : "http://localhost:7474/db/data/node/97/relationships/in",
  "extensions" : {
  },
  "create_relationship" : "http://localhost:7474/db/data/node/97/relationships",
  "paged_traverse" : "http://localhost:7474/db/data/node/97/paged/traverse/{returnType}{?pageSize,leaseTime}",
  "all_relationships" : "http://localhost:7474/db/data/node/97/relationships/all",
  "incoming_typed_relationships" : "http://localhost:7474/db/data/node/97/relationships/in/{-list|&|types}"
} ]
          ''';

          return new http.Response(responseBody, 200);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client200);

        List expectedList = new List();

        Person asterix = new Person("Asterix", "Tutu");
        asterix.id = 95;
        Person obelix = new Person("Obelix", "A la folie");
        obelix.id = 96;
        Person idefix = new Person("Idefix", "Nonos");
        idefix.id = 97;

        expectedList.add(asterix);
        expectedList.add(obelix);
        expectedList.add(idefix);


        return neoClient.executeGetByType(Person).then((nodes) => expect(nodes, unorderedEquals(expectedList)));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

//    test('- if code 500 then false', () {
//      try {
//        BatchToken batchToken = new BatchToken("POST", "/node", {
//            "name" : "bob"
//        });
//
//        var client500 = new MockClient((request) {
//          return new http.Response("", 500);
//        });
//        NeoClientBatch neoClient = new NeoClientBatch.withClient(client500);
//        Set batchTokens = new Set();
//        batchTokens.add(batchToken);
//
//        return neoClient.executeBatch(batchTokens).then((ok) => expect(ok, equals(false)));
//      } catch(e, s) {
//        _logger.severe(e);
//        _logger.severe(s);
//      }
//    });

  });

}
