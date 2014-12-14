part of neo4dart;

class BatchInsertBuilder {

  final _logger = new Logger("TokenInsertBuilder");

  Set<BatchToken> _batchTokens = new Set();

  Set _nodesWithRelationsConverted = new Set();
  Set _nodesWithRelationsViaConverted = new Set();

  Set<BatchToken> buildTokens(Iterable nodes, {bool inDepth: false}) {
    _initBuilder();

    _addNodesToBatch(nodes);
    _addNodesAndRelationsToBatch(nodes, inDepth);
    _addNodesAndRelationsViaToBatch(nodes, inDepth);

    return _batchTokens;
  }

  _initBuilder() {
    _batchTokens = new Set();
    _nodesWithRelationsConverted = new Set();
    _nodesWithRelationsViaConverted = new Set();
  }

  Set<BatchToken> _addNodesToBatch(Iterable nodes) {

    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) {
      BatchToken token = _addNodeToBatch(node);
      if(token != null) {
        tokens.add(_addNodeToBatch(node));
      }
    });
    return tokens;
  }

  BatchToken _addNodeToBatch(var node) {

    _logger.info("Converting node ${node} to token...");

    BatchToken token = _findTokenFromNode(node);
    if (token == null && node.id == null) {
      token = new BatchToken.createNodeToken(node, id: _findIdNotUsed());
      _batchTokens.add(token);
      BatchToken tokenForLabel = new BatchToken.createLabelToken(node, token.id, id: _findIdNotUsed());
      _batchTokens.add(tokenForLabel);
      _logger.info("Node ${node} has been inserted in batch via token ${token}.");
    } else {
      _logger.info("Node ${node} is already present in batch.");
    }
    return token;
  }

  BatchToken _findTokenFromNode(var node) {
    if (node == null) {
      return null;
    }

    BatchToken token = _findTokenWith(findFieldsAnnotatedValueByKey(node, Data));
    return token;
  }

  BatchToken _findTokenWith(Map body) {
    if (_batchTokens == null) {
      return null;
    }

    for(var batchToken in _batchTokens) {
      if (batchToken != null) {
        if (new DeepCollectionEquality.unordered().equals(batchToken.body, body)) {
          return batchToken;
        }
      }
    }

    return null;
  }

  int _findIdNotUsed() {
    int max = -1;
    for(var batchToken in _batchTokens) {
      if (batchToken != null) {
        if (batchToken.id != null) {
          if (batchToken.id > max) {
            max = batchToken.id;
          }
        }
      }
    }
    return max + 1;
  }

  Set<BatchToken> _addNodesAndRelationsToBatch(Iterable nodes, bool inDepth) {
    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) {
      tokens.addAll(_addNodeAndRelationsToBatch(node, inDepth));
    });
    tokens.removeWhere((token) => token == null);
    return tokens;
  }

  Set<BatchToken> _addNodeAndRelationsToBatch(var node, bool inDepth) {

    _logger.info("Converting node ${node} to token...");

    Set<BatchToken> tokens = new Set();
    Set<RelationshipWithNodes> relations = _findRelationshipNodes(node);
    relations.forEach((relation) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation));

      if (inDepth) {
        if (node != relation.startNode && !_nodesWithRelationsConverted.contains(relation.startNode)) {
          _nodesWithRelationsConverted.add(relation.startNode);
          tokens.addAll(_addNodeAndRelationsToBatch(relation.startNode, inDepth));
        }
        if (node != relation.endNode && !_nodesWithRelationsConverted.contains(relation.endNode)) {
          _nodesWithRelationsConverted.add(relation.endNode);
          tokens.addAll(_addNodeAndRelationsToBatch(relation.endNode, inDepth));
        }
      }
    });

    _nodesWithRelationsConverted.add(node);
    return tokens;
  }

  Set<BatchToken> _convertRelationToBatchTokens(RelationshipWithNodes relation) {

    Set<BatchToken> tokens = new Set();

    BatchToken startToken = _findTokenFromNode(relation.startNode);
    if (startToken == null) {
      startToken = _addNodeToBatch(relation.startNode);
      if(startToken != null) {
        tokens.add(startToken);
      }
    }

    BatchToken endToken = _findTokenFromNode(relation.endNode);
    if (endToken == null) {
      endToken = _addNodeToBatch(relation.endNode);
      if(endToken != null) {
        tokens.add(endToken);
      }
    }

    if(relation.initialRelationship == null || relation.initialRelationship.id == null) {

      var token = new BatchToken.createRelationToken(relation, startToken, endToken, id: _findIdNotUsed());
      _batchTokens.add(token);

      tokens.add(token);
    }

    return tokens;
  }

  Set<BatchToken> _addNodesAndRelationsViaToBatch(Iterable nodes, bool inDepth) {
    Set<BatchToken> tokens = new Set();
    nodes.forEach((node) {
      tokens.addAll(_addNodeAndRelationsViaToBatch(node, inDepth));
    });
    return tokens;
  }

  Set<BatchToken> _addNodeAndRelationsViaToBatch(var node, bool inDepth) {

    _logger.info("Converting node ${node} to token...");
    Set<BatchToken> tokens = new Set();
    Set<RelationshipWithNodes> relations = _findRelationshipViaNodes(node);
    relations.forEach((relation) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation));

      if (inDepth) {
        if (node != relation.startNode && !_nodesWithRelationsViaConverted.contains(relation.startNode)) {
          _nodesWithRelationsViaConverted.add(relation.startNode);
          tokens.addAll(_addNodeAndRelationsViaToBatch(relation.startNode, inDepth));
        }
        if (node != relation.endNode && !_nodesWithRelationsViaConverted.contains(relation.endNode)) {
          _nodesWithRelationsViaConverted.add(relation.endNode);
          tokens.addAll(_addNodeAndRelationsViaToBatch(relation.endNode, inDepth));
        }
      }
    });

    _nodesWithRelationsViaConverted.add(node);
    return tokens;
  }
}
