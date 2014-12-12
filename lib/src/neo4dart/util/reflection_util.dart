part of neo4dart;


Relation convertToRelation(Type type, RelationResponse relationResponse) {

  ClassMirror classMirror = reflectClass(type);
  List<String> parameters = _getConstructorParameters(type, false);
  Map<Symbol, dynamic> valuesByParameter = _getDataValuesFromParameters(parameters, relationResponse.data);

  List<String> optionalParameters = _getConstructorParameters(type, true);
  Map<Symbol, dynamic> optionalValuesByParameter = _getDataValuesFromParameters(optionalParameters, relationResponse.data);

  List positionalArguments = [];
  for (String parameter in parameters) {
    Symbol paramSymbol = new Symbol(parameter);
    if (valuesByParameter.containsKey(paramSymbol)) {
      positionalArguments.add(valuesByParameter[paramSymbol]);
    } else {
      positionalArguments.add(null);
    }
  }

  InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), positionalArguments, optionalValuesByParameter);
  instanceMirror.setField(new Symbol('id'), relationResponse.idRelation);
  return instanceMirror.reflectee;
}

dynamic convertToNode(Type type, NodeResponse nodeResponse) {

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
        var valueOfAnnotatedObject = instanceMirror.getField(key).reflectee;

        if (valueOfAnnotatedObject is Iterable) {
          fieldsByRelationship[value.reflectee] = valueOfAnnotatedObject;
        } else {
          if(valueOfAnnotatedObject != null) {
            fieldsByRelationship[value.reflectee] = [valueOfAnnotatedObject];
          }
        }
      }
    });
  });
  return fieldsByRelationship;
}

Set _findNodesAnnotatedBy(Type type, Object instance) {

  Set nodes = new Set();

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

Set<Type> _findTypesAnnotatedBy(Type type, Object instance) {

  Set<Type> types = new Set();

  InstanceMirror instanceMirror = reflect(instance);

  instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror declaration) {
    declaration.metadata.forEach((InstanceMirror value) {
      if (declaration is VariableMirror && value.reflectee.runtimeType == type) {
        types.add(declaration.type.reflectedType);
      }
    });
  });

  return types;
}

Set<RelationshipWithNodes> _findRelationshipViaNodes(var node) {

  Set<RelationshipWithNodes> relationshipWithNodes = new Set();

  Map<RelationshipVia, Iterable<Relation>> fieldsByRelationship = _findEntityByAnnotations(node, RelationshipVia);
  fieldsByRelationship.forEach((relationship, relations) {
    relations.forEach((relation) {
      if (relation != null) {
        var startNode = _findNodesAnnotatedBy(StartNode, relation).first;
        var endNode = _findNodesAnnotatedBy(EndNode, relation).first;
        relationshipWithNodes.add(new RelationshipWithNodes(startNode, new Relationship(relationship.type, data: findFieldsAnnotatedValueByKey(relation, Data)), endNode, initialRelationship: relation));
      }
    });
  });

  return relationshipWithNodes;
}

Set<RelationshipWithNodes> _findRelationshipNodes(var node) {

  Set<RelationshipWithNodes> relations = new Set();

  Map<Relationship, Iterable> nodesByRelationship = _findEntityByAnnotations(node, Relationship);
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

VariableMirror _findRelationField(Type typeNode, String typeRelation) {

  ClassMirror mirror = reflectClass(typeNode);

  VariableMirror field = null;
  mirror.declarations.forEach((Symbol key, DeclarationMirror declaration) {
    declaration.metadata.forEach((InstanceMirror value) {
      if (value.reflectee.runtimeType == RelationshipVia) {
        RelationshipVia relationshipVia = value.reflectee;
        if (declaration is VariableMirror && relationshipVia.type == typeRelation) {
          field = declaration;
        }
      } else if (value.reflectee.runtimeType == Relationship) {
        Relationship relationship = value.reflectee;
        if (declaration is VariableMirror && relationship.type == typeRelation) {
          field = declaration;
        }
      }
    });
  });
  return field;
}

dynamic _convertToNode(Type type, Map dataNode, int idNode) {

  ClassMirror classMirror = reflectClass(type);
  List<String> parameters = _getConstructorParameters(type, false);
  Map<Symbol, dynamic> valuesByParameter = _getDataValuesFromParameters(parameters, dataNode);

  List<String> optionalParameters = _getConstructorParameters(type, true);
  Map<Symbol, dynamic> optionalValuesByParameter = _getDataValuesFromParameters(optionalParameters, dataNode);

  InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(''), new List.from(valuesByParameter.values), optionalValuesByParameter);
  instanceMirror.setField(new Symbol('id'), idNode);
  return instanceMirror.reflectee;
}

int _extractNodeId(String self) {
  String idNode = self.split('/').last;
  if (idNode.isEmpty) {
    throw "Node id cannot be retrieved from : ${self}.";
  }
  return int.parse(idNode);
}

Map findFieldsAnnotatedValueByKey(Object objectAnnotated, Type type) {

  var valueByKey = {};

  InstanceMirror instanceMirror = reflect(objectAnnotated);
  instanceMirror.type.declarations.forEach((Symbol key, DeclarationMirror value) {
    value.metadata.forEach((InstanceMirror value) {
      if (value.reflectee.runtimeType == type) {
        var valueOfAnnotatedObject = instanceMirror.getField(key).reflectee;
        if(valueOfAnnotatedObject != null) {
          valueByKey[MirrorSystem.getName(key)] = valueOfAnnotatedObject;
        }
      }
    });
  });
  return valueByKey;
}

bool isNode(dynamic object) {
  return _isAnnotatedBy(object, Node);
}

bool _isAnnotatedBy(dynamic object, Type type) {

  ClassMirror classMirror = null;
  if(object is ClassMirror || object.type.isSubclassOf(reflectClass(ClassMirror))) {
    classMirror = object;
  } else {
    classMirror = reflectClass(object.runtimeType);
  }

  for(var instanceMirror in classMirror.metadata) {
    if (instanceMirror.reflectee.runtimeType == type) {
      return true;
    }
  }
  return false;
}
