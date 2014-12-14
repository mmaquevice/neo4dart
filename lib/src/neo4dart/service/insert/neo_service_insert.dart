part of neo4dart;

class NeoServiceInsert {

  final _logger = new Logger("NeoServiceInsert");

  BatchInsertExecutor tokenInsertExecutor = new BatchInsertExecutor();

  insertNode(var node, {bool inDepth: false}) async {
    return tokenInsertExecutor.insertNode(node, inDepth: inDepth);
  }

  insertNodes(Iterable nodes, {bool inDepth: false}) async {
    return tokenInsertExecutor.insertNodes(nodes, inDepth: inDepth);
  }
}



