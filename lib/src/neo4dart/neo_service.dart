part of neo4dart;

class NeoService {

  final _logger = new Logger("NeoService");

  NeoClient neoClient = new NeoClient();

  Future insertNode(Node node) {

    BatchTokens batch = new BatchTokens();
    _addNodeToBatch(node, batch);
    _addNodeAndRelationsToBatch(node, batch);

    return neoClient.executeBatch(batch.batchTokens);
  }

  BatchToken _addNodeToBatch(Node node, BatchTokens batch) {

    _logger.info("Converting node ${node} to token...");

    BatchToken token = batch.findTokenFromNode(node);
    if (token == null) {
      token = new BatchToken.withId(batch.findIdNotUsed(), "POST", "/node", node.toJson());
      batch.batchTokens.add(token);
      _logger.info("Node ${node} has been inserted in batch via token ${token}.");
    } else {
      _logger.info("Node ${node} is already present in batch.");
    }
    return token;
  }

  Set<BatchToken> _addNodeAndRelationsToBatch(Node node, BatchTokens batch) {

    Set<BatchToken> tokens = new Set();
    Set<Relation> relations = _findRelationsFrom(node);
    relations.forEach((relation) {
      tokens.addAll(_convertRelationToBatchTokens(relation, batch));
      if(node != relation.startNode && !batch.nodesWithRelationsConverted.contains(relation.startNode)) {
        batch.nodesWithRelationsConverted.add(relation.startNode);
        tokens.addAll(_addNodeAndRelationsToBatch(relation.startNode, batch));
      }
      if(node != relation.endNode && !batch.nodesWithRelationsConverted.contains(relation.endNode)) {
        batch.nodesWithRelationsConverted.add(relation.endNode);
        tokens.addAll(_addNodeAndRelationsToBatch(relation.endNode, batch));
      }
      batch.nodesWithRelationsConverted.add(node);
    });
    return tokens;
  }

  Set<BatchToken> _convertRelationToBatchTokens(Relation relation, BatchTokens batch) {

    Set<BatchToken> tokens = new Set();

    BatchToken startToken = batch.findTokenFromNode(relation.startNode);
    if (startToken == null) {
      startToken = _addNodeToBatch(relation.startNode, batch);
      tokens.add(startToken);
    }

    BatchToken endToken = batch.findTokenFromNode(relation.endNode);
    if (endToken == null) {
      endToken = _addNodeToBatch(relation.endNode, batch);
      tokens.add(endToken);
    }

    var token = new BatchToken("POST", "{${startToken.id}}/relationships", {
        'to' : '{${endToken.id}}', 'data' : {
            'since' : '2010'
        }, 'type' : 'loves'
    });
    batch.batchTokens.add(token);

    tokens.add(token);

    return tokens;
  }

  Set<Relation> _findRelationsFrom(Node node) {

    Set<Relation> relations = new Set();
    Set<Node> nodes = _findRelationshipNodes(node);

    nodes.forEach((endNode) {
      if (endNode != null) {
        relations.add(new Relation(node, endNode));
      }
    });

    return relations;
  }

  Set<Node> _findRelationshipNodes(Node node) {

    Set<Node> nodes = new Set();

    Set<Symbol> symbols = _findRelationshipSymbols(node);
    symbols.forEach((symbol) {
      nodes.add(reflect(node).getField(symbol).reflectee);
    });

    return nodes;
  }

  Set<Symbol> _findRelationshipSymbols(Node node) {

    Set<Symbol> symbols = new Set();

    InstanceMirror instanceMirror = reflect(node);
    instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror value) {
      value.metadata.forEach((InstanceMirror value) {
        if (value.reflectee is Relationship) {
          symbols.add(key);
        }
      });
    });

    return symbols;
  }
}



