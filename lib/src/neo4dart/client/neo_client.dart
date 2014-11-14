part of neo4dart;

class NeoClient {

  final _logger = new Logger("NeoClient");

  http.Client client;

  NeoClient() {
    client = new http.Client();
  }

  NeoClient.withClient(this.client);

  Future executeBatch(Set<BatchToken> batchTokens) {

    List data = _convertBatchTokensToJsonArray(batchTokens);
    _logger.info(data);

    return client.post("http://localhost:7474/db/data/batch", body : '${data}');
  }

  List _convertBatchTokensToJsonArray(Set<BatchToken> batchTokens) {
    return batchTokens.map((batchToken) {
      _logger.info(batchToken.body);
      return new JsonEncoder().convert(batchToken);
    }).toList();
  }

  List<AroundNodeResponse> _convertResponse(var response) {

    List<AroundNodeResponse> aroundNodes = new List();

    List<NeoResponse> neoResponses = _convertResponseToEntities(response);

    Multimap responsesById = new Multimap();
    neoResponses.forEach((r) {
      if (r is LabelResponse) {
        responsesById.add(r.idNode, r);
      } else if (r is NodeResponse) {
        responsesById.add(r.idNode, r);
      } else if (r is RelationResponse) {
        responsesById.add(r.idStartNode, r);
        responsesById.add(r.idEndNode, r);
      }
    });

    responsesById.forEachKey((k, v) {
      Multimap dataByType = new Multimap();
      v.forEach((response) {
        if (response is LabelResponse) {
          dataByType.add(NeoType.LABEL, response);
        } else if (response is NodeResponse) {
          dataByType.add(NeoType.NODE, response);
        } else if (response is RelationResponse) {
          dataByType.add(NeoType.RELATIONSHIP, response);
        }
      });

      LabelResponse label = null;
      if (dataByType.containsKey(NeoType.LABEL)) {
        label = dataByType[NeoType.LABEL].first;
      }

      NodeResponse node = null;
      if (dataByType.containsKey(NeoType.NODE)) {
        node = dataByType[NeoType.NODE].first;
      }

      aroundNodes.add(new AroundNodeResponse(label, node, dataByType[NeoType.RELATIONSHIP]));
    });

    return aroundNodes;
  }

  List<NeoResponse> _convertResponseToEntities(var response) {
    _logger.info("Response status : ${response.statusCode}");

    if (response.statusCode == 200) {
      _logger.info("Response body : ${response.body}");

      var jsonArray = new JsonDecoder().convert(response.body);
      List<NeoResponse> responseEntities = new List();
      for (var json in jsonArray) {
        responseEntities.addAll(_convertToResponseEntity(json));
      }
      return responseEntities;
    } else {
      _logger.severe('Error requesting neo4j : status ${response.statusCode} - ${response.body}');
      throw "Error requesting neo4j : status ${response.statusCode}";
    }
  }

  List<NeoResponse> _convertToResponseEntity(Map json) {

    if (!json.containsKey('body')) {
      return [];
    }

    List<NeoResponse> responses = new List();

    var body = json['body'];
    if (body is List) {
      body.forEach((bodyElement) {
        if (bodyElement is Map) {
          responses.add(_convertResponseWithBodyMap(bodyElement, json['id']));
        } else if (bodyElement is String) {

          String from = json['from'];
          List<String> split = from.split('/');
          int neoId = int.parse(split[split.length - 2]);
          responses.add(new LabelResponse(neoId, [bodyElement], requestId: json['id']));
        }
      });
    } else if (body is Map) {
      responses.add(_convertResponseWithBodyMap(body, json['id']));
    } else {
      throw "Neo response cannot be handled.";
    }

    return responses;
  }

  NeoResponse _convertResponseWithBodyMap(Map body, int requestId) {

    String self = body['self'];
    NeoType neoType = _extractNeoType(self);
    int neoId = int.parse(self.split('/').last);

    Map data = null;
    if (body.containsKey('data')) {
      data = body['data'];
    }

    if (neoType == NeoType.NODE) {
      return new NodeResponse(neoId, data, requestId: requestId);
    }

    if (neoType == NeoType.RELATIONSHIP) {
      int startNodeId = int.parse(body['start'].split('/').last);
      int endNodeId = int.parse(body['end'].split('/').last);
      String type = body['type'];

      return new RelationResponse(neoId, startNodeId, endNodeId, type, data, requestId: requestId);
    }

    throw "Neo response cannot be handled.";
  }

  NeoType _extractNeoType(String self) {

    List<String> split = self.split('/');
    String type = split[split.length - 2];

    switch (type) {
      case 'node' :
        return NeoType.NODE;
      case 'relationship' :
        return NeoType.RELATIONSHIP;
      case 'labels' :
        return NeoType.LABEL;
      default:
        throw 'Response type unknown : $type.';
    }
  }

  VariableMirror _findRelationField(Type typeNode, String typeRelation) {

    ClassMirror mirror = reflectClass(typeNode);

    VariableMirror field = null;
    mirror.declarations.forEach((Symbol key, DeclarationMirror declaration) {
      declaration.metadata.forEach((InstanceMirror value) {
        if (value.reflectee.runtimeType == RelationshipVia) {
          RelationshipVia relationshipVia = value.reflectee;
          if (declaration is VariableMirror && relationshipVia.type == typeRelation) {
            _logger.info(declaration.type.reflectedType);

            _logger.info(declaration.type.typeArguments.map((t) => t.qualifiedName));
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

  Node _convertToNode(Type type, Map dataNode, int idNode) {

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

  Future executeCypher(String query) {

    Map map = {
        "statements" : [{
            "statement" : query
        }]
    };
    return client.post("http://localhost:7474/db/data/transaction/commit", body : new JsonEncoder().convert(map), headers : {
        'Content-Type' : 'application/json'
    });
  }

  Set<int> _extractNodeIdsFromCypherResponse(var cypherResponse) {
    _logger.info("Response status : ${cypherResponse.statusCode}");

    if (cypherResponse.statusCode == 200) {
      _logger.info("Response body : ${cypherResponse.body}");

      Set<int> nodeIds = new Set();

      var jsonObject = new JsonDecoder().convert(cypherResponse.body);
      List results = jsonObject['results'];
      var result = results.first;
      List data = result['data'];

      for (var json in data) {
        List nodes = json['row'].first;
        nodeIds.addAll(nodes);
      }
      return nodeIds;
    } else {
      _logger.severe('Error requesting neo4j : status ${cypherResponse.statusCode} - ${cypherResponse.body}');
      throw "Error requesting neo4j : status ${cypherResponse.statusCode}";
    }
  }

  Set<int> _extractRelationshipIdsFromCypherResponse(var cypherResponse) {

    _logger.info("Response status : ${cypherResponse.statusCode}");

    if (cypherResponse.statusCode == 200) {
      _logger.info("Response body : ${cypherResponse.body}");

      Set<int> relationshipIds = new Set();

      var jsonObject = new JsonDecoder().convert(cypherResponse.body);
      List results = jsonObject['results'];
      var result = results.first;
      List data = result['data'];

      for (var json in data) {
        List rows = json['row'];
        List nodes = rows.last;
        relationshipIds.addAll(nodes);
      }
      return relationshipIds;
    } else {
      _logger.severe('Error requesting neo4j : status ${cypherResponse.statusCode} - ${cypherResponse.body}');
      throw "Error requesting neo4j : status ${cypherResponse.statusCode}";
    }
  }
}
