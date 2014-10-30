part of neo4dart;

class TokenFindExecutor extends NeoClient {

  final _logger = new Logger("TokenFindExecutor");

  http.Client _client;

  TokenFindExecutor() {
    _client = new http.Client();
  }

  TokenFindExecutor.withClient(this._client);

  Future executeBatch(Set<BatchToken> batchTokens) {

    List data = _convertBatchTokensToJsonArray(batchTokens);
    _logger.info(data);

    return _client.post("http://localhost:7474/db/data/batch", body : '${data}');
  }

  List _convertBatchTokensToJsonArray(Set<BatchToken> batchTokens) {
    return batchTokens.map((batchToken) {
      _logger.info(batchToken.body);
      return new JsonEncoder().convert(batchToken);
    }).toList();
  }

  Future findNodeById(int id) {

    return executeBatch(new TokenFindBuilder().addNodeToBatch(id)).then((response) => _convertResponse(response));
  }

  Node _convertResponse(response) {

    List<ResponseEntity> responseEntities = _convertResponseToNodes(response);

    Multimap responsesById = new Multimap();
    responseEntities.forEach((r) {
      responsesById.add(r.neoId, r);
    });

    return null;

  }

  // TODO mma - to factorize with batch
  List<ResponseEntity> _convertResponseToNodes(var response) {
    _logger.info("Response status : ${response.statusCode}");

    if (response.statusCode == 200) {
      _logger.info("Response body : ${response.body}");

      var jsonArray = new JsonDecoder().convert(response.body);
      List<ResponseEntity> responseEntities = new List();
      for (var json in jsonArray) {
        responseEntities.add(_convertToResponseEntity(json));
      }
      return responseEntities;
    } else {
      _logger.severe('Error requesting neo4j : status ${response.statusCode} - ${response.body}');
      throw "Error requesting neo4j : status ${response.statusCode}";
    }
  }

  // TODO mma - to factorize with batch
  ResponseEntity _convertToResponseEntity(Map json) {

    if(json['body'] is Map) {
      return _convertResponseWithBodyMap(json);
    }

    if (json['body'] is List) {
      return _convertResponseWithBodyList(json);
    }

    throw "Neo response cannot be handled.";
  }

  ResponseEntity _convertResponseWithBodyMap(Map json) {
    int id = json['id'];

    NeoType neoType;
    int neoId;
    Map data;
    Map body = json['body'];

    if (body.containsKey('self')) {
      String self = body['self'];
      neoId = self != null ? int.parse(self.split('/').last) : null;
      neoType = self != null ? _extractNeoType(self) : null;
    }

    if (body.containsKey('data')) {
      data = body['data'];
    }

    return new ResponseEntity(id, neoId, neoType, data);
  }

  ResponseEntity _convertResponseWithBodyList(Map json) {
    int id = json['id'];

    String from = json['from'];
    List<String> split = from.split('/');
    int neoId = int.parse(split[split.length-2]);

    NeoType neoType = NeoType.LABEL;

    List body = json['body'];

    return new ResponseEntity(id, neoId, neoType, json['body']);
  }

  NeoType _extractNeoType(String self) {

    List<String> split = self.split('/');
    String type = split[split.length - 2];

    switch (type) {
      case 'node' :
        return NeoType.NODE;
      case 'relationships' :
        return NeoType.RELATIONSHIP;
      case 'labels' :
        return NeoType.LABEL;
      default:
        throw 'Response type unknown : $type.';
    }
  }

}
