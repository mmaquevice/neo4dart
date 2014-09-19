part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClient neoClient = new NeoClient();

  Future insertNode(Node node) {
    BatchTokens batch = new BatchTokens();
    BatchToken batchToken = convertNodeToBatchToken(node, batch);
    batch.batchTokens.add(batchToken);

    Set<Relation> relations = findRelationsFrom(node);
    relations.forEach((relation) {
      batch.batchTokens.addAll(convertRelationToBatchTokens(relation, batch));
    });

    return neoClient.executeBatch(batch.batchTokens);
  }

  BatchToken convertNodeToBatchToken(Node node, BatchTokens batch) {

    int id = batch.findTokenIdFromNode(node);
    if(id == null) {
      return new BatchToken.withId(batch.findIdNotUsed(), "POST", "/node", node.toJson());
    }
    return null;
  }

  Set<BatchToken> convertRelationToBatchTokens(Relation relation, BatchTokens batch) {

    Set<BatchToken> tokens = new Set();

    int id = batch.findIdNotUsed();

    int startId = batch.findTokenIdFromNode(relation.startNode);
    if(startId == null) {
      BatchToken startToken = convertNodeToBatchToken(relation.startNode, batch);
      tokens.add(startToken);
      startId = startToken.id;
    }

    int endId = batch.findTokenIdFromNode(relation.endNode);
    if(endId == null) {
      BatchToken stopToken =  convertNodeToBatchToken(relation.endNode, batch);
      tokens.add(stopToken);
      stopToken.id = stopToken.id + 1;
      endId = stopToken.id;
    }

    tokens.add(new BatchToken("POST", "{${startId}}/relationships", {'to' : '{${endId}}', 'data' : {'since' : '2010'}, 'type' : 'loves'}));

    return tokens;
  }

  Set<Relation> findRelationsFrom(Node node) {

    Set<Relation> relations = new Set();

    Set<Node> nodes = findRelationshipNodes(node);

    nodes.forEach((endNode) {
      if(endNode != null) {
      relations.add(new Relation(node, endNode));
    }
    });

    return relations;
  }

  Set<Node> findRelationshipNodes(Node node) {

    Set<Node> nodes = new Set();

    Set<Symbol> symbols = findRelationshipSymbols(node);
    symbols.forEach((symbol) {
      nodes.add(reflect(node).getField(symbol).reflectee);
    });

    return nodes;
  }

  Set<Symbol> findRelationshipSymbols(Node node) {

    Set<Symbol> symbols = new Set();

    InstanceMirror instanceMirror = reflect(node);
    instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror value) {
      value.metadata.forEach((InstanceMirror value) {
        if(value.reflectee is Relationship) {
          symbols.add(key);
        }
      });
    });

    return symbols;
  }
}



