library neo4dart.service.find.neo_service_delete_test;

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

  final _logger = new Logger("neo4dart.neo_service_delete_test");

  group('deleteNode', () {

//    solo_test('to delete', () {
//
//      NeoServiceInsert neoService = new NeoServiceInsert();
//
//
//      Person toto = new Person("Toto", city: "Blagoland");
//      Person mickey = new Person("Mickey", city: "MickeyLand");
//      Person minnie = new Person("Minnie", city: "MickeyLand");
//      toto.coworkers = [mickey];
//      mickey.coworkers = [minnie];
//
//      return neoService.insertNodeInDepth(toto);
//    });
//
    test('ok', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person toto = new Person("Toto", city: "Blagoland");
      toto.id = 13;

      return neoService.deleteNode(toto);
    });

    test('error - constraint violation', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/constraint_violation.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person toto = new Person("Toto", city: "Blagoland");
      toto.id = 13;

      return expect(neoService.deleteNode(toto), throwsA(new isInstanceOf<String>()));
    });
  });

  group('deleteNodes', () {

    test('ok', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person mickey = new Person("Mickey", city: "Mickeyville");
      mickey.id = 85;
      Person minnie = new Person("Minnie", city: "Mickeyville");
      minnie.id = 86;

      return neoService.deleteNodes([mickey, minnie], force: true);
    });

    test('error - constraint violation', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/constraint_violation.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person mickey = new Person("Mickey", city: "Mickeyville");
      mickey.id = 85;
      Person minnie = new Person("Minnie", city: "Mickeyville");
      minnie.id = 86;

      return expect(neoService.deleteNodes([mickey, minnie]), throwsA(new isInstanceOf<String>()));
    });
  });

  group('deleteRelation', () {

    test('ok', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person mickey = new Person("Mickey", city: "Mickeyville");
      mickey.id = 85;
      Person minnie = new Person("Minnie", city: "Mickeyville");
      minnie.id = 86;
      Love love = new Love(mickey, minnie, 'how mouse', 'walt disney');
      love.id = 4;

      return neoService.deleteRelation(love);
    });

    test('error - constraint violation', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/constraint_violation.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person mickey = new Person("Mickey", city: "Mickeyville");
      mickey.id = 85;
      Person minnie = new Person("Minnie", city: "Mickeyville");
      minnie.id = 86;
      Love love = new Love(mickey, minnie, 'how mouse', 'walt disney');
      love.id = 4;

      return expect(neoService.deleteRelation(love), throwsA(new isInstanceOf<String>()));
    });
  });

  group('deleteRelations', () {

    test('ok', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/ok.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person mickey = new Person("Mickey", city: "Mickeyville");
      mickey.id = 85;
      Person minnie = new Person("Minnie", city: "Mickeyville");
      minnie.id = 86;
      Love loveMickey = new Love(mickey, minnie, 'how mouse', 'walt disney');
      loveMickey.id = 27;
      Love loveMinnie = new Love(minnie, mickey, 'how mouse', 'walt disney');
      loveMinnie.id = 0;

      return neoService.deleteRelations([loveMickey, loveMinnie]);
    });

    test('error - constraint violation', () {

      NeoServiceDelete neoService = new NeoServiceDelete();

      var client200 = new MockClient((request) {
        var responseBody = util.readFile('test/neo4dart/service/delete/json/constraint_violation.json');
        return new http.Response(responseBody, 200);
      });
      neoService.cypherDeleteExecutor = new CypherDeleteExecutor.withClient(client200);

      Person mickey = new Person("Mickey", city: "Mickeyville");
      mickey.id = 85;
      Person minnie = new Person("Minnie", city: "Mickeyville");
      minnie.id = 86;
      Love loveMickey = new Love(mickey, minnie, 'how mouse', 'walt disney');
      loveMickey.id = 4;
      Love loveMinnie = new Love(minnie, mickey, 'how mouse', 'walt disney');
      loveMinnie.id = 5;

      return expect(neoService.deleteRelations([loveMickey, loveMinnie]), throwsA(new isInstanceOf<String>()));
    });
  });

}
