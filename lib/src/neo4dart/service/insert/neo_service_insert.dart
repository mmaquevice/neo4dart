part of neo4dart;

class NeoServiceInsert {

  final _logger = new Logger("NeoServiceInsert");

  BatchInsertExecutor tokenInsertExecutor = new BatchInsertExecutor();
  BatchFindExecutor tokenFindExecutor = new BatchFindExecutor();

  insertNode(var node) async {
    return tokenInsertExecutor.insertNode(node, false);
  }

  insertNodeInDepth(var node) async {
    return tokenInsertExecutor.insertNode(node, true);
  }

  insertNodes(Iterable nodes) async {
    return tokenInsertExecutor.insertNodes(nodes, false);
  }

  insertNodesInDepth(Iterable nodes) async {
    return tokenInsertExecutor.insertNodes(nodes, true);
  }
}



