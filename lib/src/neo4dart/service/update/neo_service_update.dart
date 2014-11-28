part of neo4dart;

class NeoServiceUpdate {

  final _logger = new Logger("NeoServiceUpdate");

  BatchUpdateExecutor batchUpdateExecutor = new BatchUpdateExecutor();

  Future updateNode(Node node) {
    return batchUpdateExecutor.updateNode(node);
  }

  Future updateNodes(Iterable<Node> nodes) {
    return batchUpdateExecutor.updateNodes(nodes);
  }

  Future updateRelation(Relation relation) {
    return batchUpdateExecutor.updateRelation(relation);
  }

  Future updateRelations(Iterable<Relation> relations) {
    return batchUpdateExecutor.updateRelations(relations);
  }
}



