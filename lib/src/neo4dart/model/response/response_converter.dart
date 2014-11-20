part of neo4dart;

class ResponseConverter {

  Map<int, Node> nodesWithRelationsById = {};

  Map<int, Node> nodesWithoutRelationsById = {};

  Map<int, Node> nodesInProgressById = {};

  Node convertResponsesToNodeWithRelations(int id, Map<int, AroundNodeResponse> aroundNodeById, {Type typeNode}) {

    if (nodesWithRelationsById.containsKey(id)) {
      return nodesWithRelationsById[id];
    }

    if (nodesInProgressById.containsKey(id)) {
      return nodesInProgressById[id];
    }

    if(!aroundNodeById.containsKey(id)) {
      return null;
    }

    AroundNodeResponse aroundNode = aroundNodeById[id];
    Node node = _retrieveNodeWithAroundNodeResponseData(id, aroundNode, typeNode: typeNode);
    nodesInProgressById[id] = node;

    aroundNode.relations.forEach((relationResponse) {
      if(aroundNodeById.containsKey(relationResponse.idStartNode) && aroundNodeById.containsKey(relationResponse.idEndNode)) {
        _bindResponseToNode(node, relationResponse, aroundNodeById[relationResponse.idStartNode], aroundNodeById[relationResponse.idEndNode]);

        if(id != relationResponse.idStartNode) {
          convertResponsesToNodeWithRelations(relationResponse.idStartNode, aroundNodeById);
        }

        if(id != relationResponse.idEndNode) {
          convertResponsesToNodeWithRelations(relationResponse.idEndNode, aroundNodeById);
        }
      }
    });

    nodesWithRelationsById[id] = node;
    return node;
  }

  Node _retrieveNodeWithAroundNodeResponseData(int idNode, AroundNodeResponse aroundNode, {Type typeNode}) {

    if (nodesWithoutRelationsById.containsKey(idNode)) {
      return nodesWithoutRelationsById[idNode];
    }

    if(typeNode == null) {
      throw 'Node type is  null for node <$idNode>.';
    }

    Node node = _convertToNode(typeNode, aroundNode.node.data, aroundNode.node.idNode);
    nodesWithoutRelationsById[idNode] = node;
    return node;
  }

  Node _bindResponseToNode(Node node, RelationResponse relationResponse, AroundNodeResponse startNode, AroundNodeResponse endNode) {

    VariableMirror nodeFieldForRelation = _findRelationField(reflect(node).type.reflectedType, relationResponse.type);
    if (nodeFieldForRelation.type.isSubtypeOf(reflectType(Iterable))) {

      if (nodeFieldForRelation.type.isAssignableTo(reflectType(Set)) || nodeFieldForRelation.type.isAssignableTo(reflectType(List))) {
        // TODO mma : check if typeNeoEntity is really a neo entity
        Type typeNeoEntity = nodeFieldForRelation.type.typeArguments.map((t) => t.reflectedType).first;
        NeoEntity neoEntity = _convertToNeoEntity(node, reflectType(typeNeoEntity), relationResponse,  startNode,  endNode);
        if(neoEntity != null) {
          _addNeoEntityToCollectionField(node, nodeFieldForRelation, neoEntity);
        }
      }
    } else {
      NeoEntity neoEntity = _convertToNeoEntity(node, nodeFieldForRelation.type, relationResponse,  startNode,  endNode);
      reflect(node).setField(nodeFieldForRelation.simpleName, neoEntity);
    }

    return node;
  }

  NeoEntity _convertToNeoEntity(Node node, TypeMirror typeNeoEntity, RelationResponse relationResponse, AroundNodeResponse startNode, AroundNodeResponse endNode) {
    if (typeNeoEntity.isSubtypeOf(reflectType(Node))) {
      // TODO mma : check Direction
      if (node.id != relationResponse.idEndNode) {
        return _retrieveNodeWithAroundNodeResponseData(relationResponse.idEndNode, endNode, typeNode: typeNeoEntity.reflectedType);
      }
    }

    if (typeNeoEntity.isSubtypeOf(reflectType(Relation))) {
      return _createRelationWithNodes(typeNeoEntity.reflectedType, relationResponse, startNode, endNode);
    }

    return null;
  }

  _addNeoEntityToCollectionField(Node node, VariableMirror field, NeoEntity neoEntity) {
    var nodeFieldForRelationInstance = reflect(node).getField(field.simpleName).reflectee;
    if (nodeFieldForRelationInstance == null) {
      if (field.type.isAssignableTo(reflectType(Set))) {
        Set set = new Set.from([neoEntity]);
        reflect(node).setField(field.simpleName, set);
      }

      if (field.type.isAssignableTo(reflectType(List))) {
        reflect(node).setField(field.simpleName, [neoEntity]);
      }
    } else {
      nodeFieldForRelationInstance.add(neoEntity);
    }
  }

  Relation _createRelationWithNodes(Type typeRelation, RelationResponse relationResponse, AroundNodeResponse startAroundNodeResponse, AroundNodeResponse endAroundNodeResponse) {

    Relation relation = convertToRelation(typeRelation, relationResponse);

    Node startNode = _retrieveNodeWithAroundNodeResponseData(relationResponse.idStartNode, startAroundNodeResponse, typeNode : _findTypesAnnotatedBy(StartNode, relation).first);
    Node endNode = _retrieveNodeWithAroundNodeResponseData(relationResponse.idEndNode, endAroundNodeResponse, typeNode : _findTypesAnnotatedBy(EndNode, relation).first);

    InstanceMirror relationMirror = reflect(relation);
    relationMirror.setField(_findSymbolsAnnotatedBy(StartNode, relation).first, startNode);
    relationMirror.setField(_findSymbolsAnnotatedBy(EndNode, relation).first, endNode);

    return relation;
  }

}
