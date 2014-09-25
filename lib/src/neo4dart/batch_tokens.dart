part of neo4dart;

class BatchTokens {

  final _logger = new Logger("BatchTokens");

  Set<BatchToken> batchTokens = new Set();

  Set<Node> nodesWithRelationsConverted = new Set();

  BatchToken addNodeToBatch(Node node) {

    _logger.info("Converting node ${node} to token...");

    BatchToken token = _findTokenFromNode(node);
    if (token == null) {
      token = new BatchToken.withId(_findIdNotUsed(), "POST", "/node", node.toJson());
      batchTokens.add(token);
      _logger.info("Node ${node} has been inserted in batch via token ${token}.");
    } else {
      _logger.info("Node ${node} is already present in batch.");
    }
    return token;
  }


  BatchToken _findTokenFromNode(Node node) {
    if (node == null) {
      return null;
    }

    BatchToken token = _findTokenWith(node.toJson());
    return token;
  }

  BatchToken _findTokenWith(Map body) {
    if (batchTokens == null) {
      return null;
    }

    BatchToken found;
    batchTokens.forEach((batchToken) {
      if (batchToken != null) {
        // TODO mma - find a way to correctly verify equality
        if ('${batchToken.body}' == '${body}') {
          found = batchToken;
        }
      }
    });

    return found;
  }

  int _findIdNotUsed() {
    int max = -1;
    batchTokens.forEach((batchToken) {
      if (batchToken != null) {
        if (batchToken.id != null) {
          if (batchToken.id > max) {
            max = batchToken.id;
          }
        }
      }
    });
    return max + 1;
  }

  Set<BatchToken> addNodeAndRelationsToBatch(Node node) {

    _logger.info("Converting node ${node} to token...");

    Set<BatchToken> tokens = new Set();
    Set<Relation> relations = _findRelationshipNodes(node);
    relations.forEach((relation) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation));
      if (node != relation.startNode && !nodesWithRelationsConverted.contains(relation.startNode)) {
        nodesWithRelationsConverted.add(relation.startNode);
        tokens.addAll(addNodeAndRelationsToBatch(relation.startNode));
      }
      if (node != relation.endNode && !nodesWithRelationsConverted.contains(relation.endNode)) {
        nodesWithRelationsConverted.add(relation.endNode);
        tokens.addAll(addNodeAndRelationsToBatch(relation.endNode));
      }
      nodesWithRelationsConverted.add(node);
    });
    return tokens;
  }

  Set<BatchToken> _convertRelationToBatchTokens(Relation relation) {

    Set<BatchToken> tokens = new Set();

    BatchToken startToken = _findTokenFromNode(relation.startNode);
    if (startToken == null) {
      startToken = addNodeToBatch(relation.startNode);
      tokens.add(startToken);
    }

    BatchToken endToken = _findTokenFromNode(relation.endNode);
    if (endToken == null) {
      endToken = addNodeToBatch(relation.endNode);
      tokens.add(endToken);
    }

    var token = new BatchToken("POST", "{${startToken.id}}/relationships", {
        'to' : '{${endToken.id}}', 'data' : relation.relationship.data, 'type' : '${relation.relationship.type}'
    });
    batchTokens.add(token);

    tokens.add(token);

    return tokens;
  }

  Set<Relation> _findRelationshipNodes(Node node) {

    Set<Relation> relations = new Set();

    Map<Symbol, Relationship> fieldsByRelationship = _findRelationshipSymbols(node);
    fieldsByRelationship.forEach((symbol, relationship) {
      Node toNode = reflect(node).getField(symbol).reflectee;
      if (toNode != null) {
        relations.add(new Relation(node, relationship, toNode));
      }
    });

    return relations;
  }

  Map<Symbol, Relationship> _findRelationshipSymbols(Node node) {

    var fieldsByRelationship = <Symbol, Relationship>{
    };

    InstanceMirror instanceMirror = reflect(node);
    instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror value) {
      value.metadata.forEach((InstanceMirror value) {
        if (value.reflectee is Relationship) {
          fieldsByRelationship[key] = value.reflectee;
        }
      });
    });

    return fieldsByRelationship;
  }

}
