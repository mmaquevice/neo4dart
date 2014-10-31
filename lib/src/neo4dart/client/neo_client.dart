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

  List<ResponseEntity> _convertResponseToEntities(var response) {
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

    if(!json.containsKey('body')) {
      return new ResponseEntity(json['id'], null, NeoType.LABEL, null);
    }

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
      case 'relationship' :
        return NeoType.RELATIONSHIP;
      case 'labels' :
        return NeoType.LABEL;
      default:
        throw 'Response type unknown : $type.';
    }
  }
}
