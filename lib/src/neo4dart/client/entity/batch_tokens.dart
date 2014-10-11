part of neo4dart;

class BatchTokens {

  final _logger = new Logger("BatchTokens");

  Set<BatchToken> batchTokens = new Set();

  Set<Node> nodesWithRelationsConverted = new Set();
  Set<Node> nodesWithRelationsViaConverted = new Set();

  BatchToken addNodeToBatch(Node node) {

    _logger.info("Converting node ${node} to token...");

    BatchToken token = _findTokenFromNode(node);
    if (token == null) {
      token = new BatchToken("POST", "/node", node.toJson(), id : _findIdNotUsed());
      batchTokens.add(token);
      BatchToken tokenForLabel = new BatchToken("POST", "{${token.id}}/labels", node.labels, id: _findIdNotUsed());
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

    Map<Relationship, Iterable<Node>> nodesByRelationship = _findEntityByAnnotations(node, Relationship);
    nodesByRelationship.forEach((relationship, toNodes) {
      toNodes.forEach((toNode) {
        if (toNode != null) {
          if (relationship.direction == Direction.OUTGOING) {
            relations.add(new RelationshipWithNodes(node, relationship, toNode));
          } else if (relationship.direction == Direction.INGOING) {
            relations.add(new RelationshipWithNodes(toNode, relationship, node));
          } else if (relationship.direction == Direction.BOTH) {
            relations.add(new RelationshipWithNodes(node, relationship, toNode));
            relations.add(new RelationshipWithNodes(toNode, relationship, node));
          }
        }
      });
    });

    return relations;
  }

  Set<BatchToken> addNodeAndRelationsViaToBatch(Node node) {

    _logger.info("Converting node ${node} to token...");
    Set<BatchToken> tokens = new Set();
    Set<RelationshipWithNodes> relations = _findRelationshipViaNodes(node);
    relations.forEach((relation) {
      _logger.info("Converting relation ${relation} to token...");
      tokens.addAll(_convertRelationToBatchTokens(relation));
      if (node != relation.startNode && !nodesWithRelationsViaConverted.contains(relation.startNode)) {
        nodesWithRelationsViaConverted.add(relation.startNode);
        tokens.addAll(addNodeAndRelationsViaToBatch(relation.startNode));
      }
      if (node != relation.endNode && !nodesWithRelationsViaConverted.contains(relation.endNode)) {
        nodesWithRelationsViaConverted.add(relation.endNode);
        tokens.addAll(addNodeAndRelationsViaToBatch(relation.endNode));
      }
      nodesWithRelationsViaConverted.add(node);
    });
    return tokens;
  }

  Set<RelationshipWithNodes> _findRelationshipViaNodes(Node node) {

    Set<RelationshipWithNodes> relationshipWithNodes = new Set();

    Map<RelationshipVia, Iterable<Relation>> fieldsByRelationship = _findEntityByAnnotations(node, RelationshipVia);
    fieldsByRelationship.forEach((relationship, relations) {
      relations.forEach((relation) {
        if (relation != null) {
          Node startNode = _findNodesAnnotatedBy(StartNode, relation).first;
          Node endNode = _findNodesAnnotatedBy(EndNode, relation).first;
          relationshipWithNodes.add(new RelationshipWithNodes(startNode, new Relationship(relationship.type, data: relation.toJson()), endNode));
        }
      });
    });

    return relationshipWithNodes;
  }

  Map _findEntityByAnnotations(Object objectAnnotated, Type type) {

    var fieldsByRelationship = {
    };

    InstanceMirror instanceMirror = reflect(objectAnnotated);
    instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror value) {
      value.metadata.forEach((InstanceMirror value) {
        if (value.reflectee.runtimeType == type) {
          if (instanceMirror.getField(key).reflectee is Iterable) {
            fieldsByRelationship[value.reflectee] = instanceMirror.getField(key).reflectee;
          } else {
            fieldsByRelationship[value.reflectee] = [instanceMirror.getField(key).reflectee];
          }
        }
      });
    });
    return fieldsByRelationship;
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

}
