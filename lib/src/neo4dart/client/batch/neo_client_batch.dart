part of neo4dart;

class NeoClientBatch extends NeoClient {

  final _logger = new Logger("NeoClientBatch");

  http.Client _client;

  NeoClientBatch() {
    _client = new http.Client();
  }

  NeoClientBatch.withClient(this._client);

  Future executeBatch(Set<BatchToken> batchTokens) {

    List data = _convertBatchTokensToJsonArray(batchTokens);
    _logger.info(data);

    return _client.post("http://localhost:7474/db/data/batch", body : '${data}').then((response) => _addIdToNeoEntities(response, batchTokens));
  }

  List _convertBatchTokensToJsonArray(Set<BatchToken> batchTokens) {
    return batchTokens.map((batchToken) {
      _logger.info(batchToken.body);
      return new JsonEncoder().convert(batchToken);
    }).toList();
  }

  _addIdToNeoEntities(var response, Set<BatchToken> batchTokens) {

    List<ResponseEntity> responseEntities = _convertResponseToNodes(response);
    Map<int, ResponseEntity> responsesById = new Map.fromIterable(responseEntities, key: (k) => k.id, value: (v) => v);

    batchTokens.forEach((token) {
      if(responsesById.containsKey(token.id)) {
        if(token.neoEntity != null) {
          _logger.info(token.neoEntity);
          token.neoEntity.id = responsesById[token.id].neoId;
          _logger.info('Matching ${token.id} to ${token.neoEntity.id}.');
        }
      }
    });

    return true;
  }

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

  ResponseEntity _convertToResponseEntity(Map json) {

    int id = json['id'];

    String from = json['from'];
    String typeFromResponse = from != null ? from.split('/').last : null;
    NeoType neoType;
    switch (typeFromResponse) {
      case 'node' :
        neoType = NeoType.NODE;
        break;
      case 'relationships' :
        neoType = NeoType.RELATIONSHIP;
        break;
      case 'labels' :
        neoType = NeoType.LABEL;
        break;
      default:
        throw 'Response type unknown : $typeFromResponse.';
    }

    int neoId;
    Map data;
    Map body = json['body'];
    if(body != null) {
      String self = body['self'];
      neoId = self != null ? int.parse(self.split('/').last) : null;

      data = body['data'];
    }

    return new ResponseEntity(id, neoId, neoType, data);
  }
}
