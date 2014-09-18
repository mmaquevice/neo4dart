library neo4dart.testing.person;

import 'package:neo4dart/neo4dart.dart';

class Person extends Node {

  String name;
  String language;

  Person(this.name, this.language);

  Map toJson() {
    Map map = new Map();
    map["name"] = name;
    map["language"] = language;
    return map;
  }


}