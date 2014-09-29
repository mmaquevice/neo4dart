part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClient neoClient = new NeoClient();

  Future insertNode(Node node) {

    BatchTokens batch = new BatchTokens();
    batch.addNodeToBatch(node);
    batch.addNodeAndRelationsToBatch(node);
    batch.addNodeAndRelationsViaToBatch(node);

    return neoClient.executeBatch(batch.batchTokens);
  }

  Future findNodesByType(Type type) {

    ClassMirror classMirror = reflectClass(type);
    Symbol symbol = classMirror.simpleName;
    String simpleName = MirrorSystem.getName(symbol);

    return findNodesByLabel(simpleName);
  }

  Future findNodesByLabel(String label) {

    return neoClient.executeGetByLabel(label);
  }

  Future findNodesByTypeAndProperties(Type type, Map properties) {

    ClassMirror classMirror = reflectClass(type);
    Symbol symbol = classMirror.simpleName;
    String simpleName = MirrorSystem.getName(symbol);

    return findNodesByLabelAndProperties(simpleName, properties);
  }

  Future findNodesByLabelAndProperties(String label, Map properties) {

    return neoClient.executeGetByLabelAndProperties(label, properties);
  }

}



