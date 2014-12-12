part of neo4dart;

class BatchInsertBuilder {

  final _logger = new Logger("TokenInsertBuilder");

  Set<BatchToken> batchTokens = new Set();

  Set nodesWithRelationsConverted = new Set();
  Set nodesWithRelationsViaConverted = new Set();

  Set<BatchToken> addNodesToBatch(Iterable nodes) {

    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) {
      BatchToken token = addNodeToBatch(node);
      if(token != null) {
        tokens.add(addNodeToBatch(node));
      }
    });
    return tokens;
  }

  BatchToken addNodeToBatch(var node) {

    _logger.info("Converting node ${node} to token...");

    BatchToken token = findTokenFromNode(node);
    if (token == null && node.id == null) {
      token = new BatchToken.createNodeToken(node, id: _findIdNotUsed());
      batchTokens.add(token);
      BatchToken tokenForLabel = new BatchToken.createLabelToken(node, token.id, id: _findIdNotUsed());
      batchTokens.add(tokenForLabel);
      _logger.info("Node ${node} has been inserted in batch via token ${token}.");
    } else {
      _logger.info("Node ${node} is already present in batch.");
    }
    return token;
  }

  BatchToken findTokenFromNode(var node) {
    if (node == null) {
      return null;
    }

    BatchToken token = _findTokenWith(findFieldsAnnotatedValueByKey(node, Data));
    return token;
  }

  BatchToken _findTokenWith(Map body) {
    if (batchTokens == null) {
      return null;
    }

    BatchToken found;
    batchTokens.forEach((batchToken) {
      if (batchToken != null) {
        if (new DeepCollectionEquality.unordered().equals(batchToken.body, body)) {
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

  Set<BatchToken> addNodesAndRelationsToBatch(Iterable nodes, bool inDepth) {
    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) {
      tokens.addAll(addNodeAndRelationsToBatch(node, inDepth));
    });
    tokens.removeWhere((token) => token == null);
    return tokens;
  }

  Set<BatchToken> addNodeAndRelationsToBatch(var node, bool inDepth) {

    _logger.info("Converting node ${node} to token...");

    Set<BatchToken> tokens = new Set();
    Set<RelationshipWithNodes> relations = _findRelationshipNodes(node);
    relations.forEach((relation) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation));

      if (inDepth) {
        if (node != relation.startNode && !nodesWithRelationsConverted.contains(relation.startNode)) {
          nodesWithRelationsConverted.add(relation.startNode);
          tokens.addAll(addNodeAndRelationsToBatch(relation.startNode, inDepth));
        }
        if (node != relation.endNode && !nodesWithRelationsConverted.contains(relation.endNode)) {
          nodesWithRelationsConverted.add(relation.endNode);
          tokens.addAll(addNodeAndRelationsToBatch(relation.endNode, inDepth));
        }
      }
    });

    nodesWithRelationsConverted.add(node);
    return tokens;
  }

  Set<BatchToken> _convertRelationToBatchTokens(RelationshipWithNodes relation) {

    Set<BatchToken> tokens = new Set();

    BatchToken startToken = findTokenFromNode(relation.startNode);
    if (startToken == null) {
      startToken = addNodeToBatch(relation.startNode);
      if(startToken != null) {
        tokens.add(startToken);
      }
    }

    BatchToken endToken = findTokenFromNode(relation.endNode);
    if (endToken == null) {
      endToken = addNodeToBatch(relation.endNode);
      if(endToken != null) {
        tokens.add(endToken);
      }
    }

    if(relation.initialRelationship == null || relation.initialRelationship.id == null) {

      var token = new BatchToken.createRelationToken(relation, startToken, endToken, id: _findIdNotUsed());
      batchTokens.add(token);

      tokens.add(token);
    }

    return tokens;
  }

  Set<BatchToken> addNodesAndRelationsViaToBatch(Iterable nodes, bool inDepth) {
    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) {
      tokens.addAll(addNodeAndRelationsViaToBatch(node, inDepth));
    });
    return tokens;
  }

  Set<BatchToken> addNodeAndRelationsViaToBatch(var node, bool inDepth) {

    _logger.info("Converting node ${node} to token...");
    Set<BatchToken> tokens = new Set();
    Set<RelationshipWithNodes> relations = _findRelationshipViaNodes(node);
    relations.forEach((relation) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation));

      if (inDepth) {
        if (node != relation.startNode && !nodesWithRelationsViaConverted.contains(relation.startNode)) {
          nodesWithRelationsViaConverted.add(relation.startNode);
          tokens.addAll(addNodeAndRelationsViaToBatch(relation.startNode, inDepth));
        }
        if (node != relation.endNode && !nodesWithRelationsViaConverted.contains(relation.endNode)) {
          nodesWithRelationsViaConverted.add(relation.endNode);
          tokens.addAll(addNodeAndRelationsViaToBatch(relation.endNode, inDepth));
        }
      }
    });

    nodesWithRelationsViaConverted.add(node);
    return tokens;
  }
}
