part of neo4dart;


Node convertToNode(Type type, NodeResponse nodeResponse) {

  ClassMirror classMirror = reflectClass(type);
  List<String> parameters = _getConstructorParameters(type, false);
  Map<Symbol, dynamic> valuesByParameter = _getDataValuesFromParameters(parameters, nodeResponse.data);

  List<String> optionalParameters = _getConstructorParameters(type, true);
  Map<Symbol, dynamic> optionalValuesByParameter = _getDataValuesFromParameters(optionalParameters, nodeResponse.data);

  InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), new List.from(valuesByParameter.values), optionalValuesByParameter);
  instanceMirror.setField(new Symbol('id'), nodeResponse.idNode);
  return instanceMirror.reflectee;
}

List<String> _getConstructorParameters(Type type, bool optional) {

  List<String> parametersToReturn = new List();

  ClassMirror mirror = reflectClass(type);
  List<DeclarationMirror> constructors = new List.from(mirror.declarations.values.where((declare) {
    return declare is MethodMirror && declare.isConstructor;
  }));

  constructors.forEach((constructor) {
    if (constructor is MethodMirror) {
      List<ParameterMirror> parameters = constructor.parameters;
      parameters.forEach((parameter) {
        if (optional && parameter.isOptional || !optional && !parameter.isOptional) {
          parametersToReturn.add(MirrorSystem.getName(parameter.simpleName));
        }
      });
    }
  });

  return parametersToReturn;
}

Map<Symbol, dynamic> _getDataValuesFromParameters(List parameters, Map data) {

  Map<Symbol, dynamic> valueByParameter = new Map();

  parameters.forEach((parameter) {
    if (data.containsKey(parameter)) {
      valueByParameter[new Symbol(parameter)] = data[parameter];
    }
  });

  return valueByParameter;
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

Set<RelationshipWithNodes> _findRelationshipViaNodes(Node node) {

  Set<RelationshipWithNodes> relationshipWithNodes = new Set();

  Map<RelationshipVia, Iterable<Relation>> fieldsByRelationship = _findEntityByAnnotations(node, RelationshipVia);
  fieldsByRelationship.forEach((relationship, relations) {
    relations.forEach((relation) {
      if (relation != null) {
        Node startNode = _findNodesAnnotatedBy(StartNode, relation).first;
        Node endNode = _findNodesAnnotatedBy(EndNode, relation).first;
        relationshipWithNodes.add(new RelationshipWithNodes(startNode, new Relationship(relationship.type, data: relation.toJson()), endNode, initialRelationship: relation));
      }
    });
  });

  return relationshipWithNodes;
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
