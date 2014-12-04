library neo4dart.service.find.neo_service_update_test;

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.clearListeners();
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_service_update_test");

  group('updateNode', () {

    test('ok', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client200 = new MockClient((request) {
        return new http.Response('[{"from": "/node/10/properties"}]', 200);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client200);

      Person toto = new Person("Toto", city: "Blagoland");
      toto.id = 10;

      return neoService.updateNode(toto).then((totoUpdated) {
        expect(totoUpdated, equals(toto));
      });
    });

    test('error 500', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client500 = new MockClient((request) {
        return new http.Response("", 500);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client500);

      Person toto = new Person("Toto", city: "Blagoland");
      toto.id = 24260;

      return expect(neoService.updateNode(toto), throwsA(new isInstanceOf<String>()));
    });
  });

  group('updateNodes', () {

    test('ok', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client200 = new MockClient((request) {
        return new http.Response('[{"from": "/node/1/properties"}, {"from": "/node/2/properties"}]', 200);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client200);

      Person mickey = new Person("Mickey", city: "DisneyLand");
      mickey.id = 1;
      Person donald = new Person("Donald", city: "DonaldVille");
      donald.id = 2;

      return neoService.updateNodes([mickey, donald]).then((updatedNodes) {
        expect(updatedNodes, unorderedEquals([mickey, donald]));
      });
    });

    test('error 500', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client500 = new MockClient((request) {
        return new http.Response("", 500);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client500);

      Person mickey = new Person("Mickey", city: "DisneyLand");
      mickey.id = 1;
      Person donald = new Person("Donald", city: "DonaldVille");
      donald.id = 2;

      return expect(neoService.updateNodes([mickey, donald]), throwsA(new isInstanceOf<String>()));
    });
  });

  group('updateRelation', () {

    test('ok', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client200 = new MockClient((request) {
        return new http.Response('[{"from": "/relationship/1/properties"}]', 200);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client200);

      Love relation = new Love(new Person("Mickey"), new Person("Minnie"), "So so", "1 hour ago");
      relation.id = 1;

      return neoService.updateRelation(relation).then((relationUpdated) {
        expect(relationUpdated, equals(relation));
      });
    });

    test('error 500', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client500 = new MockClient((request) {
        return new http.Response("", 500);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client500);

      Love relation = new Love(new Person("Mickey"), new Person("Minnie"), "So so", "1 hour ago");
      relation.id = 1;

      return expect(neoService.updateRelation(relation), throwsA(new isInstanceOf<String>()));
    });
  });

  group('updateRelations', () {

    test('ok', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client200 = new MockClient((request) {
        return new http.Response('[{"from": "/relationship/1/properties"}, {"from": "/relationship/2/properties"}]', 200);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client200);

      Love relationMickey = new Love(new Person("Mickey"), new Person("Minnie"), "So so", "1 hour ago");
      relationMickey.id = 1;
      Love relationMinnie = new Love(new Person("Minnie"), new Person("Mickey"), "A lot more", "3 hours ago");
      relationMinnie.id = 2;

      return neoService.updateRelations([relationMickey, relationMinnie]).then((updatedRelations) {
        expect(updatedRelations, unorderedEquals([relationMickey, relationMinnie]));
      });
    });

    test('error 500', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client500 = new MockClient((request) {
        return new http.Response("", 500);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client500);

      Love relationMickey = new Love(new Person("Mickey"), new Person("Minnie"), "So so", "1 hour ago");
      relationMickey.id = 1;
      Love relationMinnie = new Love(new Person("Minnie"), new Person("Mickey"), "A lot more", "3 hours ago");
      relationMinnie.id = 2;

      return expect(neoService.updateRelations([relationMickey, relationMinnie]), throwsA(new isInstanceOf<String>()));
    });
  });
}
