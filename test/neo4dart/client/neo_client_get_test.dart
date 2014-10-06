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

  group('findByType', () {

    test('ok', () {
      try {
        var client200 = new MockClient((request) {
          var responseBody = new File('json/findNodesByType_200.json').readAsStringSync();
          return new http.Response(responseBody, 200);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client200);

        List expectedList = new List();

        Person asterix = new Person("Asterix", "Tutu");
        Person obelix = new Person("Obelix", "A la folie");
        Person idefix = new Person("Idefix", "Nonos");

        expectedList.add(asterix);
        expectedList.add(obelix);
        expectedList.add(idefix);

        return neoClient.findNodesByType(Person).then((nodes) => expect(nodes, unorderedEquals(expectedList)));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

    test('if [500 from neo4j server] then [exception]', () {
      try {
        var client500 = new MockClient((request) {
          return new http.Response('', 500);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client500);
        expect(neoClient.findNodesByType(Person), throwsA(new isInstanceOf<String>()));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });

  group('findByTypeAndProperties', () {

    test('ok', () {
      try {
        var client200 = new MockClient((request) {
          var responseBody = new File('json/findNodesByTypeAndProperties_200.json').readAsStringSync();
          return new http.Response(responseBody, 200);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client200);

        List expectedList = new List();
        expectedList.add(new Person("Asterix", "Tutu"));

        return neoClient.findNodesByTypeAndProperties(Person, {"name":"Asterix"}).then((nodes) => expect(nodes, unorderedEquals(expectedList)));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

    test('if [500 from neo4j server] then [exception]', () {
      try {
        var client500 = new MockClient((request) {
          return new http.Response('', 500);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client500);
        expect(neoClient.findNodesByTypeAndProperties(Person, {"name":"Asterix"}), throwsA(new isInstanceOf<String>()));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

    test('if [properties are empty] then [exception]', () {
      try {
        NeoClientGet neoClient = new NeoClientGet.withClient(null);

        List expectedList = new List();
        expectedList.add(new Person("Asterix", "Tutu"));

        expect(neoClient.findNodesByTypeAndProperties(Person, {}), throwsA(new isInstanceOf<StateError>()));
      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });
}
