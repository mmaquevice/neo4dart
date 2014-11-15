part of neo4dart;

class NeoServiceInsert {

  final _logger = new Logger("NeoServiceInsert");

  BatchInsertExecutor tokenInsertExecutor = new BatchInsertExecutor();
  BatchFindExecutor tokenFindExecutor = new BatchFindExecutor();

  Future insertNode(Node node) {
    return tokenInsertExecutor.insertNode(node, false);
  }

  Future insertNodeInDepth(Node node) {
    return tokenInsertExecutor.insertNode(node, true);
  }

  Future insertNodes(Iterable<Node> nodes) {
    return tokenInsertExecutor.insertNodes(nodes, false);
  }

  Future insertNodesInDepth(Iterable<Node> nodes) {
    return tokenInsertExecutor.insertNodes(nodes, true);
  }
}



