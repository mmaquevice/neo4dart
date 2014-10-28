library neo4dart.client.get.neo_client_get_test;

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../util/util.dart' as util;

import 'package:neo4dart/testing/person.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.clearListeners();
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_client_get_test");

  group('findByType', () {

    test('ok', () {
        var client200 = new MockClient((request) {

          var responseBody = util.readFile('test/neo4dart/client/get/json/findNodesByType_200.json');
          return new http.Response(responseBody, 200);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client200);

        List expectedList = new List();

        Person asterix = new Person("Asterix", city:"Gaule");
        Person obelix = new Person("Obelix", city:"Gaule");
        Person idefix = new Person("Idefix", city:"Gaule");

        expectedList.add(asterix);
        expectedList.add(obelix);
        expectedList.add(idefix);

        return neoClient.findNodesByType(Person).then((nodes) => expect(nodes, unorderedEquals(expectedList)));
    });

    test('if [500 from neo4j server] then [exception]', () {
        var client500 = new MockClient((request) {
          return new http.Response('', 500);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client500);
        expect(neoClient.findNodesByType(Person), throwsA(new isInstanceOf<String>()));
    });

  });

  group('findByTypeAndProperties', () {

    test('ok', () {
        var client200 = new MockClient((request) {

          var responseBody = util.readFile('test/neo4dart/client/get/json/findNodesByTypeAndProperties_200.json');
          return new http.Response(responseBody, 200);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client200);

        List expectedList = new List();
        expectedList.add(new Person("Asterix", city:"Gaule"));

        return neoClient.findNodesByTypeAndProperties(Person, {"name":"Asterix"}).then((nodes) => expect(nodes, unorderedEquals(expectedList)));
    });

    test('if [500 from neo4j server] then [exception]', () {
        var client500 = new MockClient((request) {
          return new http.Response('', 500);
        });
        NeoClientGet neoClient = new NeoClientGet.withClient(client500);
        expect(neoClient.findNodesByTypeAndProperties(Person, {"name":"Asterix"}), throwsA(new isInstanceOf<String>()));
    });

    test('if [properties are empty] then [exception]', () {
        try {
          new NeoClientGet().findNodesByTypeAndProperties(Person, {});
        } on StateError catch(e) {
          expect(e.message, 'Properties are empty.');
          return;
        }
        throw "Expected StateError";
    });

  });
}
