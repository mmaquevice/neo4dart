library neo4dart.testing.person;

import 'package:neo4dart/neo4dart.dart';
import 'package:neo4dart/testing/love.dart';

import 'package:quiver/core.dart';

class Person extends Node {

  String name;
  String city;

  @Relationship("loves", data: const {
      "since":"2010", "with": "passion"
  }, direction: Direction.OUTGOING)
  Person lover;

  @RelationshipVia("lovesVia")
  Love love;

  @Relationship("works with")
  List<Person> coworkers;

  @RelationshipVia("secretly loves")
  Set<Love> eternalLovers = new Set();

  Person(this.name, {this.city, this.lover}) : super();

  Map toJson() {
    Map map = new Map();
    map["name"] = name;
    if (city != null) {
      map["city"] = city;
    }
    return map;
  }

  // TODO mma - test client get with id
  bool operator ==(o) => o is Person && o.name == name && o.city == city;

  int get hashCode => hash2(name.hashCode, city.hashCode);

  toString() => "Person $name is from $city.";

}
