part of neo4dart;

class Relationship {

  final String type;
  final Map data;
  final Direction direction;

  const Relationship(this.type, {this.data, this.direction: Direction.OUTGOING});
}
