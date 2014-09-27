part of neo4dart;

class BatchTokens {

  final _logger = new Logger("BatchTokens");

  Set<BatchToken> batchTokens = new Set();

  Set<Node> nodesWithRelationsConverted = new Set();

  BatchToken addNodeToBatch(Node node) {

    _logger.info("Converting node ${node} to token...");

    BatchToken token = _findTokenFromNode(node);
    if (token == null) {
      token = new BatchToken("POST", "/node", node.toJson(), id : _findIdNotUsed());
      batchTokens.add(token);
      BatchToken tokenForLabel =  new BatchToken("POST", "{${token.id}}/labels", node.labels, id: _findIdNotUsed());
      batchTokens.add(tokenForLabel);
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
    Set<RelationshipWithNodes> relations = _findRelationshipNodes(node);
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

  Set<BatchToken> _convertRelationToBatchTokens(RelationshipWithNodes relation) {

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

  Set<RelationshipWithNodes> _findRelationshipNodes(Node node) {

    Set<RelationshipWithNodes> relations = new Set();

    Map<Symbol, Relationship> fieldsByRelationship = _findRelationshipSymbols(node);
    fieldsByRelationship.forEach((symbol, relationship) {
      Node toNode = reflect(node).getField(symbol).reflectee;
      if (toNode != null) {
        relations.add(new RelationshipWithNodes(node, relationship, toNode));
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

    Set<BatchToken> addNodeAndRelationsViaToBatch(Node node) {

      _logger.info("Converting node ${node} to token...");
      Set<BatchToken> tokens = new Set();
      Set<RelationshipWithNodes> relations = _findRelationshipViaNodes(node);
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

  Set<RelationshipWithNodes> _findRelationshipViaNodes(Node node) {

    Set<RelationshipWithNodes> relations = new Set();

    Map<Symbol, RelationshipVia> fieldsByRelationship = _findRelationshipViaSymbols(node);
    fieldsByRelationship.forEach((symbol, relationship) {
      Relation relation = reflect(node).getField(symbol).reflectee;
      if (relation != null) {
        Node startNode = _findNodesAnnotatedBy(StartNode, relation).first;
        Node endNode = _findNodesAnnotatedBy(EndNode, relation).first;
        relations.add(new RelationshipWithNodes(startNode, new Relationship(relationship.type, data: relation.toJson()), endNode));
      }
    });

    return relations;
  }

  Set<Node> _findNodesAnnotatedBy(Type type, Object instance) {

    Set<Node> nodes = new Set();

    Set<Symbol> symbols = _findSymbolsAnnotatedBy(type, instance);

    symbols.forEach((symbol) {
      nodes.add(reflect(instance).getField(symbol).reflectee);
    });

    return nodes;
  }

  Set<Symbol> _findSymbolsAnnotatedBy(Type type, Object instance) {

    Set<Symbol> symbols = new Set();

    InstanceMirror instanceMirror = reflect(instance);

    instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror value) {
      value.metadata.forEach((InstanceMirror value) {
        if (value.reflectee.runtimeType == type) {
          symbols.add(key);
        }
      });
    });

    return symbols;
  }

  Map<Symbol, RelationshipVia> _findRelationshipViaSymbols(Node node) {

    var fieldsByRelationship = <Symbol, RelationshipVia>{
    };

    InstanceMirror instanceMirror = reflect(node);
    instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror value) {
      value.metadata.forEach((InstanceMirror value) {
        if (value.reflectee is RelationshipVia) {
          fieldsByRelationship[key] = value.reflectee;
        }
      });
    });
    return fieldsByRelationship;
  }

}
