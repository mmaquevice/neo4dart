library neo4dart.service.neo_service_test;

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../util/util.dart' as util;

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.clearListeners();
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_service_test");

  group('insertNode', () {

    test('ok - with @Relationship', () {

        NeoService neoService = new NeoService();

        var client200 = new MockClient((request) {

          var responseBody = util.readFile('test/neo4dart/service/json/insertNode_Relationship.json');
          return new http.Response(responseBody, 200);
        });
        neoService.tokenInsertExecutor = new TokenInsertExecutor.withClient(client200);

        Person lucille = new Person("Lucille", city:"Paris");
        Person matthieu = new Person("Matthieu", city:"Paris");
        Person gerard = new Person("Gérard", city:"Paris");
        lucille.lover = matthieu;
        matthieu.lover = gerard;
        gerard.lover = lucille;

        return neoService.insertNode(lucille).then((_) {
          _logger.info(lucille);
          expect(lucille.id, equals(88));
          expect(matthieu.id, equals(89));
          expect(gerard.id, isNull);
        });
    });

    test('ok - with Set of @Relationship', () {

        NeoService neoService = new NeoService();

        var client200 = new MockClient((request) {
          var responseBody = util.readFile('test/neo4dart/service/json/insertNode_Set_Relationship.json');
          return new http.Response(responseBody, 200);
        });
        neoService.tokenInsertExecutor = new TokenInsertExecutor.withClient(client200);

        Person matthieu = new Person("Matthieu", city:"Paris");
        Person mikael = new Person("Mikael", city:"Budapest");
        Person quentin = new Person("Quentin", city:"England");

        matthieu.coworkers = [mikael, quentin];

        return neoService.insertNode(matthieu).then((_) {
          _logger.info(matthieu);
          expect(matthieu.id, equals(4));
          expect(mikael.id, equals(5));
          expect(quentin.id, equals(7));
        });
    });

    test('ok - with @RelationshipVia', () {

        NeoService neoService = new NeoService();

        var client200 = new MockClient((request) {
          var responseBody = util.readFile('test/neo4dart/service/json/insertNode_RelationshipVia.json');
          return new http.Response(responseBody, 200);
        });
        neoService.tokenInsertExecutor = new TokenInsertExecutor.withClient(client200);

        Person lucille = new Person("Lucille", city:"Paris");
        Person romeo = new Person("Roméo", city:"Roma");
        Person antonio = new Person("Antonio", city:"Madrid");

        lucille.eternalLovers.addAll([new Love(lucille, romeo, "A lot", "1985"),
                                      new Love(lucille, antonio, "Muchos", "1984")]);

        return neoService.insertNode(lucille).then((_) {
          _logger.info(lucille);
          expect(lucille.id, equals(124));
          expect(romeo.id, equals(2));
          expect(antonio.id, equals(3));

          expect(lucille.eternalLovers.first.id, equals(27));
          expect(lucille.eternalLovers.last.id, equals(28));
        });
    });
  });

  group('insertNodeInDepth', () {

    test('ok', () {

      NeoService neoService = new NeoService();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/json/insertNode_Relationship.json');
        return new http.Response(responseBody, 200);
      });
      neoService.tokenInsertExecutor = new TokenInsertExecutor.withClient(client200);

      Person lucille = new Person("Lucille", city:"Paris");
      Person matthieu = new Person("Matthieu", city:"Paris");
      Person gerard = new Person("Gérard", city:"Paris");
      lucille.lover = matthieu;
      matthieu.lover = gerard;
      gerard.lover = lucille;

      return neoService.insertNodeInDepth(lucille).then((_) {
        _logger.info(lucille);
        expect(lucille.id, equals(88));
        expect(matthieu.id, equals(89));
        expect(gerard.id, equals(90));
      });
    });
  });

  group('findNodeById', () {

    test('ok', () {

      NeoService neoService = new NeoService();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/json/findNodeById_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.tokenFindExecutor = new TokenFindExecutor.withClient(client200);

      return neoService.findNodeById(9, Person).then((node) {
        expect(node, equals(new Person("Antonio", city: "Madrid")));
      });
    });
  });

  group('findNodesByIds', () {

    test('ok', () {

      NeoService neoService = new NeoService();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/json/findNodesByIds_ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.tokenFindExecutor = new TokenFindExecutor.withClient(client200);

      return neoService.findNodesByIds([9, 11], Person).then((nodes) {
        expect(nodes, unorderedEquals([new Person("Antonio", city: "Madrid"), new Person("Lucille", city: "Paris")]));
      });
    });
  });

  group('findNodeAndRelationsById', () {

    test('ok', () {

      NeoService neoService = new NeoService();

      return neoService.findNodeAndRelationsById(11, Person).then((node) {
        Person lucille = node;
        expect(lucille.name, "Lucille");
        expect(lucille.city, "Paris");
        expect(lucille.eternalLovers, hasLength(2));
      });
    });
  });
}
