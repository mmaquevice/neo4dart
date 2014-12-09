part of neo4dart;

class NeoServiceUpdate {

  final _logger = new Logger("NeoServiceUpdate");

  BatchUpdateExecutor batchUpdateExecutor = new BatchUpdateExecutor();

  updateNode(Node node) async {
    return batchUpdateExecutor.updateNode(node);
  }

  updateNodes(Iterable<Node> nodes) async {
    return batchUpdateExecutor.updateNodes(nodes);
  }

  updateRelation(Relation relation) async {
    return batchUpdateExecutor.updateRelation(relation);
  }

  updateRelations(Iterable<Relation> relations) async {
    return batchUpdateExecutor.updateRelations(relations);
  }
}



