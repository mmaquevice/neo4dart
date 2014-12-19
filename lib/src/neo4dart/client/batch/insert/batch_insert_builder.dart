part of neo4dart;

class BatchInsertBuilder {

  final _logger = new Logger("TokenInsertBuilder");

  Set<BatchToken> _batchTokens = new Set();

  Set _nodesWithRelationsConverted = new Set();
  Set _nodesWithRelationsViaConverted = new Set();

  Set<BatchToken> buildTokens(Iterable nodes, {bool inDepth: false}) {
    _initBuilder();
    _addNodesToBatch(nodes, inDepth);
    return _batchTokens;
  }

  _initBuilder() {
    _batchTokens = new Set();
    _nodesWithRelationsConverted = new Set();
    _nodesWithRelationsViaConverted = new Set();
  }

  Set<BatchToken> _addNodesToBatch(Iterable nodes, bool inDepth) {

    Set<BatchToken> tokens = new Set();
    for (var node in nodes) {
      BatchToken token = _findTokenFromNode(node);
      if (token == null) {
        tokens.addAll(_addNodeToBatch(node, inDepth, firstCall: true));
      }
    }
    return tokens;
  }

  Set<BatchToken> _addNodeToBatch(var node, bool inDepth, {bool firstCall: false}) {

    _logger.info("Converting node ${node} to token...");

    Set<BatchToken> tokens = new Set();

    BatchToken token = _findTokenFromNode(node);
    if (token == null && node.id == null) {
      token = new BatchToken.createNodeToken(node, id: _findIdNotUsed());
      tokens.add(token);
      _batchTokens.add(token);
      BatchToken tokenForLabel = new BatchToken.createLabelToken(node, token.id, id: _findIdNotUsed());
      tokens.add(tokenForLabel);
      _batchTokens.add(tokenForLabel);
      _logger.info("Node ${node} has been inserted in batch via token ${token}.");
    } else {
      _logger.info("Node ${node} is already present in batch.");
    }

    if (firstCall || (!firstCall && inDepth)) {
      if (!_nodesWithRelationsConverted.contains(node)) {
        _nodesWithRelationsConverted.add(node);
        tokens.addAll(_addNodeAndRelationsToBatch(node, inDepth));
      }

      if (!_nodesWithRelationsViaConverted.contains(node)) {
        _nodesWithRelationsViaConverted.add(node);
        tokens.addAll(_addNodeAndRelationsViaToBatch(node, inDepth));
      }
    }

    return tokens;
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

    for (var batchToken in _batchTokens) {
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
    for (var batchToken in _batchTokens) {
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
    for (var relation in relations) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation, inDepth));

      if (inDepth) {
        if (node != relation.startNode && !_nodesWithRelationsConverted.contains(relation.startNode)) {
          tokens.addAll([_addNodeToBatch(relation.startNode, inDepth)]);
        }
        if (node != relation.endNode && !_nodesWithRelationsConverted.contains(relation.endNode)) {
          tokens.addAll([_addNodeToBatch(relation.endNode, inDepth)]);
        }
      }
    }

    return tokens;
  }

  Set<BatchToken> _convertRelationToBatchTokens(RelationshipWithNodes relation, bool inDepth) {

    Set<BatchToken> tokens = new Set();

    BatchToken startToken = _findTokenFromNode(relation.startNode);
    if (startToken == null) {
      _addNodeToBatch(relation.startNode, inDepth);
      startToken = _findTokenFromNode(relation.startNode);
      if (startToken != null) {
        tokens.add(startToken);
      }
    }

    BatchToken endToken = _findTokenFromNode(relation.endNode);
    if (endToken == null) {
      _addNodeToBatch(relation.endNode, inDepth);
      endToken = _findTokenFromNode(relation.endNode);
      if (endToken != null) {
        tokens.add(endToken);
      }
    }

    if (relation.initialRelationship == null || relation.initialRelationship.id == null) {

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

    for (var relation in relations) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation, inDepth));

      if (inDepth) {
        if (node != relation.startNode && !_nodesWithRelationsViaConverted.contains(relation.startNode)) {
          tokens.addAll([_addNodeToBatch(relation.startNode, inDepth)]);
        }
        if (node != relation.endNode && !_nodesWithRelationsViaConverted.contains(relation.endNode)) {
          tokens.addAll([_addNodeToBatch(relation.endNode, inDepth)]);
        }
      }
    }

    return tokens;
  }
}
