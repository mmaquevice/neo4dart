library neo4dart.batch_token_test;

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

import 'package:neo4dart/testing/person.dart';
import 'package:neo4dart/testing/love.dart';
import 'dart:mirrors';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.neo_service_test");

//  group('batch_token toJson', () {
//
//    test('- json is well formated', () {
//      try {
//
//        NeoService neoService = new NeoService();
//
//        neoService.insertNode(new Person("Lucille", "Fleur"));
//        neoService.insertNode(new Person("Matthieu", "Voiture"));
//        neoService.insertNode(new Person("Catherine", "Maison"));
//
//        return neoService.insertNode(new Person("Jimmy", "Caca++")).then((ok) => expect(ok, equals(true)));
//
//
//      } catch(e, s) {
//        _logger.severe(e);
//        _logger.severe(s);
//      }
//    });
//
//  });

  group('convert to relationship', () {

    test('- relationship from node', () {
      try {

        NeoService neoService = new NeoService();

        Person lucille = new Person("Lucille", "Beaucoup");
        Person matthieu = new Person("Matthieu", "A la folie");
        Person gerard = new Person("Gérard", "Le dauphin");
        lucille.lover = matthieu;
        matthieu.lover = gerard;
        gerard.lover = lucille;

        neoService.insertNode(lucille);

      } catch(e, s) {
        _logger.severe(e);
        _logger.severe(s);
      }
    });

  });
//
//  group('convert to relationshipVia', () {
//
//    test('- relationship from node', () {
//      try {
//
//        NeoService neoService = new NeoService();
//
//        Person asterix = new Person("Asterix", "Tutu");
//        Person obelix = new Person("Obelix", "A la folie");
//        Person idefix = new Person("Idefix", "Nonos");
//
//        asterix.love = new Love(asterix, obelix, "crazy", "always");
//        obelix.love = new Love(obelix, idefix, "wouaaff", "romain");
//        idefix.love = new Love(idefix, asterix, "woufff wouff", "croquette");
//
//        neoService.insertNode(asterix);
//
//      } catch(e, s) {
//        _logger.severe(e);
//        _logger.severe(s);
//      }
//    });
//
//  });

//  group('Get by label and properties', () {
//
//    test('Type and properties', () {
//      try {
//        NeoService neoService = new NeoService();
//        neoService.findNodesByTypeAndProperties(Person, {"name":"Asterix"}).then((nodes) {
//          nodes.forEach((node){
//            Person person = node;
//            _logger.info(person.id);
//            _logger.info(person.toJson());
//          });
//        });
//
//      } catch(e, s) {
//        _logger.severe(e);
//        _logger.severe(s);
//      }
//    });
//
//    test('Only Type', () {
//      try {
//
//        NeoService neoService = new NeoService();
//        neoService.findNodesByType(Person).then((nodes) {
//          nodes.forEach((node){
//            Person person = node;
//            _logger.info(person.id);
//            _logger.info(person.toJson());
//          });
//        });
//
//      } catch(e, s) {
//        _logger.severe(e);
//        _logger.severe(s);
//      }
//    });
//
//  });

}
