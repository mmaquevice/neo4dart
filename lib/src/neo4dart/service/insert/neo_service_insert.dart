part of neo4dart;

class NeoServiceInsert {

  final _logger = new Logger("NeoServiceInsert");

  BatchInsertExecutor tokenInsertExecutor = new BatchInsertExecutor();
  BatchFindExecutor tokenFindExecutor = new BatchFindExecutor();

  insertNode(Node node) async {
    return tokenInsertExecutor.insertNode(node, false);
  }

  insertNodeInDepth(Node node) async {
    return tokenInsertExecutor.insertNode(node, true);
  }

  insertNodes(Iterable<Node> nodes) async {
    return tokenInsertExecutor.insertNodes(nodes, false);
  }

  insertNodesInDepth(Iterable<Node> nodes) async {
    return tokenInsertExecutor.insertNodes(nodes, true);
  }
}



