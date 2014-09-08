library neo4dart.all_tests;

import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:neo4dart/neo4dart.dart';
import 'package:mock/mock.dart';
import 'dart:async';

import 'package:logging/logging.dart';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'dart:convert';

main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final _logger = new Logger("neo4dart.all_tests");

  group('rest', () {

    var client = new MockClient((request) {
      if (request.url.path != "/data.json") {
        return new Response("", 404);
      }
      return new Response(JSON.encode({
          'numbers': [1, 4, 15, 19, 214]
      }), 200, headers: {
          'content-type': 'application/json'
      });
    });

    test('should be assignable to CreateTimer', () {
      _logger.severe('turlututu');
      expect(toto(client), true);

    });
  });

}
