part of neo4dart;

class NeoServiceDelete {

  final _logger = new Logger("NeoServiceDelete");

  CypherDeleteExecutor cypherDeleteExecutor = new CypherDeleteExecutor();

  Future deleteNode(Node node, Type type, {bool force: false}) {
    return cypherDeleteExecutor.deleteNode(node, type, force: force);
  }

  Future deleteNodes(Iterable<Node> nodes) {
    return cypherDeleteExecutor.deleteNodes(nodes);
  }

  Future deleteRelation(Relation relation) {
    return cypherDeleteExecutor.deleteRelation(relation);
  }

  Future deleteRelations(Iterable<Relation> relations) {
    return cypherDeleteExecutor.deleteRelations(relations);
  }
}



