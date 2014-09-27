library neo4dart.testing.love;

import 'package:neo4dart/neo4dart.dart';
import 'package:neo4dart/testing/person.dart';

class Love extends Relation {

  @StartNode()
  Person personWhoLoves;
  @EndNode()
  Person personLoved;

  String howMuch;
  String since;

  Love(this.personWhoLoves, this.personLoved, this.howMuch, this.since);

  Map toJson() {
    Map map = new Map();
    if(howMuch != null) {
      map["howMuch"] = howMuch;
    }
    if(since != null) {
      map["since"] = since;
    }
    return map;
  }
}
