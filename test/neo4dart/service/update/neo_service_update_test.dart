library neo4dart.service.find.neo_service_update_test;

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

  final _logger = new Logger("neo4dart.neo_service_update_test");

  group('updateNode', () {

//    test('ok', () {
//
//      NeoServiceUpdate neoService = new NeoServiceUpdate();
//
////      var client200 = new MockClient((request) {
////        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodeById_ok.json');
////        return new http.Response(responseBody, 200);
////      });
////      neoService.tokenFindExecutor = new BatchFindExecutor.withClient(client200);
//
//      Person toto = new Person("Toto", city: "Blagoland");
//      toto.id = 24260;
//
//      return neoService.updateNode(toto);
//    });

    test('error 500', () {

      NeoServiceUpdate neoService = new NeoServiceUpdate();

      var client500 = new MockClient((request) {
//        var responseBody = util.readFile('test/neo4dart/service/find/json/findNodeById_ok.json');
        return new http.Response("", 500);
      });
      neoService.batchUpdateExecutor = new BatchUpdateExecutor.withClient(client500);

      Person toto = new Person("Toto", city: "Blagoland");
      toto.id = 24260;

      return expect(neoService.updateNode(toto), throwsA(new isInstanceOf<String>()));
    });
  });
}
