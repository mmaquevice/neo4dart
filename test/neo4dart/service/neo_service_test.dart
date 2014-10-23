library neo4dart.service.neo_service_test;

import 'dart:core';
import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';
import 'package:mock/mock.dart';
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import '../util/util.dart' as util;

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';
import 'dart:mirrors';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_service_test");

  group('insertNode', () {

    test('ok - with @Relationship', () {
      try {

        NeoService neoService = new NeoService();

        var client200 = new MockClient((request) {

          var responseBody = util.readFile('neo4dart/service/json/insertNode_Relationship.json');
          return new http.Response(responseBody, 200);
        });
        neoService.neoClientBatch = new NeoClientBatch.withClient(client200);

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
          expect(gerard.id, equals(90));
        });

      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

    test('ok - with Set of @Relationship', () {
      try {

        NeoService neoService = new NeoService();

        var client200 = new MockClient((request) {
          var responseBody = util.readFile('neo4dart/service/json/insertNode_Set_Relationship.json');
          return new http.Response(responseBody, 200);
        });
        neoService.neoClientBatch = new NeoClientBatch.withClient(client200);

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

      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

    test('ok - with @RelationshipVia', () {
      try {

        NeoService neoService = new NeoService();

        var client200 = new MockClient((request) {
          var responseBody = util.readFile('neo4dart/service/json/insertNode_RelationshipVia.json');
          return new http.Response(responseBody, 200);
        });
        neoService.neoClientBatch = new NeoClientBatch.withClient(client200);

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

      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });
  });
}
