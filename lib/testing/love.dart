library neo4dart.testing.love;

import 'package:neo4dart/neo4dart.dart';
import 'package:neo4dart/testing/person.dart';

import 'package:quiver/core.dart';

class Love extends Relation {

  @StartNode()
  Person personWhoLoves;
  @EndNode()
  Person personLoved;

  @Data()
  String howMuch;
  @Data()
  String since;

  Love(this.personWhoLoves, this.personLoved, this.howMuch, this.since);

  bool operator ==(o) => o is Love && o.howMuch == howMuch && o.since == since;

  int get hashCode => hash2(howMuch.hashCode, since.hashCode);
}
