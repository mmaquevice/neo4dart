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

  group('findNodeAndRelationsById', () {

    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
        var json = new JsonDecoder().convert(request.body);
        if (json.length == 1) {
          var responseBody = util.readFile('test/neo4dart/service/find/json/findNodeAndRelationsById_relationships.json');
          return new http.Response(responseBody, 200);
        }

        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodeAndRelationsById_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.tokenFindExecutor = new BatchFindExecutor.withClient(client200);

      return neoService.findNodeAndRelationsById(11, Person).then((node) {

        Person lucille = new Person('Lucille', city: 'Paris');
        lucille.eternalLovers.add(new Love(lucille, new Person('Antonio', city: 'Madrid'), 'Muchos', '1984'));
        lucille.eternalLovers.add(new Love(lucille, new Person('Roméo', city: 'Roma'), 'A lot', '1985'));

        expect(node, lucille);
      });
    });
  });

  group('findAllNodeAndRelationsById', () {
    test('ok', () {

      NeoServiceFind neoService = new NeoServiceFind();

      var client200 = new MockClient((request) {
        if (request.url.path.endsWith("commit")) {
          var responseBody = util.readFile('test/neo4dart/service/find/json/findAllNodeAndRelationsById_cypherIds.json');
          return new http.Response(responseBody, 200);
        } else {
          var responseBody = util.readFile('test/neo4dart/service/find/json/findAllNodeAndRelationsById_batchEntities.json');
          return new http.Response(responseBody, 200);
        }
      });
      neoService.tokenFindExecutor = new BatchFindExecutor.withClient(client200);
      neoService.cypherFindExecutor = new CypherFindExecutor.withClient(client200);

      Person lucille = new Person('Lucille', city: 'Paris');
      Person toto = new Person('Toto', city: 'Lisbonne');
      Person gerard = new Person('Gerard', city: 'Moscou');

      lucille.coworkers = [toto];
      toto.coworkers = [gerard];
      gerard.coworkers = [lucille];

      return neoService.findAllNodeAndRelationsById(24267, Person).then((node) {
        expect(node, equals(gerard));
      });
    });
  });
}
