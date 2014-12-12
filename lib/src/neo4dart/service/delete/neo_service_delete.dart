part of neo4dart;

class NeoServiceDelete {

  final _logger = new Logger("NeoServiceDelete");

  CypherDeleteExecutor cypherDeleteExecutor = new CypherDeleteExecutor();

  deleteNode(var node, {bool force: false}) async {
    return cypherDeleteExecutor.deleteNode(node, force: force);
  }

  deleteNodes(Iterable nodes, {bool force: false}) async {
    return cypherDeleteExecutor.deleteNodes(nodes, force: force);
  }

  deleteNodeById(int id, {bool force: false}) async {
    return cypherDeleteExecutor.deleteNodeById(id, force: force);
  }

  deleteNodesByIds(Iterable<int> ids, {bool force: false}) async {
    return cypherDeleteExecutor.deleteNodesByIds(ids, force: force);
  }

  deleteRelation(Relation relation) async {
    return cypherDeleteExecutor.deleteRelation(relation);
  }

  deleteRelations(Iterable<Relation> relations) async {
    return cypherDeleteExecutor.deleteRelations(relations);
  }

  deleteRelationById(int id) async {
    return cypherDeleteExecutor.deleteRelationById(id);
  }

  deleteRelationsByIds(Iterable<int> ids) async {
    return cypherDeleteExecutor.deleteRelationsByIds(ids);
  }
}
