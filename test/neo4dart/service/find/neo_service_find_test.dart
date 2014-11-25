library neo4dart.service.find.neo_service_find_test;

import 'dart:convert';

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../util/util.dart' as util;

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.clearListeners();
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_service_find_test");

  group('findNodeById', () {

    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodeById_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.tokenFindExecutor = new BatchFindExecutor.withClient(client200);

      return neoService.findNodeById(9, Person).then((node) {
        expect(node, equals(new Person("Antonio", city: "Madrid")));
      });
    });
  });

  group('findNodesByIds', () {

    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodesByIds_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.tokenFindExecutor = new BatchFindExecutor.withClient(client200);

      return neoService.findNodesByIds([9, 11], Person).then((nodes) {
        expect(nodes, unorderedEquals([new Person("Antonio", city: "Madrid"), new Person("Lucille", city: "Paris")]));
      });
    });
  });

  group('findNodeWithRelationsById', () {

    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodeWithRelationsById_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherFindExecutor = new CypherFindExecutor.withClient(client200);

      return neoService.findNodeWithRelationsById(24260, Person).then((node) {

        Person gerard = new Person('Gerard', city: 'Moscou');
        Person lucille = new Person('Lucille', city: 'Paris');
        gerard.coworkers = [lucille];

        Person josette = new Person('Josette', city: 'Berlin');
        gerard.eternalLovers = new Set.from([new Love(gerard, josette, 'a lot', '2 hours ago')]);

        expect(node, gerard);
      });
    });
  });

  group('findNodeWithAllRelationsById', () {
    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
          var responseBody = util.readFile('test/neo4dart/service/find/json/findNodeWithAllRelationsById_ok.json');
          return new http.Response(responseBody, 200);
      });
      neoService.cypherFindExecutor = new CypherFindExecutor.withClient(client200);

      Person lucille = new Person('Lucille', city: 'Paris');
      Person toto = new Person('Toto', city: 'Lisbonne');
      Person gerard = new Person('Gerard', city: 'Moscou');

      lucille.coworkers = [toto];
      toto.coworkers = [gerard];
      gerard.coworkers = [lucille];

      Person josette = new Person('Josette', city: 'Berlin');
      gerard.eternalLovers = new Set.from([new Love(gerard, josette, 'a lot', '2 hours ago')]);

      return neoService.findNodeWithAllRelationsById(24260, Person).then((node) {
        expect(node, equals(gerard));
      });
    });
  });

  group('findNodesWithAllRelationsByIds', () {
    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodesWithAllRelationsByIds_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherFindExecutor = new CypherFindExecutor.withClient(client200);

      Person lucille = new Person('Lucille', city: 'Paris');
      Person toto = new Person('Toto', city: 'Lisbonne');
      Person gerard = new Person('Gerard', city: 'Moscou');

      lucille.coworkers = [toto];
      toto.coworkers = [gerard];
      gerard.coworkers = [lucille];

      Person josette = new Person('Josette', city: 'Berlin');
      gerard.eternalLovers = new Set.from([new Love(gerard, josette, 'a lot', '2 hours ago')]);

      return neoService.findNodesWithAllRelationsByIds([24260, 24262], Person).then((nodes) {
        expect(nodes, unorderedEquals([gerard,toto]));
      });
    });
  });

  group('findNodesWithAllRelations', () {
    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodesWithAllRelationsByProperties_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherFindExecutor = new CypherFindExecutor.withClient(client200);

      Person lucille = new Person('Lucille', city: 'Paris');
      Person toto = new Person('Toto', city: 'Lisbonne');
      Person gerard = new Person('Gerard', city: 'Moscou');

      lucille.coworkers = [toto];
      toto.coworkers = [gerard];
      gerard.coworkers = [lucille];

      Person josette = new Person('Josette', city: 'Berlin');
      gerard.eternalLovers = new Set.from([new Love(gerard, josette, 'a lot', '2 hours ago')]);

      return neoService.findNodesWithAllRelations(Person, properties: {"name": "Lucille"}).then((nodes) {
        expect(nodes, unorderedEquals([lucille]));
      });

      });
    });
}
