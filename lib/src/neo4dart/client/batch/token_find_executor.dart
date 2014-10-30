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

  Future findNodeById(int id, Type type) {
    return executeBatch(new TokenFindBuilder().addNodeToBatch(id)).then((response) => _convertResponseToNode(response, type));
  }

  Future findNodesByIds(Iterable<int> ids, Type type) {
    return executeBatch(new TokenFindBuilder().addNodesToBatch(ids)).then((response) => _convertResponseToNodes(response, type));
  }

  Node _convertResponseToNode(var response, Type type) {

    Set<Node> nodes = _convertResponseToNodes(response, type);

    if(nodes.isEmpty) {
      return null;
    }

    if(nodes.length > 1) {
      throw "Response contains more than one node : $nodes.";
    }

    return nodes.first;
  }

  Set<Node> _convertResponseToNodes(var response, Type type) {

    Set<Node> nodes = new Set();

    List<ResponseEntity> responseEntities = _convertResponseToEntities(response);

    Multimap responsesById = new Multimap();
    responseEntities.forEach((r) {
      responsesById.add(r.neoId, r);
    });

    responsesById.forEachKey((k, v) {
      Map<NeoType, ResponseEntity> dataByType = new Map.fromIterable(v, key: (k) => k.type, value: (v) => v);

      List<String> labels = dataByType[NeoType.LABEL].data;

      if(labels.length == 0) {
        throw "Node <$k> is not labelled.";
      }
      if(labels.length > 1) {
        throw "Node <$k> has multiple labels, this is not currently supported.";
      }
      if(!type.toString().endsWith(labels.first)) {
        throw "Node <$k> has a label <${labels.first}> not matching its type <${type.toString()}>.";
      }

      Node node = convertToNode(type, dataByType[NeoType.NODE]);
      nodes.add(node);
    });

    return nodes;
  }
}
