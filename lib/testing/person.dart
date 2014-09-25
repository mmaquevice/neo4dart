library neo4dart.testing.person;

import 'package:neo4dart/neo4dart.dart';

class Person extends Node {

  String name;
  String language;

  @Relationship("loves", data: const {"since":"2010", "with": "passion"})
  Person lover;

  Person(this.name, this.language);

  Person.withLover(this.name, this.language, this.lover);

  Map toJson() {
    Map map = new Map();
    map["name"] = name;
    map["language"] = language;
    return map;
  }


}
