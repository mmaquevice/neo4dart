library neo4dart;

import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:logging/logging.dart';

final _logger = new Logger("neo4dart");

bool toto(var client) {



  List jsonData = [{
      "method" : "POST",
      "to" : "/node",
      "id" : 0,
      "body" : {
          "name" : "bob"
      }
  }, {
      "method" : "POST",
      "to" : "/node",
      "id" : 1,
      "body" : {
          "age" : 12
      }
  }, {
      "method" : "POST",
      "to" : "{0}/relationships",
      "id" : 3,
      "body" : {
          "to" : "{1}",
          "data" : {
              "since" : "2010"
          },
          "type" : "KNOWS"
      }
  }, {
      "method" : "POST",
      "to" : "/index/relationship/my_rels",
      "id" : 4,
      "body" : {
          "key" : "since",
          "value" : "2010",
          "uri" : "{3}"
      }
  }];

  _logger.info(jsonData);

  client.post("http://localhost:7474/db/data/batch", body : JSON.encode(jsonData)).then((response) {
    _logger.info("Response status : ${response.statusCode}");
    _logger.info("Response body : ${response.body}");
  }).catchError((error, stackTrace) {
    _logger.info(error);
    _logger.info(stackTrace);
  });

  return true;
}
