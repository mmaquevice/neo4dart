library neo4dart.testing.person;

import 'package:neo4dart/neo4dart.dart';
import 'package:neo4dart/testing/love.dart';

import 'package:quiver/core.dart';

class Person extends Node {

  String name;
  String language;

  @Relationship("loves", data: const {"since":"2010", "with": "passion"}, direction: Direction.OUTGOING)
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

  // TODO mma - test client get with id
  bool operator ==(o) => o is Person && o.name == name && o.language == language;
  int get hashCode => hash2(name.hashCode, language.hashCode);

}
