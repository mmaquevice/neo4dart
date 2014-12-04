library neo4dart.service.find.neo_service_delete_test;

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

  final _logger = new Logger("neo4dart.neo_service_delete_test");

  group('deleteNode', () {

//    test('to delete', () {
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

      return neoService.deleteNode(toto, Person);
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

      return expect(neoService.deleteNode(toto, Person), throwsA(new isInstanceOf<String>()));
    });
  });
}
