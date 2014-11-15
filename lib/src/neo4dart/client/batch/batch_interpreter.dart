part of neo4dart;

class BatchInterpreter {

  final _logger = new Logger("BatchInterpreter");

  List<AroundNodeResponse> convertResponse(var response) {

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
}
