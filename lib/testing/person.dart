library neo4dart.testing.person;

import 'package:neo4dart/neo4dart.dart';
import 'package:neo4dart/testing/love.dart';

import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

@Node()
class Person {

  int id;

  @Data()
  String name;
  @Data()
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

  // TODO mma - test client get with id
  bool operator ==(o) => o is Person && o.name == name && o.city == city && new  IterableEquality().equals(o.eternalLovers, eternalLovers);

  int get hashCode => hash3(name.hashCode, city.hashCode, eternalLovers.hashCode);

  toString() => "Person $name is from $city.";

}
