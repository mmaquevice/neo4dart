part of neo4dart;

class NeoServiceDelete {

  final _logger = new Logger("NeoServiceDelete");

  CypherDeleteExecutor cypherDeleteExecutor = new CypherDeleteExecutor();

  Future deleteNode(Node node, {bool force: false}) {
    return cypherDeleteExecutor.deleteNode(node, force: force);
  }

  Future deleteNodes(Iterable<Node> nodes, {bool force: false}) {
    return cypherDeleteExecutor.deleteNodes(nodes, force: force);
  }

  Future deleteNodeById(int id, {bool force: false}) {
    return cypherDeleteExecutor.deleteNodeById(id, force: force);
  }

  Future deleteNodesByIds(Iterable<int> ids, {bool force: false}) {
    return cypherDeleteExecutor.deleteNodesByIds(ids, force: force);
  }

  Future deleteRelation(Relation relation) {
    return cypherDeleteExecutor.deleteRelation(relation);
  }

  Future deleteRelations(Iterable<Relation> relations) {
    return cypherDeleteExecutor.deleteRelations(relations);
  }

  Future deleteRelationById(int id) {
    return cypherDeleteExecutor.deleteRelationById(id);
  }

  Future deleteRelationsByIds(Iterable<int> ids) {
    return cypherDeleteExecutor.deleteRelationsByIds(ids);
  }
}



