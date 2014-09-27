library neo4dart.testing.person;

import 'package:neo4dart/neo4dart.dart';
import 'package:neo4dart/testing/love.dart';

class Person extends Node {

  String name;
  String language;

  @Relationship("loves", data: const {"since":"2010", "with": "passion"})
  Person lover;

  @RelationshipVia("lovesVia")
  Love love;

  Person(this.name, this.language, {this.lover}) : super();

  Map toJson() {
    Map map = new Map();
    map["name"] = name;
    map["language"] = language;
    return map;
  }


}
