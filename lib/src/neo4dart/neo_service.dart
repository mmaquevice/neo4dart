part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClientGet neoClientGet = new NeoClientGet();

  TokenInsertExecutor tokenInsertExecutor = new TokenInsertExecutor();
  TokenFindExecutor tokenFindExecutor = new TokenFindExecutor();

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

  Future findNodes(Type type, {Map properties}) {

    if(properties == null || properties.length == 0) {
      return neoClientGet.findNodesByType(type);
    }

    return neoClientGet.findNodesByTypeAndProperties(type, properties);
  }

  Future findNodeById(int id, Type type) {
    return tokenFindExecutor.findNodeById(id, type);
  }

  Future findNodesByIds(Iterable<int> ids, Type type) {
    return tokenFindExecutor.findNodesByIds(ids, type);
  }

  Future findNodeAndRelationsById(int id, Type type) {
    return tokenFindExecutor.findNodeAndRelationsById(id, type);
  }

  Future findAllNodeAndRelationsById(int id, Type type) {
    return tokenFindExecutor.findAllNodeAndRelationsById(id, type);
  }
}



